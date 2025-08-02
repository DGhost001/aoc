program day07;
(*This is the implementation of the aoc24 day 1*)

uses aoc, utils, stdint, progressbar, cassert;
type TOperation = (Addition, Multiplication, Concatination);


const InputFileName = 'INP\DAY07_IN.TXT';

var validCache : array[0..1023] of boolean;

function isValid(var   result : uint64_t;
                 var   total  : uint64_t;
                 var   numbers: array of Uint64_t;
                 const idx    : word;
                 const count  : word;
                 const maxOp  : TOperation
                 ): boolean;
const ten : uint64_t = (10,0,0,0,0,0,0,0);
var tmp : uint64_t;
    op  : TOperation;
    log : integer;
      i : integer;
begin
  if idx > count then isValid := false else
  if idx = count then isValid := isEqual64(total, result) else
  if isGreater64(total, result) then isValid := false else begin
    isValid := false;
    for op:= Addition to maxOp do begin
      tmp := total;
      case op of
        Addition:       add64(tmp, numbers[idx]);
        Multiplication: mul64(tmp, numbers[idx]);
        Concatination: begin
          log := ilog10(numbers[idx]) + 1;
          assert(log > 0,'0 is not supported');
          for i := 1 to log do mul64(tmp,ten);
          add64(tmp, numbers[idx]);
        end;
      end;
      if isValid(result, tmp, numbers, idx + 1, count, maxOp) then begin
        isValid := true;
        break;
      end;
    end;
  end
end;

function part1(var input: Text):comp; far;
var numbers : array[0..15] of Uint64_t;
    count   : word;
    result  : uint64_t;
    p       : TProgressBar;
begin
  fillchar(validCache,sizeof(validCache), 0);
  result := zero64;
  p.init(countLines(input),'mmpf');
  while not eof(input) do begin
    count := readUint64Array(input, numbers);
    if isValid(numbers[0], numbers[1], numbers, 2, count, Multiplication) then begin
      add64(result, numbers[0]);
      validCache[p.progress_] := true;
    end;
    p.step(1);
  end;
  p.done;
  part1 := uint64ToComp(result);
end;

function part2(var input: Text):comp; far;
var numbers : array[0..15] of Uint64_t;
    count   : word;
    result  : uint64_t;
    p       : TProgressBar;
begin
  result := zero64;
  p.init(countLines(input),'mmpf');
  while not eof(input) do begin
    count := readUint64Array(input, numbers);
    if validCache[p.progress_] or
       isValid(numbers[0], numbers[1], numbers, 2, count, Concatination) then begin
      add64(result, numbers[0]);
    end;
    p.step(1);
  end;
  p.done;
  part2 := uint64ToComp(result);
end;
var n : Uint64_t;
begin
  runAoc(InputFileName, 7, part1, part2);
end.
