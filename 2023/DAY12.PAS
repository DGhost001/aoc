program day12;
uses jstring, dequeue, progressBar, utils,crt;
type TState = (Unknown, Broken, Working);
     TStateArray = array [0..23] of TState;
     TReport = record
       numberOfSprings     : byte;
       numberControlGroups : byte;
       springStates : TStateArray;
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

function part1(var input : Text):longint;
var report : TReport;
    final  : TStateArray;
  function countOptions2(pos, group, run: byte) : word;
  var finished : boolean;
      count    : word;
  begin
    with report do begin
     finished := false;
     count := 0;
     repeat
       if (pos >= numberOfSprings) and (
        (
         (run > 0) and (group = numberControlGroups - 1) and (control[group] = run)
        ) or (group >= numberControlGroups)) then begin
         inc(count);
         printSprings(final, report.numberOfSprings);
         finished := true;
       end else if (pos >= numberOfSprings) or
             (group > numberControlGroups) or
             ((group < numberControlGroups) and (run > control[group]))
       then begin
         finished := true;
       end else begin
         final[pos] := springStates[pos];
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
                    final[pos] := Broken;
                    inc(pos);
                    inc(run);
                  end else if (group < numberControlGroups) and (run = control[group]) then begin
                    final[pos] := Working;
                    run := 0;
                    inc(group);
                    inc(pos);
                  end else if (group = numberControlGroups) and (run = 0) then begin
                    final[pos] := Working;
                    inc(pos);
                  end else begin
                    final[pos] := Broken;
                    count := count + countOptions2(pos+1, group, 1);
                    final[pos] := Working;
                    count := count + countOptions2(pos+1, group, 0);
                    finished := true;
                  end;
           end;
         end;
       end;
     until finished;
    end;

    countOptions2 := count;
  end;

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
     printSprings(report.springStates, report.numberOfSprings);
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
    c1, c2: word;
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
   (* countSpringTypes(report, good, failed);
    c1:= countOptions(good, failed, 0);
    writeln('------------------'); *)
    c2:= countOptions2(0, 0, 0);
    count := count + c2;
(*    if c1 <> c2 then begin
      writeln('Error in line ', p.progress_,' ',c1,'<>',c2);
      runError(300);
    end; *)
    writeln('===================');
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
