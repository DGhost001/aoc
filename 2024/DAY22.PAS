program day22;
(*This is the implementation of the aoc24 day 22*)

uses aoc, utils, progressbar, SparsArray, ItemHandler;
const InputFileName = 'INP\DAY22_IN.TXT';

type TDiffType = integer; (* -9..+9 *)
     PHistItem = ^THistItem;
     THistItem = object(TLongItem)
       index_ : word;

       constructor init(const value: longint; const index: word);
     end;

constructor THistItem.init(const value: longint; const index: word);
begin
  TLongItem.init(value);
  index_ := index;
end;

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

function getIndexForDiff(const a,b,c,d : TDiffType): longint;
var index : longint;
begin
  index := 10 + a;
  index := index * 20 + 10 + b;
  index := index * 20 + 10 + c;
  index := index * 20 + 10 + d;
  getIndexForDiff := index;
end;

procedure scanNumbers(number: longint; var hist : TSparseArray; const count : word; var p: TProgressBar);
var i    : word;
    now, last : word;
    a,b,c,d : TDiffType;
    h     : PHistItem;
    index : longint;

begin
  last := 0;
  a := 0;
  b := 0;
  c := 0;
  d := 0;
  for i := 0 to 2000 do begin
    now := number mod 10;
    d := c;
    c := b;
    b := a;
    a := now - last;
    last := now;
    
    if i >= 3 then begin
      index := getIndexForDiff(a,b,c,d);
      h := PHistItem(hist.at(index));
      if (h <> nil) and (h^.index_ < count) then begin
        inc(h^.value_, now);
        h^.index_ := count;
      end else if h = nil then begin
        h := new(PHistItem, init(now, count));
        hist.setValue(index, h);
      end;
    end;
    p.step(1);
    number := getNextSecretNumber(number, 1);
  end;
end;

var hist : PSparseArray;

function part2(var input: Text):comp; far;
var sum : comp;
    number : longint;
    lines  : longint;
    i      : longint;
    p      : TProgressBar;
begin
  hist := new(PSparseArray, init);
  sum := 0;

  lines := countLines(input);
  p.init(lines*2001,'Banana');
  for i:= 1 to lines do begin
    number := readLong(input);
    scanNumbers(number,hist^, i, p);
  end;
  p.done;
  part2 := PLongItem(hist^.getMax)^.value_;
  hist^.dispose;
end;

begin
  runAoc(InputFileName, 22, part1, part2, nil, nil);
end.
