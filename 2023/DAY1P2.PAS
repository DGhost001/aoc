program day1p2;
uses crt;

(* This is the implementation for the advent of code 2023 Day 2 *)

const InputFileName : string = 'DAY1_INP.TXT';
const Numbers        : set of char = ['0'..'9'];
const NumberWords    : array [1..9] of string =
('one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine');

function charToInt(const c:char): integer;
begin
  if c in Numbers then begin
    charToInt := ord(c) - ord('0');
  end else
    charToInt := -1;
end;

function lettersToInt(const s:string; const start: integer): integer;
var i,j    : integer;
    result : integer;
begin
  result := -1;
  i := 1;
  while (i <= high(NumberWords)) and (result < 0) do begin
    if (length(NumberWords[i]) + start - 1 <= length(s)) then begin
      j := 1;
      while (j <= length(NumberWords[i])) and
            (NumberWords[i][j] = s[start + j - 1])
      do
        inc(j);

      if j > length(NumberWords[i]) then
        result := i;

    end;
    inc(i);
  end;
  lettersToInt := result;
end;

function firstNumberFromLeft(s:string):integer;
var pos   : integer;

begin
  pos := 1;

  while (pos <= length(s)) and
        (charToInt(s[pos]) < 0) and
        (lettersToInt(s, pos) < 0)
  do
    inc(pos);

  if (pos <= length(s)) then begin
    if (charToInt(s[pos]) >= 0) then
      firstNumberFromLeft := charToInt(s[pos])
    else
      firstNumberFromLeft := lettersToInt(s, pos);
  end else
    firstNumberFromLeft := -1;
end;

function firstNumberFromRight(s:string):integer;
var pos   : integer;

begin
  pos := length(s);

  while (pos > 0) and
        (charToInt(s[pos]) < 0) and
        (lettersToInt(s, pos) < 0)
  do
    dec(pos);

  if (pos > 0) then begin
    if (charToInt(s[pos]) >= 0) then
      firstNumberFromRight := charToInt(s[pos])
    else
      firstNumberFromRight := lettersToInt(s, pos);
  end else
    firstNumberFromRight := -1;
end;

var sum         : longint;
    input       : Text;
    line        : string;
    left, right : integer;
begin
  sum := 0;

  assign(input,InputFileName);
  reset(input);

  (* line := '8blvspztqjnine854fivefour';*)

  while not eof(input) do begin
    readln(input, line);
    left := firstNumberFromLeft(line);
    right:= firstNumberFromRight(line);

    if (left >= 0) and (right >= 0) then
      sum := sum + left * 10 + right
    else
      writeln('Illegal Input encountered ... skipping line');
  end;

  close(input);

  writeln('The day-1p2 sum is: ',sum);
end.
