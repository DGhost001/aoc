program day04;
(*This is the implementation of the aoc24 day 4*)

uses aoc, utils, cassert, progressbar;
const InputFileName = 'INP\DAY04_IN.TXT';
      MinimumMap = 0;
      MaximumMap = 140;
      MinPos : TPos = ( x: MinimumMap; y: MinimumMap);
      MaxPos : TPos = ( x: MaximumMap; y: MaximumMap);
type TMap = array[MinimumMap..MaximumMap, MinimumMap..MaximumMap] of char;
     String4 = string[4];
     String3 = string[3];
var  map : TMap;

function extractString4(pos : TPos; const dir : TDirection8) : String4;
var result : String4;
         i : integer;
begin
  result :='';
  for i := 1 to 4 do begin
    result:=result + map[pos.x, pos.y];
    if not advancePos8(pos, dir, MinPos, MaxPos) then break;
  end;
  extractString4 := result;
end;


function part1(var input: Text):comp; far;
const xmas     : String4 = 'XMAS';
var maxX, maxY : word;
    pos        : TPos;
    count      : word;
    dir        : TDirection8;
    p          : TProgressBar;
begin
  count := 0;
  maxX := MaximumMap+1;
  maxY := MaximumMap+1;
  fillchar(map,sizeof(map),0);

  loadCharMap(input, map, maxX, maxY);
  assert(maxX = MaxPos.x, 'X Dimensions Wrong');
  assert(maxY = MaxPos.y, 'Y Dimensions Wrong');
  p.init(maxX*maxY,'xmas');
  for pos.y := 0 to maxY do
    for pos.x :=0 to maxX do begin
      if map[pos.x, pos.y]='X' then
        for dir := NO to SO do begin
          if extractString4(pos, dir) = xmas then begin
            inc(count);
          end;
        end;
      p.step(1);
    end;
    p.done;
  part1 := count;
end;

procedure extractXString3(const pos : TPos;
                         var s1 : String3;
                         var s2 : String3);
var p1, p2 : TPos;
         i : integer;
begin
  s1:= '';
  s2:= '';
  p1 := pos;
  p2 := pos;

  if not advancePos8(p1, NE, MinPos, MaxPos) then exit;
  if not advancePos8(p2, NW, MinPos, MaxPos) then exit;

  for i := 1 to 3 do begin
    s1 := s1 + map[p1.x, p2.y];
    s2 := s2 + map[p2.x, p2.y];
    if not advancePos8(p1, SW, MinPos, MaxPos) then break;
    if not advancePos8(p2, SE, MinPos, MaxPos) then break;
  end;
end;

function part2(var input: Text):comp; far;
const mas1  : string3 = 'MAS';
      mas2  : string3 = 'SAM';
var   count      : word;
          p      : TProgressBar;
      maxX, maxY : word;
      pos        : TPos;
      s1, s2     : string3;
begin
  count := 0;
  maxX := MaximumMap+1;
  maxY := MaximumMap+1;
  fillchar(map,sizeof(map),0);

  loadCharMap(input, map, maxX, maxY);
  assert(maxX = MaxPos.x, 'X Dimensions Wrong');
  assert(maxY = MaxPos.y, 'Y Dimensions Wrong');
  p.init(maxX*maxY,'mas');
  for pos.y := 0 to maxY do
    for pos.x :=0 to maxX do begin
      if map[pos.x, pos.y]='A' then begin
        extractXString3(pos,s1,s2);
        if (((s1 = mas1) or (s1 = mas2)) and
            ((s2 = mas1) or (s2 = mas2))) then inc(count);
      end;
      p.step(1);
    end;
    p.done;
  part2 := count;
end;

begin
  runAoc(InputFileName, 4, part1, part2, nil, nil);
end.
