program day23;
uses crt, utils, itemhandler, cassert, progressbar;
const  Wood     = '#';
       Way      = '.';
       NClif    = '^';
       SClif    = 'v';
       WClif    = '<';
       EClif    = '>';
       Crossing = 'N';
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

procedure markNodesInMap(var map: TMap; nodes: array of PNode);
var i: word;
begin
  i := 0;
  while (i <= HIGH(nodes)) and (nodes[i] <> NIL) do begin
    with nodes[i]^.pos_ do
      map.map[x, y] :=  Crossing;
    inc(i);
  end;
end;

procedure findNextNodes(var node  : PNode;
                            nodes : array of PNode;
                        const map : TMap);
var p,np     : TPos;
    min, max : TPos;
    dir      : TDirection;
      d      : TDirection;
      nd     : TDirection;
      steps  : word;
      i      : word;
begin
 min.x := 0;
 max.x := map.maxX;
 min.y := 0;
 max.y := map.maxY;

 for dir := North to South do begin
   p := node^.pos_;
   d := dir;
   steps := 0;
   while advancePos(p, d, min, max) do begin
     inc(steps);
     case map.map[p.x, p.y] of
        Crossing : break;
        Wood     : break;
        NClif    : nd := North;
        EClif    : nd := East;
        WClif    : nd := West;
        SClif    : nd := South;
        Way      : begin
          nd := d;
          repeat
            np := p;
            if advancePos(np,nd, min, max) then begin
              if map.map[np.x, np.y] <> Wood then break;
            end;
            nd := nextDirection(d, nd);
          until nd = d;
        end;
     end;
     if nd = reverseDirection(d) then break;
     d := nd;
   end;
   if (not posEqual(p,node^.pos_)) and (map.map[p.x,p.y] = Crossing) then begin
     for i:= 0 to HIGH(nodes) do
         if (nodes[i] <> NIL) and (posEqual(nodes[i]^.pos_, p)) then break;
     node^.nextNodes_[dir].node     := nodes[i];
     node^.nextNodes_[dir].distance := steps;
   end else begin
     node^.nextNodes_[dir].node     := NIL;
     node^.nextNodes_[dir].distance := 0;
   end;
 end;
end;

function part1(var map : TMap): longint;
var nodes    : array[0..128] of PNode;
    nodeCount: word;
    c        : word;
    p        : TProgressbar;
begin
  nodeCount := scanForNodes(map,nodes);
  markNodesInMap(map, nodes);

  p.init(nodeCount - 2,'meshing');
  for c:=1 to nodeCount - 1 do begin
    p.step(1);
    findNextNodes(nodes[c], nodes, map);
  end;
  p.done;

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
