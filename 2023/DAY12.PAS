program day12;
{$N+} {$E+}
uses jstring, dequeue, progressBar, utils,crt;
type PCacheLine = ^TCacheLine;
     TCacheLine = array [0..63,0..1] of comp;
     TCache     = array [0..127] of PCacheLine;

     TState = (Unknown, Broken, Working);
     TStateArray = array [0..127] of TState;
     TReport = record
       numberOfSprings     : byte;
       numberControlGroups : byte;
       springStates : TStateArray;
       control      : array [0..63] of byte;
     end;
const InputFile = 'INP\DAY12_IN.TXT';

var cache : TCache;
    ch    : longint;
procedure flushCache;
var line : byte;
begin
  (* writeln('Cache hits: ',ch);*)
  ch:=0;
  for line := 0 to 127 do
    if cache[line] <> NIL then begin
      dispose(cache[line]);
      cache[line] := NIL;
    end;
end;

procedure addToCache(const pos, group, run : byte; const value : comp);
var i,j : byte;
begin
  if cache[pos] = NIL then begin
    cache[pos] := new(PCacheLine);
    for i:=0 to 63 do begin
     cache[pos]^[i,0] := -1;
     cache[pos]^[i,1] := -1;
    end;
  end;

  cache[pos]^[group][run] := value;
end;

function checkCache(const pos, group, run : byte; var value : comp) : boolean;
begin
  if (cache[pos] <> NIL) and (cache[pos]^[group,run] <> -1) then begin
    value := cache[pos]^[group,run];
    checkCache := true;
    inc(ch);
  end else checkCache := false;
end;

procedure initCache;
var line : byte;
begin
  for line := 0 to 127 do cache[line] := NIL;
end;

procedure parseReport(const items : PDequeue;  var report : TReport);
var s       : PJString;
    pos     : byte;
    tmp     : integer;
    it      : PJStringIterator;
    it2     : PDequeueIterator;
    elements: PDequeue;
begin
  with report do begin
    s := PJString(items^.at(0));
    it:= s^.first;
    pos := 0;
    while it^.valid do begin
      case char(it^.at^) of
        '?' : springStates[pos] := Unknown;
        '.' : springStates[pos] := Working;
        '#' : springStates[pos] := Broken;
      else runError(300); (* Not a valid input character *)
      end;
      it^.next;
      inc(pos);
    end;
    numberOfSprings := pos;
    it^.dispose;

    (*--- Spring State is loaded, load the control now ---*)

    elements := PJString(items^.at(1))^.split(',');
    pos := 0;
    it2 := elements^.first;

    while it2 <> NIL do begin
      val(PJString(it2^.at)^.toString, control[pos], tmp);
      inc(pos);
      it2:=it2^.next;
    end;
    numberControlGroups := pos;
    elements^.dispose;
  end;
end;

procedure printSprings(const states : TStateArray; const len : byte);
var pos : byte;
begin
  for pos := 0 to len-1 do
   case states[pos] of
      Unknown: write('?');
      Working: write('.');
      Broken : write('#');
   end;
  writeln;
end;

function count(const report : TReport):comp;
  function countOptions(pos, group, run: byte) : comp;
  var finished : boolean;
      count    : comp;
      p,g,r    : byte;
  begin
    p := pos;
    g := group;
    r := run;

    if not checkCache(p,g,r,count) then
      with report do begin
       finished := false;
       count := 0;
       repeat
         if keypressed then runError(302);
         if (pos >= numberOfSprings) and (
          (
           (run > 0) and (group = numberControlGroups - 1) and (control[group] = run)
          ) or (group >= numberControlGroups)) then begin
           count:=count+1;
           finished := true;
         end else if (pos >= numberOfSprings) or
               (group > numberControlGroups) or
               ((group < numberControlGroups) and (run > control[group]))
         then begin
           finished := true;
         end else begin
           case springStates[pos] of
             Broken : begin
                     if group < numberControlGroups then begin
                       inc(run);
                       inc(pos);
                     end else begin
                       count := 0;
                       finished := true;
                     end
                    end;
             Working: begin
                      inc(pos);
                      if (run > 0) and (run = control[group]) then begin
                        run  := 0;
                        inc(group);
                      end else if run > 0 then begin
                        count := 0;
                        finished := true;
                      end;
                  end;
             Unknown: begin
                    if (run > 0) and ( run < control[group]) then begin
                      inc(pos);
                      inc(run);
                    end else if (group < numberControlGroups) and (run = control[group]) then begin
                      run := 0;
                      inc(group);
                      inc(pos);
                    end else if (group = numberControlGroups) and (run = 0) then begin
                      inc(pos);
                    end else begin
                      count := count + countOptions(pos+1, group, 1);
                      count := count + countOptions(pos+1, group, 0);
                      finished := true;
                    end;
             end;
           end;
         end;
       until finished;
       addToCache(p,g,r,count);
      end;

    countOptions := count;
  end;
begin
  flushCache;
  count := countOptions(0,0,0);
end;

function part1(var input : Text):longint;
var line : PJString;
    sline: PJString;
    items: PDequeue;
    c: longint;
    c1, c2: word;
    good, failed : byte;
    p : TProgressbar;
    report: TReport;
begin

  p.init(countLines(input),'Thinking...');
  c:= 0;
  while not eof(input) do begin
    line := readLine(input);
    sline:= line^.stripWhiteSpace;

    items := sline^.split(' ');

    parseReport(items, report);
    c2:= trunc(count(report));
    c := c + c2;
    items^.dispose;
    sline^.dispose;
    line^.dispose;
    p.step(1);
  end;

  p.done;
  part1 := c;
end;

procedure appendToReport(const spring : TState; var report : TReport);
begin
  report.springStates[report.numberOfSprings] := spring;
  inc(report.numberOfSprings);
end;

procedure appendReport(const r1 : TReport; var r2 : TReport);
var i : integer;
begin
  for i:= 0 to r1.numberOfSprings-1 do
    r2.springStates[r2.numberOfSprings+i] := r1.springStates[i];

  for i:= 0 to r1.numberControlGroups-1 do
    r2.control[r2.numberControlGroups+i] := r1.control[i];

  inc(r2.numberOfSprings,r1.numberOfSprings);
  inc(r2.numberControlGroups, r1.numberControlGroups);
end;

procedure unfoldReport(const r1 : TReport; var r2 : TReport);
var i : integer;
begin
  r2.numberOfSprings := 0;
  r2.numberControlGroups := 0;
  appendReport(r1, r2);
  for i:= 1 to 4 do begin
   appendToReport(Unknown, r2);
   appendReport(r1, r2);
  end;
end;

function part2(var input : Text):comp;
var line : PJString;
    sline: PJString;
    items: PDequeue;
    c: comp;
    c2: comp;
    good, failed : byte;
    p : TProgressbar;
    report, r2: TReport;
begin

  p.init(countLines(input),'Thinking...');
  c:= 0;
  while not eof(input) do begin
    line := readLine(input);
    sline:= line^.stripWhiteSpace;

    items := sline^.split(' ');

    parseReport(items, report);
    unfoldReport(report, r2);
    c2:= count(r2);
    c := c + c2;
    items^.dispose;
    sline^.dispose;
    line^.dispose;
    p.step(1);
  end;

  p.done;
  part2 := c;
end;


var input : Text;
    p1    : longint;
    p2    : comp;
begin
  initCache;
  assign(input, InputFile);
  reset(input);

  p1 := part1(input);
  reset(input);
  p2 := part2(input);

  close(input);

  writeln('Part1 Answer: ',p1);
  writeln('Part2 Answer: ',p2:1:0);
end.
