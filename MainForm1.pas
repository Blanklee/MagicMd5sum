unit MainForm1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.StdCtrls, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls,
  Vcl.Buttons, FileDrop, MyThread1;

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
    btOpen: TButton;
    btCopyText: TButton;
    btClear: TButton;
    btExit: TButton;
    btTemp: TBitBtn;
    FileDrop1: TFileDrop;
    OpenDialog1: TOpenDialog;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FileDrop1Drop(Sender: TObject);
    procedure Memo1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btRunClick(Sender: TObject);
    procedure btPauseClick(Sender: TObject);
    procedure btStopClick(Sender: TObject);
    procedure btOpenClick(Sender: TObject);
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
    Md5Thread: TMyThread;
    function GetTotalSize: Int64;
    function Int64ToKiloMegaGiga(ASize: Int64): string;
    procedure Get_SubDirectory(FolderName: string; PathLength: integer);
    procedure BeforeRun;
    procedure AfterRun(Sender: TObject);
    procedure Md5ThreadFileRead(numRead: integer);
    procedure Md5ThreadFileStep(Index: integer; Sum: string);
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  ClipBrd, Math, BlankUtils;

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
  btOpen.Enabled:= False;
  btClear.Enabled:= False;
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

procedure TMainForm.AfterRun(Sender: TObject);
var
  s, t: string;
begin
  // Finish after run
  btRun.Enabled:= True;
  btStop.Enabled:= False;
  if pauseCompare then btPauseClick(Self);
  btPause.Enabled:= False;
  btOpen.Enabled:= True;
  btClear.Enabled:= True;
  btExit.Enabled:= True;
  stopCompare := False;
  pauseCompare:= False;

  DatetimeToString(s, 'hh:nn:ss', Now);
  DatetimeToString(t, 'hh:nn:ss', Now-FTime);
  Memo1.Lines.Add('[' + s + '] finish (' + t + ' elapsed)');
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
  if ASize < 1000 *    1 then  Result:= ASize.ToString + ' Bytes' else
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

procedure TMainForm.btOpenClick(Sender: TObject);
var
  i, PathLength: integer;
  s, FileName: string;
begin
  // Open File with DialogBox
  if not OpenDialog1.Execute then exit;

  // refer FileDrop1Drop
  // Add selected files (except Directory - cannot select at OpenDialog1)
  for i:= 1 to OpenDialog1.Files.Count do
  begin
    FileName:= OpenDialog1.Files[i-1];
    PathLength:= Length(ExtractFilePath(FileName));
    FFileList.AddObject(FileName, Pointer(PathLength));
  end;

  // Show message on the screen (count & size)
  s:= Int64ToKiloMegaGiga(GetTotalSize);
  Memo1.Lines.Add(OpenDialog1.Files.Count.ToString + ' Files Added (Total ' + FFileList.Count.ToString + ' files, ' + s + ')');
end;

procedure TMainForm.btRunClick(Sender: TObject);
begin
  // Initialize before run
  if FFileList.Count = 0 then exit;
  BeforeRun;

  // Sort FileList
  FFileList.Sort;

  // Create thread and Start!
  Md5Thread:= TMyThread.Create(FFileList);
  Md5Thread.OnFileRead:= Md5ThreadFileRead;
  Md5Thread.OnFileStep:= Md5ThreadFileStep;
  Md5Thread.OnTerminate:= AfterRun;
  Md5Thread.Start;

  // Finish after run => OnTerminate
  // AfterRun;
end;

procedure TMainForm.btPauseClick(Sender: TObject);
begin
  // Pause
  pauseCompare:= not pauseCompare;

  if pauseCompare then
  begin
    // Md5Thread.Suspend;
    btPause.Caption:= 'Start';
    btPause.Glyph:= btRun.Glyph;
  end else
  begin
    // Md5Thread.Resume;
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

  // Stop thread
  Md5Thread.Terminate;
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
  Memo1.Lines.Add('Please Open or Drop Files and click RUN! button.');

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
  // Ctrl-A (Select All) / Ctrl-C (Copy) / Ctrl-O (Open)
  if ssCtrl in Shift then
  begin
    if (Key = Ord('A')) or (Key = Ord('a')) then Memo1.SelectAll;
    if (Key = Ord('C')) or (Key = Ord('c')) then ClipBrd.Clipboard.AsText:= Memo1.SelText;
    if (Key = Ord('O')) or (Key = Ord('o')) then btOpenClick(Sender);
  end;
end;





// -----------------------------------------------------------------------------
// Thread event functions

procedure TMainForm.Md5ThreadFileRead(numRead: integer);
begin
  // come here after read file as numRead bytes in thread
  ProgressBar1.StepBy64(numRead);
  fileRate.Caption:= inttostr(Floor(ProgressBar1.Position64/ProgressBar1.Max64*100)) + '%';
  ProgressBar2.StepBy64(numRead);
  totalRate.Caption:= inttostr(Floor(ProgressBar2.Position64/ProgressBar2.Max64*100)) + '%';
end;

procedure TMainForm.Md5ThreadFileStep(Index: integer; Sum: string);
var
  pl: integer;
  FileName: string;
begin
  FileName:= FFileList[Index];

  // Before run 1 file in thread (Sum = '')
  if Sum = '' then
  begin
    // Show filename, initialize file size
    curFile.Caption:= FileName;
    ProgressBar1.Max64:= File_Size(FileName, 0);
    ProgressBar1.Position64:= 0;
    fileRate.Caption:= '0%';
  end

  // After run 1 file in thread (Sum <> '')
  else begin
    // Output: delete first PathLength bytes from FullName,
    // show only relative path from base directory
    pl:= Integer(FFileList.Objects[Index]);
    Delete(FileName, 1, pl);
    Memo1.Lines.Add(Sum + ': ' + FileName);
  end;
end;

end.

