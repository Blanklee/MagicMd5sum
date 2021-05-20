unit MainForm1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.StdCtrls, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls,
  Vcl.Buttons, FileDrop, MyHash5;

const
  // buf size to compare at once (Test : speed improved until 512KB, little improved more than 512KB)
  maxRecord = 1024 * 512;
  maxRecord32 = maxRecord div 4;

type
  // To use Int64 with Max & Position (up to 2TB)
  TProgressBar = class(Vcl.ComCtrls.TProgressBar)
  private
    FInt32: Boolean;
    FMax64: Int64;
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
    btRun: TBitBtn;
    btPause: TBitBtn;
    btStop: TBitBtn;
    btCopyText: TButton;
    btClear: TButton;
    btExit: TButton;
    btTemp: TBitBtn;
    FileDrop1: TFileDrop;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FileDrop1Drop(Sender: TObject);
    procedure Memo1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btRunClick(Sender: TObject);
    procedure btPauseClick(Sender: TObject);
    procedure btStopClick(Sender: TObject);
    procedure btCopyTextClick(Sender: TObject);
    procedure btClearClick(Sender: TObject);
    procedure btExitClick(Sender: TObject);
    procedure btTempClick(Sender: TObject);
  private
    { Private declarations }
    FFileList: TStringList;
    pauseCompare: boolean;
    stopCompare: boolean;
    FTime: TDateTime;
    FBuf: array[1..maxRecord] of byte;
    procedure CheckPause;
    function GetTotalSize: Int64;
    function Int64ToKiloMegaGiga(ASize: Int64): string;
    function GetMyMd5Sum(const FileName: string): string;
    procedure Get_SubDirectory(FolderName: string; PathLength: integer);
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
  FFileList.NameValueSeparator:= '|';

  // Initialize members
  stopCompare:= False;
  pauseCompare:= false;
  curFile.Caption:= '';

  {$IFOPT D+}
  btTemp.Show;
  {$ENDIF}
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  FFileList.Free;
end;





// -----------------------------------------------------------------------------
// Private functions

procedure TMainForm.Get_SubDirectory(FolderName: string; PathLength: integer);
var
  sr: TSearchRec;
begin
  // find first file in FolderName, then FFileList.Add
  if FindFirst(FolderName+'\*.*', faAnyFile, sr) <> 0 then exit;
  begin
    // run recursively if Directory, FFileList.Add if File
    if (sr.Name <> '.') and (sr.Name <> '..') then
    if sr.Attr and faDirectory <> 0
    then Get_SubDirectory(FolderName+'\'+sr.Name, PathLength)
    else FFileList.AddObject(FolderName+'\'+sr.Name, Pointer(PathLength));
  end;

  // find all file in FolderName, then FFileList.Add
  while FindNext(sr) = 0 do
  begin
    // run recursively if Directory, FFileList.Add if File
    if (sr.Name <> '.') and (sr.Name <> '..') then
    if sr.Attr and faDirectory <> 0
    then Get_SubDirectory(FolderName+'\'+sr.Name, PathLength)
    else FFileList.AddObject(FolderName+'\'+sr.Name, Pointer(PathLength));
  end;

  FindClose (sr);
end;

procedure TMainForm.BeforeRun;
var
  s: string;
begin
  // Initialize before run
  btRun.Enabled:= False;
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

  FTime:= Now;
  DatetimeToString(s, 'hh:nn:ss', FTime);
  Memo1.Lines.Add('');
  Memo1.Lines.Add('[' + s + '] start md5sum calculation...');
end;

procedure TMainForm.AfterRun;
var
  s, t: string;
begin
  // Finish after run
  btRun.Enabled:= True;
  btStop.Enabled:= False;
  if pauseCompare then btPauseClick(Self);
  btPause.Enabled:= False;
  btExit.Enabled:= True;

  DatetimeToString(s, 'hh:nn:ss', Now);
  DatetimeToString(t, 'hh:nn:ss', Now-FTime);
  Memo1.Lines.Add('[' + s + '] finish (' + t + ' elapsed)');
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

function TMainForm.GetTotalSize: Int64;
var
  i: integer;
begin
  // get sum of all file size
  Result:= 0;
  for i:= 1 to FFileList.Count do
    Inc(Result, File_Size(FFileList[i-1], 0));
end;

function TMainForm.Int64ToKiloMegaGiga(ASize: Int64): string;
const
  KILO = Int64(1024);
  MEGA = Int64(KILO * 1024);
  GIGA = Int64(MEGA * 1024);
begin
  // Bytes를 용량에 따라 적당한 단위로 보기좋게 출력한다
  if ASize < 1000 *    1 then  Result:= inttostr(ASize) + ' Bytes' else
  if ASize <   10 * KILO then  Result:= Format('%3.2f KB', [ASize / KILO]) else
  if ASize <  100 * KILO then  Result:= Format('%3.1f KB', [ASize / KILO]) else
  if ASize < 1000 * KILO then  Result:= Format('%3.0f KB', [ASize / KILO]) else
  if ASize <   10 * MEGA then  Result:= Format('%3.2f MB', [ASize / MEGA]) else
  if ASize <  100 * MEGA then  Result:= Format('%3.1f MB', [ASize / MEGA]) else
  if ASize < 1000 * MEGA then  Result:= Format('%3.0f MB', [ASize / MEGA]) else
  if ASize <   10 * GIGA then  Result:= Format('%3.2f GB', [ASize / GIGA]) else
  if ASize <  100 * GIGA then  Result:= Format('%3.1f GB', [ASize / GIGA]) else
 {if ASize <  100 * GIGA then} Result:= Format('%3.0f GB', [ASize / GIGA]);
end;

procedure TMainForm.btTempClick(Sender: TObject);
begin
  {$IFOPT D+}
  // Only for Test..
  Memo1.Lines.Add('');
  Memo1.Lines.Add('Int64ToKiloMegaGiga Test');
  Memo1.Lines.Add(Int64ToKiloMegaGiga(1011));
  Memo1.Lines.Add(Int64ToKiloMegaGiga(12345));
  Memo1.Lines.Add(Int64ToKiloMegaGiga(101*1024));
  Memo1.Lines.Add(Int64ToKiloMegaGiga(999*1024));
  Memo1.Lines.Add(Int64ToKiloMegaGiga(1000*1024));
  Memo1.Lines.Add(Int64ToKiloMegaGiga(1024*1024));
  Memo1.Lines.Add(Int64ToKiloMegaGiga(123456));
  Memo1.Lines.Add(Int64ToKiloMegaGiga(1234567));
  Memo1.Lines.Add(Int64ToKiloMegaGiga(12345678));
  Memo1.Lines.Add(Int64ToKiloMegaGiga(123456789));
  Memo1.Lines.Add(Int64ToKiloMegaGiga(1234567890));
  Memo1.Lines.Add(Int64ToKiloMegaGiga(12345678901));
  Memo1.Lines.Add(Int64ToKiloMegaGiga(123456789012));
  Memo1.Lines.Add(Int64ToKiloMegaGiga(1234567890123));
  {$ENDIF}
end;

function TMainForm.GetMyMd5Sum(const FileName: string): string;
var
  srcFile: TFileStream;
  memStream: TMemoryStream;
  numRead: integer;
  idmd5: TMyIdHashMessageDigest5;
begin
  //returns MD5 hash for a file
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
    // until v1.3 : only 1 line, very slow, no response
    // Result:= idmd5.HashStreamAsHex(srcFile);

    // from v1.4 : New Improved method
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
  i, a, PathLength: integer;
  s, FileName: string;
begin
  // save FileCount before adding files
  a:= FFileList.Count;

  // If several dropped FileDrop1 only keeps the last drop,
  // so we must save it into FFileList accumulatively.
  for i:= 1 to FileDrop1.FileCount do
  begin
    // PathLength: length of original path, save for later use - output filepath removed original path
    FileName:= FileDrop1.Files[i-1];
    PathLength:= Length(ExtractFilePath(FileName));

    // When folder is dropped, add all files in the folder.
    if IsDirectory(FileName)
    then Get_SubDirectory(FileName, PathLength)
    else FFileList.AddObject(FileName, Pointer(PathLength));
  end;

  // Show message on the screen (count & size)
  s:= Int64ToKiloMegaGiga(GetTotalSize);
  a:= FFileList.Count - a;
  Memo1.Lines.Add(a.ToString + ' Files Added (Total ' + FFileList.Count.ToString + ' files, ' + s + ')');
end;

procedure TMainForm.btRunClick(Sender: TObject);
var
  i, pl: integer;
  fn, sum: string;
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

    // calculate md5sum by v1.4 method (NEW)
    sum:= LowerCase(GetMyMd5Sum(fn));

    // Output: delete first PathLength bytes from FullName,
    // show only relative path from base directory
    pl:= Integer(FFileList.Objects[i-1]);
    Delete(fn, 1, pl);
    Memo1.Lines.Add(sum + ': ' + fn);
  end;

  // Finish after run
  AfterRun;
end;

procedure TMainForm.btPauseClick(Sender: TObject);
begin
  // Pause
  pauseCompare:= not pauseCompare;

  if pauseCompare then
  begin
    btPause.Caption:= 'Start';
    btPause.Glyph:= btRun.Glyph;
  end else
  begin
    btPause.Caption:= 'Pause';
    btPause.Glyph:= btTemp.Glyph;
  end;
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

