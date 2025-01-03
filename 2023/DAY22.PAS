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
        p1, p2 : TPoint;

        constructor initf( var input: Text);
        procedure setHeight( const z: integer);
        function compare(other:PItemType):TRelation;virtual;

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

constructor TCube.initf(var input: Text);
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
    if self.p1.z_ < p1.z_ then compare := Bigger else
    if self.p1.z_ > p1.z_ then compare := Smaller else
    compare := Equal;
  end;
end;

function loadCubes(var input: Text): PDeQueue;
var result : PDeQueue;
    foo    : char;
begin
  result := new(PDeQueue, init);

  while not eof(input) do begin
    result^.pushBack(new(PCube, initf(input)));
    read(input, foo); (* Forwar to the next line *)
  end;

  sortQueue(result);

  loadCubes := result;
end;

function part1(var input: Text): longint;
var cubes : PDeQueue;
begin
  cubes := loadCubes(input);

  cubes^.dispose;
  part1 := 0;
end;

function part2(var input: Text): comp;
begin
end;

var input: Text;
    p1   : longint;
    p2   : comp;
begin
  assign(input, InputFileName);
  reset(input);
  p1 := part1(input);

  writeln('Answer part1 is: ', p1);
  reset(input);
  p2 := part2(input);
  writeln('Answer part2 is: ', p2);
  close(input);
end.
