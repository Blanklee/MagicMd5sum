unit MainForm1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.StdCtrls, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  IdBaseComponent, IdAntiFreezeBase, FileDrop, IdAntiFreeze, Vcl.ExtCtrls;

type
  TMainForm = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    FileDrop1: TFileDrop;
    Memo1: TMemo;
    IdAntiFreeze1: TIdAntiFreeze;
    Label1: TLabel;
    Timer1: TTimer;
    procedure FileDrop1Drop(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
    FFileStream: TFileStream;
    function GetMD5(const FileName: string): string;
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  IdHashMessageDigest, IdHash;

//returns MD5 has for a file
function TMainForm.GetMD5(const FileName: string): string;
var
  idmd5: TIdHashMessageDigest5;
begin
  idmd5:= TIdHashMessageDigest5.Create;
  FFileStream:= TFileStream.Create(fileName, fmOpenRead OR fmShareDenyWrite);

  try
    Result:= idmd5.HashStreamAsHex(FFileStream);
  finally
    FFileStream.Free;
    FFileStream:= nil;
    idmd5.Free;
  end;
end;

procedure TMainForm.Button1Click(Sender: TObject);
var
  i: integer;
  fn, s: string;
begin
  // Calculate MD5SUM
  for i:= 1 to FileDrop1.FileCount do
  begin
    fn:= FileDrop1.Files[i-1];
    s:= LowerCase(GetMD5(fn));
    Memo1.Lines.Add(s + ': ' + ExtractFileName(fn));
  end;
end;

procedure TMainForm.Button2Click(Sender: TObject);
begin
  FileDrop1.Files.Clear;
  Memo1.Lines.Clear;
end;

procedure TMainForm.Button3Click(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.FileDrop1Drop(Sender: TObject);
begin
  Memo1.Lines.Add(inttostr(FileDrop1.FileCount) + ' Files Dropped')
end;

procedure TMainForm.Timer1Timer(Sender: TObject);
begin
  // Try to show progress, but it do NOT act as expected !!
  Application.ProcessMessages;
  if Assigned(FFileStream) then
  begin
    Label1.Caption:= inttostr(FFileStream.Position);
  end;
  Application.ProcessMessages;
end;

end.

