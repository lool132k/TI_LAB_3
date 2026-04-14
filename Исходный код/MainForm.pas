unit MainForm;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Math,
  System.IOUtils,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.StdCtrls,
  Vcl.Dialogs;

type
  TFormMain = class(TForm)
    LabelP: TLabel;
    LabelQ: TLabel;
    LabelB: TLabel;
    EditP: TEdit;
    EditQ: TEdit;
    EditB: TEdit;
    LabelInput: TLabel;
    EditInput: TEdit;
    ButtonBrowseInput: TButton;
    LabelOutput: TLabel;
    EditOutput: TEdit;
    ButtonBrowseOutput: TButton;
    ButtonEncrypt: TButton;
    ButtonDecrypt: TButton;
    MemoLog: TMemo;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    procedure ButtonBrowseInputClick(Sender: TObject);
    procedure ButtonBrowseOutputClick(Sender: TObject);
    procedure ButtonEncryptClick(Sender: TObject);
    procedure ButtonDecryptClick(Sender: TObject);
  private
    function IsPrime(Value: UInt64): Boolean;
    function AddMod(A, B, Modulus: UInt64): UInt64;
    function MulMod(A, B, Modulus: UInt64): UInt64;
    function PowMod(Base, Exponent, Modulus: UInt64): UInt64;
    function ExtendedGCD(A, B: Int64; out X, Y: Int64): Int64;
    function NormalizeMod(Value: Int64; Modulus: UInt64): UInt64;
    function TryReadParams(out P, Q, B, N: UInt64): Boolean;
    function EncryptByte(M, B, N: UInt64): UInt64;
    function DecryptBlock(C, P, Q, B, N: UInt64; out Plain: Byte): Boolean;
    procedure Log(const S: string);
  public
  end;

var
  FormMain: TFormMain;

implementation

{$R *.dfm}

procedure TFormMain.Log(const S: string);
begin
  MemoLog.Lines.Add(S);
end;

function TFormMain.IsPrime(Value: UInt64): Boolean;
var
  D: UInt64;
begin
  if Value < 2 then Exit(False);
  if (Value = 2) or (Value = 3) then Exit(True);
  if (Value and 1) = 0 then Exit(False);
  D := 3;
  while D * D <= Value do
  begin
    if (Value mod D) = 0 then Exit(False);
    Inc(D, 2);
  end;
  Result := True;
end;

// сложение по модулю без cf
function TFormMain.AddMod(A, B, Modulus: UInt64): UInt64;
begin
  A := A mod Modulus;
  B := B mod Modulus;
  if A >= Modulus - B then
    Result := A - (Modulus - B)
  else
    Result := A + B;
end;

// алгоритм двоичного умножения
function TFormMain.MulMod(A, B, Modulus: UInt64): UInt64;
begin
  A := A mod Modulus;
  B := B mod Modulus;
  Result := 0;
  while B > 0 do
  begin
    if (B and 1) = 1 then
      Result := AddMod(Result, A, Modulus);
    A := AddMod(A, A, Modulus);
    B := B shr 1;
  end;
end;

// алг. быстрого возведения в степень по модулю
function TFormMain.PowMod(Base, Exponent, Modulus: UInt64): UInt64;
var
  A1, Z1: UInt64;
begin
  if Modulus = 1 then Exit(0);
  A1 := Base mod Modulus;
  Z1 := Exponent;
  Result := 1;
  while Z1 > 0 do
  begin
    while (Z1 mod 2) = 0 do
    begin
      Z1 := Z1 div 2;
      A1 := MulMod(A1, A1, Modulus);
    end;
    Z1 := Z1 - 1;
    Result := MulMod(Result, A1, Modulus);
  end;
end;

// алг евклида
function TFormMain.ExtendedGCD(A, B: Int64; out X, Y: Int64): Int64;
var
  D0, D1, D2: Int64;
  X0, X1, X2: Int64;
  Y0, Y1, Y2: Int64;
  Q: Int64;
begin
  D0 := A; D1 := B;
  X0 := 1; X1 := 0;
  Y0 := 0; Y1 := 1;
  while D1 > 1 do
  begin
    Q := D0 div D1;
    D2 := D0 mod D1;
    X2 := X0 - Q * X1;
    Y2 := Y0 - Q * Y1;
    D0 := D1; D1 := D2;
    X0 := X1; X1 := X2;
    Y0 := Y1; Y1 := Y2;
  end;
  X := X1;
  Y := Y1;
  Result := D1;
end;

function TFormMain.NormalizeMod(Value: Int64; Modulus: UInt64): UInt64;
var
  R: Int64;
begin
  R := Value mod Int64(Modulus);
  if R < 0 then Inc(R, Int64(Modulus));
  Result := UInt64(R);
end;

function TFormMain.TryReadParams(out P, Q, B, N: UInt64): Boolean;
var
  P64, Q64, B64: Int64;
begin
  Result := False;
  if not TryStrToInt64(Trim(EditP.Text), P64) then
  begin ShowMessage('Некорректное значение p.'); Exit; end;
  if not TryStrToInt64(Trim(EditQ.Text), Q64) then
  begin ShowMessage('Некорректное значение q.'); Exit; end;
  if not TryStrToInt64(Trim(EditB.Text), B64) then
  begin ShowMessage('Некорректное значение b.'); Exit; end;
  if P64 <= 1 then
  begin ShowMessage('p должно быть > 1.'); Exit; end;
  if Q64 <= 1 then
  begin ShowMessage('q должно быть > 1.'); Exit; end;
  if B64 <= 0 then
  begin ShowMessage('b должно быть натуральным числом (> 0).'); Exit; end;
  P := UInt64(P64);
  Q := UInt64(Q64);
  B := UInt64(B64);
  if P = Q then
  begin ShowMessage('p и q должны быть разными простыми числами.'); Exit; end;
  if not IsPrime(P) then
  begin ShowMessage('Число p не является простым.'); Exit; end;
  if not IsPrime(Q) then
  begin ShowMessage('Число q не является простым.'); Exit; end;
  if (P mod 4 <> 3) then
  begin ShowMessage('Требуется p mod 4 = 3.' + #13#10 +
    'Подходящие простые: 3, 7, 11, 19, 23, 31, 43, 47, 59, 67, 71, 79, 83, ...' +
    #13#10 + 'Например: p=523, q=3511'); Exit; end;
  if (Q mod 4 <> 3) then
  begin ShowMessage('Требуется q mod 4 = 3.' + #13#10 +
    'Подходящие простые: 3, 7, 11, 19, 23, 31, 43, 47, 59, 67, 71, 79, 83, ...' +
    #13#10 + 'Например: p=523, q=3511'); Exit; end;
  if P > High(UInt64) div Q then
  begin ShowMessage('Переполнение: n = p*q слишком велико. Возьмите меньше p и q.'); Exit; end;
  N := P * Q;
  if N <= 255 then
  begin ShowMessage('Нужно n = p*q > 255 для однозначной расшифровки байтов.' +
    #13#10 + 'Рекомендуется p > 3, q > 3511 (или наоборот).'); Exit; end;

  if B >= N then
  begin ShowMessage('Требуется 0 < b < n = ' + UIntToStr(N) + '.'); Exit; end;
  Result := True;
end;

function TFormMain.EncryptByte(M, B, N: UInt64): UInt64;
begin
  Result := MulMod(M, AddMod(M, B, N), N);
end;

function TFormMain.DecryptBlock(C, P, Q, B, N: UInt64; out Plain: Byte): Boolean;
var
  D: UInt64;
  MP, MQ: UInt64;
  Yp, Yq: Int64;
  Dummy: Int64;
  GCD: Int64;
  T1, T2: UInt64;
  Roots: array[0..3] of UInt64;
  Inv2: UInt64;
  XInv2: Int64;
  DI, DiffMod, MI: UInt64;
  I: Integer;
begin
  Result := False;

  D := AddMod(MulMod(B, B, N), MulMod(4, C, N), N);

  MP := PowMod(D mod P, (P + 1) div 4, P);
  MQ := PowMod(D mod Q, (Q + 1) div 4, Q);

  GCD := ExtendedGCD(Int64(P), Int64(Q), Yp, Dummy);
  if GCD <> 1 then Exit(False);
  GCD := ExtendedGCD(Int64(Q), Int64(P), Yq, Dummy);
  if GCD <> 1 then Exit(False);

  T1 := MulMod(NormalizeMod(Yp, N), MulMod(P, MQ, N), N);  // yp * p * mq
  T2 := MulMod(NormalizeMod(Yq, N), MulMod(Q, MP, N), N);  // yq * q * mp
  Roots[0] := AddMod(T1, T2, N);
  Roots[1] := N - Roots[0];
  Roots[2] := AddMod(T1, N - T2, N);
  Roots[3] := N - Roots[2];

  GCD := ExtendedGCD(2, Int64(N), XInv2, Dummy);
  if GCD <> 1 then Exit(False);
  Inv2 := NormalizeMod(XInv2, N);

  for I := 0 to 3 do
  begin
    DI := Roots[I];
    DiffMod := AddMod(DI, N - B, N);
    MI := MulMod(DiffMod, Inv2, N);

    if MI <= 255 then
    begin
      Plain := Byte(MI);
      Result := True;
      Exit;
    end;
  end;
end;

procedure TFormMain.ButtonBrowseInputClick(Sender: TObject);
begin
  if OpenDialog1.Execute then
    EditInput.Text := OpenDialog1.FileName;
end;

procedure TFormMain.ButtonBrowseOutputClick(Sender: TObject);
begin
  if SaveDialog1.Execute then
    EditOutput.Text := SaveDialog1.FileName;
end;

// Шифрование
procedure TFormMain.ButtonEncryptClick(Sender: TObject);
const
  CIPHER_BLOCK = 4; // зашифрованный блок 4 байта
var
  P, Q, B, N: UInt64;
  InStream, OutStream: TFileStream;
  Buffer: TBytes;
  I: Integer;
  M, C: UInt64;
  B0, B1, B2, B3: Byte;
  LogLine: string;
  LogCount: Integer;
begin
  MemoLog.Clear;
  if not TryReadParams(P, Q, B, N) then Exit;
  if not TFile.Exists(EditInput.Text) then
  begin ShowMessage('Входной файл не найден.'); Exit; end;
  if Trim(EditOutput.Text) = '' then
  begin ShowMessage('Укажите путь выходного файла.'); Exit; end;

  InStream := TFileStream.Create(EditInput.Text, fmOpenRead or fmShareDenyWrite);
  try
    SetLength(Buffer, InStream.Size);
    if Length(Buffer) > 0 then
      InStream.ReadBuffer(Buffer[0], Length(Buffer));
  finally
    InStream.Free;
  end;

  OutStream := TFileStream.Create(EditOutput.Text, fmCreate);
  try
    Log('=== Зашифрованные блоки (десятичная СС) ===');
    LogLine := '';
    LogCount := 0;
    for I := 0 to High(Buffer) do
    begin
      M := Buffer[I];
      C := EncryptByte(M, B, N);

      B0 := Byte(C and $FF);
      B1 := Byte((C shr 8) and $FF);
      B2 := Byte((C shr 16) and $FF);
      B3 := Byte((C shr 24) and $FF);
      OutStream.WriteBuffer(B0, 1);
      OutStream.WriteBuffer(B1, 1);
      OutStream.WriteBuffer(B2, 1);
      OutStream.WriteBuffer(B3, 1);

      if LogCount < 100 then
      begin
        if LogLine <> '' then LogLine := LogLine + ' ';
        LogLine := LogLine + UIntToStr(C);
        Inc(LogCount);
        if LogCount mod 10 = 0 then
        begin
          Log(LogLine);
          LogLine := '';
        end;
        if (LogCount = 100) and (Length(Buffer) > 100) then
        begin
          if LogLine <> '' then Log(LogLine);
          Log('... (показаны первые 100 из ' + IntToStr(Length(Buffer)) + ' блоков)');
          LogLine := '';
        end;
      end
      else
        Inc(LogCount);
    end;
    if LogLine <> '' then Log(LogLine);
  finally
    OutStream.Free;
  end;

  Log('');
  Log('Параметры:');
  Log(' p = ' + UIntToStr(P));
  Log(' q = ' + UIntToStr(Q));
  Log(' b = ' + UIntToStr(B));
  Log(' n = p*q = ' + UIntToStr(N));
  Log(' Размер входного файла: ' + IntToStr(Length(Buffer)) + ' байт');
  Log(' Размер выходного файла: ' + IntToStr(Length(Buffer)*CIPHER_BLOCK) + ' байт');
  Log('');
  Log('Готово: файл зашифрован → ' + EditOutput.Text);
end;

// Дешифрование
procedure TFormMain.ButtonDecryptClick(Sender: TObject);
var
  P, Q, B, N: UInt64;
  InStream, OutStream: TFileStream;
  BlocksCount, I: Int64;
  C: UInt64;
  B0, B1, B2, B3: Byte;
  PlainByte: Byte;
begin
  MemoLog.Clear;
  if not TryReadParams(P, Q, B, N) then Exit;
  if not TFile.Exists(EditInput.Text) then
  begin ShowMessage('Входной файл не найден.'); Exit; end;
  if Trim(EditOutput.Text) = '' then
  begin ShowMessage('Укажите путь выходного файла.'); Exit; end;

  InStream := TFileStream.Create(EditInput.Text, fmOpenRead or fmShareDenyWrite);
  try
    if InStream.Size = 0 then
    begin ShowMessage('Файл пуст.'); Exit; end;
    if (InStream.Size mod 4) <> 0 then
    begin
      ShowMessage('Размер файла не кратен 4. Возможно, файл повреждён или не является зашифрованным.');
      Exit;
    end;
    BlocksCount := InStream.Size div 4;

    OutStream := TFileStream.Create(EditOutput.Text, fmCreate);
    try
      for I := 1 to BlocksCount do
      begin
        if InStream.Read(B0, 1) <> 1 then
        begin ShowMessage('Ошибка чтения блока #' + IntToStr(I) + ' (байт 0).'); Exit; end;
        if InStream.Read(B1, 1) <> 1 then
        begin ShowMessage('Ошибка чтения блока #' + IntToStr(I) + ' (байт 1).'); Exit; end;
        if InStream.Read(B2, 1) <> 1 then
        begin ShowMessage('Ошибка чтения блока #' + IntToStr(I) + ' (байт 2).'); Exit; end;
        if InStream.Read(B3, 1) <> 1 then
        begin ShowMessage('Ошибка чтения блока #' + IntToStr(I) + ' (байт 3).'); Exit; end;

        C := UInt64(B0) or (UInt64(B1) shl 8) or (UInt64(B2) shl 16) or (UInt64(B3) shl 24);

        if not DecryptBlock(C, P, Q, B, N, PlainByte) then
        begin
          ShowMessage(
            'Не удалось однозначно расшифровать блок #' + IntToStr(I) + '.' + #13#10 +
            'c = ' + UIntToStr(C) + #13#10 +
            'Ни один из 4 корней не попал в диапазон [0..255].' + #13#10 +
            'Попробуйте использовать бо́льшие p и q (рекомендуется p > 3, q > 3511).');
          Exit;
        end;
        OutStream.WriteBuffer(PlainByte, 1);
      end;
    finally
      OutStream.Free;
    end;
  finally
    InStream.Free;
  end;

  Log('Параметры:');
  Log(' p = ' + UIntToStr(P));
  Log(' q = ' + UIntToStr(Q));
  Log(' b = ' + UIntToStr(B));
  Log(' n = p*q = ' + UIntToStr(N));
  Log(' Блоков расшифровано: ' + IntToStr(BlocksCount));
  Log('');
  Log('Готово: файл расшифрован → ' + EditOutput.Text);
end;

end.