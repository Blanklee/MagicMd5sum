unit BlankUtils;

{$I-}

interface

uses
  Windows, Classes, System.SysUtils;

// File & Directory functions
function File_Age(AFileName: string): integer;
function File_Exists(AFileName: string): boolean;
function File_Size(AFileName: string; Default: int64=-1): int64;
function IsDirectory(AFileName: string): boolean;


implementation

type
  TFileInfo = record
    FullName: string;           // Full PathName
    FileSize: int64;            // File Size
    FileAge: integer;           // same value as SysUtils.FileAge
    FileAttr: DWORD;            // File Attributes
  end;

var
  FileInfo: TFileInfo;




// -------------------------------------
// File & Directory functions
// -------------------------------------

procedure GetFileInfo(AFileName: string);
var
  FindData: TWin32FileAttributeData;
  LocalFileTime: TFileTime;
  Age: integer;
begin
  // get only once for the same file
  if FileInfo.FullName = AFileName then exit;

  FileInfo.FullName:= AFileName;
  Age:= -1;

  // Get file information
  if GetFileAttributesEx(PChar(AFileName), GetFileExInfoStandard, @FindData) then
  begin
    FileInfo.FileAttr:= FindData.dwFileAttributes;
    if FileInfo.FileAttr and faDirectory = 0 then
    begin
      // get FileAge & FileSize
      FileTimeToLocalFileTime(FindData.ftLastWriteTime, LocalFileTime);
      FileTimeToDosDateTime(LocalFileTime, LongRec(Age).Hi, LongRec(Age).Lo);
      FileInfo.FileSize:= FindData.nFileSizeHigh;
      FileInfo.FileSize:= FileInfo.FileSize shl 32 + FindData.nFileSizeLow;
    end;
  end;
  FileInfo.FileAge:= Age;
end;

function File_Age(AFileName: string): integer;
begin
  // same result as SysUtils.FileAge
  GetFileInfo(AFileName);
  Result:= FileInfo.FileAge;
end;

function File_Exists(AFileName: string): boolean;
var
  buf: array[0..255] of char;
begin
  // Delphi's FileExists() results False if FileAge is 1800 year
  GetFileInfo(AFileName);
  if FileInfo.FileAge <> -1 then Result:= true
  else if GetFileAttributes(StrPCopy(buf,AFileName)) = $FFFFFFFF then Result:= false
  else Result:= true;
end;

function File_Size(AFileName: string; Default: int64=-1): int64;
begin
  if not File_Exists(AFileName) then Result:= Default
  else Result:= FileInfo.FileSize;
end;

function IsDirectory(AFileName: string): boolean;
begin
  // True if Directory, False if File
  GetFileInfo(AFileName);
  Result:= (FileInfo.FileAttr and faDirectory <> 0);
end;

Initialization
  FillChar(FileInfo, SizeOf(TFileInfo), 0);
end.

