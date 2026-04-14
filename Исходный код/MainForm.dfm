object FormMain: TFormMain
  Left = 0
  Top = 0
  Caption = 'Rabin File Cipher'
  ClientHeight = 544
  ClientWidth = 856
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  TextHeight = 13
  object LabelP: TLabel
    Left = 24
    Top = 24
    Width = 7
    Height = 13
    Caption = 'p'
  end
  object LabelQ: TLabel
    Left = 24
    Top = 64
    Width = 7
    Height = 13
    Caption = 'q'
  end
  object LabelB: TLabel
    Left = 24
    Top = 104
    Width = 7
    Height = 13
    Caption = 'b'
  end
  object LabelInput: TLabel
    Left = 24
    Top = 152
    Width = 76
    Height = 13
    Caption = #1042#1093#1086#1076#1085#1086#1081' '#1092#1072#1081#1083
  end
  object LabelOutput: TLabel
    Left = 24
    Top = 192
    Width = 84
    Height = 13
    Caption = #1042#1099#1093#1086#1076#1085#1086#1081' '#1092#1072#1081#1083
  end
  object EditP: TEdit
    Left = 136
    Top = 20
    Width = 185
    Height = 21
    TabOrder = 0
    Text = '523'
  end
  object EditQ: TEdit
    Left = 136
    Top = 60
    Width = 185
    Height = 21
    TabOrder = 1
    Text = '3511'
  end
  object EditB: TEdit
    Left = 136
    Top = 100
    Width = 185
    Height = 21
    TabOrder = 2
    Text = '1234'
  end
  object EditInput: TEdit
    Left = 136
    Top = 148
    Width = 569
    Height = 21
    TabOrder = 3
  end
  object ButtonBrowseInput: TButton
    Left = 720
    Top = 147
    Width = 121
    Height = 25
    Caption = #1042#1099#1073#1088#1072#1090#1100'...'
    TabOrder = 4
    OnClick = ButtonBrowseInputClick
  end
  object EditOutput: TEdit
    Left = 136
    Top = 188
    Width = 569
    Height = 21
    TabOrder = 5
  end
  object ButtonBrowseOutput: TButton
    Left = 720
    Top = 187
    Width = 121
    Height = 25
    Caption = #1042#1099#1073#1088#1072#1090#1100'...'
    TabOrder = 6
    OnClick = ButtonBrowseOutputClick
  end
  object ButtonEncrypt: TButton
    Left = 136
    Top = 232
    Width = 185
    Height = 33
    Caption = #1064#1080#1092#1088#1086#1074#1072#1090#1100
    TabOrder = 7
    OnClick = ButtonEncryptClick
  end
  object ButtonDecrypt: TButton
    Left = 336
    Top = 232
    Width = 185
    Height = 33
    Caption = #1044#1077#1096#1080#1092#1088#1086#1074#1072#1090#1100
    TabOrder = 8
    OnClick = ButtonDecryptClick
  end
  object MemoLog: TMemo
    Left = 24
    Top = 288
    Width = 817
    Height = 249
    ScrollBars = ssVertical
    TabOrder = 9
  end
  object OpenDialog1: TOpenDialog
    Left = 640
    Top = 24
  end
  object SaveDialog1: TSaveDialog
    Left = 688
    Top = 24
  end
end
