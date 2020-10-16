{*******************************************************************************
*
*  TFileDrop Component - Adds support for dropping files from explorer onto a
*                        any Delphi TWinControl descendant.
*
*  This is a modification of the TFileDrag component by Eric C. Nielsen
*
*  Copyright (c) 1997 - Thomas Werner (Thomas.Werner@Swedenmail.com)
*  All Rights Reserved
*
*  Version 1.1
*  -----------
*  Several bugs fixed, now it should work under Delphi 2
*
*  Version 1.0
*  -----------
*  Original version adopted from TFileDrag component
*
*
*  TFileDrag component:
*
*  Copyright (c) 1996 - Erik C. Nielsen ( 72233.1314@compuserve.com )
*  All Rights Reserved
*
*******************************************************************************}

unit FileDrop;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ShellApi;

type
  TFileDrop = class(TComponent)
  private
    FNameWithPath: TStrings;
    FNumDropped: Integer;
    FEnabled: Boolean;
    FWndHandle: HWND;
    FDefProc: Pointer;
    FWndProcInstance: Pointer;
    FOnDrop: TNotifyEvent;
    FDropPt: TPoint;
    FParentControl : TWinControl;

    procedure DropFiles( hDropHandle: HDrop );
    procedure SetEnabled( Value: Boolean );
    procedure WndProc( var Msg: TMessage );
    procedure InitControl;
    procedure DestroyControl;
    procedure SetParentControl(Value : TWinControl);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Files: TStrings read FNameWithPath;
    property FileCount: Integer read FNumDropped;
    property DropPoint: TPoint read FDropPt;
    property EnableDrop: Boolean read FEnabled write SetEnabled;
    property DropControl: TWinControl read FParentControl write SetParentControl;
    property OnDrop: TNotifyEvent read FOnDrop write FOnDrop;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Samples', [TFileDrop]);
end;

constructor TFileDrop.Create( AOwner: TComponent );
begin
   inherited Create( AOwner );
   FNumDropped := 0;
   FNameWithPath := TStringList.Create;
   FWndHandle := 0;

   FDropPt.X := 0;
   FDropPt.Y := 0;
end;

destructor TFileDrop.Destroy;
begin
  DestroyControl;
  SetEnabled( FALSE );
  FNameWithPath.Free;
  inherited Destroy;
end;

procedure TFileDrop.InitControl;
var
  WinCtl: TWinControl;
begin
   if FParentControl is TWinControl then
    begin
      { Subclass the owner so this control can capture the WM_DROPFILES message }
      WinCtl := TWinControl( FParentControl );
      FWndHandle := WinCtl.Handle;
      FWndProcInstance := MakeObjectInstance( WndProc );
      FDefProc := Pointer( GetWindowLong( FWndHandle, GWL_WNDPROC ));
      SetWindowLong( FWndHandle, GWL_WNDPROC, Longint( FWndProcInstance ));
    end
   else
    FEnabled := False;
end;

procedure TFileDrop.DestroyControl;
begin
  if FWndHandle <> 0 then
   begin
     { Restore the original window procedure }
     SetWindowLong( FWndHandle, GWL_WNDPROC, Longint( FDefProc ));
     FreeObjectInstance(FWndProcInstance);
   end
end;
procedure TFileDrop.SetParentControl(Value:TWinControl);
begin
     if Value=nil then begin
        SetWindowLong( FWndHandle, GWL_WNDPROC, Longint( FDefProc ));
        FreeObjectInstance(FWndProcInstance);
        SetEnabled(False);
        FParentControl := nil;
        exit;
     end else
     if Value<>FParentControl then begin
        FParentControl := Value;
        InitControl;
        SetEnabled( TRUE );
     end;
end;
procedure TFileDrop.SetEnabled( Value: Boolean );
begin
  if FParentControl = nil then exit;
  FEnabled := Value;
  { Call Win32 API to register the owner as being able to accept dropped files }
  DragAcceptFiles( FWndHandle, FEnabled );
end;

procedure TFileDrop.DropFiles( hDropHandle: HDrop );
var
  pszFileWithPath: PChar;
  iFile, iStrLen, iTempLen: Integer;
begin
  iStrLen := 128;
  pszFileWithPath := StrAlloc( iStrLen );
  iFile := 0;

  { Clear any existing strings from the string lists }
  FNameWithPath.Clear;

  { Retrieve the number of files being dropped }
  FNumDropped := DragQueryFile( hDropHandle, $FFFFFFFF, nil, iStrLen );

  {******************}
  { Added the following on August 26, 1997 }
  { Set the drop point }
  DragQueryPoint( hDropHandle, FDropPt );
  {******************}

  { Retrieve each file being dropped }
  while ( iFile < FNumDropped ) do
  begin
   { Get the length of this file name }
   iTempLen := DragQueryFile( hDropHandle, iFile, nil, 0 ) + 1;
   { If file length > current PChar, delete and allocate one large enough }
   if ( iTempLen > iStrLen ) then
     begin
       iStrLen := iTempLen;
       StrDispose( pszFileWithPath );
       pszFileWithPath := StrAlloc( iStrLen );
     end;
   { Get the fully qualified file name }
   DragQueryFile( hDropHandle, iFile, pszFileWithPath, iStrLen );
   FNameWithPath.Add( StrPas( pszFileWithPath ));
   Inc( iFile );
  end;

  StrDispose( pszFileWithPath );

  { This will result in the OnDrop method being called, if it is defined }
  if Assigned(FOnDrop) then
   begin
    FOnDrop(Self);
   end
end;

procedure TFileDrop.WndProc( var Msg: TMessage );
begin
   with Msg do
    begin
       { If message is drop files, process, otherwise call the original window procedure }
       if Msg = WM_DROPFILES then
           DropFiles( HDrop( wParam ))
       else
           Result := CallWindowProc( FDefProc, FWndHandle, Msg, WParam, LParam);
    end;
end;

end.
