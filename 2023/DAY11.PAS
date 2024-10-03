(* This is the implementation for the day 11 of the advent of code 2023 *)
program day11;
{$E+}{$N+}
uses DeQueue,ItemHandler;
type PGalaxy = ^TGalaxy;
     TGalaxy = object(ItemType)
      x_ : longint;
      y_ : longint;

      constructor init(const x,y : word);
      function distance(const other: PGalaxy):longint;
     end;
const
 InputFile = 'INP\DAY11_IN.TXT';
 size      = 140 - 1;

function absDiff(const a,b : longint) : longint;
begin
 if a > b then absDiff := a - b else absDiff := b - a;
end;

constructor TGalaxy.init(const x,y : word);
begin
 x_ := x;
 y_ := y;
end;

function TGalaxy.distance(const other: PGalaxy):longint;
begin
  distance := absDiff(self.x_, other^.x_) + absDiff(self.y_, other^.y_);
end;

procedure loadGalaxies(var input : Text;
                       var galaxyList : PDequeue;
                       const offset: longint);
var x,y,i                : byte;
    tmp                  : char;
    rows, cols           : set of 0..size;
    rowOffset, colOffset : array[0..size] of byte;
    it                   : PDequeueIterator;
begin
  galaxyList := new(PDeQueue, init);
  rows := [];
  cols := [];
  for y:=0 to size do begin
   for x:=0 to size do begin
     read(input,tmp);
     if tmp = '#' then begin
       rows := rows + [y];
       cols := cols + [x];
       galaxyList^.pushBack(new(PGalaxy,init(x,y)));
     end;
   end;
   read(input,tmp); read(input,tmp);
  end;

  (* Get the rows and cols not in the sets *)
  rows := [0..size] -  rows;
  cols := [0..size] -  cols;

  x:= 0;
  y:= 0;
  for i:= 0 to size do begin
   if i in cols then inc(x);
   if i in rows then inc(y);
   rowOffset[i] := y;
   colOffset[i] := x;
  end;

  (* Expand the universe *)
  it := galaxyList^.first;
  while it <> NIL do begin
    with PGalaxy(it^.at)^ do begin
     x_:=x_ + longint(colOffset[x_])*offset;
     y_:=y_ + longint(rowOffset[y_])*offset;
    end;
    it := it^.next;
  end;
end;

function part1(universe : PDeQueue) : double;
var sum     : double;
   it1, it2 : PDequeueIterator;
begin
  sum := 0.0;
  it1 := universe^.first;
  while it1 <> NIL do begin
   it2 := it1^.next;
   while it2 <> NIL do begin
    sum := sum + PGalaxy(it1^.at)^.distance(PGalaxy(it2^.at));
    it2 := it2^.next;
   end;
   it1 := it1^.next;
   write('.');
  end;
  writeln;
  part1 := sum;
end;

var input    : Text;
    universe : PDeQueue;
    result1  : double;
begin
 assign(input, InputFile);
 reset(input);
 loadGalaxies(input,universe,1);
 close(input);
 result1 := part1(universe);
 writeln('Part1 Answer: ',result1:2:0);
 universe^.dispose;

 assign(input, InputFile);
 reset(input);
 loadGalaxies(input,universe,1000000-1);
 close(input);
 result1 := part1(universe);
 writeln('Part2 Answer: ',result1:2:0);
 universe^.dispose;

end.