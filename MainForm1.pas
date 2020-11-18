unit MainForm1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.StdCtrls, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls,
  FileDrop, MyHash5;

const
  // buf size to compare at once (Test : speed improved until 512KB, little improved more than 512KB)
  maxRecord = 1024 * 512;
  maxRecord32 = maxRecord div 4;

type
  // To use Int64 with Max & Position (up to 2TB)
  TProgressBar = class(Vcl.ComCtrls.TProgressBar)
  private
    FInt32: Boolean;
    FMax64: int64;
    FPosition64: Int64;
    procedure SetMax64(const Value: Int64);
    procedure SetPosition64(const Value: Int64);
  public
    procedure StepBy64(Delta: Int64);
  published
    property Max64: Int64 read FMax64 write SetMax64;
    property Position64: Int64 read FPosition64 write SetPosition64;
  end;

  TMainForm = class(TForm)
    Memo1: TMemo;
    Label1: TLabel;
    Label2: TLabel;
    curFile: TLabel;
    fileRate: TLabel;
    totalRate: TLabel;
    ProgressBar1: TProgressBar;
    ProgressBar2: TProgressBar;
    btRun1: TButton;
    btRun2: TButton;
    btPause: TButton;
    btStop: TButton;
    btCopyText: TButton;
    btClear: TButton;
    btExit: TButton;
    FileDrop1: TFileDrop;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FileDrop1Drop(Sender: TObject);
    procedure btRunClick(Sender: TObject);
    procedure btPauseClick(Sender: TObject);
    procedure btStopClick(Sender: TObject);
    procedure btCopyTextClick(Sender: TObject);
    procedure btClearClick(Sender: TObject);
    procedure btExitClick(Sender: TObject);
    procedure Memo1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
    FFileList: TStringList;
    stopCompare: boolean;
    pauseCompare: boolean;
    FBuf: array[1..maxRecord] of byte;
    procedure CheckPause;
    function GetTotalSize: int64;
    function GetMD5(const FileName: string): string;
    function GetMyMD5(const FileName: string): string;
    procedure BeforeRun;
    procedure AfterRun;
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  IdHashMessageDigest, IdHash, ClipBrd, Math, BlankUtils;

{ TProgressBar }

// -----------------------------------------------------------------------------
// Implement to show Int64 (2GB ~ 2TB) as (Value div 1024) KB

procedure TProgressBar.SetMax64(const Value: Int64);
begin
  FMax64:= Value;
  // if bigger than 2GB save as KB (Value div 1024)
  if Value <= $7FFFFFFF then FInt32:= True else FInt32:= False;
  if FInt32 then Max:= Value else Max:= Value shr 10;
end;

procedure TProgressBar.SetPosition64(const Value: Int64);
begin
  FPosition64:= Value;
  if FInt32 then Position:= Value else Position:= Value shr 10;
end;

procedure TProgressBar.StepBy64(Delta: Int64);
begin
  SetPosition64(FPosition64+Delta);
end;






{ MainForm }

// -----------------------------------------------------------------------------
// Create and Destroy

procedure TMainForm.FormCreate(Sender: TObject);
begin
  // Manage dropped files with FFileList
  FFileList:= TStringList.Create;

  // Initialize members
  stopCompare:= False;
  pauseCompare:= false;
  curFile.Caption:= '';
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  FFileList.Free;
end;





// -----------------------------------------------------------------------------
// Private functions

procedure TMainForm.BeforeRun;
var
  s: string;
begin
  // Initialize before run
  btRun2.Enabled:= False;
  btStop.Enabled:= True;
  btPause.Enabled:= True;
  btExit.Enabled:= False;
  stopCompare := False;
  pauseCompare:= False;

  ProgressBar2.Max64:= GetTotalSize;
  ProgressBar1.Position64:= 0;
  ProgressBar2.Position64:= 0;
  fileRate.Caption:= '0%';
  totalRate.Caption:= '0%';

  DatetimeToString(s, 'hh:nn:ss', now);
  Memo1.Lines.Add('');
  Memo1.Lines.Add('[' + s + '] start md5sum calculation...');
end;

procedure TMainForm.AfterRun;
var
  s: string;
begin
  // Finish after run
  btRun2.Enabled:= True;
  btStop.Enabled:= False;
  if pauseCompare then btPauseClick(Self);
  btPause.Enabled:= False;
  btExit.Enabled:= True;

  DatetimeToString(s, 'hh:nn:ss', now);
  Memo1.Lines.Add('[' + s + '] finish md5sum calculation...');
end;

procedure TMainForm.CheckPause;
begin
  // Check if the Pause button is pressed
  if pauseCompare then
  repeat
    // Wait while processing other events
    Application.ProcessMessages;
    // exit loop if Stop button is pressed
    if stopCompare then break;
    // exit loop if Restart button is pressed
  until not pauseCompare;
end;

function TMainForm.GetTotalSize: int64;
var
  i: integer;
begin
  // get sum of all file size
  Result:= 0;
  for i:= 1 to FFileList.Count do
    Inc(Result, File_Size(FFileList[i-1], 0));
end;

//returns MD5 hash for a file (Conventional method)
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

//returns MD5 hash for a file (New Improved method)
function TMainForm.GetMyMD5(const FileName: string): string;
var
  srcFile: TFileStream;
  memStream: TMemoryStream;
  numRead: integer;
  idmd5: TMyIdHashMessageDigest5;
begin
  if not FileExists(FileName) then exit;
  idmd5:= TMyIdHashMessageDigest5.Create;
  idmd5.InitializeState;
  srcFile:= TFileStream.Create(fileName, fmOpenRead OR fmShareDenyWrite);
  srcFile.Seek(0, soBeginning);
  memStream:= TMemoryStream.Create;
  memStream.Seek(0, soBeginning);

  curFile.Caption:= FileName;
  ProgressBar1.Max64:= srcFile.Size;
  ProgressBar1.Position64:= 0;
  fileRate.Caption:= '0%';

  try
    repeat
      Application.ProcessMessages;
      CheckPause;
      if stopCompare then break;

      // read maxRecord bytes. numRead is bytes actually read
      numRead:= srcFile.Read(FBuf, maxRecord);
      if numRead = 0 then break;

      // show progress bytes read
      ProgressBar1.StepBy64(numRead);
      fileRate.Caption:= inttostr(Floor(ProgressBar1.Position64/ProgressBar1.Max64*100)) + '%';
      ProgressBar2.StepBy64(numRead);
      totalRate.Caption:= inttostr(Floor(ProgressBar2.Position64/ProgressBar2.Max64*100)) + '%';

      // prepare data into memStream as bytes read
      memStream.Seek(0, soBeginning);
      memStream.Write(FBuf, numRead);
      memStream.Seek(0, soBeginning);

      // Depends on whether it is the body or the tail
      if srcFile.Position < srcFile.Size then
        idmd5.HashBody(memStream, numRead)
      else begin
        Result:= idmd5.HashTail(memStream, numRead, srcFile.Size);
        break;
      end;
    until false;

  finally
    idmd5.Free;
    memStream.Free;
    srcFile.Free;
  end;
end;





// -----------------------------------------------------------------------------
// Published event functions

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

procedure TMainForm.btRunClick(Sender: TObject);
var
  i: integer;
  fn, s: string;
begin
  // Initialize before run
  if FFileList.Count = 0 then exit;
  BeforeRun;

  // Calculate MD5SUM
  for i:= 1 to FFileList.Count do
  begin
    // Check if Stop button is pressed
    if stopCompare then break;

    // Feetch 1 file
    fn:= FFileList[i-1];

    if Sender = btRun1
    // calculate md5sum by v1.3 method (OLD)
    then s:= LowerCase(GetMD5(fn))
    // calculate md5sum by v1.4 method (NEW)
    else s:= LowerCase(GetMyMD5(fn));

    Memo1.Lines.Add(s + ': ' + ExtractFileName(fn));
  end;

  // Finish after run
  AfterRun;
end;

procedure TMainForm.btPauseClick(Sender: TObject);
begin
  // Pause
  pauseCompare:= not pauseCompare;
  if pauseCompare
  then btPause.Caption:= 'Restart'
  else btPause.Caption:= 'Pause';
end;

procedure TMainForm.btStopClick(Sender: TObject);
begin
  // Stop
  stopCompare:= true;
  // if paused than go to continue state
  if pauseCompare then btPauseClick(Sender);
end;

procedure TMainForm.btCopyTextClick(Sender: TObject);
begin
  // Copy all Text of Memo1 to ClipBoard
  ClipBrd.Clipboard.AsText:= Memo1.Text;
end;

procedure TMainForm.btClearClick(Sender: TObject);
begin
  // Clear all, go to initial state
  FileDrop1.Files.Clear;
  FFileList.Clear;
  Memo1.Lines.Clear;
  Memo1.Lines.Add('Please Drag & Drop Files and click RUN! button.');

  curFile.Caption:= '';
  ProgressBar1.Max64:= 100;
  ProgressBar2.Max64:= 100;
  ProgressBar1.Position64:= 0;
  ProgressBar2.Position64:= 0;
  fileRate.Caption:= '0%';
  totalRate.Caption:= '0%';
end;

procedure TMainForm.btExitClick(Sender: TObject);
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

