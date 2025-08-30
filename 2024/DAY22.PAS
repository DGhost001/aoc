program day22;
(*This is the implementation of the aoc24 day 22*)

uses aoc, utils, progressbar;
const InputFileName = 'INP\DAY22_IN.TXT';

function getNextSecretNumber(lastNumber : longint; repeats : word) : longint;
var tmp : longint;
begin
  while repeats > 0 do begin
    lastNumber := ((lastNumber shl 6) xor lastNumber) and $ffffff; (* Step 1 *)
    lastNumber := ((lastNumber shr 5) xor lastNumber) and $ffffff; (* Step 2 *)
    lastNumber := (((lastNumber and $1fff) shl 11) xor lastNumber) and $ffffff; (* Step 3 *)
    dec(repeats);
  end;
  getNextSecretNumber := lastNumber;
end;

function part1(var input: Text):comp; far;
var sum : comp;
    number : longint;
    lines  : longint;
    i      : longint;
    p      : TProgressBar;
begin
  sum := 0;
  number := 123;
  for i:=1 to 10 do begin
    number := getNextSecretNumber(number, 1);
    WriteLn(number);
  end;

  lines := countLines(input);
  p.init(lines,'Sum');
  for i:= 1 to lines do begin
    number := readLong(input);
    number := getNextSecretNumber(number, 2000);
    sum := sum + number;
    p.step(1);
  end;
  p.done;
  part1 := sum;
end;

function part2(var input: Text):comp; far;
begin
  part2 := 0;
end;

begin
  runAoc(InputFileName, 22, part1, part2, nil, nil);
end.
