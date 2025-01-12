program day23;
uses crt, utils, itemhandler, cassert;
const  Wood     : char = '#';
       Way      : char = '.';
       NClif    : char = '^';
       SClif    : char = 'v';
       WClif    : char = '<';
       EClif    : char = '>';
       Crossing : char = 'N';
       InputFileName = 'INP\DAY23_IN.TXT';
       MapSize   = 141;
       minMap : TPos = (x : 0; y: 0);
       maxMap : TPos = (x : MapSize; y: MapSize);

type   PNode = ^TNode;

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

constructor TNode.init(pos: TPos);
begin
  pos_ := pos;
  fillchar(nextNodes_,sizeof(nextNodes_),0);
end;

procedure loadMap(var input: Text; var map:  TMap);
begin
  map.maxX := MapSize + 1;
  map.maxY := MapSize + 1;
  loadCharMap(input, map.map, map.maxX, map.maxY);
end;

function scanForNodes(const map: TMap;
                      var nodes: array of PNode): word;
var x,y   : byte;
     count: word;
     p,p1 : TPos;
     c    : byte;
     d    : TDirection;
begin
  count := 0;
  fillchar(nodes,sizeof(nodes),0);
  for x:= 1 to map.maxX - 2 do begin
    p.x := x;
    p.y := 0;
    p1.x:= x;
    p1.y:= map.maxY - 1;

    if map.map[p.x, p.y] = Way then begin
      assert(nodes[1] = NIL,'Multiple Starts Found');
      nodes[1] := new(PNode, init(p));
    end;

    if map.map[p1.x, p1.y] = Way then begin
      assert(nodes[0] = NIL, 'Multiple Exits Found');
      nodes[0] := new(PNode, init(p1));
    end;
  end;

  assert(nodes[1] <> NIL, 'No Start Found');
  assert(nodes[0] <> NIL, 'No Exits Found');
  count := 2;

  for x:= 1 to map.maxX - 2 do
    for y:=1 to map.maxY - 2 do begin
      p.x := x;
      p.y := y;
      c := 0;
      for d := North to South do begin
        p1 := p;
        if (map.map[p.x,p.y] <> Wood) and
           advancePos(p1, d, minMap, maxMap) then
          if map.map[p1.x, p1.y] <> Wood then inc(c);
      end;
      if c > 2 then begin
        assert(count <= HIGH(nodes), 'Not enougth node memory');
        nodes[count] := new(PNode,init(p));
        inc(count);
      end;
    end;

    scanForNodes := count;
end;

function part1(var map : TMap): longint;
var nodes    : array[0..128] of PNode;
    nodeCount: word;
    c        : word;
begin
  nodeCount := scanForNodes(map,nodes);

  for c:= 0 to nodeCount - 1 do dispose(nodes[c]);
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
