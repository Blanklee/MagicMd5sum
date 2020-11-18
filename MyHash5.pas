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
  // FState�� �ʱ�ȭ

  // A straight assignment would be by ref on dotNET.
  for I := 0 to 3 do begin
    FState[I] := MD4_INIT_VALUES[I];
  end;
end;

procedure TMyIdHashMessageDigest5.HashBody(AStream: TStream; ASize: integer);
var
  LReadSize: integer;
begin
  // ������ �պκ��� Hash�Ѵ� (512KB�� ����)
  // MDCoder�� ������ �ϸ� ��
  while ASize >= 64 do
  begin
    LReadSize:= ReadTIdBytesFromStream(AStream, FCBuffer, 64);
    MDCoder;
    Dec(ASize, LReadSize);
  end;
end;

function TMyIdHashMessageDigest5.HashTail(AStream: TStream; ASize: integer; AFileSize: int64): string;
begin
  // ����ũ�� ����
  FFileSize:= AFileSize;
  // ������ ���κ��� Hash�Ѵ� (512KB ���Ϸ� ����)
  NativeGetHashBytes(AStream, ASize);
  // ���� ����� String���� ��ȯ
  Result:= HashToHex(FHashResult);
end;

function TMyIdHashMessageDigest5.NativeGetHashBytes(AStream: TStream; ASize: TIdStreamSize): TIdBytes;
var
  LStartPos: Integer;
  LSize: TIdStreamSize;
  LBitSize: Int64;
  I, LReadSize: Integer;
begin
  // �̰�� ����: 2019.09.15 ����
  // TIdHashMessageDigest4.NativeGetHashBytes�� ������ ����
  // ū ������ 512KB�� �ɰ��� MD5SUM ����Ҽ� �ְ� ����
  // ���� 512KB�� ��� ����� FState�� ����, ���� ���� �̾ �����ϰ� ��

  Result := nil;
  LSize := ASize;

  // FState[] �ʱ�ȭ ��ƾ�� InitializeState �Լ��� �и��� (���⼭ �Ź� �ʱ�ȭ ����)
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

  // ����� ���� ������ �д�
  FHashResult:= Result;
end;

end.
