program day16;
(*This is the implementation of the aoc24 day 16*)

uses aoc, utils, heap, itemhandler, cassert, fastout, crt;
const InputFileName = 'INP\DAY16_IN.TXT';
      MaxMapSize    = 140;
type  TMap      = array[0..MaxMapSize,0..MaxMapSize] of char;
      TVisited  = array[0..MaxMapSize,0..MaxMapSize] of set of TDirection;

      PRendier = ^TRendier;
      TRendier = object(ItemType)
         pos_     : TPos;
         heading_ : TDirection;
         points_  : comp;
         constructor init(const pos: TPos;
                          const heading: TDirection;
                          const points : comp);
         function compare(other:PItemType):TRelation;virtual;

      end;

var   map_     : TMap;
      visitor_ : TVisited;
constructor TRendier.init(const pos: TPos;
                          const heading: TDirection;
                          const points : comp);
begin
  pos_     := pos;
  heading_ := heading;
  points_  := points;
end;

function TRendier.compare(other:PItemType):TRelation;
var otherRendier : PRendier;
begin
  otherRendier := PRendier(other);

  if otherRendier^.points_ < points_ then compare := Bigger else
  if otherRendier^.points_ > points_ then compare := Smaller else
  compare := Equal;
end;

function getLowestPoints(var map : TMap; const mapSize : TPos): comp;
function isFree(const map: TMap; const pos: TPos): boolean;
begin
  isFree := not (map[pos.x, pos.y] = '#');
end;

function getPoints(const i:integer): longint;
begin
  case i of
       1: getPoints := 1;
       2: getPoints := 1001;
       3: getPoints := 1001;
       else assert(false, 'Invalid point index');
  end;
end;

const minMap    : TPos = (x: 0; y: 0);
var result      : comp;
    position    : TPos;
    goal        : TPos;
    heap        : TMinHeap;
    rendier     : PRendier;
    heading     : TDirection;
    options     : byte;
    i           : integer;
    s,s2        : string;
begin
  result := 0;
  heap.init;
  fillchar(visitor_, sizeof(visitor_),0);

  findFirstInMap(map, 'S', mapSize, MaxMapSize+1, position);
  findFirstInMap(map, 'E', mapSize, MaxMapSize+1, goal);

  heap.push(new(PRendier, init(position, East,0)));
  writeln;
  while heap.size > 0 do begin
    str(heap.size,s);
    s:='Heap Size: ' + s +' ';

    rendier := PRendier(heap.pop);
    str(abs(rendier^.pos_.x - goal.x) +
        abs(rendier^.pos_.y - goal.y), s2);
    s := s + ' Distance Left: '+s2+'   ';
    fastWrite(0,1,LightGray,s);
    if rendier^.heading_ in visitor_[rendier^.pos_.x,rendier^.pos_.y] then begin
      dispose(rendier);
      continue;
    end;

    visitor_[rendier^.pos_.x, rendier^.pos_.y] :=
      visitor_[rendier^.pos_.x, rendier^.pos_.y] + [rendier^.heading_];

    if map[rendier^.pos_.x,rendier^.pos_.y]='E' then begin
      result := rendier^.points_;
      dispose(rendier);
      break;
    end;

    options := 0;
    for i:=1 to 3 do begin
      position := rendier^.pos_;
      if i = 1 then heading:= rendier^.heading_
      else heading:= nextDirection(rendier^.heading_, heading);

      if(advancePos(position, heading, minMap, mapSize)) then begin
        if isFree(map, position) then
         heap.push(new(PRendier,init(position, heading, rendier^.points_ + getPoints(i))));
      end;
    end;

    dispose(rendier);
  end;

  heap.done;
  getLowestPoints := result;
end;

function part1(var input: Text):comp; far;
var maxX, maxY : word;
    mapSize    : TPos;
begin
  maxX := MaxMapSize+1; (* first value behind the map *)
  maxY := MaxMapSize+1;

  loadCharMap(input, map_, maxX, maxY);

  mapSize.x := maxX - 1;
  mapSize.y := maxY - 1;

  part1 := getLowestPoints(map_,mapSize);
end;

function part2(var input: Text):comp; far;
begin
  part2 := 0;
end;

begin
  runAoc(InputFileName, 16, part1, part2, nil, nil);
end.
