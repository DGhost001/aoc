program day06;
(*This is the implementation of the aoc24 day 6*)

uses aoc, utils, cassert, ProgressBar;
const InputFileName = 'INP\DAY06_IN.TXT';
      MapSize = 130;
      MapMax  : TPos = (x: MapSize + 1; y: MapSize +1);

type TMap = array[0..MapSize, 0..MapSize] of char;
     TGuard = object
         pos_ : TPos;
         dir_ : TDirection;

         constructor init(const pos : TPos);
         procedure markPath(var map:TMap; const maxPos: TPos);
         function  doesItLoop(const map      : TMap;
                              const maxPos   : TPos;
                              const obstacle : TPos) :boolean;
     end;
var map : TMap;

constructor TGuard.init(const pos : TPos);
begin
  pos_ := pos;
  dir_ := North;
end;

procedure TGuard.markPath(var map : TMap; const maxPos : TPos);
const minPos : TPos = (x: 0; y: 0);
var oldPos : TPos;
    newPos : TPos;
    newDir : TDirection;
begin
  newPos := pos_;
  newDir := dir_;
  oldPos := pos_;

  map[pos_.x, pos_.y] := '*';
  while advancePos(newPos, newDir, minPos, maxPos) do begin
    if map[newPos.x, newPos.y] ='#' then begin
      newDir := nextDirection(newDir, newDir);
      newPos := oldPos;
    end else begin
      map[newPos.x, newPos.y] := '*';
      oldPos := newPos;
    end;
  end;
end;

function  TGuard.doesItLoop(const map      : TMap;
                            const maxPos   : TPos;
                            const obstacle : TPos) :boolean;
const minPos : TPos = (x: 0; y: 0);
type TDirectionSet = set of TDirection;
     PLoopMap = ^TLoopMap;
     TLoopMap = array[0..MapSize, 0..MapSize] of TDirectionSet;
var  loopMap : PLoopMap;
     oldPos : TPos;
     newPos : TPos;
     newDir : TDirection;
begin
  loopMap := new(PLoopMap);
  fillChar(loopMap^,sizeof(TLoopMap),0);
  doesItLoop := false;
  newPos := pos_;
  newDir := dir_;
  oldPos := pos_;
  loopMap^[pos_.x,pos_.y] := [dir_];

  while advancePos(newPos, newDir, minPos, maxPos) do begin
    if (map[newPos.x, newPos.y] ='#') or (posEqual(obstacle,newPos)) then begin
      newDir := nextDirection(newDir, newDir);
      newPos := oldPos;
    end else begin
      if newDir in loopMap^[newPos.x,newPos.y] then begin
        doesItLoop := true;
        break;
      end else begin
        oldPos := newPos;
        with newPos do
          loopMap^[x,y] := loopMap^[x,y] + [newDir];
      end;
    end;
  end;
  dispose(loopMap);
end;

function part1(var input: Text):comp; far;
var max : TPos;
    pos : TPos;
    maxX, maxY : word;
    guard: TGuard;
begin
  maxX := MapSize + 1;
  maxY := MapSize + 1;

  loadCharMap(input, map, maxX, maxY);
  max.x := maxX-1;
  max.y := maxY-1;
  findFirstInMap(map, '^', max, MapSize + 1, pos);
  assert(not posEqual(pos,max), 'Start Pos not found');
  guard.init(pos);
  guard.markPath(map,max);

  part1 := countInMap(map,'*',max, MapSize + 1);
end;

function part2(var input: Text):comp; far;
  function  nextPos(var   pos   : TPos;
                    const guard : TGuard;
                    const max   : TPos;
                    const map   : TMap) : boolean;
  begin
    nextPos := false;
    repeat
      inc(pos.x);
      if pos.x > max.x then begin
        inc(pos.y);
        pos.x := 0;
      end;
      if (not posEqual(max, pos)) and
         (not posEqual(guard.pos_, pos)) and
         (map[pos.x, pos.y] = '*') then begin
           nextPos := true;
           break;
         end;
    until posEqual(max, pos);
  end;
var p : TProgressBar;
    max : TPos;
    pos : TPos;
    maxX, maxY : word;
    guard: TGuard;
    count: word;
begin
  count := 0;
  maxX := MapSize + 1;
  maxY := MapSize + 1;

  loadCharMap(input, map, maxX, maxY);
  max.x := maxX-1;
  max.y := maxY-1;
  findFirstInMap(map, '^', max, MapSize + 1, pos);
  assert(not posEqual(pos,max), 'Start Pos not found');
  guard.init(pos);
  guard.markPath(map,max);
  p.init(countInMap(map,'*',max, MapSize + 1),'block');
  pos.x := -1;
  pos.y := 0;
  while nextPos(pos,guard,max, map) do begin
   if guard.doesItLoop(map, max, pos) then inc(count);
   p.step(1);
  end;
  p.done;
  part2 := count;
end;

begin
  runAoc(InputFileName, 6, part1, part2, nil, nil);
end.
