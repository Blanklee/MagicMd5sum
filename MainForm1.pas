unit MainForm1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.StdCtrls, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  IdBaseComponent, IdAntiFreezeBase, IdAntiFreeze, FileDrop;

type
  TMainForm = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Memo1: TMemo;
    FileDrop1: TFileDrop;
    IdAntiFreeze1: TIdAntiFreeze;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FileDrop1Drop(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Memo1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
    FFileList: TStringList;
    function GetMD5(const FileName: string): string;
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  IdHashMessageDigest, IdHash, ClipBrd;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  // Manage dropped files with FFileList
  FFileList:= TStringList.Create;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  FFileList.Free;
end;

//returns MD5 has for a file
function TMainForm.GetMD5(const FileName: string): string;
var
  idmd5: TIdHashMessageDigest5;
  fs: TFileStream;
  // hash: T4x4LongWordRecord;
begin
  idmd5:= TIdHashMessageDigest5.Create;
  fs:= TFileStream.Create(fileName, fmOpenRead OR fmShareDenyWrite);

  try
    Result:= idmd5.HashStreamAsHex(fs);
  finally
    fs.Free;
    idmd5.Free;
  end;
end;

procedure TMainForm.FileDrop1Drop(Sender: TObject);
var
  i: integer;
begin
  // if several dropped FileDrop1 only keeps the last drop
  // so we must save it into FFileList accumulatively
  for i:= 1 to FileDrop1.FileCount do
    FFileList.Add(FileDrop1.Files[i-1]);

  // Show message on the screen
  Memo1.Lines.Add(inttostr(FileDrop1.FileCount) + ' Files Dropped (Total ' + FFileList.Count.ToString + ' files)');
end;

procedure TMainForm.Button1Click(Sender: TObject);
var
  i: integer;
  fn, s: string;
begin
  // Calculate MD5SUM
  for i:= 1 to FFileList.Count do
  begin
    fn:= FFileList[i-1];
    s:= LowerCase(GetMD5(fn));
    Memo1.Lines.Add(s + ': ' + ExtractFileName(fn));
  end;
end;

procedure TMainForm.Button2Click(Sender: TObject);
begin
  // Copy all Text of Memo1 to ClipBoard
  ClipBrd.Clipboard.AsText:= Memo1.Text;
end;

procedure TMainForm.Button3Click(Sender: TObject);
begin
  // Clear all, go to initial state
  FileDrop1.Files.Clear;
  FFileList.Clear;
  Memo1.Lines.Clear;
  Memo1.Lines.Add('Please Drag & Drop Files and click RUN! button.');
end;

procedure TMainForm.Button4Click(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.Memo1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  // Ctrl-A (Select All) / Ctrl-C (Copy)
  if ssCtrl in Shift then
  begin
    if (Key = Ord('A')) or (Key = Ord('a')) then Memo1.SelectAll;
    if (Key = Ord('C')) or (Key = Ord('c')) then ClipBrd.Clipboard.AsText:= Memo1.SelText;
  end;
end;

end.

