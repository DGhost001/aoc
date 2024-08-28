program Day8;
uses crt,jstring,dequeue,itemhandler;

type TId   = string[3];
     PNode = ^TNode;
     TNode = object(ItemType)
       id_     : TId;
       leftId_ : TId;
       rightId_: TId;
       left_   : PDeQueueIterator;
       right_  : PDeQueueIterator;

       constructor init(id, left, right : TId);
     end;
const
  InputFileName = 'INP\DAY8_INP.TXT';
constructor TNode.init(id, left, right : TId);
begin
 id_      := id;
 leftId_  := left;
 rightId_ := right;
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
                way  : PJString);
  procedure findStartNodes(nodes        : PDeQueue;
                           var nodeList : array of PDeQueueIterator);
  var i : word;
      it: PDeQueueIterator;
  begin
   for i:= LOW(nodeList) to HIGH(nodeList) do
   nodeList[i]:=NIL;
   it := nodes^.first;
   i  := LOW(nodeList);
   while it <> NIL do begin
     if PNode(it^.at)^.id_[3] = 'A' then begin
       if i > HIGH(nodeList) then runError(300);
       nodeList[i] := it;
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

  function allFinished(nodeList : array of PDeQueueIterator):boolean;
  var result : boolean;
      i,c      : word;
  begin
   result := True;
   c:=HIGH(nodeList)+1;

   for i:=LOW(nodeList) to HIGH(nodeList) do begin
     if (nodeList[i] <> NIL) and (PNode(nodeList[i]^.at)^.id_[3] <> 'Z') then begin
       result := False;
       dec(c);
     end else if nodeList[i] = NIL then dec(c);
   end;

   if c > LOW(nodeList) then begin
    printNodes(nodeList);
    {writeln;}
   end;


   allFinished := result;
  end;

  procedure multiStep(var nodeList : array of PDeQueueIterator; c : char);
  var i:word;
  begin
    for i:=LOW(nodeList) to HIGH(nodeList) do
     if nodeList[i] <> NIL then nodeList[i]:=step(nodeList[i],c);
  end;

var nodeList :array [0..8] of PDeQueueIterator;
    result: longint;
    itW   : PJStringIterator;
begin
  result := 0;
  findStartNodes(nodes,nodeList);

  itW := way^.first;

  while not allFinished(nodeList) do begin
    if not itW^.valid then begin
      itW^.dispose;
      itW := way^.first;
    end;
    inc(result);
    if (result mod 1000) = 0 then begin
    { write(chr($0D),result);}
    { printNodes(nodeList); write(itW^.at^,' ',result);}
     if keypressed then halt(1);
    end;
    multiStep(nodeList,itW^.at^);
    itW^.next;
  end;
  itW^.dispose;

  writeln('Part 2 number of steps:', result);
end;

var
  nodes: PDeQueue;
  way  : PJString;
  line : PJString;
  input: Text;
begin
  writeln('Loading Data...');
  nodes :=new(PDeQueue,init);
  assign(input,InputFileName);
  reset(input);
  line :=ReadLine(input);
  way := line^.stripWhiteSpace;
  line^.dispose;
  readln(input);
  while not eof(input) do begin
    line := ReadLine(input);
    nodes^.pushBack(parseNode(line));
    line^.dispose;
  end;
  close(input);

  writeln('Mashing the nodes...');
  mesh(nodes);

  part1(nodes,way);

  part2(nodes,way);

  nodes^.dispose;
  way^.dispose;
end.
