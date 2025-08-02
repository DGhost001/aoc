program day23;
uses crt, utils, itemhandler, cassert, progressbar, dequeue;
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
         visited_   : boolean;
         distance_  : longint;
         pos_       : TPos;
         nextNodes_ : array[TDirection] of record
           node    : PNode;
           distance: word;
         end;
         constructor init(const pos: TPos);

       end;

       PNodeRef = ^TNodeRef;
       TNodeRef = object (ItemType)
          node_ : PNode;
          constructor init(const node : PNode);
       end;

       TMap = record
            maxX, maxY : word;
            map : array[0..MapSize,0..MapSize] of char;
       end;

constructor TNodeRef.init(const node: PNode);
begin
  node_ := node;
end;

constructor TNode.init(const pos: TPos);
begin
  distance_ := -1;
  visited_ := false;
  pos_ := pos;
  fillchar(nextNodes_,sizeof(nextNodes_),0);
end;

procedure loadMap(var input: Text; var map:  TMap);
begin
  fillchar(map,sizeof(map),0);
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

procedure findNextNodes2(var node  : PNode;
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
     else begin
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



procedure topologicalSort(node : PNode; stack : PDequeue);
var d : TDirection;
begin
  if (node <> NIL) and (not node^.visited_) then begin
    node^.visited_ := true;
    for d:= North to South do begin
      if (node^.nextNodes_[d].node <> NIL) and (not node^.nextNodes_[d].node^.visited_) then
        topologicalSort(node^.nextNodes_[d].node, stack);
    end;

    stack^.pushBack(new(PNodeRef, init(node)));
  end;
end;

function part1(var map : TMap): longint;
var nodes    : array[0..128] of PNode;
    nodeCount: word;
    c        : word;
    p        : TProgressbar;
    stack    : PDeQueue;
    d        : TDirection;
    tmp      : PNodeRef;
begin
  nodeCount := scanForNodes(map,nodes);
  markNodesInMap(map, nodes);

  p.init(nodeCount - 2,'meshing');
  for c:=1 to nodeCount - 1 do begin
    p.step(1);
    findNextNodes(nodes[c], nodes, map);
  end;
  p.done;
  stack := new(PDeQueue, init);
  topologicalSort(nodes[1],stack);
  nodes[1]^.distance_ := 0; (* Set Startnode to distance 0 *)
  while stack^.size > 0 do begin
     tmp := PNodeRef(stack^.back);
     with tmp^ do begin
       assert(node_^.distance_ >= 0,'Node has no distance');
       for d:= North to South do begin
         if (node_^.nextNodes_[d].node <> NIL) and
            (node_^.nextNodes_[d].node^.distance_ < node_^.distance_ + node_^.nextNodes_[d].distance) then
              node_^.nextNodes_[d].node^.distance_ :=
                node_^.distance_ + node_^.nextNodes_[d].distance;
       end;
     end;

     stack^.popBack;
  end;

  part1 := nodes[0]^.distance_;
  stack^.dispose;
  for c:= 0 to nodeCount - 1 do dispose(nodes[c]);
end;

procedure longRecursive(node        : PNode;
                       const dist  : longint;
                       const finish: PNode;
                       var   long  : longint);
var d     : TDirection;
begin
  if keypressed then halt;
  if node = finish then begin
    if long < dist then begin
     long := dist;
     write(dist,' ');
    end;
  end else
  begin
    node^.visited_ := True;
    for d:=North to South do with node^.nextNodes_[d] do begin
     if (node <> NIL) and
        (not node^.visited_) then begin
            longRecursive(node,
                            dist + distance,
                            finish,long);
     end;
    end;
    node^.visited_ := False;
  end;
end;

function part2(var map : TMap): longint;
var nodes    : array[0..128] of PNode;
    nodeCount: word;
    c,i      : word;
    p        : TProgressbar;
    count    : longint;
    result   : longint;
begin
  nodeCount := scanForNodes(map,nodes);
  writeln('Nodes: ',nodeCount);
  markNodesInMap(map, nodes);

  p.init(nodeCount - 2,'meshing');
  for c:=1 to nodeCount - 1 do begin
    p.step(1);
    findNextNodes2(nodes[c], nodes, map);
  end;

  p.done;
  result:=0;
  longRecursive(nodes[1],0,nodes[0], result);
  part2 := result;

  for c:= 0 to nodeCount - 1 do dispose(nodes[c]);
end;

var map   : TMap;
    input : Text;
    p1    : longint;
    p2    : longint;
begin
  clrscr;
  assign(input, InputFileName);
  reset(input);
  loadMap(input, map);
  

  p1 := part1(map);
  writeln('Answer Part 1 is: ',p1);

  reset(input);
  loadMap(input,map);

  p2 := part2(map);
  writeln('Answer Part 2 is: ',p2);

  close(input);
end.
