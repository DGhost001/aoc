program day22;
uses itemhandler, crt, cassert;
const InputFileName = 'INP\DAY21_IN.TXT';

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
  read(input, x_,sx,y_,sy,z_);

  assert(sx=',','Invalid Input Format');
  assert(sy=',','Invalid Input Format');
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
  p1.initf(input); read(input, c);
  assert(c='~','Invalid Input Format');
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

function part1(var input: Text): longint;
begin
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
