program day09;
(*This is the implementation of the aoc24 day 9*)

uses aoc, dequeue, ItemHandler, Sort, cassert, stdint,progressbar;
const InputFileName = 'INP\DAY09_IN.TXT';
      FreeSpace     = $ffff;
type
      PChunk = ^TChunk;
      TChunk = object(ItemType)
         startPosition_ : longint;
         length_        : longint;
         id_            : word;

         constructor init(const position, length : longint; const id : word);
         function    canMerge(const other : PChunk): boolean;
         function    merge(const other : PChunk)   : boolean;
         function    split(const length: longint)  : PChunk;
         function    isEmpty : boolean;
         procedure   move(const pos: longint);
         function    compare(other:PItemType):TRelation;virtual;
      end;

constructor TChunk.init(const position, length : longint;
                        const id : word);
begin
  id_            := id;
  startPosition_ := position;
  length_        := length;
end;

function TChunk.canMerge(const other : PChunk): boolean;
begin
  canMerge := (((startPosition_ + length_) = other^.startPosition_) or
              ((other^.startPosition_ + other^.length_) = startPosition_)) and
              (id_ = other^.id_);
end;

function TChunk.merge(const other : PChunk)   : boolean;
var result : boolean;
begin
  result := canMerge(other);
  if result then begin
    if startPosition_ > other^.startPosition_ then
      startPosition_ := other^.startPosition_;
    length_ := length_ + other^.length_;
  end;
  merge := result;
end;

function TChunk.split(const length: longint)  : PChunk;
var result : PChunk;
begin
  result := nil;
  if length_ >= length then begin
    result  := new(PChunk, init(startPosition_, length, id_));
    length_ := length_ - length;
    startPosition_ := startPosition_ + length;
  end;

  split := result;
end;

function TChunk.isEmpty : boolean;
begin
  isEmpty := length_ = 0;
end;

procedure TChunk.move(const pos : longint);
begin
  startPosition_ := pos;
end;

function TChunk.compare(other:PItemType):TRelation;
var o : PChunk;
begin
  o := PChunk(other);
  if startPosition_ > o^.startPosition_ then compare :=  Bigger
  else if startPosition_ < o^.startPosition_ then compare :=  Smaller
  else compare := Equal;
end;

procedure printChunkMap(const chunkMap : PDeQueue);
var it : PDeQueueIterator;
    id : word;
    i  : longint;
begin
  it := chunkMap^.first;
  while it <> nil do begin
    id := PChunk(it^.at)^.id_;

    for i:= 1 to PChunk(it^.at)^.length_ do
      if id = FreeSpace then write('.')
      else write(id);

    it := it^.next;
  end;
  writeln;
end;


procedure loadFileSystem(var input    : Text;
                         var chunkMap : PDeQueue);
 function char2Num(const c : char): byte;
 begin
   char2Num := ord(c) - ord('0');
 end;

var c1,c2      : char;
       id      : word;
       pos     : longint;
       length  : byte;
       newChunk: PChunk;
begin
  chunkMap := new(PDeQueue,init);
  id       := 0;
  pos      := 0;
  while not eof(input) do begin
    read(input, c1, c2);
    if (c1 in ['0'..'9']) then begin
      write(#$0d, 'Loading... ',id,':',pos,'    ');
      length := char2Num(c1);
      assert(length <> 0,'0 length file found');
      chunkMap^.pushBack(new(PChunk,init(pos, length, id)));
      inc(pos, length);
      inc(id);
      if (c2 in ['0'..'9']) then begin
        length := char2Num(c2);
        if length > 0 then
          chunkMap^.pushBack(new(PChunk,init(pos,length,FreeSpace)));
        inc(pos,length);
      end;
    end;
  end;
  writeln;
(*  printChunkMap(chunkMap); *)
end;

procedure defrag(chunkMap: PDeQueue);
  function split(const queue : PDeQueue;
                  const it    : PDeQueueIterator;
                  const length: longint): PChunk;

  var chunk : PChunk;
  begin
    chunk := PChunk(it^.at);
    chunk := chunk^.split(length);
    queue^.insertBefore(chunk, it);
    split := chunk;
  end;

  function nextFree(it         : PDeQueueIterator;
                    const stop : PDeQueueIterator) : PDeQueueIterator;
  begin
    while (it <> nil)  and
          (it <> stop) and
          (PChunk(it^.at)^.id_ <> FreeSpace) do
            it := it^.next;
    if it = stop then it := nil;
    nextFree := it;
  end;

  function nextUsed(it         : PDeQueueIterator;
                    const stop : PDeQueueIterator) : PDeQueueIterator;
  begin
    while (it <> nil)  and
          (it <> stop) and
          (PChunk(it^.at)^.id_ = FreeSpace) do
            it := it^.prev;
    if it = stop then it := nil;
    nextUsed := it;
  end;
var freeIt, fileIt      : PDequeueIterator;
    freeChunk, fileChunk: PChunk;
    p                   : TProgressBar;
    id                  : word;
begin
  id := $ffff;
  freeIt := chunkMap^.first;
  fileIt := chunkMap^.last;
  while (freeIt <> nil) and (fileIt <> nil) do begin
    if PChunk(freeIt^.at)^.id_ <> FreeSpace then
      freeIt := nextFree(freeIt, fileIt);
    if PChunk(fileIt^.at)^.id_ = FreeSpace then
      fileIt := nextUsed(fileIt, freeIt);
    if (fileIt = NIL) or (freeIt = NIL) then break;


    freeChunk := PChunk(freeIt^.at);
    fileChunk := PChunk(fileIt^.at);

    if fileChunk^.id_ <> id then begin
      if id = $ffff then p.init(fileChunk^.id_ div 2, 'defra')
      else p.step(1);
      id := fileChunk^.id_;
    end;

    if freeChunk^.length_ = fileChunk^.length_ then begin
       freeChunk^.id_ := fileChunk^.id_;
       fileChunk^.id_ := FreeSpace;
    end else if freeChunk^.length_ < fileChunk^.length_ then begin
       freeChunk^.id_ := fileChunk^.id_;
       split(chunkMap,fileIt, fileChunk^.length_ - freeChunk^.length_);
       fileChunk^.id_ := FreeSpace;
    end else begin
      (split(chunkMap, freeIt, fileChunk^.length_))^.id_ := fileChunk^.id_;
      fileChunk^.id_ := FreeSpace;
    end;
  end;
  p.done;
end;

procedure weight(const chunk : PChunk; var a : uint64_t);
  procedure gauss(const i : longint;
                  var   a : uint64_t);
  const two64 :uint64_t =(2,0,0,0,0,0,0,0);
  var n, n1 : uint64_t;
  begin
    if i < 0 then a := zero64
    else begin
      fromLongInt64(i,n);
      n1 := n;
      add64(n1,one64);
      mul64(n,n1);
      a := n;
      div64(a, two64, n);
    end;
  end;

  procedure sumInRange(const i,i1 : longint;
                       var   a : uint64_t);
  var b : uint64_t;
  begin
    gauss(i - 1 ,b );
    gauss(i1 -1 ,a );
    sub64(a,b);
  end;
var b : uint64_t;
begin
  if chunk^.id_ <> FreeSpace then begin
    sumInRange( chunk^.startPosition_, chunk^.startPosition_ + chunk^.length_, a);
    fromLongInt64( chunk^.id_, b);
    mul64(a,b);
  end else a := zero64;
end;

function part1(var input: Text):comp; far;
var chunkMap : PDeQueue;
    it       : PDeQueueIterator;
    sum,b    : uint64_t;
    p        : TProgressbar;
begin
  sum := zero64;
  loadFileSystem(input, chunkMap);
  defrag(chunkMap);
(*  printChunkMap(chunkMap); *)
  it := chunkMap^.first;
  p.init(chunkMap^.size,'Count');
  while it <> nil do begin
    weight(PChunk(it^.at), b);
    add64(sum,b);
    it := it^.next;
    p.step(1);
  end;
  p.done;
  chunkMap^.dispose;
  part1 := uint64ToComp(sum);
end;

procedure defrag2(chunkMap: PDeQueue);
  function split(const queue : PDeQueue;
                  const it    : PDeQueueIterator;
                  const length: longint): PChunk;

  var chunk : PChunk;
  begin
    chunk := PChunk(it^.at);
    chunk := chunk^.split(length);
    queue^.insertBefore(chunk, it);
    split := chunk;
  end;

  function nextFree(it          : PDeQueueIterator;
                    var first   : PDeQueueIterator;
                    const stop  : longint;
                    const length: longint
                    ) : PDeQueueIterator;
  var ch : PChunk;
      firstSet : boolean;
  begin
    firstSet := false;

    while (it <> nil) do begin
       ch := PChunk(it^.at);
       with ch^ do begin
          if startPosition_ >= stop then begin
            it := nil;
            break;
          end else if id_ = FreeSpace then begin
            if not firstSet then begin
              first := it;
              firstSet := True;
            end;
            if length_ >= length then break;
          end;
       end;

       it := it^.next;
    end;
    nextFree := it;
  end;

  function nextUsed(it         : PDeQueueIterator;
                    const maxId: longint
                    ) : PDeQueueIterator;
  begin
    while (it <> nil)  and
          (PChunk(it^.at)^.id_ >= maxId )
          do
            it := it^.prev;
    nextUsed := it;
  end;
var freeIt, fileIt,first: PDequeueIterator;
    freeChunk, fileChunk: PChunk;
    p                   : TProgressBar;
    id                  : word;
begin
  id := $ffff;

  fileIt := chunkMap^.last;
  first  := chunkMap^.first;

  while (fileIt <> nil) do begin
    fileIt := nextUsed(fileIt, id);
    if (fileIt = NIL) then break;

    fileChunk := PChunk(fileIt^.at);
    freeIt := nextFree(first, first, fileChunk^.startposition_,fileChunk^.length_);

    if id = $ffff then p.init(fileChunk^.id_, 'defra')
    else p.step(1);

    id     := fileChunk^.id_;
    if freeIt = nil then continue;
    freeChunk := PChunk(freeIt^.at);

    if freeChunk^.length_ = fileChunk^.length_ then begin
       freeChunk^.id_ := fileChunk^.id_;
       fileChunk^.id_ := FreeSpace;
    end else begin
      (split(chunkMap, freeIt, fileChunk^.length_))^.id_ := fileChunk^.id_;
      fileChunk^.id_ := FreeSpace;
    end;
  end;
  p.done;
end;



function part2(var input: Text):comp; far;
var chunkMap : PDeQueue;
    it       : PDeQueueIterator;
    sum,b    : uint64_t;
    p        : TProgressbar;
begin
  sum := zero64;
  loadFileSystem(input, chunkMap);
  defrag2(chunkMap);
  (* printChunkMap(chunkMap); *)
  it := chunkMap^.first;
  p.init(chunkMap^.size,'Count');
  while it <> nil do begin
    weight(PChunk(it^.at), b);
    add64(sum,b);
    it := it^.next;
    p.step(1);
  end;
  p.done;
  chunkMap^.dispose;
  part2 := uint64ToComp(sum);
end;

begin
  runAoc(InputFileName, 9, part1, part2);
end.
