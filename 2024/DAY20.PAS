
Program day20;
(*This is the implementation of the aoc24 day 1*)

Uses aoc, utils, cassert;

Const InputFileName = 'INP\DAY20_IN.TXT';

Const MaxPos : TPos = (x: 140; y: 140);
  MinPos : TPos = (x: 0; y: 0);

Type PProgrammMap = ^TProgrammMap;
     PCharMap     = ^TCharMap;

     TProgrammMap = array[0..140, 0..140] Of word;
     TCharMap     = array[0..140, 0..140] Of char;

Procedure tracePath(Var progMap       : TProgrammMap;
                    Var map           : TCharMap);

Var currentPos : TPos;
  currentDir : TDirection;
  tmpDir     : TDirection;
  tmpPos     : TPos;
  stepCount  : word;
  couldAdvance : boolean;
Begin
  findFirstInMap(map, 'S', MaxPos, MaxPos.x + 1, currentPos);
  FillChar(progMap, SizeOf(progMap), 0);
  currentDir := North;
  stepCount := 1;
  While map[currentPos.x, currentPos.y] <> 'E' Do
    Begin
      progMap[currentPos.x, currentPos.y] := stepCount;
      tmpPos := currentPos;
      tmpDir := currentDir;
      couldAdvance := advancePos(tmpPos, tmpDir, MinPos, MaxPos);
      If (Not couldAdvance) or (map[tmpPos.x, tmpPos.y] = '#') Then Begin
        tmpDir := currentDir;
        Repeat
          tmpPos := currentPos;
          tmpDir := nextDirection(currentDir, tmpDir);
        Until (advancePos(tmpPos, tmpDir, MinPos, MaxPos)
               and (map[tmpPos.x, tmpPos.y] <> '#')) Or
              (tmpDir = currentDir);
        assert(tmpDir <> currentDir, 'No way to go');
        currentDir := tmpDir;
      End;
      currentPos := tmpPos;
      Inc(stepCount);
    End;
  progMap[currentPos.x, currentPos.y] := stepCount; (* When reaching we have one more field to fill *)
End;

function canGlitchTheMatrix(const progMap: TProgrammMap; 
                            const pos : TPos;
                            const dir : TDirection): longint;
var pos1, pos2 : TPos;
begin
  pos1 := pos;
  pos2 := pos;
  canGlitchTheMatrix := 0;
  if advancePos(pos1, dir, MinPos, MaxPos) and
     advancePos(pos2, dir, MinPos, MaxPos) and 
     advancePos(pos2, dir, MinPos, MaxPos) then
  Begin
    if (progMap[pos1.x, pos1.y] = 0) and 
       (progMap[pos2.x, pos2.y] <> 0) and 
       (progMap[pos.x, pos.y] <> 0)  then 
      canGlitchTheMatrix := progMap[pos2.x, pos2.y] - progMap[pos.x, pos.y] - 1;    
  end;
end;

function countGlitches(const progMap: TProgrammMap; const targetValue: longint): longint;
var count : longint;
    pos   : TPos;
    dir   : TDirection;

begin
  pos := MinPos;
  count := 0;
  for pos.y := MinPos.y to MaxPos.y do
    for pos.x := MinPos.x to MaxPos.x do
      for dir := North to South do
        if canGlitchTheMatrix(progMap, pos, dir) >= targetValue then
          Inc(count);
  countGlitches := count;
end;

Function part1(Var input: Text): comp; far;
var progMap : PProgrammMap;
    map     : PCharMap;
    maxX, maxY : word;
    count   : longint;
Begin
  new(progMap);
  new(map);

  maxX := 141;
  maxY := 141;

  loadCharMap(input, map^, maxX, maxY);
  tracePath(progMap^, map^);
  count := countGlitches(progMap^, 100);

  dispose(map);
  dispose(progMap);
  part1 := count;
End;

Function part2(Var input: Text): comp;
far;
Begin
  part2 := 0;
End;

Begin
  runAoc(InputFileName, 20, part1, part2, Nil, Nil);
End.
