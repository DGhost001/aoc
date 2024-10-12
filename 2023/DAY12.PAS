program day12;
uses jstring, dequeue, progressBar, utils,crt;
type TState = (Unknown, Broken, Working);
     TReport = record
       numberOfSprings     : byte;
       numberControlGroups : byte;
       springStates : array [0..23] of TState;
       control      : array [0..11] of byte;
     end;
const InputFile = 'INP\DAY12_IN.TXT';

function validReport(const report : TReport) : boolean;
var result    : boolean;
    group     : byte;
    pos       : byte;
    controlPos: byte;
begin
  result := true;
  with report do begin
    group      := 0;
    controlPos := 0;
    for pos := 0 to numberOfSprings-1 do begin
      case springStates[pos] of
        Unknown: begin result := false; break; end; (* One State unknown, still broken *)
        Broken : inc(group);
        Working: begin
          if group > 0 then begin
           if (controlPos < numberControlGroups) and
              (control[controlPos] = group) then begin
             inc(controlPos)
           end else begin
             result := false;
             break;
           end
          end;
          group := 0;
        end;
      end;
    end;
    if (group > 0) and
       (controlPos < numberControlGroups) and
       (control[controlPos] = group) then begin
       group := 0;
       inc(controlPos);
    end;
  end;
  validReport := (controlPos = report.numberControlGroups) and (group = 0) and result;
end;

procedure countSpringTypes(const report: TReport; var good, failed : byte);
var pos : byte;
begin
  with report do begin
    failed := 0;
    for pos := 0 to numberControlGroups-1 do
       inc(failed, control[pos]);
    good := numberOfSprings - failed;
  end;
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

function part1(var input : Text):longint;
var report : TReport;

  function countOptions(const pgood, pfailed, pstart : byte) : word;
  var result : word;
      good, failed, start : byte;
  begin
   good   := pgood;
   failed := pfailed;
   start  := pstart;
   result := 0;
   if validReport(report) then begin
     result := 1;
     for start := 0 to report.numberOfSprings-1 do
     case report.springStates[start] of
        Unknown: write('?');
        Working: write('.');
        Broken : write('#');
     end;
     writeln;
   end
   else with report do begin
     while (start < numberOfSprings) and
           (springStates[start] <> Unknown) do
           inc(start);
     if start < numberOfSprings then begin
       if failed > 0 then begin
         springStates[start] := Broken;
         result:= result + countOptions(good, failed - 1, start + 1);
       end;
       if good > 0 then begin
         springStates[start] := Working;
         result := result + countOptions(good - 1, failed, start + 1);
       end;
       springStates[start] := Unknown;
     end;
   end;
   countOptions := result;
  end;
var line : PJString;
    sline: PJString;
    items: PDequeue;
    count: longint;
    good, failed : byte;
    p : TProgressbar;
begin

  p.init(countLines(input),'Thinking...');
  clrscr;
  writeln('--- Start ---');
  count := 0;
  while not eof(input) do begin
    line := readLine(input);
    sline:= line^.stripWhiteSpace;

    items := sline^.split(' ');

    parseReport(items, report);
    countSpringTypes(report, good, failed);

    count:=count + countOptions(good, failed, 0);
    writeln('------------------');
    items^.dispose;
    sline^.dispose;
    line^.dispose;
    p.step(1);
  end;

  p.done;
  part1 := count;
end;

var input : Text;
    p1    : longint;
begin
  assign(input, InputFile);
  reset(input);

  p1 := part1(input);

  close(input);

  writeln('Part1 Answer: ',p1);
end.
