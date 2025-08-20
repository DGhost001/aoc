program day18;
(*This is the implementation of the aoc24 day 18*)
(* https://adventofcode.com/2024/day/18 *)

uses aoc, heap, itemhandler, cassert, utils;
const InputFileName = 'INP\DAY18_IN.TXT';
      CorruptedMemory : word = $ffff; (* Corrupted Memory Cell *)
      MinPos : TPos = (x: 0; y: 0); (* Top left corner of the map *)
      MaxPos : TPos = (x: 70; y: 70); (* Bottom right corner of the map *)

type  PPosition = ^TPosition;
      TPosition = object(ItemType)
        pos_    : TPos;
        weight_ : word;

        constructor init(const pos: TPos; const weight: word);
        destructor done; virtual;
        function compare(other: PItemType): TRelation; virtual;
    end;

    TMemoryMap = array[0..70, 0..70] of word; (* 71 x 71 Memory cells *)

constructor TPosition.init(const pos: TPos; const weight: word);
begin
  pos_ := pos;
  weight_ := weight;
end;

destructor TPosition.done;
begin
  (* Nothing to be done here *)
end;

function TPosition.compare(other: PItemType): TRelation;
begin
    if weight_ < PPosition(other)^.weight_ then
        compare := Smaller
    else if weight_ > PPosition(other)^.weight_ then
        compare := Bigger
    else
        compare := Equal;
end;

procedure corruptMemory(var mem: TMemoryMap; const pos: TPos);
begin
  mem[pos.x, pos.y] := CorruptedMemory;
end;

procedure computeDistanceMap(var mem: TMemoryMap; const start: TPos);
var queue: TMinHeap;
    current: PPosition;
    nextPos: TPos;
    dir    : TDirection;   
begin
  queue.init;
  mem[start.x, start.y] := 0; (* Start position has distance 0 *)

  (* Setup the inital queue positions *)
  for dir := North to South do begin
    nextPos := start;
    if advancePos(nextPos, dir, MinPos, MaxPos) then begin
       if mem[nextPos.x, nextPos.y] <> CorruptedMemory then
         queue.push(new(PPosition, init(nextPos, 1))); (* Push the next position with weight 1 *)
    end;
  end;

  while queue.size > 0 do begin
    current := PPosition(queue.pop);
    if (mem[current^.pos_.x, current^.pos_.y] <> 0) then begin
      dispose(current, done); (* Dispose the current position *)
      continue; (* Skip already corrupted/visited positions *)
    end;
    mem[current^.pos_.x, current^.pos_.y] := current^.weight_; (* Set the distance for the current position *)

    (* Check all directions from the current position *)
    for dir := North to South do begin
      nextPos := current^.pos_;
      if advancePos(nextPos, dir, MinPos, MaxPos) then begin
        if (mem[nextPos.x, nextPos.y] = 0) then
            queue.push(new(PPosition, init(nextPos, current^.weight_ + 1))); (* Push the next position with incremented weight *)
      end;
    end;
    (* Process the current position *)
    dispose(current, done); (* Dispose the current position *)
  end;
end;

var mem : TMemoryMap;  
function part1(var input: Text):comp; far;
var i          : integer;
    memoryError: TPos;
begin
  FillChar(mem, SizeOf(mem), 0); (* Initialize the memory map with zeros *)
  for i:= 1 to 1024 do begin
    readPos(input, memoryError);
    corruptMemory(mem, memoryError);
  end;
  computeDistanceMap(mem, MinPos); (* Compute the distance map starting from the top left corner *)
  part1 := mem[MaxPos.x, MaxPos.y]; (* Return the distance to the bottom right corner *)
end;

var listOfCorruptions : array [1..4096] of TPos;
    listSize : word;
function part2(var input: Text):comp; far;
var i, lowerLimit, upperLimit, center: word;
begin
  listSize := countLines(input);
  assert(listSize <= 4096, 'Too many corruptions in the input file');
  FillChar(listOfCorruptions, SizeOf(listOfCorruptions), 0);
  for i:= 1 to listSize do
    readPos(input, listOfCorruptions[i]);
  lowerLimit := 1;
  upperLimit := listSize;
  while lowerLimit < upperLimit do begin
    center := (lowerLimit + upperLimit) div 2;
    write('Lower Limit: ', lowerLimit, ' Upper Limit: ', upperLimit, ' Center: ', center);
    
    FillChar(mem, SizeOf(mem), 0); (* Reset the memory map *)
    for i:= 1 to center do
      corruptMemory(mem, listOfCorruptions[i]);
    computeDistanceMap(mem, MinPos); (* Compute the distance map with the current corruptions *)
    writeln(' - Steps: ', mem[MaxPos.x, MaxPos.y]);
        
    if (mem[MaxPos.x, MaxPos.y] = 0) or
       (mem[MaxPos.x, MaxPos.y] = CorruptedMemory) then 
       (* Than there is no longer a way to the end, so the cutoff is earlier *)
       upperLimit := center
    else (* There is still a way to the end, so we can try to include more corruptions *)
       lowerLimit := center + 1;
  end;
  writeln(' Close curruption at memory cell: ', listOfCorruptions[center].x, ',', listOfCorruptions[center].y);
  part2 := center; (* Return the number of corruptions until the first cutoff point *)
end;

begin
  runAoc(InputFileName, 18, part1, part2, nil, nil);
end.
