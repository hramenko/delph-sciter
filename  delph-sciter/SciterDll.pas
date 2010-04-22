unit SciterDll;

interface

uses
  Windows;

type
  HELEMENT = Pointer;
  THTMLAYOUT_NOTIFY = function (uMsg: UINT; wParam:WPARAM; lParam:LPARAM; vParam: Pointer): LRESULT;

type
  TEventHandle = class
  public
    class function ElementProc (pthis: TEventHandle; he: HELEMENT; evtg:UINT; prms: Pointer): Integer;
  end;

type
  PSCITER_VALUE = ^SCITER_VALUE;
  SCITER_VALUE = record
   t: UINT;
   u: UINT;
   d: UINT64;
  end;

  PSCITER_CALLBACK_NOTIFICATION = ^SCITER_CALLBACK_NOTIFICATION;
  SCITER_CALLBACK_NOTIFICATION = record
    code: UINT; //< [in] one of the codes above.*/
    hwnd: HWND; //< [in] HWND of the window this callback was attached to.*/
  end;

const
  SC_LOAD_DATA       = $01;

(**This notification indicates that external data (for example image) download process
 * completed.
 *
 * param lParam #LPSCN_DATA_LOADED
 *
 * This notifiaction is sent for each external resource used by document when
 * this resource has been completely downloaded. Sciter will send this
 * notification asynchronously.
 **)
  SC_DATA_LOADED     = $02;

(**This notification is sent when all external data (for example image) has been downloaded.
 *
 * This notification is sent when all external resources required by document
 * have been completely downloaded. Sciter will send this notification
 * asynchronously.
 **)
  SC_DOCUMENT_COMPLETE = $03;

(**This notification is sent on parsing the document and while processing
 * elements having non empty style.behavior attribute value.
 *
 * param lParam #LPSCN_ATTACH_BEHAVIOR
 *
 * Application has to provide implementation of #sciter::behavior interface.
 * Set #SCN_ATTACH_BEHAVIOR::impl to address of this implementation.
 **)
  SC_ATTACH_BEHAVIOR = $04;

(**This notification is sent on
 * 1) stdin, stdout and stderr operations and
 * 2) view.hostCallback(p1,p2) calls from script
 *
 * param lParam #LPSCN_CALLBACK_HOST
 *
 **)
  SC_CALLBACK_HOST = $05;

type
  PSciterHostCallback = function (
        pns: Pointer; callbackParam: Pointer): UINT; stdcall;

const
  SIH_REPLACE_CONTENT     = 0;
  SIH_INSERT_AT_START     = 1;
  SIH_APPEND_AFTER_LAST   = 2;

  SOH_REPLACE             = 3;
  SOH_INSERT_BEFORE       = 4;
  SOH_INSERT_AFTER        = 5;

  (* Host native classes *)
type
  HVM = ^tiscript_VM;
  tiscript_VM = record
  end;

  SciterNativeMethod_t = procedure (hvm: HVM; selfp: PSCITER_VALUE; argv: PSCITER_VALUE;
                                    argc: Integer; retval: PSCITER_VALUE); stdcall;

  SciterNativeProperty_t = procedure (hvm: HVM; selfp: PSCITER_VALUE; sets: Integer;
                                    val: PSCITER_VALUE); stdcall;

  SciterNativeDtor_t = procedure (hvm: HVM; p_data_slot_value: Pointer); stdcall;

  PSciterNativeMethodDef = ^SciterNativeMethodDef;
  SciterNativeMethodDef = record
      name: LPCSTR;
      method: SciterNativeMethod_t;
  end;

  PSciterNativePropertyDef = ^SciterNativePropertyDef;
  SciterNativePropertyDef = record
      name: LPCSTR;
      propertys: SciterNativeProperty_t;
  end;

  PSciterNativeConstantDef = ^SciterNativeConstantDef;
  SciterNativeConstantDef = record
      name: LPCSTR;
      value: SCITER_VALUE;
//      SciterNativeConstantDef( LPCSTR n,SCITER_VALUE v = SCITER_VALUE() ):name(n),value(v) {}
  end;

  PSciterNativeClassDef = ^SciterNativeClassDef;
  SciterNativeClassDef = record
      name: LPCSTR;
      methods: PSciterNativeMethodDef;
      properties: PSciterNativePropertyDef;
      dtor: SciterNativeDtor_t;
      constants: PSciterNativeConstantDef;
  end;

  function SciterClassNameA: LPCSTR; stdcall;
  function SciterGetVM (handle: HWND): HVM; stdcall;
  function SciterNativeDefineClass( hvm: HVM; pClassDef: PSciterNativeClassDef): integer; stdcall;
  function SciterSetExceptionValue( hvm: HVM; errorMsg: LPCWSTR): Integer; stdcall;
  function SciterVmEval( hvm: HVM; script: LPCWSTR; scriptLength:UINT; pretval: PSCITER_VALUE): integer; stdcall;
  function SciterCreateObject(hvm: HVM; className: LPCWSTR; pretval: PSCITER_VALUE): integer;stdcall;

  function BasicHostCallback(pns: Pointer; callbackParam: Pointer): UINT; stdcall;

 //ATTN: SOH_*** operations do not work for inline elements like <SPAN>

(*
    SCITE Section
*)

function SciterProcND(hwnd:HWND; msg:UINT; wParam:WPARAM;
                          lParam:LPARAM;  var pbHandled: Integer): LRESULT; stdcall;
function SciterCall(hWnd: HWND; functionName: LPCSTR; argc: UINT;
                          argv: PSCITER_VALUE; retval: PSCITER_VALUE): Integer; stdcall;
procedure SciterSetCallback(hWndSciter: HWND; cb: PSciterHostCallback; cbParam: Pointer); stdcall;
function SciterLoadHtml(hWndSciter:HWND; html:PBYTE; htmlSize:UINT; baseUrl:LPCWSTR): Integer; stdcall;
function SciterLoadFile(hWndSciter:HWND; filename:LPCWSTR):Integer; stdcall;
function SciterEval( hwnd: HWND; script:LPCWSTR; scriptLength: UINT; pretval: PSCITER_VALUE): Integer; stdcall;

function ValueInit( pval: PSCITER_VALUE): UINT; stdcall;
function ValueStringData(pval: PSCITER_VALUE; var pChars: LPCWSTR; var pNumChars: UINT): UINT; stdcall;
function ValueStringDataSet(pval: PSCITER_VALUE; Chars: LPCWSTR; NumChars: UINT; units: UINT): UINT; stdcall;

(*
    HTMLayout Section
*)

function HTMLayoutProcND (hwnd:HWND; msg:UINT; wParam:WPARAM;
                          lParam:LPARAM;  var pbHandled: Integer): Integer; stdcall;
function HTMLayoutLoadHtml(hwnd:HWND; html:PBYTE; htmlSize:UINT): Integer; stdcall;
function HTMLayoutLoadFile(hWndHTMLayout:HWND; filename:LPCWSTR):Integer; stdcall;

procedure HTMLayoutSetCallback(hWndHTMLayout:HWND; cb: THTMLAYOUT_NOTIFY; cbParam: Pointer); stdcall;

function HTMLayoutGetRootElement(hwnd: HWND; var phe: HELEMENT):LRESULT; stdcall;
function HTMLayoutGetChildrenCount(he: HELEMENT; var count: UINT):LRESULT; stdcall;
function HTMLayoutGetNthChild(he: HELEMENT; n: UINT; var phe: HELEMENT):LRESULT; stdcall;

function HTMLayoutGetElementText(he: HELEMENT; characters: LPWSTR; var length:UINT):LRESULT; stdcall;
function HTMLayoutGetElementHtml(he: HELEMENT; var utf8bytes: PBYTE; outer: integer):LRESULT; stdcall;
function HTMLayoutSetElementHtml(he: HELEMENT; html: PUtf8String; htmlLength: DWord; where:UINT): LRESULT; stdcall;
function HTMLayoutGetElementInnerText16(he: HELEMENT; var utf16words:LPWSTR):LRESULT; stdcall;
function HTMLayoutSetElementInnerText16(he: HELEMENT; utf16words: LPCWSTR; length: UINT):LRESULT; stdcall;

function HTMLayoutGetElementType(he: HELEMENT; var p_type: LPCSTR):LRESULT; stdcall;

function HTMLayoutDeleteElement(he: HELEMENT):LRESULT; stdcall;
function HTMLayoutCreateElement( tagname: LPCSTR;  textOrNull: LPCWSTR; var phe: HELEMENT):LRESULT; stdcall;
function HTMLayoutInsertElement(he: HELEMENT; hparent: HELEMENT; index: UINT ):LRESULT; stdcall;
function HTMLayoutDetachElement(he: HELEMENT):LRESULT; stdcall;
function HTMLayoutCloneElement(he: HELEMENT; var phe: HELEMENT ):LRESULT; stdcall;

function HTMLayoutMoveElement(he: HELEMENT; xView: INTeger; yView: INTeger):LRESULT; stdcall;

//*****************************************************************************************************

implementation

uses
  SysUtils;

const
  engineDLL = 'sciter-x.dll';

  function SciterClassNameA: LPCSTR; external engineDLL; stdcall;
  function SciterGetVM (handle: HWND): HVM; external engineDLL; stdcall;
  function SciterNativeDefineClass( hvm: HVM; pClassDef: PSciterNativeClassDef): integer; external engineDLL; stdcall;
  function SciterSetExceptionValue( hvm: HVM; errorMsg: LPCWSTR): Integer; external engineDLL; stdcall;
  function SciterVmEval( hvm: HVM; script: LPCWSTR; scriptLength:UINT; pretval: PSCITER_VALUE): integer; external engineDLL; stdcall;
  function SciterCreateObject(hvm: HVM; className: LPCWSTR; pretval: PSCITER_VALUE): integer;external engineDLL; stdcall;

(*
  Scite Section
*)
function SciterProcND(hwnd:HWND; msg:UINT; wParam:WPARAM;
                          lParam:LPARAM;  var pbHandled: Integer): LRESULT; external engineDLL; stdcall;
procedure SciterSetCallback(hWndSciter: HWND; cb: PSciterHostCallback;
                          cbParam: Pointer); external engineDLL; stdcall;

function SciterLoadHtml(hWndSciter:HWND; html:PBYTE; htmlSize:UINT;
                            baseUrl:LPCWSTR): Integer; external engineDLL; stdcall;
function SciterLoadFile(hWndSciter:HWND; filename:LPCWSTR):Integer; external engineDLL; stdcall;

function SciterEval( hwnd: HWND; script:LPCWSTR; scriptLength: UINT;
                      pretval: PSCITER_VALUE): Integer; external engineDLL; stdcall;
function SciterCall(hWnd: HWND; functionName: LPCSTR; argc: UINT;
                          argv: PSCITER_VALUE; retval: PSCITER_VALUE): Integer; external engineDLL; stdcall;

function ValueInit( pval: PSCITER_VALUE): UINT;  external engineDLL; stdcall;
function ValueStringData(pval: PSCITER_VALUE; var pChars: LPCWSTR; var pNumChars: UINT): UINT;  external engineDLL; stdcall;
function ValueStringDataSet(pval: PSCITER_VALUE; Chars: LPCWSTR; NumChars: UINT; units: UINT): UINT;  external engineDLL; stdcall;

(*
  HTMLLayout Section
*)

function HTMLayoutProcND (hwnd:HWND; msg:UINT; wParam:WPARAM;
                          lParam:LPARAM;  var pbHandled: Integer): Integer; external engineDLL; stdcall;

function HTMLayoutLoadHtml(hwnd:HWND; html:PBYTE; htmlSize:UINT): Integer; external engineDLL; stdcall;
function HTMLayoutLoadFile(hWndHTMLayout:HWND; filename:LPCWSTR):Integer;  external engineDLL; stdcall;

procedure HTMLayoutSetCallback(hWndHTMLayout:HWND; cb: THTMLAYOUT_NOTIFY; cbParam: Pointer); external engineDLL; stdcall;

function HTMLayoutGetRootElement(hwnd: HWND; var phe: HELEMENT): LRESULT;  external engineDLL; stdcall;
function HTMLayoutGetChildrenCount(he: HELEMENT; var count: UINT):LRESULT;  external engineDLL; stdcall;
function HTMLayoutGetNthChild(he: HELEMENT; n: UINT; var phe: HELEMENT):LRESULT;  external engineDLL; stdcall;

function HTMLayoutGetElementText(he: HELEMENT; characters: LPWSTR; var length:UINT): LRESULT;  external engineDLL; stdcall;
function HTMLayoutSetElementHtml(he: HELEMENT; html: PUTF8String; htmlLength: DWord; where:UINT): LRESULT;  external engineDLL; stdcall;
function HTMLayoutGetElementHtml(he: HELEMENT; var utf8bytes: PBYTE; outer: integer):LRESULT; external engineDLL; stdcall;
function HTMLayoutGetElementInnerText16(he: HELEMENT; var utf16words:LPWSTR): LRESULT;  external engineDLL; stdcall;
function HTMLayoutSetElementInnerText16(he: HELEMENT; utf16words: LPCWSTR; length: UINT): LRESULT;  external engineDLL; stdcall;

function HTMLayoutGetElementType(he: HELEMENT; var p_type: LPCSTR): LRESULT;  external engineDLL; stdcall;

function HTMLayoutDeleteElement(he: HELEMENT): LRESULT;  external engineDLL; stdcall;
function HTMLayoutCreateElement( tagname: LPCSTR;  textOrNull: LPCWSTR; var phe: HELEMENT): LRESULT;  external engineDLL; stdcall;
function HTMLayoutInsertElement(he: HELEMENT; hparent: HELEMENT; index: UINT): LRESULT;  external engineDLL; stdcall;
function HTMLayoutDetachElement(he: HELEMENT): LRESULT;  external engineDLL; stdcall;
function HTMLayoutCloneElement(he: HELEMENT; var phe: HELEMENT ): LRESULT;  external engineDLL; stdcall;

function HTMLayoutMoveElement(he: HELEMENT; xView: INTeger; yView: INTeger): LRESULT;  external engineDLL; stdcall;

{ TEventHandle }
const
      HANDLE_INITIALIZATION = $0000;      // attached/detached
      HANDLE_MOUSE          = $0001;      //  mouse events
      HANDLE_KEY            = $0002;      //  key events
      HANDLE_FOCUS          = $0004;      //  focus events, if this flag is set it also means that element it attached to is focusable
      HANDLE_SCROLL         = $0008;      //  scroll events
      HANDLE_TIMER          = $0010;      //  timer event
      HANDLE_SIZE           = $0020;      //  size changed event
      HANDLE_DRAW           = $0040;      //  drawing request (event)
      HANDLE_DATA_ARRIVED   = $0080;      //  requested data () has been delivered
      HANDLE_BEHAVIOR_EVENT = $0100;      (*  secondary, synthetic events:
                                              BUTTON_CLICK, HYPERLINK_CLICK, etc.,
                                              a.k.a. notifications from intrinsic behaviors *)
      HANDLE_METHOD_CALL    = $0200;      //  behavior specific methods

      HANDLE_ALL            = $03FF;      //  all of them

      DISABLE_INITIALIZATION = $80000000; (*  disable INITIALIZATION events to be sent.
                                              normally engine sends
                                              BEHAVIOR_DETACH / BEHAVIOR_ATTACH events unconditionally,
                                              this flag allows to disable this behavior
                                            *)

    BEHAVIOR_DETACH = 0;
    BEHAVIOR_ATTACH = 1;

type
   INITIALIZATION_PARAMS = packed record
      cmd: UINT;          // INITIALIZATION_EVENTS
   end;
   PINITIALIZATION_PARAMS = ^INITIALIZATION_PARAMS;

  MOUSE_PARAMS = packed record
      cmd: UINT;          // MOUSE_EVENTS
      target: HELEMENT;       // target element
      pos: TPOINT;          // position of cursor, element relative
      pos_document: TPOINT; // position of cursor, document root relative
      button_state: UINT; // MOUSE_BUTTONS or MOUSE_WHEEL_DELTA
      alt_state: UINT;    // KEYBOARD_STATES
      cursor_type: UINT;  // CURSOR_TYPE to set, see CURSOR_TYPE
      is_on_icon: Integer;   // mouse is over icon (foreground-image, foreground-repeat:no-repeat)

      dragging: HELEMENT;     // element that is being dragged over, this field is not NULL if (cmd & DRAGGING) != 0
      dragging_mode: UINT;// see DRAGGING_TYPE.
  end;
  PMOUSE_PARAMS = ^MOUSE_PARAMS;

  KEY_PARAMS = packed record
      cmd: UINT;          // KEY_EVENTS
      target: HELEMENT;       // target element
      key_code: UINT;     // key scan code, or character unicode for KEY_CHAR
      alt_state: UINT;    // KEYBOARD_STATES
  end;
  PKEY_PARAMS = ^KEY_PARAMS;

  FOCUS_PARAMS = packed record
      cmd: UINT;            // FOCUS_EVENTS
      target: HELEMENT;         // target element, for FOCUS_LOST it is a handle of new focus element
                      // and for FOCUS_GOT it is a handle of old focus element, can be NULL
      by_mouse_click: Integer; // TRUE if focus is being set by mouse click
      cancel: Integer;         // in FOCUS_LOST phase setting this field to TRUE will cancel transfer focus from old element to the new one.
 end;
  PFOCUS_PARAMS = ^FOCUS_PARAMS;

  DRAW_PARAMS = packed record
      cmd: UINT;          // DRAW_EVENTS
      hdc: HDC;          // hdc to paint on
      area: TRECT;         // element area to paint,
      reserved: UINT;     //   for DRAW_BACKGROUND/DRAW_FOREGROUND - it is a border box
                    //   for DRAW_CONTENT - it is a content box
  end;
  PDRAW_PARAMS = ^DRAW_PARAMS;

  TIMER_PARAMS = packed record
      timerId: PUINT;
  end;
  PTIMER_PARAMS = ^TIMER_PARAMS;

  BEHAVIOR_EVENT_PARAMS = packed record
      cmd: UINT;        // BEHAVIOR_EVENTS
      heTarget: HELEMENT;   // target element handler
      he: HELEMENT;         // source element e.g. in SELECTION_CHANGED it is new selected <option>, in MENU_ITEM_CLICK it is menu item (LI) element
      reason: UINT;     // EVENT_REASON or EDIT_CHANGED_REASON - UI action causing change.
                  // In case of custom event notifications this may be any
                  // application specific value.

//      data: JSON_VALUE;       // auxiliary data accompanied with the event. E.g. FORM_SUBMIT event is using this field to pass collection of values.
  end;
  PBEHAVIOR_EVENT_PARAMS = ^BEHAVIOR_EVENT_PARAMS;

  METHOD_PARAMS = packed record
    methodID: UINT;
  end;
  PMETHOD_PARAMS = ^METHOD_PARAMS;

  DATA_ARRIVED_PARAMS = packed record
  end;
  PDATA_ARRIVED_PARAMS = ^DATA_ARRIVED_PARAMS;

  SCROLL_PARAMS = packed record
      cmd: UINT;          // SCROLL_EVENTS
      target: HELEMENT;       // target element
      pos: integer;          // scroll position if SCROLL_POS
      vertical: integer;     // TRUE if from vertical scrollbar
  end;
  PSCROLL_PARAMS = ^SCROLL_PARAMS;

class function TEventHandle.ElementProc (pthis: TEventHandle; he: HELEMENT; evtg:UINT; prms: Pointer): Integer;
//var
//  p: PINITIALIZATION_PARAMS;
//  pm: PMOUSE_PARAMS;
//  pk: PKEY_PARAMS;
//  pf: PFOCUS_PARAMS;
//  pd: PDRAW_PARAMS;
//  pt: PTIMER_PARAMS;
//  pb: PBEHAVIOR_EVENT_PARAMS;
//  pc: PMETHOD_PARAMS;
//  pr: PDATA_ARRIVED_PARAMS;
//  ps: PSCROLL_PARAMS;
//
begin
//      if Assigned (pthis) then
//      begin
//        case evtg of
//          HANDLE_INITIALIZATION:
//          begin
//              p := PINITIALIZATION_PARAMS (prms);
//              if p^.cmd = BEHAVIOR_DETACH then
//              begin
//                pthis.detached(he);
//              end
//              else if p^.cmd = BEHAVIOR_ATTACH then
//              begin
//                   pthis.attached(he)
//              end;
//              Result := TRUE;
//              exit;
//           end;
//
//          HANDLE_MOUSE:
//          begin
//              pm := PMOUSE_PARAMS (prms);
//              Result := pThis^.handle_mouse( he, pm );
//              exit;
//          end;
//
//          HANDLE_KEY:
//          begin
//              pk := PKEY_PARAMS(prms);
//              result := pThis->handle_key( he, *p );
//              exit;
//          end;
//
//          HANDLE_FOCUS:
//          begin
//              pf := PFOCUS_PARAMS (prms);
//              result := pThis->handle_focus( he, *p );
//              exit;
//          end;
//
//          HANDLE_DRAW:
//          begin
//              pd := PDRAW_PARAMS (prms);
//              result := pThis->handle_draw(he, *p);
//              exit;
//          end;
//
//          HANDLE_TIMER:
//          begin
//              pt := PTIMER_PARAMS (prms);
//              result := pThis->handle_timer(he, *p);
//              exit;
//          end;
//
//          HANDLE_BEHAVIOR_EVENT:
//          begin
//              pb := PBEHAVIOR_EVENT_PARAMS (prms);
//              result := pThis->handle_event(he, *p );
//              exit;
//          end;
//
//          HANDLE_METHOD_CALL:
//          begin
//              pc := PMETHOD_PARAMS (prms);
//              if(pc->methodID == XCALL)
//              begin
//                xp := PXCALL_PARAMS (pc);
//                result := pThis->handle_script_call(he,*xp);
//                exit;
//              end
//              else
//              begin
//                result := pThis->handle_method_call(he, *p );
//                exit;
//              end;
//          end;
//
//          HANDLE_DATA_ARRIVED:
//          begin
//              pr := PDATA_ARRIVED_PARAMS (prms);
//              result := pThis->handle_data_arrived(he, *p );
//              exit;
//          end;
//
//          HANDLE_SIZE:
//          begin
//              pThis->handle_size(he);
//              result := FALSE;
//              exit;
//          end;
//
//          HANDLE_SCROLL:
//          begin
//              ps := PSCROLL_PARAMS (prms);
//              result := pThis->handle_scroll(he, *p );
//              exit;
//          end;
//
//          else
//          begin
//            Result := False;
//            exit;
//          end;
//        end;
      Result := 0;
//    end;
end;

{ Notify Callback function }

const
  RT_HTML = MAKEINTRESOURCE (23);
  LOAD_OK = 0;
  LOAD_DISCARD = 1; // discard request completely
  LOAD_DELAYED = 2; // data will be delivered later by the host

type
  PSCN_LOAD_DATA = ^SCN_LOAD_DATA ;
  SCN_LOAD_DATA = record
    cbhead: SCITER_CALLBACK_NOTIFICATION;
    uri: LPCWSTR;              //*< [in] Zero terminated string, fully qualified uri, for example "http://server/folder/file.ext".*/

    outData: PBYTE;          //*< [in,out] pointer to loaded data to return. if data exists in the cache then this field contain pointer to it*/
    outDataSize: UINT;      //*< [in,out] loaded data size to return.*/
    dataType: UINT;         //*< [in] SciterResourceType */

    requestId: Pointer;        //*< [in] request id that needs to be passed as is to the SciterDataReadyAsync call */

    principal: HELEMENT;
    initiator: HELEMENT;
end;

var
  protocol: WideString = 'app:';

function OnLoadData (pns: PSCN_LOAD_DATA): UINT;
var
  url, ps: WideString;
  uri: WideString;
  ext: WideString;
  resName: WideString;
  extdeliPos: integer;
begin
    url := pns.uri;
    ps := Copy (url, 1, 4);
    uri := Copy (url, 5, length (url));
    extdeliPos := Pos ('.', uri);
    resName := Copy (uri, 1, extdeliPos - 1);
    ext := UpperCase(Copy (uri, extdeliPos + 1, length (uri)));

    if ps = protocol then // we are using basic:name.ext schema to refer to resources contained in this exe.
    begin
      if (ext = 'HTML') or (ext = 'HTM') then
      begin
//        pns.outData := GetResourceAsPointer (PWideChar(resName), RT_HTML, pns.outDataSize);
      end
      else
        ;
//        pns.outData := GetResourceAsPointer (PWideChar(resName), PWideChar(ext), pns.outDataSize);

      if pns.outDataSize <> 0 then
        result := LOAD_OK
      else
        result := LOAD_DISCARD;

      exit;
    end;

    result := LOAD_OK; // proceed with the default loader.
end;

function BasicHostCallback(pns: Pointer; callbackParam: Pointer): UINT; stdcall;
var
  p: PSCN_LOAD_DATA;
begin
  p := pns;
  case p.cbhead.code of
    SC_LOAD_DATA:
      begin
        result := OnLoadData (p);
        exit;
      end;
    //case SC_DATA_LOADED: return OnDataLoad(LPSCN_DATA_LOADED(pns));
    //...
//    SC_CALLBACK_HOST: Result := OnCallbackHost(LPSCN_CALLBACK_HOST(pns));
  end;
  Result := 0;
end;

end.

