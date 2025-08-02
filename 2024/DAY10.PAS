program day10;
(*This is the implementation of the aoc24 day 10*)

uses aoc, utils, dequeue, progressbar;
const InputFileName = 'INP\DAY10_IN.TXT';
      Start = ord('0');
      Goal  = ord('9');

type TMap     = array[0..59,0..59] of byte;
     TVisited = array[0..59,0..59] of boolean;
function findAllStart(const map : TMap;
                      const max : TPos): PDequeue;
var x,y    : byte;
    result : PDeQueue;
begin
  result := new(PDequeue, init);

  for x := 0 to max.x do
    for y := 0 to max.y do
     if map[x,y] = Start then result^.pushBack(new(PPos, initxy(x,y)));

  findAllStart := result;
end;

function countAllGoals( const map: TMap;
                        const max: TPos;
                        const pos : TPos
                      ) : word;
const min  : TPos = (x: 0; y:0);
var i      : TDirection;
    height : byte;
    backlog: PDeQueue;
    cpos,npos   : TPos;
    result : word;
    visited: TVisited;
begin
  fillchar(visited,sizeof(visited),0);
  backlog := new(PDeQueue, init);
  backlog^.pushBack(new(PPos,init(pos)));
  result := 0;

  while backlog^.size > 0 do begin
    cpos := PPos(backlog^.first^.at)^.pos_;
    if not visited[cpos.x,cpos.y] then begin
      visited[cpos.x,cpos.y] := true;
      if map[cpos.x,cpos.y] = Goal then inc(result)
      else begin
        for i := North to South  do begin
          npos := cpos;
          if advancePos(npos,i,min,max) and
             ((map[npos.x,npos.y]-1) = map[cpos.x,cpos.y]) then
            backlog^.pushBack(new(PPos,init(npos)));
        end;
      end;
    end;
    backlog^.popFront;
  end;

  countAllGoals := result;
  backlog^.dispose;
end;

function countAllWays ( const map: TMap;
                        const max: TPos;
                        const pos : TPos
                      ) : word;
const min  : TPos = (x: 0; y:0);
var i      : TDirection;
    height : byte;
    backlog: PDeQueue;
    cpos,npos   : TPos;
    result : word;
begin
  backlog := new(PDeQueue, init);
  backlog^.pushBack(new(PPos,init(pos)));
  result := 0;

  while backlog^.size > 0 do begin
    cpos := PPos(backlog^.first^.at)^.pos_;
    if map[cpos.x,cpos.y] = Goal then inc(result)
    else begin
      for i := North to South  do begin
        npos := cpos;
        if advancePos(npos,i,min,max) and
           ((map[npos.x,npos.y]-1) = map[cpos.x,cpos.y]) then
          backlog^.pushBack(new(PPos,init(npos)));
      end;
    end;
    backlog^.popFront;
  end;

  countAllWays := result;
  backlog^.dispose;
end;


var count : longint;
      max : TPos;
      map : TMap;

procedure processP1(it:PDeQueueIterator); far;
begin
  inc(count, countAllGoals(map, max, PPos(it^.at)^.pos_));
end;

procedure processP2(it:PDeQueueIterator); far;
begin
  inc(count, countAllWays(map, max, PPos(it^.at)^.pos_));
end;


function part1(var input: Text):comp; far;
var mx, my : word;
    starts : PDeQueue;
begin
  mx := 60;
  my := 60;
  loadCharMap(input, map,mx, my);
  max.x := mx - 1;
  max.y := my - 1;
  count := 0;
  starts := findAllStart(map, max);
  starts^.forEach(processP1);
  starts^.dispose;
  part1 := count;
end;

function part2(var input: Text):comp; far;
var mx, my : word;
    starts : PDeQueue;
begin
  mx := 60;
  my := 60;
  loadCharMap(input, map,mx, my);
  max.x := mx - 1;
  max.y := my - 1;
  count := 0;
  starts := findAllStart(map, max);
  starts^.forEach(processP2);
  starts^.dispose;

  part2 := count;
end;

begin
  runAoc(InputFileName, 10, part1, part2, nil, nil);
end.
