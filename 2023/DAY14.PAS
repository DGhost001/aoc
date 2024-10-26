program day14;
uses ProgressBar;
const MaxDim = 128;
      InputFile = 'INP\DAY14_IN.TXT';
type TRocks = (None, Round, Square);
     TMap   = record
        map        : array[0..MaxDim -1, 0..MaxDim-1] of TRocks;
        xdim, ydim : byte;
     end;

procedure RockAndRoll(var platform : TMap);
var line, column, drop : byte;
begin
  with platform do begin
    for line := 1 to ydim - 1 do begin
      for column := 0 to xdim -1 do begin
        (* Check for round Rocks *)
        if map[line, column] = Round then begin
          drop := line - 1;
          while (drop > 0) and (map[drop,column] = None) do dec(drop);
          if map[drop, column] <> None then inc(drop);
          map[line, column] := None;
          map[drop, column] := Round;
        end;
      end;
    end;
  end;
end;

function weightRocks(const platform : TMap) : longint;
var row, column : byte;
    rocks       : byte;
    result      : longint;
begin
  result := 0;
  with platform do begin
    for row := 0 to ydim - 1 do begin
      rocks := 0;
      for column := 0 to xdim -1 do begin
        if map[row, column] = Round then inc(rocks);
      end;
      inc(result,(ydim - row) * rocks);
    end;
  end;
  weightRocks := result;
end;

procedure loadPlatformMap(var input: Text; var platform : TMap);
var x   : byte;
    line: string;
begin
  with platform do begin
   xdim := 0;
   ydim := 0;
   while not eof(input) do begin
     readln(input, line);
     if (xdim <> 0) and( length(line) <> xdim) then break
     else if xdim = 0 then xdim := length(line);
     inc(ydim);

     for x:=1 to xdim do case line[x] of
         '.': map[ydim-1, x-1] := None;
         '#': map[ydim-1, x-1] := Square;
         'O': map[ydim-1, x-1] := Round;
     end;
   end;
  end;
end;

var platform : TMap;
function part1(var input: Text) : longint;
begin
  loadPlatformMap(input, platform);
  RockAndRoll(platform);
  part1 := weightRocks(platform);
end;

var input : Text;
    p1    : longint;
begin
  assign(input, InputFile);
  reset(input);
  p1 := part1(input);
  close(input);

  writeln('Answer to part1 is: ', p1);
end.
