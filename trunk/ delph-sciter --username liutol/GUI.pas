unit GUI;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, SciterCompnent, ExtCtrls;

type
  TForm3 = class(TForm)
    Panel1: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    FSciter: TSciter;
  public
    { Public declarations }
  end;

var
  Form3: TForm3;

implementation

{$R *.dfm}

procedure TForm3.FormCreate(Sender: TObject);
begin
  FSciter := TSciter.Create(Panel1);
//  FSciter.Parent := TWinControl (Panel1);
  FSciter.Align := alClient;
end;

procedure TForm3.FormShow(Sender: TObject);
begin
  FSciter.LoadHtml('default.htm');
end;

end.
