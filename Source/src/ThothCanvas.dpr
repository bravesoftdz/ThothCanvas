program ThothCanvas;

uses
  FMX.Forms,
  MainForm in 'Forms\MainForm.pas' {Form1},
  ThItem in 'Libraries\ThItem.pas',
  ThShape in 'Libraries\ThShape.pas',
  ThCanvasEditor in 'Components\ThCanvasEditor.pas',
  ThContainer in 'Libraries\ThContainer.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
