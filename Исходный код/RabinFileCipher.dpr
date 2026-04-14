program RabinFileCipher;

uses
  Vcl.Forms,
  MainForm in 'MainForm.pas' {FormMain},
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Glow');
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
