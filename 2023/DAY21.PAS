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

(* This function computes the number of steps needed to reach the tile from
   the center to the closest point of the given tile index
 *)
function computeSteps(const tileIndex : longint;
                      const     offset: word;
                      const   tileSize: word) : longint;
begin
  if tileIndex >= 1 then
    computeSteps := offset + (tileIndex - 1)*tileSize
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
                           var   dmap      : TDistanceMap);
var heap : TMinHeap;
      bl : PBacklog;
      tmp: TPos;
        d: TDirection;
        p: TProgressbar;
begin
  fillchar(dmap,sizeof(dmap),0);
  heap.init;
  heap.push(new(PBacklog,init(start,initalStep)));
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
      if (dmap[x,y] > 0) and
         (dmap[x,y] <= threshold) and
         (isParity(dmap[x,y], parity)) then inc(result);
      if maxSteps < dmap[x,y] then maxSteps := dmap[x,y];
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
    dmap : PDistancemap;
    start: TPos;
    tmp  : word;
begin
  loadMap(input, map, start);
  dmap := new(PDistancemap);
  writeln('Build distance map...');
  buildDistanceMap(map, start, 0, dmap^);
  part1  := countPods(dmap^, 64, getParity(64), tmp);
  dispose(dmap);
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
    dmaps: array[0..8] of record
        dmap     : PDistancemap; (* Computed distance map from that point *)
        count    : array [Odd..Even] of Word;
        max      : word;
    end;

  procedure generateDMaps;
  var start: TPos;
      p    : TProgressBar;
      i    : byte;
      cache: File of TDistanceMap;
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
    if build then rewrite(cache);
    for i:=0 to 8 do with dmaps[i] do begin
      dmap := new(PDistancemap);
      if build then begin
        if i = 0 then
          buildDistanceMap(map, positions[i], 0, dmap^)
        else
          buildDistanceMap(map, positions[i], 1, dmap^);
      end else read(cache, dmap^);
      count[Odd]  := countPods(dmap^,65535,Odd, max);
      count[Even] := countPods(dmap^,65535,Even, max);
      writeln('Position: ',i,' Odd:',count[Odd],' Even:', count[Even], ' Max:',max);
      if build then write(cache, dmap^);
      p.step(1);
    end;
    close(cache);
    p.done;
  end;

  function getPosForTileIndex(tileX, tileY: longint): byte;
  begin
    if (tileX = 0) and (tileY = 0) then getPosForTileIndex := 0 else
    if (tileX = 0) then getPosForTileIndex := 4 else
    getPosForTileIndex := 3;
  end;

  const totalSteps      : longint =  196(* 26501365 *);
  var   tileY           : longint;
        endY            : longint;
        startX          : longint;
        offset, tileSize: longint;
        numTilesX       : longint;
        remainSteps     : longint;
        remainYSteps    : longint;
        result,line,tmp, tmp2 : Uint64_t;
        initalParity    : TParity;
        parity          : TParity;
        parityX         : TParity;
        pos             : byte;
        foo             : word;
        p               : TProgressBar;
        cache           : record
           pos          : byte;
           remain       : longint;
           count        : array[Odd..Even] of word;
        end;
  begin
  generateDMaps;
  result  := zero64;
  cache.remain := -1;

  (* Here goes some assumptions about the layout of the input.

     The input is a cross arround the center.
     This means that north, south, west, east have all the same distance.
     And also traveling along this cross axis makes it easy to reach the
     other tiles.

     The issue is that the sample data provided does not have this property
     which makes debugging a pain in the ass.
   *)
  offset  := dmaps[0].dmap^[positions[8].x_, positions[8].y_] + 1; (*+1 because the start was 0 here *)
  tileSize:= dmaps[4].dmap^[positions[8].x_, positions[8].y_];

  endY := computeMissingTileIndex(0,totalSteps, offset, tileSize);
  initalParity := getParity(totalSteps);

  p.init(endY+1,'calc...');

  for tileY := 0 to endY do begin

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

    if getParity(startX) = Odd then
      parityX := reverseParity(parity)
    else
      parityX := parity;

    (* +------ End  Tile    *)
    (* | +---- Even Tile    *)
    (* | |+--- Odd Tile     *)
    (* V VV    VCenter Tile *)
    (* |#+#+#+#-#+#+#+#|    *)
    if numTilesX >= 1 then begin
       pos := getPosForTileIndex(0, tileY);
       dec(numTilesX);
       if ( remainYSteps > dmaps[pos].max ) then
         add64LongInt(line, dmaps[pos].count[parity])
       else
         add64LongInt(line, countPods(dmaps[pos].dmap^, remainYSteps, getParity(remainSteps), foo))
    end;

    if numTilesX >= 1 then
      pos := getPosForTileIndex(startX, tileY);
      with dmaps[pos] do begin
        if (cache.remain <> remainSteps) or (cache.pos <> pos) then begin
          cache.pos    := pos;
          cache.remain := remainSteps;
          cache.count[Odd] := countPods(dmap^, remainSteps, Odd, foo);
          cache.count[Even]:= countPods(dmap^, remainSteps, Even, foo);
        end;

        (* First we have two ends *)
        add64LongInt(line, 2*cache.count[parityX]);

        (* The end cap handled above, now the parts on the line *)
        fromLongInt64(count[parity],tmp);
        mul64LongInt(tmp, (startX - 1)  div 2);
        fromLongInt64(count[reverseParity(parity)], tmp2);
        mul64LongInt(tmp2, (startX - 1 + 1) div 2);
        add64(tmp, tmp2);
        shiftLeft64(1,tmp2);
        add64(line, tmp);
    end;

    if tileY <> 0 then
      shiftLeft64(1,line); (*Mirror to bottom halfe*)

    add64(result, line); (* Add the line to the result *)
    p.step(1);
  end;
  p.done;

  part2 := uint64ToComp(result);
end;

var input : Text;
       p1 : longint;
       p2 : comp;
begin
  clrscr;
  assign(input, InputFileName);
  reset(input);
  (*
  p1 := part1(input);
  writeln('Answert part1 is: ', p1);
  *)
  p2 := part2(input);
  writeln('Answer to Part2 is: ',p2:1:0);
  close(input);
end.
