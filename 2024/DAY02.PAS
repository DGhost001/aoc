program day02;
(*This is the implementation of the aoc24 day 2*)

uses aoc, utils;
const InputFileName = 'INP\DAY02_IN.TXT';

procedure diff(var numbers : array of longint; const count : word);
var i : word;
begin
  for i := 1 to count - 1 do
    numbers[i-1] := numbers[i] - numbers[i-1];
end;

function Max(const numbers : array of longint; const count : word) : longint;
var  i : word;
    maxv: longint;
begin
  maxv := numbers[0];
  for i := 1 to count - 1 do
    if numbers[i] > maxv then maxv :=numbers[i];
  Max := maxv;
end;

function Min(const numbers : array of longint; const count : word) : longint;
var  i : word;
    minv: longint;
begin
  minv := numbers[0];
  for i := 1 to count - 1 do
    if numbers[i] < minv then minv :=numbers[i];
  Min := minv;
end;

function isSafe(var numbers      : array of longint;
                const count   : word) : boolean;
var  minimum, maximum : longint;
begin
  diff(numbers,count);
  minimum := min(numbers, count - 1);
  maximum := max(numbers, count - 1);
  if ((maximum <=-1) and (minimum >= -3)) or
     ((minimum >= 1) and (maximum <=  3)) then
     isSafe := true
  else
     isSafe := false;
end;

procedure dropNumber(const inNumbers : array of longint;
                     var   outNumbers: array of longint;
                     const inCount   : word;
                     const dropIdx   : word );
var i,j : word;
begin
  j := 0;
  for i := 0 to inCount - 1 do begin
    if i <> dropIdx then begin
      outNumbers[j] := inNumbers[i];
      inc(j)
    end;
  end;
end;

function part1(var input: Text):comp; far;
var numbers : array[0..8] of longint;
    numCount: word;
    count   : word;
begin
  count := 0;
  fillchar(numbers,sizeof(numbers),0);
  while not eof(input) do begin
    numCount := readLongArray(input, numbers);
    if isSafe(numbers, numCount) then inc(count);
  end;
  part1 := count;
end;

function part2(var input: Text):comp; far;
var numbers, dampend : array [0..8] of longint;
    numCount : word;
    count    : word;
    safe     : boolean;
    j        : word;
begin
  count := 0;
  fillchar(numbers,sizeof(numbers),0);
  while not eof(input) do begin
    numCount := readLongArray(input, numbers);
    dampend := numbers;
    safe := isSafe(dampend, numCount);
    j := 0;
    while (not safe) and (j < numCount) do begin
      dropNumber(numbers, dampend, numCount, j);
      safe := isSafe(dampend, numCount - 1);
      inc(j);
    end;

    if safe then inc(count)
  end;

  part2 := count;
end;

begin
  runAoc(InputFileName, 2, part1, part2, nil, nil);
end.
