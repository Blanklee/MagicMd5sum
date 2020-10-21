program MagicMd5sum;

uses
  Vcl.Forms,
  MainForm1 in 'MainForm1.pas' {MainForm},
  Filedrop in 'Filedrop.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
