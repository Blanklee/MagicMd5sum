unit MyThread1;

interface

uses
  Classes, System.SyncObjs;

const
  // buf size to compare at once (Test by Buf Size)
  // if skip ProgressBar: speed improved until 512KB, little improved over 512KB
  // if show ProgressBar: speed improved until  2MB,  little improved over  2MB
  maxRecord = 1024 * 2048;

type
  // Event type for VCL output by Synchronize function
  TFileReadEvent = procedure(numRead: integer) of object;
  TFileStepEvent = procedure(Index: integer; Sum: string) of object;

  TMyThread = class(TThread)
  private
    FEvent: TEvent;
    FPaused: boolean;
    FFileList: TStringList;
    FIndex: integer;
    FSum: string;
    FBuf: array[1..maxRecord] of byte;
    numRead: integer;
    function GetMyMd5Sum(const FileName: string): string;
    procedure SetPaused(const Value: boolean);
    // Synchronize function for VCL output
    procedure VisualOnFileRead;
    procedure VisualOnFileStep;
  protected
    FOnFileRead: TFileReadEvent;
    FOnFileStep: TFileStepEvent;
    procedure Execute; override;
  public
    constructor Create(FileList: TStringList);
    destructor Destroy; override;
    // for Pause
    property Paused: boolean read FPaused write SetPaused;
    // Event hole for VCL output on MainForm by Synchronize function
    property OnFileRead: TFileReadEvent read FOnFileRead write FOnFileRead;
    property OnFileStep: TFileStepEvent read FOnFileStep write FOnFileStep;
  end;

implementation

{ TMyThread }

uses MyHash5, System.SysUtils;

constructor TMyThread.Create(FileList: TStringList);
begin
  // Initialize members
  FPaused:= False;
  FEvent:= TEvent.Create(nil, True, not FPaused, '');

  // FileList written at Main
  FFileList:= FileList;

  // Auto free after running thread
  FreeOnTerminate:= True;

  // Create thread, suspended mode (True)
  inherited Create(True);
end;

destructor TMyThread.Destroy;
begin
  Terminate;
  FEvent.SetEvent;
  WaitFor;
  FEvent.Free;
  inherited;
end;

procedure TMyThread.SetPaused(const Value: boolean);
begin
  if (not Terminated) and (FPaused <> Value) then
  begin
    FPaused:= Value;
    if FPaused
    then FEvent.ResetEvent
    else FEvent.SetEvent;
  end;
end;

procedure TMyThread.VisualOnFileRead;
begin
  // Synchronize function for VCL output
  if Assigned(FOnFileRead) then FOnFileRead(numRead);
end;

procedure TMyThread.VisualOnFileStep;
begin
  // Synchronize function for VCL output
  if Assigned(FOnFileStep) then FOnFileStep(FIndex, FSum);
end;

procedure TMyThread.Execute;
var
  i: integer;
  fn: string;
begin
  // Main에서 Thread.Create 하면 궁극적으로 여기 들어와서 작업을 하게 된다

  // Calculate MD5SUM
  for i:= 1 to FFileList.Count do
  begin
    // Check if Stop button is pressed
    // if stopCompare then break;

    // break loop if thread is terminated
    if Terminated then break;
    FEvent.WaitFor(INFINITE);

    // Fetch 1 file
    FIndex:= i-1;
    fn:= FFileList[FIndex];

    // 계산전 화면출력 (FSum = '')
    FSum:= '';
    Synchronize(VisualOnFileStep);

    // the Core 1 line : call GetMyMd5Sum
    // calculate md5sum by v1.4 method (NEW)
    FSum:= LowerCase(GetMyMd5Sum(fn));

    // Skip below Sync(VCL) if stopped during calculation
    if Terminated then break;

    // Synchronize(VisualOnFileStep) 함수로 대체
    // FullName에서 앞쪽 PathLength만큼 삭제후 출력
    // 기본 Folder 기준으로 상대 경로만 출력한다
    // pl:= Integer(FFileList.Objects[i-1]);
    // Delete(fn, 1, pl);

    // 계산후 화면출력 (FSum <> '')
    // Memo1.Lines.Add(sum + ': ' + fn);
    Synchronize(VisualOnFileStep);
  end;
end;

function TMyThread.GetMyMd5Sum(const FileName: string): string;
var
  srcFile: TFileStream;
  memStream: TMemoryStream;
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

  // replaced to Synchronize(VisualOnFileStep) in Execute function
  // curFile.Caption:= FileName;
  // ProgressBar1.Max64:= srcFile.Size;
  // ProgressBar1.Position64:= 0;
  // fileRate.Caption:= '0%';

  try
    // until v1.3 : only 1 line, very slow, no response
    // Result:= idmd5.HashStreamAsHex(srcFile);

    // from v1.4 : New Improved method
    repeat
      // Application.ProcessMessages;
      // CheckPause;
      // if stopCompare then break;

      // break loop if thread is terminated
      if Terminated then break;
      FEvent.WaitFor(INFINITE);

      // read maxRecord bytes. numRead is bytes actually read
      numRead:= srcFile.Read(FBuf, maxRecord);
      if numRead = 0 then break;

      // replaced to Synchronize(VisualOnFileRead)
      // show progress as bytes read
      // ProgressBar1.StepBy64(numRead);
      // fileRate.Caption:= inttostr(Floor(ProgressBar1.Position64/ProgressBar1.Max64*100)) + '%';
      // ProgressBar2.StepBy64(numRead);
      // totalRate.Caption:= inttostr(Floor(ProgressBar2.Position64/ProgressBar2.Max64*100)) + '%';
      Synchronize(VisualOnFileRead);

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

end.

