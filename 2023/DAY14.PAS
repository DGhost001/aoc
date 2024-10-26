program day14;
uses ProgressBar,crt;
const MaxDim = 128;
      InputFile = 'INP\DAY14_TE.TXT';
type TRocks = (None, Round, Square);
     TMap   = record
        map        : array[0..MaxDim -1, 0..MaxDim-1] of TRocks;
        xdim, ydim : byte;
     end;

procedure RockAndRollNorth(var platform : TMap);
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

procedure RockAndRollSouth(var platform : TMap);
var line, column, drop : byte;
begin
  with platform do begin
    for line := ydim - 2 downto 0 do begin
      for column := 0 to xdim -1 do begin
        (* Check for round Rocks *)
        if map[line, column] = Round then begin
          drop := line + 1;
          while (drop < ydim - 1) and (map[drop,column] = None) do inc(drop);
          if map[drop, column] <> None then dec(drop);
          map[line, column] := None;
          map[drop, column] := Round;
        end;
      end;
    end;
  end;
end;

procedure RockAndRollWest(var platform : TMap);
var line, column, drop : byte;
begin
  with platform do begin
    for column := 1 to xdim -1 do begin
      for line := 0 to ydim - 1 do begin
        (* Check for round Rocks *)
        if map[line, column] = Round then begin
          drop := column - 1;
          while (drop > 0) and (map[line,drop] = None) do dec(drop);
          if map[line, drop] <> None then inc(drop);
          map[line, column] := None;
          map[line, drop] := Round;
        end;
      end;
    end;
  end;
end;

procedure RockAndRollEast(var platform : TMap);
var line, column, drop : byte;
begin
  with platform do begin
    for column := xdim -2 downto 0 do begin
      for line := 0 to ydim - 1 do begin
        (* Check for round Rocks *)
        if map[line, column] = Round then begin
          drop := column + 1;
          while (drop > 0) and (map[line,drop] = None) do inc(drop);
          if map[line, drop] <> None then dec(drop);
          map[line, column] := None;
          map[line, drop] := Round;
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
  RockAndRollNorth(platform);
  part1 := weightRocks(platform);
end;

function part2(var input: Text) : longint;
const Cycles = $3b9aca00;
var   i  : longint;
      p  : TProgressBar;
begin
  loadPlatformMap(input, platform);
  p.init(Cycles, 'Rolling...');
  for i:= 1 to Cycles do begin
    p.step(1);
    RockAndRollNorth(platform);
    RockAndRollWest (platform);
    RockAndRollSouth(platform);
    RockAndRollEast (platform);
    if keypressed then break;
  end;
  p.done;
  part2 := weightRocks(platform);
end;

var input : Text;
    p1    : longint;
    p2    : longint;
begin
  assign(input, InputFile);
  reset(input);
  p1 := part1(input);
  reset(input);
  p2 := part2(input);
  close(input);

  writeln('Answer to part1 is: ', p1);
  writeln('Answer to part2 is: ', p2);
end.
