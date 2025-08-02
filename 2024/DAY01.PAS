program day01;
(*This is the implementation of the aoc24 day 1*)

uses aoc, dequeue, itemhandler, utils, sort, cassert;
const InputFileName = 'INP\DAY01_IN.TXT';
type THistogramEntry = record
          number : longint;
          count  : word;
     end;
var histogram : array[0..1023] of THistogramEntry;
    histLevel : word;

function findHistEntry(const value : longint) : word;
var left, right, center : word;
begin
  left := 0;
  right:= histLevel;
  while left < right do begin
    center := (left + right) div 2;
    if histogram[center].number > value then
      right := center
    else if histogram[center].number < value then
      left  := center + 1
    else begin
      left := center;
      right:= center;
    end;
  end;
  if histogram[left].number = value then
    findHistEntry := left
  else
    findHistEntry := 65535;
end;

procedure addToHistogram(const value : longint);
var idx : word;
begin
  idx := findHistEntry(value);
  if idx = 65535 then begin
    idx := histLevel;
    inc(histLevel);
    assert(histLevel < HIGH(histogram),'Not enougth bins');
    histogram[idx].number := value;
    histogram[idx].count  := 0;
  end;
  inc(histogram[idx].count);
end;

function part1(var input: Text):comp; far;
var q1, q2 : PDeQueue;
    it1, it2 : PDeQueueIterator;
    c   : char;
    sum : longint;
begin
  q1 := new(PDeQueue, init);
  q2 := new(PDeQueue, init);

  while not eof(input) do begin
   q1^.pushBack(new(PLongItem,init(readLong(input))));
   q2^.pushBack(new(PLongItem,init(readLong(input))));
   read(input, c);
  end;

  sortQueue(q1);
  sortQueue(q2);

  it1 := q1^.first;
  it2 := q2^.first;
  sum := 0;

  while (it1 <> NIL) and (it2 <> NIL) do begin
    sum := sum + abs(PLongItem(it1^.at)^.value -
                     PLongItem(it2^.at)^.value);
    it1 := it1^.next;
    it2 := it2^.next;
  end;

  assert(it1 = NIL, 'Not all queue 1 items used');
  assert(it2 = NIL, 'Not all queue 2 items used');

  q1^.dispose;
  q2^.dispose;

  part1 := sum;
end;

function part2(var input: Text):comp; far;
var q1, q2 : PDeQueue;
    it1    : PDeQueueIterator;
    c      : char;
    sum    : longint;
    idx    : word;
begin
  q1 := new(PDeQueue, init);
  q2 := new(PDeQueue, init);

  while not eof(input) do begin
   q1^.pushBack(new(PLongItem,init(readLong(input))));
   q2^.pushBack(new(PLongItem,init(readLong(input))));
   read(input, c);
  end;

  sortQueue(q2);

  it1 := q2^.first;

  while it1 <> NIL do begin
    addToHistogram(PLongItem(it1^.at)^.value);
    it1 := it1^.next;
  end;

  it1 := q1^.first;
  sum := 0;
  while it1 <> NIL do begin
    idx := findHistEntry(PLongItem(it1^.at)^.value);
    if idx <> 65535 then
      sum := sum + PLongItem(it1^.at)^.value * histogram[idx].count;
    it1 := it1^.next;
  end;


  q1^.dispose;
  q2^.dispose;

  part2 := sum;
end;

begin
  runAoc(InputFileName, 1, part1, part2, nil, nil);
end.
