program day13;
uses progressbar, utils;
const MaxDim   = 32;
      InputFile= 'INP\DAY13_IN.TXT';
type TStonePos = set of 0..(MaxDim - 1);
     TStoneMap = array[0..MaxDim] of TStonePos;
     TMirrorPos= set of 0..(MaxDim - 1);
     TMap = record
       horizontal : TStoneMap;
       vertical    : TStoneMap;
       hdim, vdim : byte;
     end;

function getMirror( const map : TStoneMap;
                    const dim : byte) : byte;
var options    : TMirrorPos;
    newOptions : TMirrorPos;
    offset     : byte;
    line       : byte;
    result     : byte;
begin
  result := MaxDim;
  for offset := 0 to dim-2 do begin
    for line := 0 to offset do begin
      if ( line + offset + 1 >= dim ) then break;
      if ( map[line + offset + 1] <> map[offset - line] ) then begin
        result := MaxDim;
        break;
      end else result := offset;
    end;
    if result <> MaxDim then break;
  end;
  getMirror := result;
end;

function getMirror2( const map : TStoneMap;
                    const dim : byte) : byte;
 function count(a : TStonePos) : byte;
 var result, pos : byte;
 begin
   result := 0;
   for pos := 0 to MaxDim do
     if pos in a then inc(result);
   count := result;
 end;


var options    : TMirrorPos;
    newOptions : TMirrorPos;
    offset     : byte;
    line       : byte;
    result     : byte;
    smudge     : boolean;
    tmp        : TStonePos;
begin
  for offset := 0 to dim-2 do begin
    smudge := false;
    result := MaxDim;
    for line := 0 to offset do begin
      if ( line + offset + 1 >= dim ) then break;
      tmp := ( map[line + offset + 1] + map[offset - line] ) -
             ( map[line + offset + 1] * map[offset - line] );
      if tmp <> [] then
        if (not smudge) and (count(tmp) = 1) then begin
          smudge := true;
          result := offset;
        end else begin
          result := MaxDim;
          break;
        end
      else result := offset;
    end;
    (* Only if we were able to remove the smudge *)
    if (result <> MaxDim) and smudge then break;
  end;
  if smudge then (* Rules say, we have to remove one smudge, always *)
    getMirror2 := result
  else
    getMirror2 := MaxDim;
end;

procedure loadNextMap(var input : Text; var map : TMap);
var pos : byte;
    line  : string;
begin
  with map do begin
    hdim := 0;
    vdim := 0;
    for pos := 0 to MaxDim do begin
      horizontal[pos] := [];
      vertical[pos]   := [];
    end;
    while not eof(input) do begin
      readln(input, line);
      if hdim = 0 then hdim := length(line);
      if hdim <> length(line) then break
      else begin
       inc(vdim);
       for pos := 1 to hdim do begin
         if line[pos] = '#' then begin
           horizontal[vdim-1] := horizontal[vdim-1] + [pos - 1];
           vertical[pos-1]    := vertical[pos-1] + [vdim - 1];
         end;
       end;
      end;
    end;
  end;
end;

function part1(var input : text) : longint;
var map : TMap;
    sum : longint;
    tmp : word;
    p   : TProgressBar;
begin
  sum := 0;
  p.init(countLines(input),'Thinking...');
  while not eof(input) do begin
    loadNextMap(input, map);
    p.step(map.vdim+1);
    tmp := getMirror(map.horizontal, map.vdim);
    if tmp < MaxDim then inc(sum,100*(tmp+1));
    tmp := getMirror(map.vertical, map.hdim);
    if tmp < MaxDim then inc(sum,tmp+1);
  end;
  p.done;
  part1 := sum;
end;

function part2(var input : text) : longint;
var map : TMap;
    sum : longint;
    tmp : word;
    p   : TProgressBar;
begin
  sum := 0;
  p.init(countLines(input),'Thinking...');
  while not eof(input) do begin
    loadNextMap(input, map);
    p.step(map.vdim+1);
    tmp := getMirror2(map.horizontal, map.vdim);
    if tmp < MaxDim then inc(sum,100*(tmp+1))
    else begin
      tmp := getMirror2(map.vertical, map.hdim);
      if tmp < MaxDim then inc(sum,tmp+1) else runError(300);
    end;
  end;
  p.done;
  part2 := sum;
end;


var input : Text;
    r1    : longint;
    r2    : longint;
begin
  assign(input, InputFile);
  reset(input);

  r1 := part1(input);
  reset(input);
  r2 := part2(input);

  close(input);
  writeln('Part 1 Answer is: ', r1);
  writeln('Part 2 Answer is: ', r2);
end.