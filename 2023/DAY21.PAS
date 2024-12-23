program day21;
(* This is the implementation for day 21 of advent of code 2023 *)
uses crt,
     cassert,
     dequeue,
     progressbar,
     itemhandler,
     heap;

const InputFileName= 'INP\DAY21_IN.TXT';
      MaxX = 130;
      MaxY = 130;

type  TDirection = (North, South, West, East);
      TPos = record
         x_ : byte;
         y_ : byte;
      end;

      PBacklog = ^TBacklog;
      TBacklog = object(ItemType)
        pos_ : TPos;
        dist_: word;
        constructor init(const pos : TPos; const dist: word);
        function compare(other:PItemType):TRelation; virtual;
      end;

      TOccupancy = set of 0..MaxX;
      TMap = array [0..MaxY] of TOccupancy;
      PDistanceMap = ^TDistanceMap;
      TDistanceMap = array[0..MaxX,0..MaxY] of word;

function adjustPosition(var pos: TPos;
                        const direction: TDirection): boolean;
var result : boolean;
begin
  result := true;
  case direction of
     North: if pos.x_  > 0    then dec(pos.x_) else result := false;
     South: if pos.x_  < MaxX then inc(pos.x_) else result := false;
     West : if pos.y_  > 0    then dec(pos.y_) else result := false;
     East : if pos.y_  < MaxY then inc(pos.y_) else result := false;
  end;
  adjustPosition := result;
end;

procedure buildDistanceMap(const map  : TMap;
                           const start: TPos;
                           var   dmap : TDistanceMap);
var heap : TMinHeap;
      bl : PBacklog;
      tmp: TPos;
        d: TDirection;
        p: TProgressbar;
begin
  fillchar(dmap,sizeof(dmap),0);
  heap.init;
  heap.push(new(PBacklog,init(start,0)));
  p.init(MaxX*MaxY,'crunch');
  while heap.size > 0 do begin
    bl := PBacklog(heap.pop);
    with bl^ do begin
      if dmap[pos_.x_,pos_.y_] = 0 then begin
        p.step(1);
        dmap[pos_.x_, pos_.y_] := dist_;
        for d:= North to East do begin
            tmp := pos_;
            if adjustPosition(tmp,d) then begin
               if (not (tmp.x_ in map[tmp.y_])) and
                  (dmap[tmp.x_, tmp.y_] = 0) then
                    heap.push(new(PBacklog,init(tmp,dist_+1)));
            end;
        end;
      end;
    end;
    dispose(bl,done);
  end;
  p.done;
  heap.done;
end;

constructor TBacklog.init(const pos: TPos; const dist: word);
begin
  pos_  := pos;
  dist_ := dist;
end;

function TBacklog.compare(other:PItemType):TRelation;
begin
  with PBacklog(other)^ do begin
     if dist_ > self.dist_ then compare := Smaller else
     if dist_ < self.dist_ then compare := Bigger
     else compare := Equal;
  end;
end;

procedure loadMap(var input: Text;
                  var map  : TMap;
                  var start: TPos);

var x,y : byte;
   line : string;
begin

  fillchar(map,sizeof(map),0);
  start.x_ := 0;
  start.y_ := 0;

  for y:= 0 to MaxY do begin
    assert(not eof(input),'Not enougth lines');
    readln(input, line);
    assert(length(line) = (MaxX + 1),'Line to short');
    for x:= 0 to MaxX do begin
      if line[x+1] = '#' then map[y]:=map[y]+[x];
      if line[x+1] = 'S' then begin
        start.x_ := x;
        start.y_ := y;
      end;
    end;
  end;
end;

function part1(var input: Text) : longint;
var map  : TMap;
    dmap : PDistancemap;
    start: TPos;
    c,x,y: word;
begin
  loadMap(input, map, start);
  dmap := new(PDistancemap);
  writeln('Build distance map...');
  buildDistanceMap(map, start, dmap^);

  c:=0;
  for x:=0 to MaxX do
   for y:=0 to MaxY do
     if (dmap^[x,y] > 0) and (dmap^[x,y] <=64) and
        (dmap^[x,y] mod 2 = 0) then inc(c);
  dispose(dmap);
  part1 := c;
end;

var input : Text;
       p1 : longint;
begin
  clrscr;
  assign(input, InputFileName);
  reset(input);
  p1 := part1(input);
  writeln('Answert part1 is: ', p1);

  close(input);
end.
