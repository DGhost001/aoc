program day22;
uses itemhandler,
     crt,
     cassert,
     dequeue,
     sort,
     utils;

const InputFileName = 'INP\DAY22_IN.TXT';

type TPoint = object
       x_, y_, z_ : integer;

       constructor init(const x, y, z: integer);
       constructor initf(var input: Text);

       procedure add(const other: TPoint);
     end;

     PCube = ^TCube;
     TCube = object(ItemType)
        id     : word;
        p1, p2 : TPoint;

        numClients, numSupport : byte;

        clients : array[0..16] of PCube;
        support : array[0..16] of PCube;

        desintigrate: record
          run    : PCube;
          number : byte;
          count  : word;
        end;

        constructor initf( var input: Text; const i : word);
        procedure setHeight( const z: integer);
        function compare(other:PItemType):TRelation;virtual;
        procedure addSupport  (other : PCube); (* We are supported by *)
        procedure addClient   (other : PCube); (* We are supporting   *)
        procedure report;
     end;
     PBackLog = ^TBackLog;
     TBackLog = object(ItemType)
        value_ : PCube;
        constructor init(v : PCube);
     end;

constructor TPoint.init(const x,y,z: integer);
begin
  x_ := x;
  y_ := y;
  z_ := z;
end;

constructor TPoint.initf(var input: Text);
var sx,sy: char;
begin
  x_ := readInteger(input);
  y_ := readInteger(input);
  z_ := readInteger(input);
end;

procedure TPoint.add(const other: TPoint);
begin
  inc(x_,other.x_);
  inc(y_,other.y_);
  inc(z_,other.z_);
end;

procedure TCube.report;
begin
  write(chr(id + ord('A')));
end;

constructor TCube.initf(var input: Text; const i : word);
 procedure xchg(var a,b: integer);
 var t: integer;
 begin
   t:= a;
   a:= b;
   b:= t;
 end;

var     c : char;
begin
  p1.initf(input);
  p2.initf(input);

  if p2.x_ < p1.x_ then xchg(p1.x_, p2.x_);
  if p2.y_ < p1.y_ then xchg(p1.y_, p2.y_);
  if p2.z_ < p1.z_ then xchg(p1.z_, p2.z_);
  fillchar(clients, sizeof(clients),0);
  fillchar(support, sizeof(support),0);
  fillchar(desintigrate, sizeof(desintigrate), 0);

  numClients := 0;
  numSupport := 0;
  id := i;
end;

procedure TCube.setHeight(const z: integer);
var diff: integer;
begin
  diff  := p1.z_ - z;
  p1.z_ := z;
  p2.z_ := p2.z_ - diff;
end;

function TCube.compare(other:PItemType):TRelation;
begin
  with PCube(other)^ do begin
    if self.p1.z_ > p1.z_ then compare := Bigger else
    if self.p1.z_ < p1.z_ then compare := Smaller else
    compare := Equal;
  end;
end;

procedure TCube.addSupport  (other : PCube); (* We are supported by *)
var isUnknown : boolean;
           i : byte;
begin
  assert(numSupport <= HIGH(support),'Too many supporters');
  isUnknown := true;

  if numSupport > 0 then
    for i:=0 to numSupport - 1 do
      if support[i] = other then isUnknown := false;

  if isUnknown then begin
    support[numSupport] := other;
    inc(numSupport);
  end;
end;

procedure TCube.addClient   (other : PCube); (* We are supporting   *)
var isUnknown : boolean;
         i : byte;
begin
  assert(numClients <= HIGH(clients),'Too many clients');

  isUnknown := true;

  if numClients > 0 then
    for i:=0 to numClients - 1 do
      if clients[i] = other then isUnknown := false;

  if isUnknown then begin
    clients[numClients] := other;
    inc(numClients);
  end;
end;

constructor TBackLog.init(v : PCube);
begin
  value_ := v;
end;


function loadCubes(var input: Text): PDeQueue;
var result : PDeQueue;
    foo    : char;
      i    : word;
begin
  result := new(PDeQueue, init);
  i := 0;
  while not eof(input) do begin
    result^.pushBack(new(PCube, initf(input,i)));
    read(input, foo); (* Forwar to the next line *)
    inc(i);
  end;

  sortQueue(result);

  loadCubes := result;
end;

procedure compactCubes(cubes : PDeQueue);
var heighMap : array[0..16,0..16] of record
                 ref : PCube;
                 height: word;
              end;
 function getHeight(const cube : TCube): word;
 var x,y  : integer;
       max: word;
 begin
   max := 0;
   for x:= cube.p1.x_ to cube.p2.x_ do
     for y:= cube.p1.y_ to cube.p2.y_ do begin
       if heighMap[x,y].height > max then max := heighMap[x,y].height;
     end;
   getHeight := max;
 end;

 procedure setHeight(cube :  PCube; const height : word);
 var x, y: integer;
 begin
   cube^.setHeight(height); (* Move the cube to the proper hight *)
   for x:= cube^.p1.x_ to cube^.p2.x_ do
     for y:= cube^.p1.y_ to cube^.p2.y_ do begin
       if (heighMap[x,y].height = height) and (heighMap[x,y].ref <> NIL) then begin
         heighMap[x,y].ref^.addClient(cube);
         cube^.addSupport(heighMap[x,y].ref);
       end;
       heighMap[x,y].height:= cube^.p2.z_ + 1;
       heighMap[x,y].ref   := cube;
     end;
 end;

var  it  : PDeQueueIterator;
      h  : word;
begin
  fillChar(heighMap,sizeOf(heighMap), 0);
  it := cubes^.first;
  while it <> nil do begin
    h := getHeight(PCube(it^.at)^);
    setHeight(PCube(it^.at), h);
    it := it^.next;
  end;
end;

function part1(cubes : PDeQueue): longint;
var count : longint;
        it: PDeQueueIterator;
         i: byte;
        ok: boolean;
begin
  it := cubes^.first;
  count := 0;
  while it<> nil do begin
    with PCube(it^.at)^ do begin
      ok := true;
      if numClients > 0 then
        for i:=0 to numClients - 1 do
          if clients[i]^.numSupport < 2 then ok := false;

      if ok then begin
         inc(count);
      end;

    end;

    it := it^.next;
  end;

  part1 := count;
end;

procedure desintigrate(it : PDeQueueIterator); far;
var backLog : PDeQueue;
          i : byte;
         bit: PDeQueueIterator;
        cube: PCube;
        c   : PCube;
begin
  backLog := new(PDeQueue, init);
  cube  := PCube(it^.at);
  with cube^ do
    if numClients > 0 then
      for i:=0 to numClients-1 do
        backLog^.pushBack(new(PBackLog,init(clients[i])));

  while backLog^.size  > 0 do begin
    c:=  PBackLog(backLog^.first^.at)^.value_;
    with c^ do begin
        if desintigrate.run <> cube then begin
          desintigrate.run := cube;
          desintigrate.number := 1;
        end else inc(desintigrate.number);
        if desintigrate.number >= numSupport then begin
          inc(cube^.desintigrate.count);
          if numClients > 0 then
            for i:=0 to numClients-1 do
              backLog^.pushBack(new(PBackLog,init(clients[i])));
        end;
    end;
    backlog^.popFront;
  end;

  backLog^.dispose;
end;

function part2(cubes  : PDeQueue): comp;
var sum : comp;
      it: PDeQueueIterator;
begin
  cubes^.foreach(desintigrate);
  sum := 0;
  it := cubes^.first;
  while it<> nil do begin
    sum := sum + PCube(it^.at)^.desintigrate.count;
    it := it^.next;
  end;
  part2 := sum;
end;

var input: Text;
    p1   : longint;
    p2   : comp;
    cubes: PDeQueue;
begin
  clrscr;
  assign(input, InputFileName);
  reset(input);

  cubes := loadCubes(input);
  compactCubes(cubes);
  close(input);

  p1 := part1(cubes);
  writeln('Answer part1 is: ', p1);
  p2 := part2(cubes);
  writeln('Answer part2 is: ', p2:1:0);

  cubes^.dispose;
end.
