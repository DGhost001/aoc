program day10;
{$N+ $E+}
uses Dequeue, Itemhandler, graph, sort;

type TPos = record
       x : byte;
       y : byte;
     end;

     TField = array[0..139,0..139] of char;
     TPosTuple = array[1..2] of TPos;

     TPoint = record
       x : real;
       y : real;
     end;

     PPolyPoint = ^TPolyPoint;
     TPolyPoint = object(ItemType)
       pos_ : TPoint;

       constructor init(pos   : TPos);
       constructor copy(other : PPolyPoint);
       function compare(other:PItemType):TRelation;virtual;
     end;

const NullPos : TPos = (x : 255; y : 255);
      InputFile = 'INP\DAY10_IN.TXT';

constructor TPolyPoint.init(pos : TPos);
begin
  pos_.x := pos.x + 0.5;
  pos_.y := pos.y + 0.5;
end;

constructor TPolyPoint.copy(other : PPolyPoint);
begin
  pos_ := other^.pos_;
end;

procedure west(pos: TPos; var result : TPos);
begin
 if pos.x > 0 then begin
  result := pos;
  dec(result.x);
 end else
  result := NullPos;
end;

procedure east(pos: TPos; var result : TPos);
begin
 if pos.x < 139 then begin
  result := pos;
  inc(result.x);
 end else
  result := NullPos;
end;

procedure north(pos: TPos; var result : TPos);
begin
 if pos.y > 0 then begin
  result := pos;
  dec(result.y);
 end else
  result := NullPos;
end;

procedure south(pos: TPos; var result : TPos);
begin
 if pos.y < 139 then begin
  result := pos;
  inc(result.y);
 end else
  result := NullPos;
end;

function pequal(pos1, pos2 : TPos) : boolean;
begin
  pequal  := (pos1.x = pos2.x) and (pos1.y = pos2.y);
end;

procedure setField(pos : TPos; var field : TField; c : char);
begin
  if not pequal(pos, NullPos) then
    field[pos.x,pos.y] := c;
end;

function getField(pos : TPos; var field : TField) : char;
begin
  if not pequal(pos, NullPos) then
    getField := field[pos.x, pos.y]
  else
    getField := #0;
end;

function getPositions(pos     : TPos;
                      var field: TField;
                      var next : TPosTuple
                      ):boolean;
var result : boolean;
begin
  result := false;
  if not pequal(pos, NullPos) then
     case field[pos.x,pos.y] of
          '-': begin west(pos,next[1]);   east(pos,next[2]);   end;
          '|': begin north(pos, next[1]); south(pos, next[2]); end;
          'L': begin north(pos, next[1]); east(pos, next[2]); result := true; end;
          'J': begin north(pos, next[1]); west(pos, next[2]); result := true;  end;
          '7': begin south(pos, next[1]); west(pos, next[2]); result := true;  end;
          'F': begin south(pos, next[1]); east(pos, next[2]); result := true;  end;
     else begin next[1] := NullPos; next[2]:= NullPos; end;
  end else begin
    next[1] := NullPos; next[2]:= NullPos;
  end;
  getPositions := result;
end;

procedure findStart(var field : TField; var pos : TPos);
var x,y : byte;
begin
  for x:=0 to 139 do
   for y:=0 to 139 do begin
     if field[x,y] = 'S' then begin
       pos.x := x;
       pos.y := y;
     end;
   end;
end;

function runPart1(var field : TField ) : word;
var steps : word;
    start : TPos;
    pos   : TPos;
    npos  : TPos;
    inital: array[1..4] of TPosTuple;
    i,j   : integer;
    options: TPosTuple;
begin
  findStart(field,start);
  pos:=start;
  north(pos,npos); getPositions(npos, field, inital[1]);
  south(pos,npos); getPositions(npos, field, inital[2]);
  west(pos, npos); getPositions(npos, field, inital[3]);
  east(pos, npos); getPositions(npos, field, inital[4]);

  i := 1;
  npos := NullPos;
  while pequal(npos, NullPos) do begin
    for j:= 1 to 2 do
      if pequal(inital[i][j], start) then
        case i of
            1:north(start,npos);
            2:south(start,npos);
            3:west(start,npos);
            4:east(start,npos);
        else runError(300);
        end;
    inc(i);
  end;

  steps := 1;
  while not pequal(npos, start) do begin
    inc(steps);
    if steps > 140*140 then runError(300);
    if (steps mod 500)=0 then write('.');
    getPositions(npos, field, options);

    if pequal(pos,options[1]) then begin
      pos := npos;
      npos:= options[2];
    end else begin
      pos := npos;
      npos := options[1];
    end;
  end;
  writeln;
  runPart1 := (steps+1) div 2;
end;

function getIntersections(polygon : PDeQueue; line : integer):PDeQueue;
var it, itn : PDeQueueIterator;
    result  : PDeQueue;
    p1, p2  : TPoint;
    pos     : TPos;
begin
  result := new(PDequeue,init);

  it := polygon^.first;
  itn:= it^.next;

  while itn <> NIL do begin
    p1 := PPolyPoint(it^.at)^.pos_;
    p2 := PPolyPoint(itn^.at)^.pos_;

    if (trunc(p1.x) = trunc(p2.x)) and  (* We can have only vertical intersections *)
       ((p1.y < line) and (p2.y > line)) or
       ((p1.y > line) and (p2.y < line)) then begin
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

function runPart2(var field : TField) : word;
var polygon         : PDeQueue;
    intersections   : PDeQueue;
    pos,npos,start  : TPos;
    inital          : array[1..4] of TPosTuple;
    directions      : array[1..3] of TPos;
    pushed          : array[1..3] of boolean;
    i,j, x1, x2     : integer;
    tmp             : char;
    count,steps     : word;
    options         : TPosTuple;
    it, itn         : PDequeueIterator;
begin
  (* Step 1 convert the bitmap into an polygon by tracing the path *)
  (* below is basically the same as part 1, but this time we trace *)
  (* path into a polygon. *)
  polygon := new(PDeQueue,init);
  findStart(field,start);
  pos:=start;
  north(pos,npos); getPositions(npos, field, inital[1]);
  south(pos,npos); getPositions(npos, field, inital[2]);
  west(pos, npos); getPositions(npos, field, inital[3]);
  east(pos, npos); getPositions(npos, field, inital[4]);

  i := 1;
  npos := NullPos;
  while pequal(npos, NullPos) do begin
    for j:= 1 to 2 do
      if pequal(inital[i][j], start) then
        case i of
            1:north(start,npos);
            2:south(start,npos);
            3:west(start,npos);
            4:east(start,npos);
        else runError(300);
        end;
    inc(i);
  end;

  steps := 1;
  while not pequal(npos, start) do begin
    inc(steps);
    if steps > 140*140 then runError(300);
    if (steps mod 500)=0 then write('.');
    getPositions(npos, field, options);

    tmp := getField(pos,field);
    if (tmp <> '|') and (tmp <> '-') then
      polygon^.pushBack(new(PPolyPoint,init(pos))); (* Create a point a the corners *)

    if pequal(pos,options[1]) then begin
      pos := npos;
      npos:= options[2];
    end else begin
      pos := npos;
      npos := options[1];
    end;
  end;
  polygon^.pushBack(new(PPolyPoint,init(start))); (* Duplicate the start, makes things easier *)
  writeln;

  (* Step 2 shoot rays for every scanline and see where the intersections are *)
  for i:= 0 to 139 do begin
    write(#13, 'Line: ',i,' ');
    intersections := getIntersections(polygon, i);
    write(intersections^.size,'      ');
    it := intersections^.first;
    if it = nil then continue;

    itn:= it^.next;

    while (it <> NIL) and (itn <> NIL) do begin
      x1 := trunc(PPolyPoint(it^.at)^.pos_.x) + 1;
      x2 := trunc(PPolyPoint(itn^.at)^.pos_.x) - 1;
      for j:= x1 to x2 do field[j,i] := '#';
      it := itn^.next;
      itn:= it^.next;
    end;

    intersections^.dispose;
  end;

  polygon^.dispose;

  count := 0;
  for i:=0 to 139 do
   for j:=0 to 139 do
     if (field[i,j] = '#') then inc(count);

  runPart2 := count;
end;


procedure loadField(var input: Text; var field: TField);
var x,y : byte;
    tmp : char;
begin
  for y:=0 to 139 do begin
   for x:=0 to 139 do read(input,field[x,y]);
   read(input,tmp); read(input,tmp);
  end;
end;

procedure showField(var field:TField);
var i,j : integer;
begin
  i:= Detect;
  initGraph(i,j,'c:\bp\bgi');

  for i:= 0 to 139 do
   for j:= 0 to 139 do
     if field[i,j] = '#' then putpixel(i,j,Green) else
     if field[i,j] = '*' then putpixel(i,j,Yellow) else
     putpixel(i,j,LightGray);

  readln;
  closeGraph;
end;


var field : TField;
    input : Text;
    result: word;
begin
  assign(input,InputFile);
  reset(input);
  loadField(input,field);
  close(input);
  result := runPart1(field);
  writeln('Part 1 Answer: ',result);
  result := runPart2(field);
  writeln('Part 2 Answer: ', result);
  readln;
  showField(field);
end.