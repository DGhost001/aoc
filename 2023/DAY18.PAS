program day18;
uses crt, graph, dequeue, Itemhandler, sort, progressbar;
(*
   This is the implementation for AoC Day 18 2023
   Part 1 can be soloved by reusing the code from
   day 10.
   We just need to build the poloygon differntly
*)
type
     TPoint = record
       x : longint;
       y : longint;
     end;

     TIntersections =  record
        cut     : array[0..31] of longint;
        numCuts : byte;
     end;

     PEdge = ^TEdge;
     TEdgeType = (Horrizontal, Vertical);
     TEdge = object(ItemType)
       start_ : TPoint;
       end_   : TPoint;
       type_  : TEdgeType;
       constructor init(const p1, p2   : TPoint);
       constructor copy(const other : PEdge);
       function compare(other:PItemType):TRelation;virtual;
     end;

const InputFile = 'INP\DAY18_IN.TXT';
      XOffset = 300;
      YOffset = 200;
constructor TEdge.init(const p1, p2 : TPoint);
begin
  (* The edge definition is, that the start point is always above / left
     of the endpoint. This constructor makes sure this always holds at least
     for horizontal / vertical edges
   *)
  if p1.y = p2.y then begin
    if p1.x <= p2.x then begin
       start_ := p1;
       end_   := p2;
    end else begin
       start_ := p2;
       end_   := p1;
    end;
  end else if p1.y < p2.y then begin
    start_ := p1;
    end_   := p2;
  end else begin
    start_ := p2;
    end_   := p1;
  end;
  if start_.y = end_.y then type_ := Horrizontal else
  if start_.x = end_.x then type_ := Vertical
  else runError(300); (* Only H and V Edges are allowed *)
end;

constructor TEdge.copy(const other : PEdge);
begin
  start_ := other^.start_;
  end_   := other^.end_;
end;

function TEdge.compare(other:PItemType):TRelation;
var otherEdge : PEdge;
begin
  otherEdge := PEdge(other);

  if otherEdge^.start_.y > self.start_.y then compare:= Smaller else
  if otherEdge^.start_.y < self.start_.y then compare:= Bigger else
  if otherEdge^.end_.y > self.end_.y then compare:= Smaller else
  if otherEdge^.end_.y > self.end_.y then compare:= Bigger else
  if otherEdge^.start_.x > self.start_.x then compare := Smaller else
  if otherEdge^.start_.x < self.start_.x then compare := Bigger else
  if otherEdge^.end_.x > self.end_.x then compare := Smaller else
  if otherEdge^.end_.x < self.end_.x then compare := Bigger else
  compare := Equal;
end;

procedure getIntersections(const line : longint;
                           var its, ite: PDeQueueIterator;
                           var result  : TIntersections
                         );

(* Swap two cut entries *)
procedure swapCut(const i1, i2 : byte; var result: TIntersections);
var tmp : longint;
begin
  tmp := result.cut[i1];
  result.cut[i1] := result.cut[i2];
  result.cut[i2] := tmp;
end;

(* Simple insertion sort *)
procedure addCut(const pos: longint; var result: TIntersections);
var i : byte;
begin
  with result do begin
    if numCuts > HIGH(cut) then runError(300);
    cut[numCuts] := pos;
    inc(numCuts);

    i:= numCuts - 1;
    while i > 0 do begin
      if cut[i - 1] > cut[i] then swapCut(i-1, i, result)
      else break;
      dec(i);
    end;
  end;
end;

var it : PDeQueueIterator;
     i : byte;
     hline : boolean;
begin

  if ite = NIL then ite := its;

  while (ite <> NIL) and
        (PEdge(ite^.at)^.start_.y <= line)  do ite := ite^.next;

  while (its <> NIL) and
        (PEdge(its^.at)^.end_.y <= line) do its := its^.next;

  it := its;

  result.numCuts := 0;
  hline := false;
  (* First process the vertical cuts *)
  while it <> ite do begin
    with PEdge(it^.at)^ do begin
      if (type_ = Vertical) and
         (start_.y <= line ) and
         (line < end_.y) then
        addCut(start_.x, result);
      hline := hline or ((type_ = Horrizontal) and (start_.y = line));
    end;
    it := it^.next;
  end;
  if hline then i := 0 else i:= result.numCuts;
  (* Second step, take out all horrizontal lines *)
  while i < result.numCuts do begin
   it := its;
   while it <> ite do begin
     with PEdge(it^.at)^ do begin
       if (type_ = Horrizontal) and
          (start_.y = line) and
          (result.cut[i] <= start_.x) and
          (start_.x < result.cut[i+1]) then begin
           addCut(start_.x,result);
           addCut(end_.x,result);
       end;
     end;
     it := it^.next;
   end;

   inc(i,2);
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
    p1, p2 : TPoint;
begin
  reset(input);
  totalSteps := 0;
  minY       := 0;
  maxY       := 0;
  p1.x       := 0;
  p1.y       := 0;
  result := new(PDequeue, init);
  while not eof(input) do begin
    p2 := p1;
    readln(input, dir, steps, color);
    case dir of
      'R': inc(p1.x, steps);
      'L': dec(p1.x, steps);
      'D': inc(p1.y, steps);
      'U': dec(p1.y, steps);
    else
     RunError(300); (* Invalid input *)
    end;
    inc(totalSteps,steps);
    if p1.y < minY then minY := p1.y;
    if p1.y > maxY then maxY := p1.y;
    result^.pushBack(new(PEdge, init(p2,p1)));
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
    p1,p2  : TPoint;
begin
  reset(input);
  totalSteps := 0;
  minY       := 0;
  maxY       := 0;
  p1.x       := 0;
  p1.y       := 0;
  result := new(PDequeue, init);
  while not eof(input) do begin
    p2 := p1;
    readln(input, dir, steps, color);
    dir := color[length(color)-1];
    delete(color,1,3);
    delete(color,length(color)-1,2);

    steps := hexToInt(color);
    case dir of
      '0': inc(p1.x, steps);
      '2': dec(p1.x, steps);
      '1': inc(p1.y, steps);
      '3': dec(p1.y, steps);
    else
     RunError(300); (* Invalid input *)
    end;
    totalSteps:=totalSteps + steps;
    if p1.y < minY then minY := p1.y;
    if p1.y > maxY then maxY := p1.y;
    result^.pushBack(new(PEdge, init(p2,p1)));
  end;
  parseInput2 := result;
end;

procedure drawPoly(poly:PDequeue);
var it: PDeQueueIterator;
begin
  setColor(green);
  it := poly^.first;
  while it <> NIL do begin
    with PEdge(it^.at)^ do begin
      line(start_.x+XOffset, start_.y+YOffset, end_.x+XOffset, end_.y+YOffset);
    end;
    it := it^.next;
  end;
end;

function computeArea(const minY, maxY : longint;
                     poly : PDeQueue) : comp;
var intersect  : TIntersections;
    area       : comp;
    line       : longint;
    i          : byte;
    its,ite    : PDeQueueIterator;
    tmp        : longint;
    p          : TProgressBar;
begin

  its := poly^.first;
  ite := NIL;
  area := 0;
  p.init(maxY - minY + 1, 'Measure...');

  for line := minY to maxY do begin
    getIntersections(line,its,ite, intersect);
    i:= 0;
    while i < intersect.numCuts do begin
      tmp := intersect.cut[i+1] - intersect.cut[i]-1;

      if tmp > 0 then begin
       area := area + tmp;
      end;
      inc(i,2);
    end;
    p.step(1);
  end;
  p.done;
  computeArea := area;
end;


function part1(var input : Text) : longint;
var minY, maxY : integer;
    poly       : PDequeue;
    area       : longint;
    p          : TProgressBar;
begin
  poly:=parseInput(input, area, minY, maxY);
  writeln('Sorting Edges...');
  sortQueue(poly);
  part1 := trunc(computeArea(minY, maxY,poly)) + area;
  poly^.dispose;
end;

function part2(var input : Text) : comp;
var minY, maxY : longint;
    poly       : PDequeue;
    area       : comp;
    p          : TProgressBar;
begin
  poly:=parseInput2(input, area, minY, maxY);
  writeln('Sorting Edges...');
  sortQueue(poly);
  part2 := computeArea(minY, maxY,poly) + area;
  poly^.dispose;
end;


var input : Text;
    p1    : longint;
    p2    : comp;
begin
  clrscr;
  assign(input, InputFile);
  p1 := part1(input);
  writeln('Part 1 Answer is: ',p1);

  p2 := part2(input);
  close(input);
  writeln('Part 2 Answer is: ',p2:1:0);
end.