program Snake;

uses
  Forms,
  Main in 'Main.pas' {MainForm},
  Snake.Types in 'Snake.Types.pas',
  Snake.Play in 'Snake.Play.pas';

{$R *.res}

begin
  {$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := True;
  {$ENDIF}
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

