program day9;
{$N+ $E+}
(* This is the Program for day 9 of the advent of code 2023 *)

uses JString,Dequeue;

type
    TSequence = array [0..23] of double;

const
    InputFile = 'INP\DAY9_INP.TXT';

function isSequenceClear(seq : TSequence;min,max : word) : boolean;
var i      : word;
    result : boolean;
begin
  result := true;
  for i := min to max do
    result := result and (seq[i] = 0.0);
  isSequenceClear := result;
end;

procedure clearSequence(var seq : TSequence);
var i : word;
begin
  for i := LOW(seq) to HIGH(seq) do
    seq[i] := 0.0;
end;

function differentiate(var seq : TSequence; len : word) : word;
var tmp    : TSequence;
    offset : word;
    i      : word;
begin
  clearSequence(tmp);
  offset := 0;
  while not isSequenceClear(seq,offset,len) do begin
    inc(offset);
    tmp[offset - 1] := seq[offset - 1];

    for i:= offset to len do
      tmp[i] := seq[i] - seq[i-1];

    seq := tmp;
  end;
  differentiate := offset;
end;

function integrate(var seq:TSequence; offset, len :word): double;
var  i: word;
     p: double;
begin
  p := 0;
  while offset > 0 do begin
   for i:= offset to len do
     seq[i]:= seq[i-1] + seq[i];
   p:= seq[offset-1] - p;
   dec(offset);
  end;
  integrate := p;
end;

function loadSequence(var seq:TSequence;var input : Text): word;
var line : PJString;
    str  : PJString;
    list : PDequeue;
    it   : PDequeueIterator;
    s    : string;
    i    : word;
    code : integer;

begin
  line := readLine(input);
  str  := line^.stripWhiteSpace;
  list := str^.split(' ');

  it := list^.first;

  i:= 0;

  while it <> nil do begin
    s:=PJString(it^.at)^.toString;
    val(s,seq[i],code);
    inc(i);
    if (i > HIGH(seq)) or (code <>0) then runError(300);
    it := it^.next;
  end;

  dispose(list);
  dispose(str);
  dispose(line);
  loadSequence:=i-1;
end;
var input     : Text;
    deg,len   : word;
    seq       : TSequence;
    sum       : double;
    sum2      : double;
begin
  assign(input, InputFile);
  reset(input);
  writeln('Processing Data...');
  sum  := 0.0;
  sum2 := 0.0;
  while not eof(input) do begin
    clearSequence(seq);
    len := loadSequence(seq,input);
    deg := differentiate(seq, len);
    if len >= HIGH(seq) then runError(300);
    sum2 := sum2 + integrate(seq, deg, len + 1);
    writeln('Deg: ',deg,#9,' Val: ',seq[len+1]:1:0);
    sum :=sum + seq[len+1];
  end;
  writeln('Then Answer is: ',sum:1:0);
  writeln('Then Answer Part 2 is: ',sum2:1:0);
end.
