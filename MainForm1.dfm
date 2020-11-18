object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'Magic MD5SUM v1.4'
  ClientHeight = 545
  ClientWidth = 682
  Color = clBtnFace
  Font.Charset = HANGEUL_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Fixedsys'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    682
    545)
  PixelsPerInch = 96
  TextHeight = 16
  object curFile: TLabel
    Left = 24
    Top = 380
    Width = 63
    Height = 20
    Caption = 'FileName'
    Font.Charset = HANGEUL_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = #47569#51008' '#44256#46357
    Font.Style = []
    ParentFont = False
  end
  object Label1: TLabel
    Left = 24
    Top = 413
    Width = 25
    Height = 21
    Caption = 'File'
    Font.Charset = HANGEUL_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = #47569#51008' '#44256#46357
    Font.Style = []
    ParentFont = False
  end
  object Label2: TLabel
    Left = 24
    Top = 445
    Width = 37
    Height = 21
    Caption = 'Total'
    Font.Charset = HANGEUL_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = #47569#51008' '#44256#46357
    Font.Style = []
    ParentFont = False
  end
  object fileRate: TLabel
    Left = 650
    Top = 417
    Width = 16
    Height = 16
    Alignment = taRightJustify
    Caption = '0%'
  end
  object totalRate: TLabel
    Left = 650
    Top = 449
    Width = 16
    Height = 16
    Alignment = taRightJustify
    Caption = '0%'
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
    OnKeyDown = Memo1KeyDown
  end
  object btRun1: TButton
    Left = 24
    Top = 488
    Width = 97
    Height = 33
    Anchors = [akLeft, akBottom]
    Caption = 'RUN (v1.3)'
    TabOrder = 1
    OnClick = btRunClick
  end
  object btCopyText: TButton
    Left = 372
    Top = 488
    Width = 89
    Height = 33
    Anchors = [akLeft, akBottom]
    Caption = 'Copy Text'
    TabOrder = 2
    OnClick = btCopyTextClick
  end
  object btClear: TButton
    Left = 467
    Top = 488
    Width = 73
    Height = 33
    Anchors = [akLeft, akBottom]
    Caption = 'Clear'
    TabOrder = 3
    OnClick = btClearClick
  end
  object btExit: TButton
    Left = 546
    Top = 488
    Width = 73
    Height = 33
    Anchors = [akLeft, akBottom]
    Caption = 'Exit'
    TabOrder = 4
    OnClick = btExitClick
  end
  object ProgressBar1: TProgressBar
    Left = 72
    Top = 416
    Width = 547
    Height = 17
    TabOrder = 5
  end
  object ProgressBar2: TProgressBar
    Left = 72
    Top = 448
    Width = 547
    Height = 17
    TabOrder = 6
  end
  object btRun2: TButton
    Left = 127
    Top = 488
    Width = 97
    Height = 33
    Anchors = [akLeft, akBottom]
    Caption = 'RUN (v1.4)'
    TabOrder = 7
    OnClick = btRunClick
  end
  object btPause: TButton
    Left = 230
    Top = 488
    Width = 73
    Height = 33
    Anchors = [akLeft, akBottom]
    Caption = 'Pause'
    TabOrder = 8
    OnClick = btPauseClick
  end
  object btStop: TButton
    Left = 309
    Top = 488
    Width = 57
    Height = 33
    Anchors = [akLeft, akBottom]
    Caption = 'Stop'
    TabOrder = 9
    OnClick = btStopClick
  end
  object FileDrop1: TFileDrop
    EnableDrop = True
    DropControl = Owner
    OnDrop = FileDrop1Drop
    Left = 72
    Top = 72
  end
end
