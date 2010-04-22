program SciterTest;

uses
  Forms,
  GUI in 'GUI.pas' {Form3},
  SciterCompnent in 'SciterCompnent.pas',
  SciterDll in 'SciterDll.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm3, Form3);
  Application.Run;
end.
