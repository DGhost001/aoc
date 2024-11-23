program day18;
uses dequeue, Itemhandler, sort;
(*
   This is the implementation for AoC Day 18 2023
   Part 1 can be soloved by reusing the code from
   day 10.
   We just need to build the poloygon differntly
*)
type
     TPos   = record
       x : integer;
       y : integer;
     end;

     TPoint = record
       x : real;
       y : real;
     end;

     PPolyPoint = ^TPolyPoint;
     TPolyPoint = object(ItemType)
       pos_ : TPoint;

       constructor init(const pos   : TPos);
       constructor copy(const other : PPolyPoint);
       function compare(other:PItemType):TRelation;virtual;
     end;

const NullPos : TPos = (x : 255; y : 255);
      InputFile = 'INP\DAY18_TE.TXT';

constructor TPolyPoint.init(const pos : TPos);
begin
  pos_.x := pos.x;
  pos_.y := pos.y;
end;

constructor TPolyPoint.copy(const other : PPolyPoint);
begin
  pos_ := other^.pos_;
end;

function TPolyPoint.compare(other:PItemType):TRelation;
var otherPoint : PPolyPoint;
begin
  otherPoint := PPolyPoint(other);

  if otherPoint^.pos_.x > self.pos_.x then compare:=Smaller else
  if otherPoint^.pos_.x < self.pos_.x then compare:=Bigger else
  compare := Equal;
end;

function getIntersections(polygon : PDeQueue; line : integer):PDeQueue;
var it, itn    : PDeQueueIterator;
    result     : PDeQueue;
    p1, p2     : TPoint;
    pos        : TPos;
begin
  result := new(PDequeue,init);

  it  := polygon^.first;
  itn := it^.next;

  while itn <> NIL do begin
    p1 := PPolyPoint(it^.at)^.pos_;
    p2 := PPolyPoint(itn^.at)^.pos_;

    if (trunc(p1.x) = trunc(p2.x)) and  (* We can have only vertical intersections *)
       ((p1.y <= line) and (p2.y >= line)) or
       ((p1.y >= line) and  (p2.y <= line)) then begin
       pos.x := trunc(p1.x);
       pos.y := line;
       result^.pushBack(new(PPolyPoint, init(pos)));
    end;
    it := itn;
    itn := itn^.next;
  end;

  (* we can't guarantee that the polygon is clock or anti clockwise *)
  (* But we know that the left border is not part of the polygon    *)
  (* So by sorting we bring the intersections in a sensible order   *)
  sortQueue(result);

  getIntersections := result;
end;

procedure cleanOutBorder(polygon     : PDequeue;
                         intersection: PDequeue);
var it1,it2, pt1, pt2 : PDequeueIterator;
    ip1, ip2          : TPoint;
    pp1, pp2, tmp     : TPoint;
begin
  it1 := intersection^.first;
  while it1 <> NIL do begin
    it2 := it1^.next;
    if it2 = NIL then break;
    ip1 := PPolyPoint(it1^.at)^.pos_;
    ip2 := PPolyPoint(it2^.at)^.pos_;
    pt1 := polygon^.first;
    while pt1 <> NIL do begin
     pt2 := pt1^.next;
     if pt2 = NIL then break;
     pp1 := PPolyPoint(pt1^.at)^.pos_;
     pp2 := PPolyPoint(pt2^.at)^.pos_;
     (*Make sure the line is always from left to right *)
     if pp1.x > pp2.x then begin
       tmp:= pp1;
       pp1:= pp2;
       pp2:= tmp;
     end;

     if (pp1.y = pp2.y) and
        (ip1.y = pp1.y) then begin
        if (ip1.x >= pp1.x) and (ip1.x <= pp2.x) then begin
          ip1.x := pp2.x;
        end;
        if (ip2.x >= pp1.x) and (ip2.x <= pp2.x) then begin
          ip2.x := pp1.x
        end;
     end;
     pt1 := pt2^.next;
    end;
    PPolyPoint(it1^.at)^.pos_:= ip1;
    PPolyPoint(it2^.at)^.pos_:= ip2;
    it1:= it2^.next;
  end;
end;

function parseInput(var input:Text;
                    var totalSteps : longint;
                    var minY,maxY  : integer
                   ):PDeQueue;
var result : PDeQueue;
    dir    : char;
    steps  : word;
    color  : string;
    pos    : TPos;
begin
  reset(input);
  totalSteps := 0;
  minY       := 0;
  maxY       := 0;
  pos.x      := 0;
  pos.y      := 0;
  result := new(PDequeue, init);
  result^.pushBack(new(PPolyPoint,init(pos)));
  while not eof(input) do begin
    readln(input, dir, steps, color);
    case dir of
      'R': inc(pos.x, steps);
      'L': dec(pos.x, steps);
      'D': inc(pos.y, steps);
      'U': dec(pos.y, steps);
    else
     RunError(300); (* Invalid input *)
    end;
    inc(totalSteps,steps);
    if pos.y < minY then minY := pos.y;
    if pos.y > maxY then maxY := pos.y;
    result^.pushBack(new(PPolyPoint, init(pos)));
  end;
  parseInput := result;
end;

function part1(var input : Text) : longint;
var minY, maxY : integer;
    poly       : PDequeue;
    intersect  : PDequeue;
    area       : longint;
    line       : integer;
    it1,it2    : PDeQueueIterator;
    tmp        : real;
begin
  poly:=parseInput(input, area, minY, maxY);

  for line := minY to maxY do begin
    intersect := getIntersections(poly,line);
    cleanOutBorder(poly,intersect);
    it1 := intersect^.first;
    if it1 <> NIL then it2 := it1^.next else it2 := NIL;
    while it2 <> NIL do begin
      tmp := PPolyPoint(it2^.at)^.pos_.x - PPolyPoint(it1^.at)^.pos_.x - 1;
      writeln(line,':',tmp:1:0);
      if tmp > 0 then inc(area, trunc(tmp));
      it1 := it2^.next;
      if it1 <> NIL then it2 := it1^.next else it2 := NIL;
    end;
    intersect^.dispose;
  end;

  poly^.dispose;
  part1 := area;
end;

var input : Text;
    p1    : longint;
begin
  assign(input, InputFile);
  p1 := part1(input);
  close(input);

  writeln('Part 1 Answer is: ',p1);
end.