program day11;
(*This is the implementation of the aoc24 day 11*)

uses crt,aoc, stdint, utils, progressbar;
const InputFileName = 'INP\DAY11_IN.TXT';
      NumBlinks     = 25;
      NumBlinks2    = 75;

var cache : array[0..75,0..99] of uint64_t;


procedure countStones(number    : uint64_t;
                      iterations: byte;
                      var result: uint64_t;
                      var p     : TProgressbar);

var i              : longint;
    tmp, r         : uint64_t;
    cj             : longint;
    j    , cit,cidx: byte;
begin
  result := Zero64;

  cj     := ilog10(number);
  cit    := iterations;
  cidx   := number[0];

  if (cj <= 1) and (not isNull64(cache[cit,cidx])) then
     result := cache[cit,cidx];

  while isNull64(result) do begin
(*   writeln(iterations,' ',uint64ToStr(number)); *)
   if iterations = 0 then result := One64
   else begin
     if isNull64(number) then begin
       number := one64;
       dec(iterations);
     end else begin
      i := ilog10(number)+1;
      if i <= 2 then begin
        j := number[0];
        if not isNull64(cache[iterations,j]) then begin
          result := cache[iterations,j];
          break;
        end;
      end;
      if (getParity(i) = Even) and (i > 0) then begin
        pow10(i div 2, tmp);
        div64(number, tmp, r);
        countStones(number, iterations - 1, result,p);
        countStones(r, iterations - 1, tmp,p);
        add64(result,tmp);
      end else begin
        mul64LongInt(number, 2024);
        dec(iterations);
      end;
     end;
   end;
  end;
  p.step(0);
  if (cj <= 1)  and isNull64(cache[cit,cidx]) then
    cache[cit, cidx] := result;
end;

function part1(var input: Text):comp; far;
var numbers : array[0..8] of uint64_t;
    count   : word;
    i       : integer;
    sum,result     : uint64_t;
    p       : TProgressbar;
begin
  sum := zero64;
  count := readUint64Array(input,numbers);

  p.init(count,'Count');

  for i := 0 to count - 1 do begin
   countStones(numbers[i], NumBlinks, result,p);
   add64(sum, result);
   p.step(1);
  end;

  p.done;
  part1 := uint64ToComp(sum);
end;

function part2(var input: Text):comp; far;
var numbers : array[0..8] of uint64_t;
    count   : word;
    i       : integer;
    sum,result     : uint64_t;
    p       : TProgressbar;
begin
  sum := zero64;
  count := readUint64Array(input,numbers);

  p.init(count,'Count');

  for i := 0 to count - 1 do begin
   countStones(numbers[i], NumBlinks2, result,p);
   add64(sum, result);
   p.step(1);
  end;

  p.done;
  part2 := uint64ToComp(sum);

end;

procedure preFillCache;
var p : TProgressbar;
    it, idx : byte;
    tmp, r  : uint64_t;
begin
  fillchar(cache,sizeof(cache),0);
  p.init(7600,'Build');
  for  it := 0 to 75 do
    for idx := 0 to 99 do begin
      fromLongInt64(idx, tmp);
      countStones(tmp, it, r, p);
      p.step(1);
    end;
  p.done;
end;


begin
  preFillCache;
  runAoc(InputFileName, 11, part1, part2);
end.
