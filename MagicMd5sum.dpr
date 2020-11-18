program MagicMd5sum;

uses
  Vcl.Forms,
  MainForm1 in 'MainForm1.pas' {MainForm},
  BlankUtils in 'BlankUtils.pas',
  Filedrop in 'Filedrop.pas',
  MyHash5 in 'MyHash5.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
