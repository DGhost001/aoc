program day12;
(*This is the implementation of the aoc24 day 12*)

uses aoc,utils,progressbar, cassert;

const InputFileName = 'INP\DAY12_IN.TXT';
      MapSize       = 140;

type  TMap = array[0..MapSize,0..MapSize] of byte;
      TSegmentId  = word;
      TSegmentMap = array[0..MapSize,0..MapSize] of TSegmentId;
      TSegment = record
         min,max : TPos;
         edges   : word;
         area    : word;
         border  : word;
         used    : boolean;
      end;
      PSegmentList = ^TSegmentList;
      TSegmentList = array[1..640] of TSegment;

function edgeCount(const segmentMap : TSegmentMap;
                   const segmentId  : TSegmentId;
                   const pos        : TPos;
                   const max        : TPos) : byte;
var a,b,c,d : boolean;
begin
  edgeCount := 0;

  a := (pos.x >= 0) and (pos.y >= 0) and (segmentMap[pos.x,pos.y] = segmentId);
  b := (pos.x < max.x) and (pos.y >= 0) and (segmentMap[pos.x + 1,pos.y] = segmentId);
  c := (pos.x >= 0) and (pos.y < max.y) and (segmentMap[pos.x,pos.y + 1] = segmentId);
  d := (pos.y < max.y) and (pos.x < max.x) and (segmentMap[pos.x + 1,pos.y + 1] = segmentId);

     (*--------------Outer Corners--------------------*)
  if ((not a) and (not b) and (not c) and ( d )) or
     ((not a) and (not b) and ( c ) and (not d )) or
     ((not a) and ( b ) and (not c) and (not d )) or
     (( a ) and ( not b ) and (not c) and (not d )) or
     (*--------------Inner Corners--------------------*)
     (( a ) and ( b ) and ( c) and (not d )) or
     (( a ) and ( b ) and (not c) and ( d )) or
     (( a ) and (not b ) and ( c) and ( d )) or
     ((not a ) and ( b ) and ( c) and ( d )) then
      edgeCount := 1
     (*--------------Cross Edges----------------------*)
  else if (( a ) and (not b ) and (not c) and ( d )) or
          ((not a ) and ( b ) and ( c) and (not d )) then
          edgeCount := 2;
end;

procedure buildSegmentMap(const input : TMap;
                          var   output: TSegmentMap;
                          var segmentList : TSegmentList;
                          const max   : TPos);

  function getFreeSegment : TSegmentId;
  var i : TSegmentId;
  begin
    for i := 1 to HIGH(segmentList) do
      if not segmentList[i].used then begin
        getFreeSegment := i;
        break;
      end;
    assert(not segmentList[i].used, 'Not enougth segments avilable');
    segmentList[i].used := True;
    segmentList[i].min.x := 65535;
    segmentList[i].min.y := 65535;
  end;

  procedure mergeSegments(const id1, id2 : TSegmentId; const maxY : integer);
  var x,y    : integer;
      change : boolean;
  begin
    for y:= maxY downto 0 do begin
     change := False;
     for x := 0 to max.x do
      if output[x,y] = id2 then begin
        output[x,y] := id1;
        change := True;
      end;
     if not change then break;
    end;

    segmentList[id2].used := false;
  end;
var x,y : integer;
    p : TProgressBar;
begin
  fillchar(segmentList,sizeof(segmentList),0);
  fillchar(output,sizeof(output),0);
  p.init((max.x+1) * (max.y+1),'Segment');
  for y:=0 to max.y do
   for x:=0 to max.x do begin
     if (x > 0) and (input[x-1,y] = input[x,y]) then
       output[x,y] := output[x-1,y];
     if (y > 0) and (input[x,y-1] = input[x,y]) then begin
       if output[x,y] = 0 then output[x,y] := output[x,y-1]
       else if output[x,y-1] <> output[x,y] then begin
         mergeSegments(output[x,y-1], output[x,y],y);
       end;
     end;
     if output[x,y] = 0 then output[x,y] := getFreeSegment;
     p.step(1);
   end;
  p.done;
end;

procedure scanForSegmentEdges(const segmentMap: TSegmentMap;
                              var segments     : TSegmentList;
                              const max        : TPos);
var pos : TPos;
    p   : TProgressBar;
    id  : TSegmentId;
begin
  p.init(HIGH(segments),'Edges');
  for id := 1 to HIGH(segments) do begin
    if segments[id].used then
      for pos.y:= segments[id].min.y-1 to segments[id].max.y do
        for pos.x:= segments[id].min.x-1 to segments[id].max.x do begin
         inc(segments[id].edges, edgeCount(segmentMap,id, pos, max));
        end;
    p.step(1);
   end;
   p.done;
end;


procedure genStatistics(const segmentMap : TSegmentMap;
                        var segments     : TSegmentList;
                        const max        : TPos);
var x,y : Integer;
    p   : TProgressBar;
    id  : TSegmentId;
begin
  p.init((max.x+1)*(max.y+1),'Count');
  for y:= 0 to max.y do
   for x:= 0 to max.x do begin
     id := segmentMap[x,y];

     assert(segments[id].used,'Found unused segment');

     inc(segments[id].area);
     if segments[id].max.x < x then segments[id].max.x := x;
     if segments[id].max.y < y then segments[id].max.y := y;
     if segments[id].min.x > x then segments[id].min.x := x;
     if segments[id].min.y > y then segments[id].min.y := y;

     if (x = 0) or (segmentMap[x - 1, y] <> id) then inc(segments[id].border);
     if (y = 0) or (segmentMap[x ,y - 1] <> id) then inc(segments[id].border);

     if (x = max.x) or (segmentMap[x + 1, y] <> id) then inc(segments[id].border);
     if (y = max.y) or (segmentMap[x ,y + 1] <> id) then inc(segments[id].border);

     p.step(1);
   end;
   p.done;
end;

var map        : TMap;
    segmentMap : TSegmentMap;
    segments : PSegmentList;

function part1(var input: Text):comp; far;
var mx,my : word;
    max   : TPos;
    sum   : comp;
    tmp   : comp;
      i   : integer;
begin
  mx := MapSize + 1;
  my := MapSize + 1;
  loadCharMap(input, map, mx, my);
  max.x := mx - 1;
  max.y := my - 1;
  buildSegmentMap(map, segmentMap, segments^, max);
  genStatistics(segmentMap, segments^, max);
  sum := 0;

  for i:= 1 to HIGH(segments^) do begin
    if segments^[i].used then begin
      tmp := segments^[i].area;
      sum := sum + tmp*segments^[i].border;
    end;
  end;

  part1 := sum;
end;

function part2(var input: Text):comp; far;
var mx,my : word;
    max   : TPos;
    sum   : comp;
    tmp   : comp;
      i   : integer;
begin
  mx := MapSize + 1;
  my := MapSize + 1;
  loadCharMap(input, map, mx, my);
  max.x := mx - 1;
  max.y := my - 1;
  buildSegmentMap(map, segmentMap, segments^, max);
  genStatistics(segmentMap, segments^, max);
  scanForSegmentEdges(segmentMap, segments^, max);
  sum := 0;

  for i:= 1 to HIGH(segments^) do begin
    if segments^[i].used then begin
      tmp := segments^[i].area;
      sum := sum + tmp*segments^[i].edges;
    end;
  end;

  part2 := sum;

end;

begin
  segments := new(PSegmentList);
  runAoc(InputFileName, 12, part1, part2);
  dispose(segments);
end.
