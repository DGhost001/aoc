program day16;
uses graph,crt,progressbar;
const InputFile = 'INP\DAY16_IN.TXT';
type TDirection    = (Up, Down, Left, Right);
     TOpticalItems = (None, MirrorDown, MirrorUp, SplitterDownUp, SplitterLeftRight);
     TOccupancy = set of TDirection;
     TPosition  = record
        x,y : byte;
     end;
     TLightBeam = record
        position : TPosition;
        direction: TDirection;
     end;
     TMap = record
        xdim, ydim : byte;
        optical    : array[1..128, 1..128] of TOpticalItems;
        occupancy  : array[1..128, 1..128] of TOccupancy;
     end;

procedure loadMap( var input : Text; var map : TMap);
var line : string;
       x : byte;
begin
 with map do begin
   ydim := 0;
   xdim := 0;
   while not eof(input) do begin
     readln(input, line);
     if xdim = 0 then xdim := length(line);
     if length(line) <> xdim then break;
     inc(ydim);
     for x:= 1 to xdim do begin
       case line[x] of
         '.': optical[x,ydim] := None;
         '\': optical[x,ydim] := MirrorDown;
         '/': optical[x,ydim] := MirrorUp;
         '-': optical[x,ydim] := SplitterLeftRight;
         '|': optical[x,ydim] := SplitterDownUp;
       else RunError(300); (* Invalid input data *)
       end;
       occupancy[x,ydim] := [];
     end;
   end;
 end;
end;

procedure drawRay(const beam : TLightBeam);
var x,y : word;
begin
 x:= beam.position.x * 4;
 y:= beam.position.y * 4;
(*
 case beam.direction of
    Left:  setFillStyle(SolidFill, Red);
    Right: setFillStyle(SolidFill, LightRed);
    Up:    setFillStyle(SolidFill, Green);
    Down:  setFillStyle(SolidFill, LightGreen);
 end;
 *)
 case getPixel(x+2,y+2) of
      Black : setFillStyle(SolidFill, Green);
      Green : setFillStyle(SolidFill, LightGreen);
      LightGreen: setFillStyle(SolidFill, Yellow);
      Yellow: setFillStyle(SolidFill, White);
      else setFillStyle(SolidFill, Red);
 end;
 bar(x,y,x+4,y+4);
 if keypressed then halt(1);
end;

function advanceRay(var beam : TLightBeam; const xdim, ydim : byte) : boolean;
var result : boolean;
begin
 with beam do begin
   case direction of
     Up:   begin
             result := position.y > 1;
             if result then dec(position.y);
           end;
     Down: begin
             result := position.y < ydim;
             if result then inc(position.y);
           end;
     Left: begin
             result := position.x > 1;
             if result then dec(position.x);
           end;
     Right:begin
             result := position.x < xdim;
             if result then inc(position.x);
           end;
   end;
 end;
 advanceRay := result;
end;

procedure traceBeam(beam : TLightBeam; var map: TMap);
var run : boolean;
begin
  run := true;
  with map do with beam do while run do
  if not (direction in occupancy[position.x, position.y]) then
  begin
    occupancy[position.x, position.y] :=
        occupancy[position.x,position.y] + [direction];
    case optical[position.x,position.y] of
      None:       run := advanceRay(beam, xdim, ydim);
      MirrorDown: begin  (*  \  *)
                    case direction of
                      Up:    direction:= Left;
                      Down:  direction:= Right;
                      Left:  direction:= Up;
                      Right: direction:= Down;
                    end;
                    run := advanceRay(beam, xdim, ydim);
                  end;
      MirrorUp:   begin  (*  /  *)
                    case direction of
                      Up:    direction:= Right;
                      Down:  direction:= Left;
                      Left:  direction:= Down;
                      Right: direction:= Up;
                    end;
                    run := advanceRay(beam, xdim, ydim);
                  end;
      SplitterLeftRight: begin  (*  -  *)
                           if direction in [Up, Down] then begin
                             direction := Left;
                             traceBeam(beam, map);
                             direction := Right;
                             traceBeam(beam,map);
                             run := false;
                           end else
                             run := advanceRay(beam, xdim, ydim);
                         end;
      SplitterDownUp: begin  (*  |  *)
                           if direction in [Left, Right] then begin
                             direction := Up;
                             traceBeam(beam, map);
                             direction := Down;
                             traceBeam(beam,map);
                             run := false;
                           end else
                             run := advanceRay(beam, xdim, ydim);
                         end;

    end;
  end else run := false;
end;

function countEnergized(const map: TMap):longint;
var  sum : longint;
     x,y : byte;
begin
  sum := 0;
  for y:= 1 to map.ydim do
   for x:= 1 to map.xdim do
    if map.occupancy[x,y] <> [] then inc(sum);

  countEnergized:= sum;
end;

procedure resetOccupancy(var map: TMap);
var  x,y : byte;
begin
  for y:= 1 to map.ydim do
   for x:= 1 to map.xdim do
     map.occupancy[x,y] := [];
end;

function part1(var map: TMap):longint;
var beam : TLightBeam;
begin
  beam.position.x :=1;
  beam.position.y :=1;
  beam.direction := Right;

  resetOccupancy(map);
  traceBeam(beam, map);

  part1 := countEnergized(map);
end;

function runBeam(var beam: TLightBeam; var map:TMap):longint;
begin
  resetOccupancy(map);
  traceBeam(beam, map);

  runBeam := countEnergized(map);
end;

function part2(var map: TMap): longint;
var  m1, m2, m3, m4, max: longint;
       i: byte;
    beam: TLightBeam;
    p   : TProgressBar;
begin
  if map.xdim <> map.ydim then runError(300);
  max := 0;
  p.init(map.xdim, 'Tracing...');
  for i:= 1 to map.xdim do begin
    p.step(1);
    beam.position.x:=1;   beam.position.y:=i;    beam.direction:=Right;
    m1 := runBeam(beam,map);
    beam.position.x:=i;   beam.position.y:=1;    beam.direction:=Down;
    m2 := runBeam(beam,map);
    beam.position.x:=map.xdim;beam.position.y:=i;beam.direction:=Left;
    m3 := runBeam(beam,map);
    beam.position.x:=i;   beam.position.y:=map.ydim; beam.direction:=Up;
    m4 := runBeam(beam,map);
    if m1 > max then max := m1;
    if m2 > max then max := m2;
    if m3 > max then max := m3;
    if m4 > max then max := m4;
  end;
  p.done;
  part2 := max;
end;

var map   : TMap;
    input : Text;
    p1    : longint;
    p2    : longint;
begin
  assign(input, InputFile);
  reset(input);
  loadMap(input, map);
  close(input);
  p1 := part1(map);
  p2 := part2(map);

  writeln('Part 1 Answer is: ',p1);
  writeln('Part 2 Answer is: ',p2);
end.