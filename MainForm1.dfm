object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'Magic MD5SUM v1.2'
  ClientHeight = 465
  ClientWidth = 749
  Color = clBtnFace
  Font.Charset = HANGEUL_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Fixedsys'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    749
    465)
  PixelsPerInch = 96
  TextHeight = 16
  object Memo1: TMemo
    Left = 16
    Top = 8
    Width = 717
    Height = 377
    Anchors = [akLeft, akTop, akRight, akBottom]
    Lines.Strings = (
      'Please Drag & Drop Files and click RUN! button.')
    ScrollBars = ssBoth
    TabOrder = 0
    OnKeyDown = Memo1KeyDown
  end
  object Button1: TButton
    Left = 88
    Top = 408
    Width = 153
    Height = 33
    Anchors = [akLeft, akBottom]
    Caption = 'RUN MD5SUM !'
    TabOrder = 1
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 264
    Top = 408
    Width = 121
    Height = 33
    Anchors = [akLeft, akBottom]
    Caption = 'Copy Text'
    TabOrder = 2
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 408
    Top = 408
    Width = 75
    Height = 33
    Anchors = [akLeft, akBottom]
    Caption = 'Clear'
    TabOrder = 3
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 504
    Top = 408
    Width = 75
    Height = 33
    Anchors = [akLeft, akBottom]
    Caption = 'Exit'
    TabOrder = 4
    OnClick = Button4Click
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
end
