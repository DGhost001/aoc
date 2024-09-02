{$N+ $E+}
program Day8;
uses crt,jstring,dequeue,itemhandler,stdint;

const
  InputFileName = 'INP\DAY8_INP.TXT';
  MaxWaySteps   = 512;

type TNodeInfo = record
       numberOfSteps : comp;
       pos           : PDeQueueIterator;
       isCircle      : boolean;
     end;

     TNodeInfoCache  = array[0..MaxWaySteps -1] of TNodeInfo;
     PNodeInfoCache  = ^TNodeInfoCache;
     PWay = ^TWay;
     TWay            = record
       maxSteps : word;
       steps : array [0 ..MaxWaySteps -1] of char;
     end;

     TId   = string[3];
     PNode = ^TNode;
     TNode = object(ItemType)
       id_       : TId;
       leftId_   : TId;
       rightId_  : TId;
       left_     : PDeQueueIterator;
       right_    : PDeQueueIterator;
       nodeInfo_ : PNodeInfoCache;

       constructor init(id, left, right : TId);
     end;

constructor TNode.init(id, left, right : TId);
var i:integer;
begin
 id_      := id;
 leftId_  := left;
 rightId_ := right;

 if id[3] = 'Z' then begin
   nodeInfo_ := new(PNodeInfoCache);
   for i:=0 to MaxWaySteps - 1 do begin
     nodeInfo_^[i].numberOfSteps := 0;
     nodeInfo_^[i].pos := NIL;
     nodeInfo_^[i].isCircle := false;
   end;
 end else nodeInfo_ := NIL;

 left_    := NIL;
 right_   := NIL;
end;

function findNode(nodes: PDeQueue;id : TId): PDeQueueIterator;
var it : PDeQueueIterator;
begin
  it := nodes^.first;
  while (it <> NIL) and (PNode(it^.at)^.id_ <> id) do
   it := it^.next;
  findNode:=it;
end;

procedure mesh(nodes :PDeQueue);
var it: PDeQueueIterator;
    cn: word;
begin
  it:= nodes^.first;
  while it <> NIL do begin
    inc(cn);
    if cn > 100 then begin
      cn:=0;
      write('.');
    end;
    with PNode(it^.at)^ do begin
      left_ := findNode(nodes,leftId_);
      right_:= findNode(nodes,rightId_);
    end;
    it:=it^.next;
  end;
end;

function step(it:PDeQueueIterator; c : char):PDeQueueIterator;
begin
  case c of
    'L' : step:=PNode(it^.at)^.left_;
    'R' : step:=PNode(it^.at)^.right_;
  else begin
   step:=it;
   writeln('Unkown Step direction...');
  end;
  end;
end;

function findNumberOfSteps(way       : PWay;
                           offset    : word;
                           start     : PDeQueueIterator;
                           var target: PDeQueueIterator): longint;
var it    : PDeQueueIterator;
    count : longint;
begin
  count := 0;
  it := start;

  repeat
   it := step(it,way^.steps[(offset + count) mod way^.maxSteps]);
   inc(count);
   if (count mod 10000) = 0 then begin
     write('.');
     if keypressed then halt(1);
   end;
  until PNode(it^.at)^.id_[3] ='Z';
  target:=it;
  findNumberOfSteps:=count;
end;

function parseNode(line :PJString):PNode;
var id, left, right:TId;
    s : string;
    result : PNode;
begin
  result := NIL;
(* 0        1       *)
(* 1234567890123456 *)
(* DRM = (DLQ, BGR) *)
  if line^.size >= 16 then begin
    s:=line^.toString;
    id[0]:=#3;    id[1]   :=s[1];  id[2]   :=s[2];  id[3]   :=s[3];
    left[0]:=#3;  left[1] :=s[8];  left[2] :=s[9];  left[3] :=s[10];
    right[0]:=#3; right[1]:=s[13]; right[2]:=s[14]; right[3]:=s[15];
    result := new(PNode,init(id,left,right));
  end else
   writeln('Invalid input ... skipping Length:',line^.size);

  parseNode := result;
end;

procedure part1(nodes: PDeQueue;
                way  : PJString);
 function walk(start,goal:PDeQueueIterator; way:PJString):word;
 var result:word;
    itM   : PDeQueueIterator;
    itW   : PJStringIterator;
 begin
  result := 0;

  itM := start;
  itW := way^.first;
  write(PNode(itM^.at)^.id_,' ');
  while itM <> goal do begin
    if not itW^.valid then begin
      itW^.dispose;
      itW := way^.first;
    end;
    inc(result);
    itM := step(itM,itW^.at^);
    write(PNode(itM^.at)^.id_,' ');
    itW^.next;
  end;
  itW^.dispose;
  walk := result;
 end;
var
  start: PDeQueueIterator;
  goal : PDeQueueIterator;
  steps: word;

begin
  start := findNode(nodes,'AAA');
  goal  := findNode(nodes,'ZZZ');

  writeln('Walking the way...');
  steps := walk(start,goal,way);
  writeln;

  writeln('Required Steps: ',steps);
end;


procedure part2(nodes: PDeQueue;
                way  : PWay);

  function divMul(a,b : comp) : comp;
  var tmp: extended;
  begin
    tmp := a / b;
    divMul := trunc(tmp) * b;
  end;

  procedure findStartNodes(nodes        : PDeQueue;
                           var nodeList : array of TNodeInfo);
  var i : word;
      it: PDeQueueIterator;
  begin
   for i:= LOW(nodeList) to HIGH(nodeList) do begin
    nodeList[i].pos:=NIL;
    nodeList[i].numberOfSteps:=0;
   end;
   it := nodes^.first;
   i  := LOW(nodeList);
   while it <> NIL do begin
     if PNode(it^.at)^.id_[3] = 'A' then begin
       if i > HIGH(nodeList) then runError(300);
       nodeList[i].pos:=it;
       nodeList[i].numberOfSteps:=0;
       inc(i);
     end;
     it := it^.next;
   end;
  end;

  procedure printNodes(nodeList : array of PDeQueueIterator);
  var i:word;
  begin
    write(char($0d));
    for i:=LOW(nodeList) to HIGH(nodeList) do
     if nodeList[i] <> NIL then write(PNode(nodeList[i]^.at)^.id_,' ');
  end;

var nodeList :array [0..8] of TNodeInfo;
    max   : comp;
    tmp   : comp;
    tmp2  : comp;
    offset: longint;
    i,i2  : word;
begin
  findStartNodes(nodes,nodeList);
  max := 1.0e10;

  for i:= 0 to HIGH(nodeList) do
    with nodeList[i] do begin
      if pos <> NIL then
        numberOfSteps:=findNumberOfSteps(way,0,pos,pos);
      if max < numberOfSteps then max := numberOfSteps;
    end;

  i:=0;
  i2:= 0;

  while i < 8 do with nodeList[i] do begin
    if pos = NIL then inc(i) else
    if numberOfSteps > max then begin
      max := numberOfSteps;
      i:= 0;
      if keypressed then halt(1);
    end else if numberOfSteps = max then begin
     inc(i);
     if i>i2 then i2:=i;
     if i>1 then write(chr($d),max,' ',i,'/',i2);
    end else begin
     tmp := way^.maxSteps;
     offset := round(numberOfSteps-divMul(numberOfSteps,tmp));
     if PNode(pos^.at)^.nodeInfo_^[offset].numberOfSteps <=0 then begin
        PNode(pos^.at)^.nodeInfo_^[offset].numberOfSteps :=
        findNumberOfSteps(way,
                          offset,
                          pos,
                          PNode(pos^.at)^.nodeInfo_^[offset].pos);

        PNode(pos^.at)^.nodeInfo_^[offset].isCircle:=
         (divMul(PNode(pos^.at)^.nodeInfo_^[offset].numberOfSteps, way^.maxSteps) =
            PNode(pos^.at)^.nodeInfo_^[offset].numberOfSteps) and
         (pos = PNode(pos^.at)^.nodeInfo_^[offset].pos);
     end;
     tmp2:= PNode(pos^.at)^.nodeInfo_^[offset].numberOfSteps;
     if PNode(pos^.at)^.nodeInfo_^[offset].isCircle then begin
       tmp:= (divMul(max - numberOfSteps, tmp2)) + numberOfSteps;

       if tmp <> max then numberOfSteps := tmp + tmp2
       else numberOfSteps := tmp;
     end else begin
       pos:=PNode(pos^.at)^.nodeInfo_^[offset].pos;
       numberOfSteps:=numberOfSteps+tmp2;
     end;
    end;
  end;

  writeln('Part 2 number of steps:', max);
end;

var
  i    : word;
  nodes: PDeQueue;
  way  : PJString;
  away : TWay;
  line : PJString;
  input: Text;
  it   : PJStringIterator;
begin
  writeln('Loading Data...');
  nodes :=new(PDeQueue,init);
  assign(input,InputFileName);
  reset(input);
  line :=ReadLine(input);
  way := line^.stripWhiteSpace;
  i:=0;

  writeln('Number of steps loaded: ',way^.size);

  it:= way^.first;
  while it^.valid do
  begin
   away.maxSteps:=i+1;
   away.steps[i]:=it^.at^;
   it^.next;
   inc(i);
  end;
  it^.dispose;
  line^.dispose;
  readln(input);
  while not eof(input) do begin
    line := ReadLine(input);
    nodes^.pushBack(parseNode(line));
    line^.dispose;
  end;
  close(input);

  writeln('Mashing ',nodes^.size,' nodes...');
  mesh(nodes);

  {part1(nodes,way);}

  part2(nodes,@away);

  nodes^.dispose;
  way^.dispose;
end.
