program day21;
(* This is the implementation for day 21 of advent of code 2023 *)
uses crt,
     cassert,
     dequeue,
     progressbar,
     itemhandler,
     heap,
     utils,
     stdint;

const InputFileName= 'INP\DAY21_IN.TXT';
      MaxX = 130;
      MaxY = 130;
      Const MaxRange = MaxX + MaxY + 1;

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
      TRangeMap    = array[0..MaxRange] of word;

function adjustPosition(var pos: TPos;
                        const direction: TDirection): boolean;
var result : boolean;
begin
  result := true;
  case direction of
     West  : if pos.x_  > 0    then dec(pos.x_) else result := false;
     East  : if pos.x_  < MaxX then inc(pos.x_) else result := false;
     North : if pos.y_  > 0    then dec(pos.y_) else result := false;
     South : if pos.y_  < MaxY then inc(pos.y_) else result := false;
  end;
  adjustPosition := result;
end;

(* This function computes the number of steps needed to reach the tile from
   the center to the closest point of the given tile index
 *)
function computeSteps(const tileIndex : longint;
                      const     offset: word;
                      const   tileSize: word) : longint;
begin
  if abs(tileIndex) >= 1 then
    computeSteps := offset + (abs(tileIndex) - 1)*tileSize
  else
    computeSteps := 0;
end;

(* Compute the second axis based on the number of total number of steps
   and the index of the other axis.
   Again only as many steps as needed to reach the closest point are
   considered.
 *)
function computeMissingTileIndex( const otherIndex : longint;
                                  const totalSteps : longint;
                                  const offset     : word;
                                  const tileSize   : word
                                 ):longint;
var result : longint;
begin
  result := totalSteps - computeSteps(otherIndex, offset, tileSize);
  if result >= offset then begin
    result := result - offset;
    result := (result div tileSize) + 1
  end else
    result := 0;
  computeMissingTileIndex := result;
end;

procedure buildDistanceMap(const map       : TMap;
                           const start     : TPos;
                           const initalStep: word;
                           var   rangeMap  : TRangeMap);
var heap : TMinHeap;
      bl : PBacklog;
      tmp: TPos;
       d : TDirection;
       p : TProgressbar;
    dmap : PDistanceMap;
       i : word;
begin
  dmap := new(PDistanceMap);

  fillchar(dmap^,sizeof(TDistanceMap),$ff);
  fillchar(rangeMap, sizeof(TRangeMap),0);
  heap.init;
  heap.push(new(PBacklog,init(start,initalStep)));
  p.init(MaxX*MaxY,'crunch');
  while heap.size > 0 do begin
    bl := PBacklog(heap.pop);
    with bl^ do begin
      if dmap^[pos_.x_,pos_.y_] = $ffff then begin
        p.step(1);
        dmap^[pos_.x_, pos_.y_] := dist_;
        assert(dist_ <= MaxRange,'Range out of bounds');
        inc(rangeMap[dist_]);
        for d:= North to East do begin
            tmp := pos_;
            if adjustPosition(tmp,d) then begin
               if (not (tmp.x_ in map[tmp.y_])) and
                  (dmap^[tmp.x_, tmp.y_] = $ffff) then
                    heap.push(new(PBacklog,init(tmp,dist_+1)));
            end;
        end;
      end;
    end;
    dispose(bl,done);
  end;
  p.done;
  heap.done;
  dispose(dmap);

  (* Propagate through *)
  for i:= 2 to MaxRange do
    inc(rangeMap[i],rangeMap[i-2]);

end;

function countPods(const dmap     : TDistanceMap;
                   const threshold: word;
                   const parity   : TParity;
                   var   maxSteps : word) : word;
var result : word;
    x,y    : byte;
begin
  result := 0;
  maxSteps := dmap[0,0];
  for x:=0 to MaxX do
    for y:=0 to MaxY do begin
      if (dmap[x,y] < $ffff) and
         (dmap[x,y] <= threshold) and
         (isParity(dmap[x,y], parity)) then inc(result);
      if  (dmap[x,y] <> $ffff) and
          (maxSteps < dmap[x,y]) then maxSteps := dmap[x,y];
    end;
  countPods := result;
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
    dmap : TRangeMap;
    start: TPos;
    tmp  : word;
begin
  loadMap(input, map, start);
  writeln('Build distance map...');
  buildDistanceMap(map, start, 0, dmap);
  part1  := dmap[64];
end;

function part2(var input: Text): comp;
const positions : array[0..8] of TPos =
      ((x_ : (MaxX div 2);   y_ : (MaxY div 2)),
       (x_ : 0;              y_ : 0),
       (x_ : 0;              y_ : (MaxY div 2)),
       (x_ : 0;              y_ : MaxX),
       (x_ : (MaxX div 2);   y_ : MaxX),
       (x_ : MaxX;           y_ : MaxX),
       (x_ : MaxX;           y_ : (MaxY div 2)),
       (x_ : MaxX;           y_ : 0),
       (x_ : (MaxX div 2);   y_ : 0)
      );

var map  : TMap;
    dmaps: array[0..8] of TRangeMap;

  procedure generateDMaps;
  var start: TPos;
      p    : TProgressBar;
      i    : byte;
      cache: File of TRangeMap;
      build:boolean;
  begin
    loadMap(input, map, start);
    assert(start.x_ = positions[0].x_,'Invalid X-Start position');
    assert(start.y_ = positions[0].y_,'Invalid Y-Start position');
    writeln('Build distance maps ...');
    p.init(9,'dmaps ');

    assign(cache, 'day21.tmp');
    {$I-}
    reset(cache);
    build := ioresult <> 0;
    {$I+}
    if build then begin
      rewrite(cache);
      for i:=0 to 8 do begin
          buildDistanceMap(map, positions[i], 0, dmaps[i]);
          write(cache, dmaps[i]);
          p.step(1);
      end;
    end else begin
      for i:=0 to 8 do begin
        read(cache, dmaps[i]);
        p.step(1);
      end;
    end;
    close(cache);
    p.done;
  end;

  function getPosForTileIndex(tileX, tileY: longint): byte;
  begin
    if tileY = 0 then begin
      if tileX = 0 then getPosForTileIndex := 0 else
      if tileX > 0 then getPosForTileIndex := 2
      else getPosForTileIndex := 6;
    end else if tileY > 0 then begin
      if tileX = 0 then getPosForTileIndex := 8 else
      if tileX > 0 then getPosForTileIndex := 1
      else getPosForTileIndex := 7;
    end else begin
      if tileX = 0 then getPosForTileIndex := 4 else
      if tileX > 0 then getPosForTileIndex := 3
      else getPosForTileIndex := 5;
    end;
  end;

  function computeTotalSteps(const totalSteps: longint): comp;
  var   tileY           : longint;
        endY            : longint;
        startX          : longint;
        offset, tileSize: longint;
        numTilesX       : longint;
        remainSteps     : longint;
        remainYSteps    : longint;
        remainXSteps    : longint;
        result,line,tmp, tmp2 : Uint64_t;
        initalParity    : TParity;
        parity          : TParity;
        parityX         : TParity;
        pos             : byte;
        foo             : word;
        p               : TProgressBar;
  begin
  result  := zero64;

  (* Here goes some assumptions about the layout of the input.

     The input is a cross arround the center.
     This means that north, south, west, east have all the same distance.
     And also traveling along this cross axis makes it easy to reach the
     other tiles.

     The issue is that the sample data provided does not have this property
     which makes debugging a pain in the ass.
   *)
  offset  := (MaxX div 2) + 1;
  tileSize:= MaxX+1;

  endY := computeMissingTileIndex(0,totalSteps, offset, tileSize);
  initalParity := getParity(totalSteps);

  p.init(2*endY+1,'calc...');

  for tileY := -endY to endY do begin

    if getParity(tileY) = Odd then
      parity := reverseParity(initalParity)
    else
     parity  := initalParity;

    line   := Zero64;
    startX := computeMissingTileIndex(tileY, totalSteps, offset, tileSize);
    numTilesX := startX + 1;
    remainSteps := totalSteps -
                     computeSteps(startX, offset, tileSize) -
                     computeSteps(tileY, offset, tileSize);
    remainYSteps:= totalSteps -
                     computeSteps(tileY, offset, tileSize);
    if startX > 1 then
      remainXSteps := totalSteps -
                        computeSteps(startX - 1, offset, tileSize) -
                        computeSteps(tileY, offset, tileSize)
    else
      remainXSteps := 0;
    if remainXSteps > MaxRange then
      if getParity(remainXSteps) = Odd then remainXSteps := MaxRange
      else remainXSteps := MaxRange - 1;

    parityX := getParity(remainSteps);

    (* +------ End  Tile    *)
    (* | +---- Even Tile    *)
    (* | |+--- Odd Tile     *)
    (* V VV    VCenter Tile *)
    (* |#+#+#+#-#+#+#+#|    *)
    if numTilesX >= 1 then begin
       pos := getPosForTileIndex(0, tileY);
       dec(numTilesX);
       if ( remainYSteps > HIGH(dmaps[pos])) then
         if getParity(remainYSteps) = Odd then
            add64LongInt(line, dmaps[pos][MaxRange])
         else
            add64LongInt(line, dmaps[pos][MaxRange-1])
       else
         add64LongInt(line,  dmaps[pos][remainYSteps])
    end;

    if (numTilesX >= 1) and (startX > 0) then begin
      (* First we have two ends *)
      pos := getPosForTileIndex(startX, tileY);
      add64LongInt(line, dmaps[pos][remainSteps]);


      pos := getPosForTileIndex(-startX, tileY);
      add64LongInt(line, dmaps[pos][remainSteps]);

      (* The edges may bleed into one tile further down the road *)
      if remainXSteps > 0 then begin
        pos := getPosForTileIndex(startX, tileY);
        add64LongInt(line, dmaps[pos][remainXSteps]);

        pos := getPosForTileIndex(-startX, tileY);
        add64LongInt(line, dmaps[pos][remainXSteps]);
      end;

      if startX > 2 then begin
      (* The end cap handled above, now the parts on the line *)
        pos := getPosForTileIndex(startX, tileY);

        if parity = Even then begin
          fromLongInt64(dmaps[pos][MaxRange - 1],tmp);
          fromLongInt64(dmaps[pos][MaxRange], tmp2);
        end else begin
          fromLongInt64(dmaps[pos][MaxRange],tmp);
          fromLongInt64(dmaps[pos][MaxRange - 1], tmp2);
        end;

        mul64LongInt(tmp, (startX - 1)  div 2);
        mul64LongInt(tmp2, (startX - 1 + 1) div 2);

        add64(tmp, tmp2);
        shiftLeft64(1,tmp);
        add64(line, tmp);
      end;
    end;

    add64(result, line); (* Add the line to the result *)
    p.step(1);
  end;
  p.done;

  computeTotalSteps := uint64ToComp(result);
end;
const n        : comp = 202300;
var p0, p1, p2 : comp;
     a,  b, c  : comp;
begin
  generateDMaps;
  p0 := computeTotalSteps(65);
  p1 := computeTotalSteps(196);
  p2 := computeTotalSteps(327);
  a  := (p2 - 2*p1 + p0) / 2;
  b  := (p1 - p0 - a);
  c  := p0;

  part2 := a*(n*n) + b*n + c;
end;

var input : Text;
       p1 : longint;
       p2 : comp;
begin
  clrscr;
  assign(input, InputFileName);
  reset(input);

  p1 := part1(input);
  writeln('Answer to Part1 is: ', p1);
  reset(input);

  p2 := part2(input);
  writeln('Answer to Part2 is: ',p2:1:0);

  close(input);
end.
