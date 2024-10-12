program day12;
uses jstring, dequeue, progressBar;
type TState = (Unknown, Broken, Working);
     TReport = record
       numberOfSprings     : byte;
       numberControlGroups : byte;
       springStates : array [0..23] of TState;
       control      : array [0..11] of byte;
     end;

function validReport(const report : TReport) : boolean;
var result    : boolean;
    group     : byte;
    pos       : byte;
    controlPos: byte;
begin

  with report do begin
    group      := 0;
    controlPos := 0;
    for pos := 0 to numberOfSprings do begin
      case springStates[pos] of
        Unknown: begin result := false; exit; end; (* One State unknown, still broken *)
        Broken : inc(group);
        Working: begin
          if group > 0 then begin
           if (controlPos < numberControlGroups) and
              (control[controlPos] = group) then begin
             inc(controlPos)
           end else begin
             result := false;
             exit;
           end
          end;
          group := 0;
        end;
      end;
    end;
  end;
  result := true;
  validReport := result;
end;

procedure countSpringTypes(const report: TReport; var good, failed : byte);
var pos : byte;
begin
  with report do begin
    failed := 0;
    for pos := 0 to numberControlGroups do
       inc(failed, control[pos]);
    good := numberOfSprings - failed;
  end;
end;

function part1(var input : Text):longint;
var report : TReport;

  function countOptions(good, failed, start : byte) : word;
  var result : word;
  begin
   result := 0;
   if validReport(report) then result := 1
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
begin
  count := 0;
  while not eof(input) do begin
    line := readLine(input);
    sline:= line^.stripWhiteSpace;

    items := sline^.split(' ');

    parseReport(report,items);
    countSpringTypes(report, good, failed);

    count:=count + countOptions(good, failed, 0);

    items^.dispose;
    sline^.dispose;
    line^.dispose;
  end;
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
