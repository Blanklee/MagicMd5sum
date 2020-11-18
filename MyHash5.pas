unit MyHash5;

interface

uses
  System.Classes, IdHashMessageDigest, IdHash, IdGlobal;

type
  TMyIdHashMessageDigest5 = class(TIdHashMessageDigest5)
  private
    FHashResult: TIdBytes;
    FFileSize: int64;
  protected
    // FState: T4x4LongWordRecord = array[0..3] of UInt32;
    function NativeGetHashBytes(AStream: TStream; ASize: TIdStreamSize): TIdBytes; override;
  public
    procedure InitializeState;
    procedure HashBody(AStream: TStream; ASize: integer);
    function HashTail(AStream: TStream; ASize: integer; AFileSize: int64): string;
  end;

implementation

{ TMyIdHashMessageDigest5 }

const
  MD4_INIT_VALUES: T4x4LongWordRecord = (
  $67452301, $EFCDAB89, $98BADCFE, $10325476);

procedure TMyIdHashMessageDigest5.InitializeState;
var
  I: Integer;
begin
  // FState를 초기화

  // A straight assignment would be by ref on dotNET.
  for I := 0 to 3 do begin
    FState[I] := MD4_INIT_VALUES[I];
  end;
end;

procedure TMyIdHashMessageDigest5.HashBody(AStream: TStream; ASize: integer);
var
  LReadSize: integer;
begin
  // 파일의 앞부분을 Hash한다 (512KB씩 들어옴)
  // MDCoder만 열심히 하면 됨
  while ASize >= 64 do
  begin
    LReadSize:= ReadTIdBytesFromStream(AStream, FCBuffer, 64);
    MDCoder;
    Dec(ASize, LReadSize);
  end;
end;

function TMyIdHashMessageDigest5.HashTail(AStream: TStream; ASize: integer; AFileSize: int64): string;
begin
  // 파일크기 저장
  FFileSize:= AFileSize;
  // 파일의 끝부분을 Hash한다 (512KB 이하로 들어옴)
  NativeGetHashBytes(AStream, ASize);
  // 최종 결과를 String으로 변환
  Result:= HashToHex(FHashResult);
end;

function TMyIdHashMessageDigest5.NativeGetHashBytes(AStream: TStream; ASize: TIdStreamSize): TIdBytes;
var
  LStartPos: Integer;
  LSize: TIdStreamSize;
  LBitSize: Int64;
  I, LReadSize: Integer;
begin
  // 이경백 수정: 2019.09.15 새벽
  // TIdHashMessageDigest4.NativeGetHashBytes를 가져와 수정
  // 큰 파일을 512KB씩 쪼개서 MD5SUM 계산할수 있게 수정
  // 기존 512KB의 계산 결과를 FState에 저장, 다음 계산시 이어서 진행하게 함

  Result := nil;
  LSize := ASize;

  // FState[] 초기화 루틴을 InitializeState 함수로 분리함 (여기서 매번 초기화 않음)
  {
  for I := 0 to 3 do begin
    FState[I] := MD4_INIT_VALUES[I];
  end;
  }

  while LSize >= 64 do
  begin
    LReadSize := ReadTIdBytesFromStream(AStream, FCBuffer, 64);

    MDCoder;
    Dec(LSize, LReadSize);
  end;

  // Read the last set of bytes.
  LStartPos := ReadTIdBytesFromStream(AStream, FCBuffer, LSize);

  // Append one bit with value 1
  FCBuffer[LStartPos] := $80;
  Inc(LStartPos);

  // Must have sufficient space to insert the 64-bit size value
  if LStartPos > 56 then
  begin
    for I := LStartPos to 63 do begin
      FCBuffer[I] := 0;
    end;
    MDCoder;
    LStartPos := 0;
  end;

  // Pad with zeroes. Leave room for the 64 bit size value.
  for I := LStartPos to 55 do begin
    FCBuffer[I] := 0;
  end;

  // Append the Number of bits processed.
  LBitSize := FFileSize * 8;
  for I := 56 to 63 do
  begin
    FCBuffer[I] := LBitSize and $FF;
    LBitSize := LBitSize shr 8;
  end;
  MDCoder;

  SetLength(Result, SizeOf(UInt32)*4);
  for I := 0 to 3 do begin
    CopyTIdUInt32(FState[I], Result, SizeOf(UInt32)*I);
  end;

  // 결과를 따로 저장해 둔다
  FHashResult:= Result;
end;

end.
