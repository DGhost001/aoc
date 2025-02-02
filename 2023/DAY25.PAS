program day25;
(* This is the implementation for day 25 of the AOC 2023 *)
uses ItemHandler,cassert, dequeue, JString, ProgressBar, utils, sort;

const InputFileName = 'INP\DAY25_INP.TXT';
type  TGroup = (None, Group1, Group2);
      PNode = ^TNode;
      PEdge = ^TEdge;
      TEdge = object(ItemType)
        next_  : PNode;
        weight_: word;

        constructor  init(const next: PNode; const weight : word);
      end;

      TNode = object (ItemType)
        edges_    : PDeQueue;
        id_       : word;
        group_    : TGroup;

        constructor init(id : word);
        destructor done; virtual;

        procedure   addEdge(node : PNode; const weight : word);
        function    majorNeighbourGroup : TGroup;
        function    isBorderNode : boolean;
        function    numBorderConnections : word;
      end;

      PNodeBackLog = ^TNodeBackLog;
      TNodeBackLog = object(ItemType)
        node_              : PNode;
        borderConnections_ : word;

        constructor init(node : PNode);
        function compare(other:PItemType):TRelation; virtual;
        function update : word;
      end;

constructor TNodeBackLog.init(node: PNode);
begin
  node_ := node;
  borderConnections_ := node^.numBorderConnections;
end;

function TNodeBackLog.compare(other:PItemType):TRelation;
var o: PNodeBackLog;
begin
  o := PNodeBackLog(other);

  if borderConnections_ > o^.borderConnections_ then compare := Bigger else
  if borderConnections_ < o^.borderConnections_ then compare := Smaller else
  compare := Equal;

end;

function TNodeBackLog.update: word;
begin
  borderConnections_ := node_^.numBorderConnections;
  update := borderConnections_;
end;

constructor TEdge.init(const next: PNode; const weight : word);
begin
  next_   := next;
  weight_ := weight
end;

constructor TNode.init(id : word);
begin
  id_    := id;
  edges_ := new(PDeQueue, init);
  group_ := None;
end;

destructor TNode.done;
begin
  edges_^.dispose;
end;

procedure TNode.addEdge(node : PNode; const weight : word);
begin
  edges_^.pushBack(new(PEdge, init(node, weight)));
end;

function TNode.majorNeighbourGroup : TGroup;
var  it: PDeQueueIterator;
     i : integer;
begin
  it := edges_^.first;
  i  := 0;
  while it <> nil do begin
    if PEdge(it^.at)^.next_^.group_ = Group1 then inc(i) else
    if PEdge(it^.at)^.next_^.group_ = Group2 then dec(i);
    it := it^.next;
  end;

  if i > 0 then majorNeighbourGroup:= Group1 else
  if i < 0 then majorNeighbourGroup:= Group2 else
  majorNeighbourGroup:= group_;
end;

function TNode.isBorderNode : boolean;
var it    : PDeQueueIterator;
    result: boolean;
begin
  it      := edges_^.first;
  result  := false;
  while (it <> nil) and (not result) do begin
    result := PEdge(it^.at)^.next_^.group_ <> group_;
    it := it^.next;
  end;
  isBorderNode := result;
end;

function TNode.numBorderConnections : word;
var it    : PDeQueueIterator;
    result: word;
begin
  it      := edges_^.first;
  result  := 0;
  while (it <> nil) do begin
    if PEdge(it^.at)^.next_^.group_ <> group_ then inc(result);
    it := it^.next;
  end;

  numBorderConnections:= result;
end;

procedure buildGraph(var input:Text; var graph : PDeQueue);
 function getNodeId(const node : PJString) : word;
 var it     : PJStringIterator;
     result : word;
 begin
   it := node^.first;
   result := 0;

   while it^.valid do begin
     result := result * 26;
     result := result + (ord(it^.at^)-ord('a'));
     it^.next;
   end;
   it^.dispose;
   getNodeId := result;
 end;

 function findNode(graph: PDeQueue; const id : word) : PNode;
 var result : PNode;
         it : PDeQueueIterator;
 begin
   it := graph^.first;
   while (it <> nil) and (PNode(it^.at)^.id_ <> id) do
     it := it^.next;
   if it <> nil then
     result := PNode(it^.at)
   else begin
     result := new(PNode, init(id));
     graph^.pushBack(result);
   end;

   findNode := result;
 end;

 procedure addEdge(graph: PDequeue; node : PNode; id : word);
 var other : PNode;
 begin
   other := findNode(graph, id);

   (* Undirected graph, so we need to add two edges ... *)
   node^.addEdge(other,1);
   other^.addEdge(node, 1);
 end;
var  line  : PJString;
    sline  : PJString;
     tokens: PDeQueue;
     edges : PDeQueue;
     it    : PDeQueueIterator;
     node  : PNode;
        p  : TProgressBar;
begin
  graph := new(PDeQueue,init);
  p.init(countLines(input),'load');
  while not eof(input) do begin
    line := ReadLine(input);
    sline:= line^.stripWhiteSpace;
    line^.dispose;
    tokens := sline^.split(':');
    sline^.dispose;
    assert(tokens^.size = 2,'Invalid line format');

    sline := PJString(tokens^.at(0))^.stripWhiteSpace;
    node := findNode(graph,getNodeId(sline));
    sline^.dispose;

    sline := PJString(tokens^.at(1))^.stripWhiteSpace;
    tokens^.dispose;
    tokens := sline^.split(' ');
    sline^.dispose;

    it := tokens^.first;
    while it <> nil do begin
      addEdge(graph, node, getNodeId(PJString(it^.at)));
      it := it^.next;
    end;
    tokens^.dispose;
    p.step(1);
  end;
  p.done;
end;

procedure colorGraph(graph : PDeQueue);
var queue : PDeQueue;
    it    : PDeQueueIterator;
    n1, n2: PNode;
    i     : integer;
    p     : TProgressBar;
begin
  queue := new(PDeQueue,init);
  n1 := PNode(graph^.at(0));
  n2 := PNode(graph^.at(1));

  n1^.group_ := Group1;
  n2^.group_ := Group2;

  it := n1^.edges_^.first;
  while it <> nil do begin
    queue^.pushBack(new(PNodeBackLog,init(PEdge(it^.at)^.next_)));
    it := it^.next;
  end;

  it := n2^.edges_^.first;
  while it <> nil do begin
    queue^.pushBack(new(PNodeBackLog,init(PEdge(it^.at)^.next_)));
    it := it^.next;
  end;
  p.init(graph^.size,'color');
  while queue^.size > 0 do begin
    n1 := PNodeBackLog(queue^.front)^.node_;

    if n1^.group_ = None then begin
      it := n1^.edges_^.first;
      i  := 0;
      while it <> nil do begin
        if PEdge(it^.at)^.next_^.group_ = Group1 then inc(i) else
        if PEdge(it^.at)^.next_^.group_ = Group2 then dec(i) else
        queue^.pushBack(new(PNodeBackLog,init(PEdge(it^.at)^.next_)));
        it := it^.next;
      end;
      if i >=0 then n1^.group_ := Group1 else n1^.group_ := Group2;
      p.step(1);
    end;
    queue^.popFront;
  end;
  p.done;
  queue^.dispose;
end;

procedure minimizeBorder(graph : PDeQueue);

 function findBorder(graph : PDeQueue; var border: PDeQueue): word;
 var result : word;
          b : PNodeBackLog;
         it : PDeQueueIterator;
          n : PNode;
 begin
   border := new(PDeQueue, init);
   it := graph^.first;
   result := 0;

   while it <> nil do begin
     n := PNode(it^.at);
     if n^.isBorderNode then begin
       b := new(PNodeBackLog,init(n));
       inc(result, b^.borderConnections_);
       border^.pushBack(b);
     end;
     it := it^.next;
   end;

   sortQueue(border);
 end;

 function getBorderLength(const border: PDeQueue): word;
 var result : word;
         it : PDeQueueIterator;
 begin
   result := 0;
   it := border^.first;
   while it <> NIL do begin
      inc(result, PNodeBackLog(it^.at)^.update);
      it := it^.next;
   end;
   getBorderLength := result;
 end;

 function findNode(border: PDeQueue; n : PNode) : PDeQueueIterator;
 var it : PDeQueueIterator;
 begin
   it := border^.first;
   while (it <> nil) and
         (PNodeBackLog(it^.at)^.node_ <> n) do it := it^.next;
   findNode := it;
 end;

 procedure swapNode(node : PNode; border : PDeQueue);
 var it1, it2 : PDeQueueIterator;
 begin
   node^.group_ := node^.majorNeighbourGroup;
   it1 := node^.edges_^.first;

   while it1 <> nil do begin
     ...
     it1 := it1^.next;
   end;
 end;

begin
end;


function part1(var input: Text) : longint;
var graph : PDeQueue;
begin
  buildGraph(input, graph);
  colorGraph(graph);

  graph^.dispose;
  part1 := 0;
end;

var input : Text;
       p1 : longint;
begin
  assign(input, InputFileName);
  reset(input);

  p1 := part1(input);

  writeln('Part 1 Answer is: ',p1);

  close(input)
end.