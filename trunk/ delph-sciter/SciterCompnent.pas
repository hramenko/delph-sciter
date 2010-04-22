unit SciterCompnent;

interface

uses
  SysUtils, Classes, Controls, Messages,
  SciterDll;

type
  TSciter = class(TWinControl)
  private
    { Private declarations }
    FSciterVM: HVM;
    FSciterBarPackage: PSciterNativeClassDef;
    { Private declarations }
    procedure SetNative (p: PSciterNativeClassDef);
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
  protected
    { Protected declarations }
    procedure CreateParams(var Params: TCreateParams); override;
//    procedure CreateWnd; override;
  public
    constructor Create(AOwner: TComponent); override;
  public
    { Public declarations }
    procedure LoadHtml(pHtml: PByte; cb: Cardinal); overload;
    procedure LoadHtml(filename: widestring); overload;
  published
    property Action;
    property Align;
    property Anchors;
    property BiDiMode;
    property Caption;
    property Constraints;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Font;
    property ParentBiDiMode;
    property ParentFont default True;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop default True;
    property Visible;
    property OnClick;
    property OnContextPopup;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseActivate;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;
end;

procedure Register;

implementation

uses
  Windows, Forms, Themes;

procedure Register;
begin
  RegisterComponents('Sciter', [TSciter]);
end;

{ TSciter }

constructor TSciter.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := [csSetCaption, csDoubleClicks];
  Width := 275;
  Height := 225;
  TabStop := True;
end;

procedure TSciter.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);

  CreateSubClass(Params, SciterClassNameA);
//  Params.Style := Params.Style or CS_PARENTDC;
//  Params.ExStyle := Params.ExStyle and (not WS_EX_CONTROLPARENT);
end;

procedure TSciter.LoadHtml(pHtml: PByte; cb: Cardinal);
begin
      ;
end;

procedure TSciter.LoadHtml(filename: widestring);
begin
  SciterLoadFile (Handle, PWidechar(filename));
end;

procedure TSciter.SetNative(p: PSciterNativeClassDef);
begin
;
end;

procedure TSciter.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin
  if ThemeServices.ThemesEnabled then
    Message.Result := 1
  else
    DefaultHandler(Message);
end;

end.
