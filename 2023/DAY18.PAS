program day18;
uses crt, graph, dequeue, Itemhandler, sort, progressbar;
(*
   This is the implementation for AoC Day 18 2023
   Part 1 can be soloved by reusing the code from
   day 10.
   We just need to build the poloygon differntly
*)
type
     TPos   = record
       x : longint;
       y : longint;
     end;

     TPoint = record
       x : double;
       y : double;
     end;

     PPolyPoint = ^TPolyPoint;
     TPolyPoint = object(ItemType)
       pos_ : TPoint;

       constructor init(const pos   : TPos);
       constructor init2(const p     : TPoint);
       constructor copy(const other : PPolyPoint);
       function compare(other:PItemType):TRelation;virtual;
     end;

const NullPos : TPos = (x : 255; y : 255);
      InputFile = 'INP\DAY18_IN.TXT';

constructor TPolyPoint.init(const pos : TPos);
begin
  pos_.x := pos.x;
  pos_.y := pos.y+0.5;
end;

constructor TPolyPoint.init2(const p : TPoint);
begin
  pos_:=p;
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
       (((p1.y <= line) and (p2.y >= line)) or
       ((p1.y >= line) and  (p2.y <= line))) then begin
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

(* The main issue with the intersection function above is that if
   we have horrizontals lines it will create intersections for the
   corners.
   This means we would count the area twice.
   This function filters out the parts that are covered by a
   horrizontal polygon line.
*)
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

     if (trunc(pp1.y) = trunc(pp2.y)) and
        (trunc(ip1.y) = trunc(pp1.y)) then begin
        if (ip1.x >= pp1.x) and (ip1.x <= pp2.x) then begin
          ip1.x := pp2.x;
        end;
        if (ip2.x >= pp1.x) and (ip2.x <= pp2.x) then begin
          ip2.x := pp1.x;
        end;
        (* We need to split the line *)
        if (ip1.x <= pp1.x) and (ip2.x >= pp2.x) then begin
          intersection^.pushBack(new(PPolyPoint,init2(pp2)));
          intersection^.pushBack(new(PPolyPoint,init2(ip2)));
          ip2.x := pp1.x;
        end;
     end;
     pt1 := pt2^.next;
    end;
    PPolyPoint(it1^.at)^.pos_:= ip1;
    PPolyPoint(it2^.at)^.pos_:= ip2;
    it1:= it2^.next;
  end;
end;

procedure drawPoly(poly:PDeQueue; const minY : integer);
var it1, it2 : PDeQueueIterator;
    ip1, ip2 : TPoint;
begin
  it1 := poly^.first;
  setColor(green);
  while it1 <> NIL do begin
    it2 := it1^.next;
    if it2 = NIL then break;
    ip1 := PPolyPoint(it1^.at)^.pos_;
    ip2 := PPolyPoint(it2^.at)^.pos_;

    line(trunc(ip1.x-300),trunc(ip1.y)-minY,
         trunc(ip2.x-300),trunc(ip2.y)-minY);

    it1 := it2;
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
  minY       := 512;
  maxY       := 512;
  pos.x      := 512;
  pos.y      := 512;
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

function parseInput2(var input:Text;
                     var totalSteps : comp;
                     var minY,maxY  : longint
                    ):PDeQueue;
  function hexToInt(s: string):longint;
  var result : longint;
      i      : word;
  begin
    result := 0;
    for i:=1 to length(s) do begin
      result := result shl 4;
      case s[i] of
        '0'..'9': result := result + (ord(s[i]) - ord('0'));
        'a'..'f': result := result + (ord(s[i]) - ord('a')) + 10;
      else runError(300);
      end;
    end;
    hexToInt:=result;
  end;

var result : PDeQueue;
    dir    : char;
    steps  : longint;
    color  : string;
    pos    : TPos;
begin
  reset(input);
  totalSteps := 0;
  minY       := 0;
  maxY       := 0;
  pos.x      := 0;
  pos.y      := 10521646;
  result := new(PDequeue, init);
  result^.pushBack(new(PPolyPoint,init(pos)));
  while not eof(input) do begin
    readln(input, dir, steps, color);
    dir := color[length(color)-1];
    delete(color,1,3);
    delete(color,length(color)-1,2);

    steps := hexToInt(color);
    case dir of
      '0': inc(pos.x, steps);
      '2': dec(pos.x, steps);
      '1': inc(pos.y, steps);
      '3': dec(pos.y, steps);
    else
     RunError(300); (* Invalid input *)
    end;
    totalSteps:=totalSteps + steps;
    if pos.y < minY then minY := pos.y;
    if pos.y > maxY then maxY := pos.y;
    result^.pushBack(new(PPolyPoint, init(pos)));
  end;
  parseInput2 := result;
end;

function part1(var input : Text) : longint;
var minY, maxY : integer;
    poly       : PDequeue;
    intersect  : PDequeue;
    area       : longint;
    line       : integer;
    it1,it2    : PDeQueueIterator;
    tmp        : real;
    p          : TProgressBar;
begin
  poly:=parseInput(input, area, minY, maxY);
  (* drawPoly(poly,minY);
  setColor(red);
  writeln('Dim: ',minY,'-',maxY);*)
  p.init(maxY - minY + 1, 'Measure...');
  for line := minY to maxY do begin
    intersect := getIntersections(poly,line);
    cleanOutBorder(poly,intersect);
    it1 := intersect^.first;
    if it1 <> NIL then it2 := it1^.next else it2 := NIL;
    while it2 <> NIL do begin
      tmp := PPolyPoint(it2^.at)^.pos_.x - PPolyPoint(it1^.at)^.pos_.x - 1;
      (* writeln(line-minY,':',tmp:1:0);*)
      if tmp > 0 then begin
(*      graph.line(trunc(PPolyPoint(it1^.at)^.pos_.x+1) - 300, trunc(PPolyPoint(it1^.at)^.pos_.y)-minY,
             trunc(PPolyPoint(it2^.at)^.pos_.x-1) - 300, trunc(PPolyPoint(it2^.at)^.pos_.y)-minY);
*)     inc(area, trunc(tmp));
      end;
      it1 := it2^.next;
      if it1 <> NIL then it2 := it1^.next else it2 := NIL;
    end;
    intersect^.dispose;
    p.step(1);
  end;
  p.done;
  poly^.dispose;
  part1 := area;
end;

function part2(var input : Text) : comp;
var minY, maxY : longint;
    poly       : PDequeue;
    intersect  : PDequeue;
    area       : comp;
    line       : longint;
    it1,it2    : PDeQueueIterator;
    tmp        : double;
    p          : TProgressBar;
begin
  poly:=parseInput2(input, area, minY, maxY);
  (* drawPoly(poly,minY);
  setColor(red); *)
  writeln('Dim: ',minY,'-',maxY);

  p.init(maxY - minY + 1, 'Measure...');
  for line := minY to maxY do begin
    intersect := getIntersections(poly,line);
    cleanOutBorder(poly,intersect);
    it1 := intersect^.first;
    if it1 <> NIL then it2 := it1^.next else it2 := NIL;
    while it2 <> NIL do begin
      tmp := PPolyPoint(it2^.at)^.pos_.x - PPolyPoint(it1^.at)^.pos_.x - 1;
      (* writeln(line-minY,':',tmp:1:0);*)
      if tmp > 0 then begin
(*      graph.line(trunc(PPolyPoint(it1^.at)^.pos_.x+1) - 300, trunc(PPolyPoint(it1^.at)^.pos_.y)-minY,
             trunc(PPolyPoint(it2^.at)^.pos_.x-1) - 300, trunc(PPolyPoint(it2^.at)^.pos_.y)-minY);
*)     area:=area + trunc(tmp);
      end;
      it1 := it2^.next;
      if it1 <> NIL then it2 := it1^.next else it2 := NIL;
    end;
    intersect^.dispose;
    p.step(1);
  end;
  p.done;
  poly^.dispose;
  part2 := area;
end;


var input : Text;
    p1    : longint;
    p2    : comp;
    a,b   : integer;
begin
  clrscr;
  a:=0;
  b:=0;
  (* initGraph(a,b,'c:\bp\bgi'); *)

  assign(input, InputFile);
  (* p1 := part1(input); *)
  p2 := part2(input);
  close(input);

 (* readln;
  closeGraph; *)

  writeln('Part 1 Answer is: ',p1);
  writeln('Part 2 Answer is: ',p2:1:0);
end.