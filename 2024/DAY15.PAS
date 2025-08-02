program day15;
(*This is the implementation of the aoc24 day 15*)

uses aoc, utils, progressbar, cassert (*graph*);
const InputFileName = 'INP\DAY15_IN.TXT';
      Box       : char = 'O';
      BLeft     : char = '[';
      BRight    : char = ']';
      Wall      : char = '#';
      FreeSpace : char = '.';
      Robot     : char = '@';
      TopLeft   : TPos = (x:0; y:0);
      MapSize   = 100;

type  TMap  = array[0..MapSize - 1,0..MapSize - 1] of char;
      TSteps= array[0..19999] of TDirection;

function moveBox(const pos     : TPos;
                 const dir     : TDirection;
                 const min,max : TPos;
                 var   map     : TMap): boolean;
var next : TPos;
begin
  moveBox := false;
  next := pos;
  if advancePos(next, dir, min, max) then begin
    case map[next.x,next.y] of
      '#', '@' : moveBox := false; (* No way ... *)
      '.'      : begin
                   moveBox := true;
                   map[next.x, next.y] := 'O';
                   map[pos.x, pos.y] := '.';
                 end;
      'O'      : begin
                   if moveBox(next,dir,min,max,map) then begin
                     moveBox := true;
                     map[next.x, next.y] := 'O';
                     map[pos.x, pos.y] := '.';
                    end else
                     moveBox := false;
                 end;
    end;
  end;
end;

function moveBigBox(pos     : TPos;
                    const dir     : TDirection;
                    const min,max : TPos;
                    var   map     : TMap;
                    const dryRun  : boolean
                    ): boolean;
var  pos1  : TPos;
     n1,n2 : TPos;
     result: boolean;
begin
  if map[pos.x,pos.y] = ']' then dec(pos.x);
  pos1 := pos;
  inc(pos1.x);

  result := false;
  n1 := pos;
  n2 := pos1;

  if advancePos(n1, dir, min, max) and advancePos(n2, dir, min, max) then begin
    if (((map[n1.x, n1.y] = '.') or ( dir = East )) and
        ((map[n2.x, n2.y] = '.') or ( dir = West )))
     then
      result := true
    else if ( map[n1.x, n1.y] = '#' ) or (map[n2.x, n2.y] = '#') then
      result := false
    else begin
      if (map[n1.x, n2.y] = '[') and (map[n2.x, n2.y] = ']') and ((dir = South) or (dir = North)) then
        result := moveBigBox(n1, dir, min, max, map, dryRun) else
      if (map[n1.x, n2.y] = ']') and (map[n2.x, n2.y] = '[') and (dir = West) then
        result := moveBigBox(n1,dir,min,max,map, dryRun) else
      if (map[n1.x, n2.y] = ']') and (map[n2.x, n2.y] = '[') and (dir = East) then
        result := moveBigBox(n2,dir,min,max,map, dryRun) else
      if (map[n1.x, n2.y] = ']') and (map[n2.x, n2.y] = '[') then
        result := moveBigBox(n1,dir,min,max,map, dryRun) and moveBigBox(n2, dir, min, max, map, dryRun) else
      if (map[n1.x, n2.y] = ']') and (map[n2.x, n2.y] = '.') then
        result := moveBigBox(n1,dir,min,max,map, dryRun)
      else
      if (map[n1.x, n2.y] = '.') and (map[n2.x, n2.y] = '[') then
        result := moveBigBox(n2,dir,min,max,map, dryRun)
      else assert(false , 'There is a missing case ...');
    end;
  end;

  if (result) and (not dryRun) then begin
    map[pos.x, pos.y]   := '.';
    map[pos1.x, pos1.y] := '.';
    map[n1.x, n1.y] := '[';
    map[n2.x, n2.y] := ']';
  end;

  moveBigBox := result;
end;
(*
procedure ShowMap(const map : TMap; const max : TPos);
var x,y : word;
    a,b : integer;
begin
  for y := 0 to max.y do
   for x := 0 to max.x do begin
     case map[x,y] of
       '.': setFillStyle(SolidFill, Black);
       'O': setFillStyle(SolidFill, Brown);
       '[': setFillStyle(SolidFill, Brown);
       ']': setFillStyle(SolidFill, Brown);
       '@': setFillStyle(SolidFill, LightGreen);
       '#': setFillStyle(SolidFill, White);
     end;
     bar(x*6,y*6,x*6+5,y*6+5);
   end;
end;
*)

procedure saveMap(var f:Text; const map:TMap; const max:TPos);
var x,y : word;
begin
  for y := 0 to max.y do begin
    for x := 0 to max.x do begin
      write(f,map[x,y]);
    end;
    writeln(f);
  end;
end;

procedure runRobot( const steps    : TSteps;
                    const count    : word;
                    const min, max : TPos;
                    var   map      : TMap);
var      index : word;
            p : TProgressBar;
    pos, next : TPos;
    a,b : integer;
    debug : Text;
begin
  {assign(debug,'debug.txt');
  rewrite(debug);}

  p.init(count,'Robot');
  findFirstInMap(map, Robot, max, MapSize, pos);

  for index := 0 to count - 1 do begin
    map[pos.x,pos.y] := FreeSpace;
    next := pos;
    if advancePos(next,steps[index], min, max) then begin
      case map[next.x,next.y] of
        '.'    : pos := next;
        'O'    : if moveBox(next, steps[index], min, max, map) then pos:= next;
        ']','[': if moveBigBox(next, steps[index], min, max, map, true) then begin
                   moveBigBox(next, steps[index], min, max, map, false);
                   pos:= next;
                 end;
      end;
    end;
    map[pos.x,pos.y] := Robot;
    {saveMap(debug,map,max);}
    p.step(1);
  end;
  {close(debug);}
  p.done;
end;

function parseDirections(var input : Text;
                         var steps : TSteps) : word;
var result : word;
         c : char;
begin
  result := 0;
  while not eof(input) do begin
    read(input,c);
    case c of
       '^': begin steps[result] := North; inc(result); end;
       'v': begin steps[result] := South; inc(result); end;
       '>': begin steps[result] := East;  inc(result); end;
       '<': begin steps[result] := West;  inc(result); end;
    end;
  end;

  parseDirections := result;
end;

var map  : TMap;
    steps: TSteps;

function part1(var input: Text):comp; far;
var max   : TPos;
    mx,my : word;
    scount: word;
    sum   : comp;
begin
  sum := 0;
  mx := MapSize;
  my := MapSize;
  loadCharMap(input, map, mx, my);
  max.x := mx - 1;
  max.y := my - 1;
  scount := parseDirections(input, steps);
  runRobot(steps,scount,TopLeft, max, map);

  for my := TopLeft.y to max.y do
    for mx := TopLeft.x to max.x do begin
      if map[mx,my] = 'O' then
        sum := sum + 100*my + mx;
    end;
  part1 := sum;
end;

procedure blowUpMap(var map : TMap; var max : TPos);
var x, y : word;
begin
  for y := TopLeft.y to max.y do
    for x:= max.x downto TopLeft.x do
      case map[x,y] of
         '.': begin map[2*x,y] := '.'; map[2*x + 1,y] := '.'; end;
         '#': begin map[2*x,y] := '#'; map[2*x + 1,y] := '#'; end;
         'O': begin map[2*x,y] := '['; map[2*x + 1,y] := ']'; end;
         '@': begin map[2*x,y] := '@'; map[2*x + 1,y] := '.'; end;
      else assert(false,'Invalid map');
      end;
  max.x := max.x * 2 + 1;
end;

function part2(var input: Text):comp; far;
var max   : TPos;
    mx,my : word;
    scount: word;
    sum   : comp;
begin
  sum := 0;
  mx := MapSize;
  my := MapSize;
  loadCharMap(input, map, mx, my);
  max.x := mx - 1;
  max.y := my - 1;
  scount := parseDirections(input, steps);
  blowUpMap(map,max);
  runRobot(steps,scount,TopLeft, max, map);

  for my := TopLeft.y to max.y do begin
    for mx := TopLeft.x to max.x do begin
      if map[mx,my] = '[' then
        sum := sum + 100*my + mx;
    end;
  end;
  part2 := sum;
end;

begin
  runAoc(InputFileName, 15, part1, part2);
end.
