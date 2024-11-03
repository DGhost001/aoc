program day16;
const InputFile = 'INP\DAY16_IN.TXT';
type TDirection    = (Up, Down, Left, Right);
     TOpticalItems = (None, MirrorDown, MirrorUp, SplitterDownUp, SplitterLeftRight);
     TOccupancy = set of TDirection;
     TPosition  = record
        x,y : byte;
     end;
     TLightBeam = record
        position : TPosition;
        direction: TDirection;
     end;
     TMap = record
        xdim, ydim : byte;
        optical    : array[1..128, 1..128] of TOpticalItems;
        occupancy  : array[1..128, 1..128] of TOccupancy;
     end;

procedure loadMap( var input : Text; var map : TMap);
var line : string;
       x : byte;
begin
 with map do begin
   ydim := 0;
   xdim := 0;
   while not eof(input) do begin
     readln(input, line);
     if xdim = 0 then xdim := length(line);
     if length(line) <> xdim then break;
     inc(ydim);
     for x:= 1 to xdim do begin
       case line[x+1] of
         '.': optical[x,ydim] := None;
         '\': optical[x,ydim] := MirrorDown;
         '/': optical[x,ydim] := MirrorUp;
         '-': optical[x,ydim] := SplitterLeftRight;
         '|': optical[x,ydim] := SplitterDownUp;
       else RunError(300); (* Invalid input data *)
       end;
       occupancy[x,ydim] := [];
     end;
   end;
 end;
end;

begin
end.