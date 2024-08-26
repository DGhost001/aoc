program day1;
uses crt;

(* This is the implementation for the advent of code 2023 Day 1 *)

const InputFileName : string = 'DAY1_INP.TXT';
const Numbers       : set of char = ['0'..'9'];

function charToInt(const c:char): integer;
begin
  if c in Numbers then begin
    charToInt := ord(c) - ord('0');
  end else
    charToInt := -1;
end;

function firstNumberFromLeft(s:string):integer;
var pos   : integer;

begin
  pos := 1;

  while (pos <= length(s)) and (charToInt(s[pos]) < 0) do inc(pos);

  if (pos <= length(s)) then
    firstNumberFromLeft := charToInt(s[pos])
  else
    firstNumberFromLeft := -1;
end;

function firstNumberFromRight(s:string):integer;
var pos   : integer;

begin
  pos := length(s);

  while (pos > 0) and (charToInt(s[pos]) < 0) do dec(pos);

  if (pos > 0) then
    firstNumberFromRight := charToInt(s[pos])
  else
    firstNumberFromRight := -1;
end;

var sum         : longint;
    input       : Text;
    line        : string;
    left, right : integer;
begin
  clrscr;
  sum := 0;

  assign(input,InputFileName);
  reset(input);

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

  writeln('The day-1 sum is: ',sum);
end.
