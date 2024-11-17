(*
This is the solution for day 17
================================

  This day is a bit tricky, but can be solved by using the Dykstra Algorithm.
  We consider every step taken a node in a graph.
  Each node is connected to 9 other nodes (3 directions by 3 possible step
  sizes).

  We than run just the Dykstra and the requested answer will be generated.

  For the map data structure, we can reuse a lot from day16.

*)
program Day17;
uses crt,heap, ItemHandler;
const InputFile = 'INP/DAY17_IN.TXT';
type TDirection = (Up,Left,Right, Down);
     TOccupancy = set of TDirection;
     TPos = record
       x,y : byte;
     end;
     TMap = record
        xdim, ydim : byte;
        weight     : array[1..141, 1..141] of byte;
        occupancy  : array[1..141, 1..141] of TOccupancy;
     end;
     PStep = ^TStep;
     TStep = object(ItemType)
       pos_       : TPos;
       weight_     : longint;
       direction_ : TDirection;
       constructor init(const pos       : TPos;
                        const weight    : longint;
                        const direction : TDirection);
       function compare(other:PItemType):TRelation;virtual;
     end;

function advancePos(var position : TPos;
                    const xdim, ydim : byte;
                    const direction  : TDirection
                    ) : boolean;
var result : boolean;
begin
   case direction of
     Up:   begin
             result := position.y > 1;
             if result then dec(position.y);
           end;
     Down: begin
             result := position.y < ydim;
             if result then inc(position.y);
           end;
     Left: begin
             result := position.x > 1;
             if result then dec(position.x);
           end;
     Right:begin
             result := position.x < xdim;
             if result then inc(position.x);
           end;
   end;
 advancePos := result;
end;
function isEligableDirection(const src, dst : TDirection): boolean;
begin
  isEligableDirection :=
    ((src in [Up, Down]) and (dst in [Left, Right])) or
    ((src in [Left, Right]) and (dst in [Up, Down]));
end;

function findShortestPath(var map: TMap;
                          const minStep, maxStep :byte): longint;
const start : TPos = (x:1; y:1);
var   prio      : PMinHeap;
      goal      : TPos;
      step      : PStep;
      i         : integer;
      direction : TDirection;
      pos       : TPos;
      weight    : longint;
begin
  prio := new(PMinHeap, init);
  prio^.push(new(PStep,init(start,0,Right)));
  prio^.push(new(PStep,init(start,0,Down)));
  goal.x := map.xdim;
  goal.y := map.ydim;

  while prio^.size > 0 do begin
    step := PStep(prio^.pop);
    write(#$0d);
    write(step^.weight_,' ',prio^.size,'  ');
    if (step^.pos_.x = goal.x) and
       (step^.pos_.y = goal.y)
     then begin
      findShortestPath := step^.weight_;
      dispose(step,done);
      break;
    end;
    if not (step^.direction_ in map.occupancy[step^.pos_.x, step^.pos_.y]) then begin
      map.occupancy[step^.pos_.x, step^.pos_.y] :=
        map.occupancy[step^.pos_.x, step^.pos_.y] + [step^.direction_];
      for direction := Up to Down do begin
        pos    := step^.pos_;
        weight := step^.weight_;
        if isEligableDirection(step^.direction_, direction) then
          for i := 1 to maxStep do begin
            if advancePos(pos, map.xdim, map.ydim, direction) then begin
              inc(weight, map.weight[pos.x, pos.y]);
              if (i >= minStep) and
                 (not(direction in map.occupancy[pos.x, pos.y]))
              then begin
                prio^.push(new(PStep, init(pos, weight, direction)));
              end;
            end else break;
        end;
      end;
    end;
    dispose(step,done);
  end;
  dispose(prio,done);
end;

constructor TStep.init(const pos       : TPos;
                        const weight    : longint;
                        const direction : TDirection);
begin
  pos_       := pos;
  weight_    := weight;
  direction_ := direction;
end;

function TStep.compare(other:PItemType):TRelation;
var o : PStep;
begin
  o := PStep(other);
  if   self.weight_ > o^.weight_ then compare := Bigger
  else if self.weight_ < o^.weight_ then compare := Smaller
  else compare := Equal;
end;

procedure loadMap( var input : Text; var map : TMap);
var line : string;
       x : byte;
begin
 with map do begin
   ydim := 0;
   xdim := 0;
   while not eof(input) do begin
     readln(input, line);
     if xdim = 0 then xdim := length(line);
     if length(line) <> xdim then break;
     inc(ydim);
     for x:= 1 to xdim do begin
       weight[x,ydim] := ord(line[x]) - ord('0');
       occupancy[x,ydim] := [];
     end;
   end;
 end;
end;


var map : TMap;

function part1(var input : Text) : longint;
begin
  reset(input);
  loadMap(input, map);
  part1 := findShortestPath(map,1,3);
end;

var input : Text;
    p1    : longint;
begin
  assign(input, InputFile);
  p1 := part1(input);

  close(input);

  writeln('Part 1 Answer is: ',p1);
end.
