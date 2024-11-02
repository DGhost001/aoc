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
        optical    : array[0..127, 0..127] of TOpticalItems;
        occupancy  : array[0..127, 0..127] of TOccupancy;
     end;

var x  : TOccupancy;
    map: TMap;
begin
 writeln(sizeof(map));
end.
