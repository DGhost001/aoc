program day13;
(*This is the implementation of the aoc24 day 13*)
(* The Math in a nutshell:
   x = a * xa + b * xb
   y = a * ya + b * yb

   x     xa
   -- =  -- * a + b ; y analogous
   xb    xb

   x    y     / xa   ya \
   -- - -- =  | -- - -- | * a
   xb   yb    \ xb   yb /

   x * yb - y * xb    xa * yb - ya * xb
   ---------------  = ----------------- * a
       xb * yb            xb * yb

   x  * yb - y  * xb
   -----------------  = a
   xa * yb - ya * xb

        x  -  xa * a
        ------------  = b
            xb
*)
uses aoc, utils;
const InputFileName = 'INP\DAY13_IN.TXT';

procedure computeAB(const ba, bb, p : TPos;
                    var   a , b : double);
begin
  a := ( p.x * bb.y -  p.y * bb.x) /
       (ba.x * bb.y - ba.y * bb.x);
  b := (p.x - ba.x * a) / bb.x;
end;

procedure computeAB2(const ba, bb, p : TPos;
                    var   a , b : double);
var px, py : double;
begin
  px := p.x + 10000000000000.0;
  py := p.y + 10000000000000.0;
  a := ( px * bb.y -  py * bb.x) /
       (ba.x * bb.y - ba.y * bb.x);
  b := (px - ba.x * a) / bb.x;
end;


procedure parseButton(var input: Text; var b : TPos);
var c : char;
begin
  read(input,c);
  while c <> '+' do read(input,c);
  b.x := readLong(input);
  read(input,c);
  while c <> '+' do read(input,c);
  b.y := readLong(input);
  read(input,c);
end;

procedure parsePrize(var input : Text; var p : TPos);
var c : char;
begin
  read(input,c);
  while c <> '=' do read(input,c);
  p.x := readLong(input);
  read(input,c);
  while c <> '=' do read(input,c);
  p.y := readLong(input);
  read(input,c);
end;

procedure parseInput(var input : Text; var a,b,p : TPos);
begin
  parseButton(input, a);
  parseButton(input, b);
  parsePrize(input, p);
  readln(input);
end;

function part1(var input: Text):comp; far;
var ba, bb, p : TPos;
     a, b     : double;
     sum      : comp;
begin
  sum := 0;
  while not eof(input) do begin
    parseInput(input, ba,bb,p);
    computeAB(ba, bb, p, a, b);
    if (trunc(a) = a) and (trunc(b) = b) and (a <= 100) and (b <= 100) then
      sum := sum + (a * 3 + b);
  end;
  part1 := sum;
end;

function part2(var input: Text):comp; far;
var ba, bb, p : TPos;
     a, b     : double;
     sum      : comp;
begin
  sum := 0;
  while not eof(input) do begin
    parseInput(input, ba,bb,p);
    computeAB2(ba, bb, p, a, b);
    if (frac(a) = 0.0) and (frac(b) = 0.0) then
      sum := sum + (a * 3 + b);
  end;
  part2 := sum;
end;

begin
  runAoc(InputFileName, 13, part1, part2);
end.
