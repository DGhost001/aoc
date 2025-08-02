program day16;
(*This is the implementation of the aoc24 day 16*)

uses aoc, utils, heap, itemhandler, cassert, fastout, crt, progressbar, dequeue;
const InputFileName = 'INP\DAY16_IN.TXT';
      MaxMapSize    = 140;
      MaxNodes      = 1024*2;
const minPos : TPos = (x: 0; y: 0);
      
type  PMap      = ^TMap;
      TMap      = array[0..MaxMapSize,0..MaxMapSize] of char;
      
      PNode = ^TNode;
      TEdge = record
         steps_ : word;
         turns_ : word;
         next_  : PNode; (* next node in the direction of the edge *)
         entry_ : TDirection; (* entry direction of the edge *)
      end;

      TNode = record
          pos_          : TPos;
          edges_        : array[TDirection] of TEdge;
          visited_      : set of TDirection;
          pointsToStart_: array[TDirection] of longint; 
      end;

      PRendier = ^TRendier;
      TRendier = object(ItemType)
         pos_     : PNode;
         heading_ : TDirection;
         steps_   : word;
         turns_   : word;

         constructor init(const pos: PNode;
                          const heading: TDirection;
                          const steps : word;
                          const turns : word);
         function compare(other:PItemType):TRelation;virtual;
         function getPoints: longint;

      end;

var nodeList_          : array[1..MaxNodes] of TNode;
    startNode, goalNode: PNode;
    nodesInList_       : word;

procedure initializeNodes(const map: TMap; const mapSize: TPos);

  function isIntersection(const pos: TPos; const map: TMap; const mapSize: TPos): boolean;
  var dir    : TDirection;
      nextPos: TPos;
      options: byte;
  begin
    if (map[pos.x, pos.y] = 'S') or (map[pos.x,pos.y] = 'E') then
      isIntersection := true
    else begin
      options :=0;
      for dir := North to South do begin
        nextPos := pos;
        if advancePos(nextPos, dir, minPos, mapSize) then begin
          if map[nextPos.x,nextPos.y] <> '#' then inc(options);
        end;
      end;
      isIntersection := (options <> 2) and (options <> 0); (* 2 is a way; <2 is an end; and >2 is an intersection *)
    end;
  end;

  procedure initializeEdge(pos : TPos; dir: TDirection; const map: TMap; const mapSize: TPos; var edge: TEdge);
  function findNode(const pos: TPos): PNode;
  var i : Word;
  begin
    findNode := nil;
    for i := 1 to nodesInList_ do begin
      if posEqual(nodeList_[i].pos_, pos) then begin
        findNode := @nodeList_[i];
        exit;
      end;
    end;
  end;
  var newDirection : TDirection;
      nextPos      : TPos;
  begin
    edge.steps_ := 0;
    edge.turns_ := 0;

    if advancePos(pos, dir, minPos, mapSize) then begin
      if map[pos.x,pos.y] <> '#' then inc(edge.steps_);
      while (not isIntersection(pos, map, mapSize)) and (map[pos.x,pos.y] <> '#') do begin
        newDirection := dir;
        repeat
          nextPos := pos;
          while not advancePos(nextPos, newDirection, minPos, mapSize) do begin
              nextPos := pos;
              newDirection := nextDirection(dir, newDirection);
              if newDirection = dir then break;
          end;
          if map[nextPos.x,nextPos.y] = '#' then
            newDirection := nextDirection(dir, newDirection);

        until (posEqual(nextPos,pos)) or (map[nextPos.x,nextPos.y] <> '#');

        if posEqual(nextPos, pos) then break;

        inc(edge.steps_);
        if newDirection <> dir then inc(edge.turns_);
        
        pos := nextPos;
        dir := newDirection;
      end;

      if edge.steps_ > 0 then edge.next_ := findNode(pos)
      else edge.next_ := nil; (* no next node *)
      edge.entry_ := dir; (* entry direction of the edge *)
    end;
  end;
var pos : TPos;
    dir : TDirection;
    i   : word;
    p   : TProgressBar;
begin
  p.init(mapSize.x * mapSize.y,'Nodes');
  nodesInList_ := 0;
  fillchar(nodeList_, sizeof(nodeList_), 0);
  for pos.x := 0 to mapSize.x do begin
    for pos.y := 0 to mapSize.y do begin
      if ((map[pos.x,pos.y] <>'#') and isIntersection(pos, map, mapSize))
      then begin
        inc(nodesInList_);
        assert(nodesInList_ <= MaxNodes, 'Too many nodes in map');
        nodeList_[nodesInList_].pos_ := pos;
        nodeList_[nodesInList_].visited_ := [];
        for dir := North to South do begin
          nodeList_[nodesInList_].edges_[dir].steps_ := 0;
          nodeList_[nodesInList_].edges_[dir].turns_ := 0;
        end;
        if map[pos.x,pos.y] = 'S' then startNode := @nodeList_[nodesInList_]
        else if map[pos.x,pos.y] = 'E' then goalNode := @nodeList_[nodesInList_];
      end;
      p.step(1);
    end;
  end;
  p.done;
  p.init(nodesInList_ * 4,'Edges');
  for i := 1 to nodesInList_ do
    for dir := North to South do begin
      p.step(1);
      initializeEdge(nodeList_[i].pos_, dir, map, mapSize, nodeList_[i].edges_[dir]);
    end;
  p.done;
end;

constructor TRendier.init(const pos: PNode;
                          const heading: TDirection;
                          const steps: word;
                          const turns: word);
begin
  pos_     := pos;
  heading_ := heading;
  steps_   := steps;
  turns_   := turns;
end;

function TRendier.compare(other:PItemType):TRelation;
var otherRendier : PRendier;
    otherPoints : longint;
    myPoints    : longint;
begin
  otherRendier := PRendier(other);
  myPoints := getPoints;
  otherPoints := otherRendier^.getPoints;

  if otherPoints < myPoints then compare := Bigger else
  if otherPoints > myPoints then compare := Smaller else
  compare := Equal;
end;

function TRendier.getPoints: longint;
begin
  getPoints := longint(steps_) + longint(turns_) * 1000;
end;

procedure computeLowestPoints(const startNode : PNode);
const minMap    : TPos = (x: 0; y: 0);
var position    : PNode;
    heap        : TMinHeap;
    rendier     : PRendier;
    heading     : TDirection;
    i           : integer;
    s           : string;
    steps       : byte;
begin
  position := startNode;

  heap.init;

  heap.push(new(PRendier, init(position, East,0, 0)));

  writeln;
  while heap.size > 0 do begin
    str(heap.size,s);
    s:='Heap Size: ' + s +' ';

    rendier := PRendier(heap.pop);

    if rendier^.heading_ in rendier^.pos_^.visited_ then begin
      dispose(rendier);
      continue; (* already visited from this direction *)
    end;

    rendier^.pos_^.visited_ := rendier^.pos_^.visited_ + [rendier^.heading_];
    rendier^.pos_^.pointsToStart_[rendier^.heading_] := rendier^.getPoints;
    
    if steps = 0 then  fastWrite(0,1,LightGray,s);
    steps := (steps + 1 ) mod 64;

    for i:=1 to 3 do begin
      position := rendier^.pos_;
      if i = 1 then heading:= rendier^.heading_
      else heading:= nextDirection(rendier^.heading_, heading);
      if (position^.edges_[heading].next_ <> nil) then begin
        if i = 1 then
          heap.push(new(PRendier, init(
              position^.edges_[heading].next_,
              position^.edges_[heading].entry_,
              rendier^.steps_ + position^.edges_[heading].steps_,
              rendier^.turns_ + position^.edges_[heading].turns_)))
        else
          heap.push(new(PRendier, init(
              position^.edges_[heading].next_,
              position^.edges_[heading].entry_,
              rendier^.steps_ + position^.edges_[heading].steps_,
              rendier^.turns_ + position^.edges_[heading].turns_ + 1)))
      end;
    end;

    dispose(rendier);
  end;

  heap.done;
end;

procedure setup(var input: Text); far;
var maxX, maxY : word;
    mapSize            : TPos;
    map        : PMap;
begin
  maxX := MaxMapSize+1; (* first value behind the map *)
  maxY := MaxMapSize+1;
  map  := new(PMap);

  loadCharMap(input, map^, maxX, maxY);

  mapSize.x := maxX - 1;
  mapSize.y := maxY - 1;

  initializeNodes(map^, mapSize);

  assert(nodesInList_ > 0, 'No nodes found in map');
  assert(startNode <> nil, 'No start node found');
  assert(goalNode <> nil, 'No goal node found');

  computeLowestPoints(startNode);

  dispose(map);
end;

function getFinishPoints(const goalNode: PNode): longint;
var i : TDirection;
    points: longint;
begin
  points := 0;
  for i:= North to South do begin
    if ((goalNode^.pointsToStart_[i] < points)  and
        (goalNode^.pointsToStart_[i] > 0)) or (points = 0) then
        points := goalNode^.pointsToStart_[i];
  end;

  assert(points > 0, 'No finish heading found');
  getFinishPoints := points;
end;

function part1(var input: Text):comp; far;
begin
  part1 := getFinishPoints(goalNode);
end;

function traceSteps(const startNode: PNode; const goalNode: PNode): longint;
  function isOption(const node: PNode; const dir: TDirection; const targetPoints: longint): PNode;
  
  begin
    isOption := nil;
    if node^.pointsToStart_[dir] = targetPoints then
      isOption := node;
  end;              

  procedure addAllOptions(const node: PNode; 
                          const rendier: PRendier;
                          var posibilities: TDequeue);
  var dir        : TDirection;
      nodeOption : PNode;
      nextNode   : PNode;
  begin
    for dir := North to South do begin
      nextNode := node^.edges_[dir].next_;
      if nextNode = nil then continue; (* no next node in this direction *)
      
      if dir = heading then begin
        nodeOption := isOption(node, dir, rendier^.getPoints);
        if nodeOption <> nil then
          posibilities.pushBack(new(PRendier, init(nextNode, 
                                                   node^.edges_[dir].entry_,
                                                   rendier^.steps_ - node^.edges_[dir].steps_,
                                                   rendier^.turns_ - node^.edges_[dir].turns_)));
      end else begin
        nodeOption := isOption(node, dir, rendier^.getPoints - 1000);
        if nodeOption <> nil then
           posibilities.pushBack(new(PRendier, init(nextNode, 
                                                   node^.edges_[dir].entry_,
                                                   rendier^.steps_ - node^.edges_[dir].steps_,
                                                   rendier^.turns_ - node^.edges_[dir].turns_ - 1)));
      end;
    end;
  end;

var rendier : PRendier;
    posibilities : TDequeue;
    points : longint;
    heading, reverse : TDirection;
begin
  posibilities.init;
  points := getFinishPoints(goalNode);
  for heading := North to South do begin
    reverse := reverseDirection(heading);
    if points = goalNode^.pointsToStart_[heading] then begin
      rendier := new(PRendier, 
          init(goalNode^.edges_[reverse].next_, 
               goalNode^.edges_[reverse].entry_, 
               goalNode^.pointsToStart_.steps_ - goalNode^.edges_[reverse].steps_,
               goalNode^.pointsToStart_.turns_ - goalNode^.edges_[reverse].turns_));
      posibilities.pushBack(rendier);
    end;
  end;
end;

function part2(var input: Text):comp; far;
begin
  part2 := 0;
end;

begin
  runAoc(InputFileName, 16, part1, part2, setup, nil);
end.
