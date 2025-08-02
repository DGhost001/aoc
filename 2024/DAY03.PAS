program day03;
(*This is the implementation of the aoc24 day 3*)

uses aoc;
const InputFileName = 'INP\DAY03_IN.TXT';
type FMatcher = function (const c : char; const p : word) : boolean;
     TMatching= record
        matcher : FMatcher;
        yes     : word;
        no      : word;
        param   : word;
     end;

function isNumber(const c: char; const p : word):boolean; far; forward;
function isChar  (const c: char; const p : word):boolean; far; forward;

(*
  * - m - u - l - ( - # - # - #-, - # - # - # - )
      |   |   |   |   |   |   |   | |   |   |
      x   x   x   x   |   | x-,---+
                      |   ,-------+
                      ,-----------+
*)

const Part1Matcher : array [0..11] of TMatching =
(*0*)   ( (matcher : isChar;   yes : 1;  no : 0;  param : ord('m')),
(*1*)     (matcher : isChar;   yes : 2;  no : 0;  param : ord('u')),
(*2*)     (matcher : isChar;   yes : 3;  no : 0;  param : ord('l')),
(*3*)     (matcher : isChar;   yes : 4;  no : 0;  param : ord('(')),
(*4*)     (matcher : isNumber; yes : 5;  no : 0;  param : 0),
(*5*)     (matcher : isNumber; yes : 6;  no : 7;  param : 0),
(*6*)     (matcher : isNumber; yes : 7;  no : 7;  param : 0),
(*7*)     (matcher : isChar;   yes : 8;  no : 0;  param : ord(',')),
(*8*)     (matcher : isNumber; yes : 9;  no : 0;  param : 0),
(*9*)     (matcher : isNumber; yes : 10; no : 11; param : 0),
(*10*)    (matcher : isNumber; yes : 11; no : 11; param : 0),
(*11*)    (matcher : isChar;   yes : 12; no : 0;  param : ord(')'))
);
      Part2Matcher1: array [0..3] of TMatching =
      ( (matcher : isChar; yes : 1; no : 0; param : ord('d')),
        (matcher : isChar; yes : 2; no : 0; param : ord('o')),
        (matcher : isChar; yes : 3; no : 0; param : ord('(')),
        (matcher : isChar; yes : 4; no : 0; param : ord(')'))
);
      Part2Matcher2: array [0..6] of TMatching =
      ( (matcher : isChar; yes : 1; no : 0; param : ord('d')),
        (matcher : isChar; yes : 2; no : 0; param : ord('o')),
        (matcher : isChar; yes : 3; no : 0; param : ord('n')),
        (matcher : isChar; yes : 4; no : 0; param : ord('''')),
        (matcher : isChar; yes : 5; no : 0; param : ord('t')),
        (matcher : isChar; yes : 6; no : 0; param : ord('(')),
        (matcher : isChar; yes : 7; no : 0; param : ord(')'))
);

function matchString(const s : string;
                     matcher : array of TMatching) : boolean;
  function getNextIndex( const matcher : array of TMatching;
                         c : char;
                         idx : word) : word;
  var result : word;
  begin
    result := idx;
    repeat
      if matcher[result].matcher(c, matcher[result].param) then begin
        result := matcher[result].yes;
        break;
      end else
        result := matcher[result].no;
    until (result = 0) or ( result > HIGH(matcher));
    getNextIndex := result;
  end;


var idx, i : word;
begin
  i   := 1;
  idx := getNextIndex(matcher, s[i], 0);
  inc(i);
  while (idx <> 0) and (i <= length(s)) and (idx <= HIGH(matcher)) do begin
    idx := getNextIndex(matcher, s[i], idx);
    inc(i);
  end;
  matchString := idx > HIGH(matcher);
end;

function isNumber(const c: char; const p : word):boolean;
begin
  isNumber := c in ['0'..'9'];
end;

function isChar  (const c: char; const p : word):boolean;
begin
  isChar := ord(c) = p;
end;

function part1(var input: Text):comp; far;
var s : string;
    n1, n2: string;
    p1, p2, p3 : byte;
    i : integer;
    t1, t2: comp;
    sum   : comp;
    c : char;
begin
  s := '';
  sum := 0;
  while not eof(input) do begin
    read(input, c);
    s := s + c;
    while length(s) > (HIGH(Part1Matcher)+1) do
      delete(s,1,1);
    if matchString(s,Part1Matcher) then begin
      p1 := pos('(',s);
      p2 := pos(',',s);
      p3 := pos(')',s);
      n1 := copy(s, p1 + 1, p2 - p1 - 1);
      n2 := copy(s, p2 + 1, p3 - p2 - 1);
      val(n1,t1,i);
      val(n2,t2,i);
      sum := sum + t1*t2;
    end;
  end;

  part1 := sum;
end;

function part2(var input: Text):comp; far;
var s          : string;
    n1, n2     : string;
    p1, p2, p3 : byte;
    i          : integer;
    t1, t2     : comp;
    sum        : comp;
    c          : char;
    enable     : boolean;
begin
  s := '';
  sum := 0;
  enable := True;
  while not eof(input) do begin
    read(input, c);
    s := s + c;
    while length(s) > (HIGH(Part1Matcher)+1) do
      delete(s,1,1);
    if not enable and matchString(s, Part2Matcher1) then
      enable := True
    else if enable and matchString(s, Part2Matcher2) then
      enable := False
    else if enable and matchString(s, Part1Matcher) then begin
      p1 := pos('(',s);
      p2 := pos(',',s);
      p3 := pos(')',s);
      n1 := copy(s, p1 + 1, p2 - p1 - 1);
      n2 := copy(s, p2 + 1, p3 - p2 - 1);
      val(n1,t1,i);
      val(n2,t2,i);
      sum := sum + t1*t2;
    end;
  end;

  part2 := sum;
end;

begin
  runAoc(InputFileName, 3, part1, part2);
end.
