object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'Magic MD5SUM v1.8'
  ClientHeight = 545
  ClientWidth = 682
  Color = clBtnFace
  Constraints.MinHeight = 480
  Constraints.MinWidth = 650
  Font.Charset = HANGEUL_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Fixedsys'
  Font.Style = []
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  DesignSize = (
    682
    545)
  TextHeight = 16
  object Memo1: TMemo
    Left = 16
    Top = 8
    Width = 650
    Height = 354
    Anchors = [akLeft, akTop, akRight, akBottom]
    Lines.Strings = (
      'Please Open or Drop Files and click RUN! button.')
    ScrollBars = ssBoth
    TabOrder = 0
    OnKeyDown = Memo1KeyDown
  end
  object curFile: TLabel
    Left = 24
    Top = 380
    Width = 63
    Height = 20
    Anchors = [akLeft, akBottom]
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
    Anchors = [akLeft, akBottom]
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
    Anchors = [akLeft, akBottom]
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
    Anchors = [akRight, akBottom]
    Caption = '0%'
  end
  object totalRate: TLabel
    Left = 650
    Top = 449
    Width = 16
    Height = 16
    Alignment = taRightJustify
    Anchors = [akRight, akBottom]
    Caption = '0%'
  end
  object ProgressBar1: TProgressBar
    Left = 72
    Top = 416
    Width = 547
    Height = 17
    Anchors = [akLeft, akRight, akBottom]
    TabOrder = 1
  end
  object ProgressBar2: TProgressBar
    Left = 72
    Top = 448
    Width = 547
    Height = 17
    Anchors = [akLeft, akRight, akBottom]
    TabOrder = 2
  end
  object btRun: TBitBtn
    Left = 24
    Top = 488
    Width = 89
    Height = 33
    Anchors = [akLeft, akBottom]
    Caption = '&RUN!'
    Glyph.Data = {
      76010000424D7601000000000000760000002800000020000000100000000100
      0400000000000001000000000000000000001000000010000000000000000000
      800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
      333333333333333333333333333333333333333333333333333333F333333333
      333333F333333333333337AFF33333333333378FF3333333333337AAAFF33333
      333337888FF33333333337AAAAAFF33333333788888FF333333337AAAAAAAFF3
      3333378888888FF3333337AAAAAAAAAFF33337888888888FF33337AAAAAAAAA7
      7F333788888888877F3337AAAAAAA7733333378888888773333337AAAAA77333
      3333378888877333333337AAA77333333333378887733333333337A773333333
      3333378773333333333337733333333333333773333333333333333333333333
      3333333333333333333333333333333333333333333333333333}
    NumGlyphs = 2
    TabOrder = 3
    OnClick = btRunClick
  end
  object btPause: TBitBtn
    Left = 119
    Top = 488
    Width = 73
    Height = 33
    Anchors = [akLeft, akBottom]
    Caption = '&Pause'
    Enabled = False
    Glyph.Data = {
      76010000424D7601000000000000760000002800000020000000100000000100
      0400000000000001000000000000000000001000000010000000000000000000
      800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
      33333333333333333333333333333333333333333333333333333337FFF37FFF
      33333337FF337FF333333337BBF37BBF333333373F3373F333333337BBF37BBF
      333333373F3373F333333337BBF37BBF333333373F3373F333333337BBF37BBF
      333333373F3373F333333337BBF37BBF333333373F3373F333333337BBF37BBF
      333333373F3373F333333337BBF37BBF333333373F3373F333333337BBF37BBF
      333333373F3373F333333337BBF37BBF333333373F3373F333333337BBF37BBF
      333333373F3373F33333333777F3777F333333377F3377F33333333333333333
      3333333333333333333333333333333333333333333333333333}
    NumGlyphs = 2
    TabOrder = 4
    OnClick = btPauseClick
  end
  object btStop: TBitBtn
    Left = 198
    Top = 488
    Width = 73
    Height = 33
    Anchors = [akLeft, akBottom]
    Caption = '&Stop'
    Enabled = False
    Glyph.Data = {
      76010000424D7601000000000000760000002800000020000000100000000100
      0400000000000001000000000000000000001000000000000000000000000000
      8000008000000080800080000000800080008080000080808000C0C0C0000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
      3333333333333333333333333333333333333333333333333333333333333333
      3333333333333333333333FFFFFFFFFFFF3333FFFFFFFFFFFF33379999999999
      9F333788888888888F333799999999999F333788888888888F33379999999999
      9F333788888888888F333799999999999F333788888888888F33379999999999
      9F333788888888888F333799999999999F333788888888888F33379999999999
      9F333788888888888F333799999999999F333788888888888F33377777777777
      7333377777777777733333333333333333333333333333333333333333333333
      3333333333333333333333333333333333333333333333333333}
    NumGlyphs = 2
    TabOrder = 5
    OnClick = btStopClick
  end
  object btOpen: TButton
    Left = 293
    Top = 488
    Width = 73
    Height = 33
    Anchors = [akLeft, akBottom]
    Caption = '&Open'
    TabOrder = 6
    OnClick = btOpenClick
  end
  object btCopyText: TButton
    Left = 372
    Top = 488
    Width = 89
    Height = 33
    Anchors = [akLeft, akBottom]
    Caption = '&Copy Text'
    TabOrder = 7
    OnClick = btCopyTextClick
  end
  object btClear: TButton
    Left = 467
    Top = 488
    Width = 73
    Height = 33
    Anchors = [akLeft, akBottom]
    Caption = 'C&lear'
    TabOrder = 8
    OnClick = btClearClick
  end
  object btExit: TButton
    Left = 546
    Top = 488
    Width = 73
    Height = 33
    Anchors = [akLeft, akBottom]
    Caption = 'E&xit'
    TabOrder = 9
    OnClick = btExitClick
  end
  object btTemp: TBitBtn
    Left = 625
    Top = 492
    Width = 25
    Height = 25
    Anchors = [akLeft, akBottom]
    Glyph.Data = {
      76010000424D7601000000000000760000002800000020000000100000000100
      0400000000000001000000000000000000001000000010000000000000000000
      800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
      33333333333333333333333333333333333333333333333333333337FFF37FFF
      33333337FF337FF333333337BBF37BBF333333373F3373F333333337BBF37BBF
      333333373F3373F333333337BBF37BBF333333373F3373F333333337BBF37BBF
      333333373F3373F333333337BBF37BBF333333373F3373F333333337BBF37BBF
      333333373F3373F333333337BBF37BBF333333373F3373F333333337BBF37BBF
      333333373F3373F333333337BBF37BBF333333373F3373F333333337BBF37BBF
      333333373F3373F33333333777F3777F333333377F3377F33333333333333333
      3333333333333333333333333333333333333333333333333333}
    NumGlyphs = 2
    TabOrder = 10
    Visible = False
    OnClick = btTempClick
  end
  object FileDrop1: TFileDrop
    EnableDrop = True
    DropControl = Owner
    OnDrop = FileDrop1Drop
    Left = 72
    Top = 72
  end
  object OpenDialog1: TOpenDialog
    Filter = 'All Files (*.*)|*.*'
    Options = [ofHideReadOnly, ofAllowMultiSelect, ofEnableSizing]
    Left = 144
    Top = 72
  end
end
