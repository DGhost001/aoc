program day25;
(* This is the implementation for day 25 of the AOC 2023 *)
uses ItemHandler,cassert, dequeue, JString, ProgressBar, utils, sort, crt;

const InputFileName = 'INP/DAY25_IN.TXT';
type  TGroup = (None, Group1, Group2);
      PNode = ^TNode;
      PEdge = ^TEdge;
      TEdge = object(ItemType)
       
        constructor  copy(const other : PEdge);
        constructor  init(const n: PNode; const weight : word);
        
        function next : PNode;
        procedure setNext(const n: PNode);
        
        private
            next_  : PNode;
            weight_: word;
      end;

      TNode = object (ItemType)
        edges_    : PDeQueue;
        id_       : word;
        group_    : TGroup;
        weight_   : word;

        constructor init(const id   : word);
        constructor copy(const other: PNode);
        destructor done; virtual;

        procedure   addEdge(node : PNode; const weight : word);
        procedure   merge(const node : PNode);
        function    majorNeighbourGroup : TGroup;
        function    isBorderNode : boolean;
        function    numBorderConnections : word;
        procedure   invertGroup;
        procedure   verify;
      end;

      PNodeBackLog = ^TNodeBackLog;
      TNodeBackLog = object(ItemType)
        node_              : PNode;
        borderConnections_ : word;

        constructor init(const node : PNode);
        function compare(other:PItemType):TRelation; virtual;
        function update : word;
      end;

constructor TNodeBackLog.init(const node: PNode);
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

constructor TEdge.init(const n: PNode; const weight : word);
begin
  next_   := n;
  weight_ := weight
end;

constructor TEdge.copy(const other: PEdge);
begin
  assert(typeof(other^) = typeof(TEdge), 'Invalid Edge type');
  assert(typeof(other^.next_^) = typeof(TNode), 'Invalid Node type');
  next_ := other^.next_;
  weight_ := other^.weight_;
end;

function TEdge.next : PNode;
begin
  assert(typeof(next_^) = typeof(TNode), 'Invalid Node type ');
  next := next_;
end;

procedure TEdge.setNext(const n: PNode);
begin
  assert(typeof(next^) = typeof(TNode), 'Invalid Node type');
  next_ := n;
end;

constructor TNode.init(const id : word);
begin
  id_    := id;
  edges_ := new(PDeQueue, init);
  group_ := None;
  weight_:= 1;
end;

constructor TNode.copy(const other : PNode);
var it : PDeQueueIterator;
begin
  assert(typeof(other^) = typeof(TNode), 'Invalid Node type');
  id_ := other^.id_;

  edges_ := new(PDeQueue, init);
  it := other^.edges_^.first;
  while it <> nil do begin
   edges_^.pushBack(new(PEdge,copy(PEdge(it^.at))));
   it := it^.next;
  end;

  group_ := other^.group_;
  weight_:= other^.weight_;
end;

destructor TNode.done;
var it1, it2 : PDeQueueIterator;
           n : PNode;
begin
  it1 := edges_^.first;

  (* Go through all edges and remove the reverse references *)
  while it1 <> Nil do begin
    n := PEdge(it1^.at)^.next;
    it2 := n^.edges_^.first;

    while it2 <> nil do begin
      it2 := n^.edges_^.first;
      while (it2 <> nil) and (PEdge(it2^.at)^.next <> @self) do it2 := it2^.next;
      if it2 <> nil then n^.edges_^.remove(it2);
    end;

    it1 := it1^.next;
  end;

  (* Dispose the edges *)
  edges_^.dispose;
end;

procedure TNode.addEdge(node : PNode; const weight : word);
begin
  edges_^.pushBack(new(PEdge, init(node, weight)));
end;

procedure TNode.merge(const node : PNode);
var it1             : PDeQueueIterator;
    edge            : PEdge;
    otherNode       : PNode;
begin
  it1 := node^.edges_^.first;

  while it1 <> nil do begin
   edge := PEdge(it1^.at);
   assert(typeof(edge^) = typeof(TEdge), 'Invalid Edge type');
   
   otherNode := edge^.next;
  
   (* Check if the edge points not to our self *)
   if (otherNode <> @self) then begin
     
     edges_^.pushBack(new(PEdge,copy(edge))); (* Copy the edge *)    
     otherNode^.edges_^.pushBack(new(PEdge,init(@self, edge^.weight_))); (* Add the reverse edge *)
   
   end;
   it1 := it1^.next;
  end;
  inc(weight_, node^.weight_);
end;

function TNode.majorNeighbourGroup : TGroup;
var  it: PDeQueueIterator;
     i : integer;
begin
  it := edges_^.first;
  i  := 0;
  while it <> nil do begin
    if PEdge(it^.at)^.next^.group_ = Group1 then inc(i) else
    if PEdge(it^.at)^.next^.group_ = Group2 then dec(i);
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
    result := PEdge(it^.at)^.next^.group_ <> group_;
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
    if PEdge(it^.at)^.next^.group_ <> group_ then inc(result);
    it := it^.next;
  end;

  numBorderConnections:= result;
end;

procedure TNode.verify;
var it1 : PDeQueueIterator;
begin
  it1 := edges_^.first;
  while it1 <> nil do begin
    assert(typeof(it1^.at^) = typeof(TEdge), 'Invalid Edge type');
    PEdge(it1^.at)^.next;
    it1 := it1^.next;
  end;
end;  
  

procedure TNode.invertGroup;
begin
  if group_ = Group1 then group_ := Group2 else
  if group_ = Group2 then group_ := Group1;
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

var  line  : PJString;
    sline  : PJString;
     tokens: PDeQueue;
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

function copyGraph(const graph:PDeQueue) : PDeQueue;
var result   : PDeQueue;
    it1, it2 : PDeQueueIterator;
    n1 , n2  : PNode;
         edge: PEdge;
begin
  result := new(PDeQueue,init);
  it1 := graph^.first;

  (* Copy all nodes first *)
  while it1 <> nil do begin
    n1 := PNode(it1^.at);
    result^.pushBack(new(PNode, copy(n1)));
    it1 := it1^.next;
  end;

  (* Now adjust the edges to point to the new graph *)
  it1 := result^.first;
  while it1 <> nil do begin
    n2 := PNode(it1^.at);
    it2 := n2^.edges_^.first;
    while it2 <> nil do begin
      edge := PEdge(it2^.at);
      edge^.setNext(findNode(result, edge^.next_^.id_));
      it2 := it2^.next;
    end;

    it1 := it1^.next;
  end;

  copyGraph := result;
end;

procedure mergeNodesInGraph(graph   : PDeQueue;
                            node1   : PNode;
                            node2   : PNode);
var it : PDeQueueIterator;
begin
  node1^.merge(node2); (* Merge the two nodes *)

  it := graph^.first;
  while (it <> nil) and (PNode(it^.at) <> node2) do
   it := it^.next;
  assert(it <> nil, 'Node not found!');
  graph^.remove(it);
end;

procedure kargerStein(graph      : PDeQueue;
                     var cut    : word;
                     var c1, c2 : word
                     );

  procedure contract( graph : PDeQueue; threshold : word);
  var n1, n2 : PNode;
  begin
    while graph^.size > threshold do begin
      (* Find a random edge from the graph *)
      n1 := PNode(graph^.at(random(graph^.size)));
      n2 := PEdge(n1^.edges_^.at(random(n1^.edges_^.size)))^.next;
      mergeNodesInGraph(graph, n1,n2); (* Collaps the edge *)
    end;
  end;

  function minCut(graph : PDeQueue; var c1, c2 : word; var p: TProgressBar) : word;
  var g1       : PDeQueue;
      t,i,k    : word;
      ic1, ic2 : word;
      kc1, kc2 : word;
  begin
    if graph^.size < 6 then begin
      g1 := copyGraph(graph);
      contract(g1,2);
      (* write(' ',PNode(g1^.at(0))^.edges_^.size); *)
      minCut := PNode(g1^.at(0))^.edges_^.size;
      c1 := PNode(g1^.at(0))^.weight_;
      c2 := PNode(g1^.at(1))^.weight_;
      g1^.dispose;
      p.step(1);
    end else begin

      t := round(1 + graph^.size / sqrt(2)); (* sqrt(2) *)
      g1 := copyGraph(graph);
      contract(g1,t);
      i := minCut(g1,ic1, ic2,p);
      g1^.dispose;

      if i = 3 then begin
        minCut := i;
        c1 := ic1;
        c2 := ic2;
        exit;
      end;

      g1 := copyGraph(graph);
      contract(g1,t);
      k := minCut(g1,kc1,kc2,p);
      g1^.dispose;

      if i < k then begin
        minCut := i;
        c1 := ic1;
        c2 := ic2;
      end else begin
        minCut := k;
        c1 := kc1;
        c2 := kc2;
      end;
    end;
  end;
var p : TProgressBar;
begin
 p.init(round(exp(ln(2)*(ln(graph^.size)/ln(sqrt(2))))),'minC');
 cut := minCut(graph,c1,c2, p);
 p.done;
end;


function part1(var input: Text) : longint;
var graph       : PDeQueue;
    c1, c2, cut : word;
begin
  randSeed := 1234;
  c1 := 0;
  c2 := 0;

  buildGraph(input, graph);
  kargerStein(graph, cut, c1, c2);

  writeln('MinCut is: ',cut);
  assert(cut = 3, 'MinCut is not correct');
  graph^.dispose;
  part1 := c1 * c2;
end;

var input : Text;
       p1 : longint;
begin
  clrscr;
  assign(input, InputFileName);
  reset(input);

  p1 := part1(input);

  writeln('Part 1 Answer is: ',p1);

  close(input)
end.