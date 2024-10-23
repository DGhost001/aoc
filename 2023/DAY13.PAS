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

function isMirror( const offset, dim : byte;
                   const stones : TStonePos) : boolean;
var i        : integer;
    result   : boolean;
    pos, neg : byte;
begin
  result := true;
  for i := 0 to offset do begin
   pos := offset + i + 1;
   neg := offset - i;
   if pos >= dim then break;
   if not ((pos in stones) = (neg in stones)) then begin
     result := false;
     break;
   end;
  end;
  isMirror := result;
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

var input : Text;
    r     : longint;
begin
  assign(input, InputFile);
  reset(input);

  r := part1(input);

  close(input);
  writeln('Part 1 Answer is: ', r);
end.