unit App;

interface
  type THandle = word;

  procedure startApplication;
  procedure endApplication;

  function getApplicationWorkspace: THandle;
  function getSizeX: word;
  function getSizeY: word;

  procedure line(const x1, y1, x2, y2: word);
  procedure rectangle(const x1, y1, x2, y2: word);
  procedure fillRectangle(const x1, y1, x2, y2, pattern, color: word); 
  procedure window(const x1, y1, x2, y2: word);

  procedure putText(const x, y: word; text: string);

implementation

uses aes, vdi, cassert;

var applicationWorkspace: THandle;
    sizeX, sizeY        : word;
    offsetX, offsetY    : word;

function openVirtualDesktop: THandle;
var 
  workSpaceInputSpefication: array[0..16] of SmallInt;
  workSpaceInformation: array[0..64] of SmallInt;
  workSpaceHandle: THandle;
  i: Integer;
begin
    FillChar(workSpaceInputSpefication, SizeOf(workSpaceInputSpefication), 0);
    (* Take all the defaults, see 
        https://tho-otto.de/hypview/hypview.cgi?url=%2Fhyp%2Ftos.hyp&charset=UTF-8&index=1678 
    *)
    for i:=0 to 9 do
        workSpaceInputSpefication[i] := 1;
    workSpaceInputSpefication[10] := 2; (* RCS Coordinate System ... there is only this option *)

    v_opnvwk(@workSpaceInputSpefication,@workSpaceHandle, @workSpaceInformation);

    sizeX := workSpaceInformation[0];
    sizeY := workSpaceInformation[1];
    offsetX := 0;
    offsetY := 0;

    openVirtualDesktop := workSpaceHandle;
end;


procedure startApplication;
begin
  appl_init;
  applicationWorkspace := openVirtualDesktop;
end;

procedure endApplication;
begin
  v_clsvwk(applicationWorkspace);
  appl_exit;
end;

function getApplicationWorkspace: THandle;
begin
  getApplicationWorkspace := applicationWorkspace;
end;

function getSizeX: word;
begin
    getSizeX := sizeX;
end;

function getSizeY: word;
begin
    getSizeY := sizeY;
end;

procedure line(const x1, y1, x2, y2: word);
var points : array[0..3] of SmallInt;
begin
    points[0] := x1 + offsetX;
    points[1] := y1 + offsetY;
    points[2] := x2 + offsetX;
    points[3] := y2 + offsetY;

    v_pline(applicationWorkspace, 2, @points);
end;


procedure rectangle(const x1, y1, x2, y2: word);
var points : array[0..7] of SmallInt;
begin
    points[0] := x1 + offsetX;
    points[1] := y1 + offsetY;
    points[2] := x2 + offsetX;
    points[3] := y1 + offsetY;
    points[4] := x2 + offsetX;
    points[5] := y2 + offsetY;
    points[6] := x1 + offsetX;
    points[7] := y2 + offsetY;

    v_pline(applicationWorkspace, 4, @points);
end;

procedure fillRectangle(const x1, y1, x2, y2, pattern, color: word); 
var points : array[0..4] of SmallInt;
begin
    points[0] := x1 + offsetX;
    points[1] := y1 + offsetY;
    points[2] := x2 + offsetX;
    points[3] := y2 + offsetY;

    vsf_interior(applicationWorkspace, (pattern shr 8) and $ff);
    vsf_style(applicationWorkspace, pattern and $ff);
    vsf_color(applicationWorkspace, color);
    
    v_bar(applicationWorkspace, @points);
end;

procedure window(const x1, y1, x2, y2: word); 
var points : array[0..3] of SmallInt;
begin
    points[0] := x1;
    points[1] := y1;
    points[2] := x2;
    points[3] := y2;

    offsetX := x1;
    offsetY := y1;

    sizeX := x2 - x1 + 1;
    sizeY := y2 - y1 + 1;

    vs_clip(applicationWorkspace,1, @points);
end;

procedure putText(const x, y: word; text: string);
begin
  text:= text + #0; // Ensure null-termination
  v_gtext(applicationWorkspace, x + offsetX, y + offsetY+10, PChar(@text[1]));
end;

begin
end.