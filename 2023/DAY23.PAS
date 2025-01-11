program day23;
uses crt, utils, itemhandler;
const  Wood : char = '#';
       Way  : char = '.';
       NClif: char = '^';
       SClif: char = 'v';
       WClif: char = '<';
       EClif: char = '>';
       InputFileName = 'INP\DAY23_IN.TXT';
       MapSize   = 141;

type   PNode = ^Node;

       TNode = object(ItemType)
         pos_       : TPos;
         nextNodes_ : array[TDirection] of record
           node    : PNode;
           distance: word;
         end;
         constructor init(pos: TPos);

       end;

       TMap = record
            maxX, maxY : word;
            map : array[0..MapSize,0..MapSize] of char;
       end;


function part1(var map : TMap): longint;
begin
end;

procedure loadMap(var input: Text; var map:  TMap);
begin
  map.maxX := MapSize + 1;
  map.maxY := MapSize + 1;
  loadCharMap(input, map.map, map.maxX, map.maxY);
end;

var map   : TMap;
    input : Text;
    p1    : longint;
begin
  clrscr;
  assign(input, InputFileName);
  reset(input);
  loadMap(input, map);
  close(input);

  p1 := part1(map);

  writeln('Answer Part 1 is: ',p1);
end.
