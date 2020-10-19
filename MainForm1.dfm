object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'Magic MD5SUM v1.1'
  ClientHeight = 442
  ClientWidth = 682
  Color = clBtnFace
  Font.Charset = HANGEUL_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Fixedsys'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    682
    442)
  PixelsPerInch = 96
  TextHeight = 16
  object Label1: TLabel
    Left = 16
    Top = 392
    Width = 64
    Height = 16
    Caption = 'Progress'
  end
  object Memo1: TMemo
    Left = 16
    Top = 8
    Width = 650
    Height = 354
    Anchors = [akLeft, akTop, akRight, akBottom]
    Lines.Strings = (
      'Please Drag & Drop Files and click RUN! button.')
    ScrollBars = ssBoth
    TabOrder = 0
  end
  object Button1: TButton
    Left = 152
    Top = 385
    Width = 153
    Height = 33
    Anchors = [akLeft, akBottom]
    Caption = 'RUN MD5SUM !'
    TabOrder = 1
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 328
    Top = 385
    Width = 75
    Height = 33
    Anchors = [akLeft, akBottom]
    Caption = 'Clear'
    TabOrder = 2
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 424
    Top = 385
    Width = 75
    Height = 33
    Anchors = [akLeft, akBottom]
    Caption = 'Exit'
    TabOrder = 3
    OnClick = Button3Click
  end
  object FileDrop1: TFileDrop
    EnableDrop = True
    DropControl = Owner
    OnDrop = FileDrop1Drop
    Left = 152
    Top = 64
  end
  object IdAntiFreeze1: TIdAntiFreeze
    Left = 80
    Top = 64
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 224
    Top = 64
  end
end
