program day05;
(*This is the implementation of the aoc24 day 5*)

uses aoc, ItemHandler, cassert, utils;
const InputFileName = 'INP\DAY05_IN.TXT';
type  TNumberSet = set of 0..99;
      TOrder     = array[0..99] of TNumberSet;


function compare(const n1, n2 : byte; const order : TOrder) : TRelation;
begin
  assert((n1 < 100) and (n2 < 100), 'Number out of range');
  if n2 in order[n1] then compare := Smaller
  else if n1 in order[n2] then compare := Bigger
  else compare := Equal;
end;

procedure loadOrder(var input:Text; var order:TOrder);
var n1, n2 : byte;
    c : char;
begin
  fillchar(order,sizeOf(order),0);

  while not eoln(input) do begin
   n1 := readInteger(input);
   n2 := readInteger(input);
   read(input, c);

   order[n1] := order[n1] + [n2];
  end;
end;

function checkOrder(const pages :array of longInt;
                    const count : word;
                    const order : TOrder) : boolean;
var result : boolean;
    i,j    : word;
begin
  result := True;

  for i := 0 to count - 1 do
    for j := i + 1 to count - 1 do begin
      if compare(pages[i], pages[j], order) = Bigger then begin
        result := false;
        break;
      end;
    end;

  checkOrder := result;
end;

var order  : TOrder;

function part1(var input: Text):comp; far;
var pages  : array[0..31] of longint;
    count  : word;
    sum    : comp;
begin
  sum := 0;
  loadOrder(input, order);
  while not eof(input) do begin
    count := readLongArray(input,pages);
    if count > 0 then begin
      if checkOrder(pages, count, order) then begin
        sum := sum + pages[count div 2];
      end;
    end;
  end;

  part1 := sum;
end;

procedure sortPages(var pages : array of longint; const count : byte);
var changed : boolean;
        tmp : longint;
          i : integer;
begin
  repeat
    changed := false;
    for i:= 0 to count - 2 do begin
      if compare(pages[i],  pages[i+1], Order) = Bigger then begin
        tmp := pages[i+1];
        pages[i+1] := pages[i];
        pages[i] := tmp;
        changed := true;
      end;
    end;
  until not changed;
end;

function part2(var input: Text):comp; far;
var pages  : array[0..31] of longint;
    count  : word;
    sum    : comp;
begin
  sum := 0;
  loadOrder(input, order);
  while not eof(input) do begin
    count := readLongArray(input,pages);
    if count > 0 then begin
      if not checkOrder(pages, count, order) then begin
        sortPages(pages,count);
        assert(checkOrder(pages, count, order),'Still invalid book found');
        sum := sum + pages[count div 2];
      end;
    end;
  end;

  part2 := sum;
end;

begin
  runAoc(InputFileName, 5, part1, part2);
end.
