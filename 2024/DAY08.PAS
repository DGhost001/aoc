program day08;
(*This is the implementation of the aoc24 day 8*)

uses aoc,utils, dequeue, ItemHandler, cassert;
const InputFileName = 'INP\DAY08_IN.TXT';
      LowerPos : TPos = (x: 0; y: 0);
type HarmonicType = (Positiv, Negative);
     PAntenna = ^TAntenna;
     TAntenna = object(ItemType)
        pos_ : TPos;

        constructor init(const pos : TPos);
        procedure resonance(const other: PAntenna; var result : array of TPos);
        procedure harmonics(const other: PAntenna;
                           const htype : HarmonicType;
                           var result : array of TPos);
     end;

     TAntenaList   = array[0..127] of PDeQueue;
     TOccupancyMap = array[0..49] of set of 0..49;
     TCharMap      = array[0..49, 0..49] of char;

constructor TAntenna.init(const pos : TPos);
begin
  pos_ := pos;
end;

procedure   TAntenna.resonance(const other: PAntenna; var result : array of TPos);
var delta : TPos;
begin
  deltaPos(pos_, other^.pos_, delta);

  result[0] := pos_;
  result[1] := other^.pos_;

  subPos(result[0], delta);
  addPos(result[1], delta);
end;

procedure TAntenna.harmonics(const other: PAntenna;
                            const htype : HarmonicType;
                            var result : array of TPos);
var delta : TPos;
    i     : integer;
    count : word;
begin
  deltaPos(pos_, other^.pos_, delta);
  if htype = Positiv then result[0] := other^.pos_ else result[0] := pos_;
  result[1] := result[0];
  for i:=1 to HIGH(result) do begin
    if htype = Positiv then
      addPos(result[i],delta)
    else
      subPos(result[i],delta);
    if i < HIGH(result)  then result[i+1] := result[i];
  end;
end;

procedure cleanup(var ant : TAntenaList);
var i : integer;
begin
  for i := 0 to HIGH(ant) do begin
    if ant[i] <> NIL then begin
      ant[i]^.dispose;
      ant[i] := NIL;
    end;
  end;
end;

procedure loadAntennaPos(var input : Text;
                         var ant   : TAntenaList;
                         var maxPos: TPos);
var map    : TCharMap;
    mx, my : word;
    afreq  : byte;
    pos    : TPos;
    i      : integer;
begin
  mx := 50;
  my := 50;
  loadCharMap(input, map, mx, my);
  maxPos.x := mx - 1;
  maxPos.y := my - 1;

  for i := 0 to HIGH(ant) do
   ant[i] := new(PDeQueue,init);

  for pos.x := 0 to maxPos.x do
   for pos.y := 0 to maxPos.y do
    if map[pos.x,pos.y] in ['a'..'z','A'..'Z','0'..'9'] then begin
      afreq := ord(map[pos.x,pos.y]) - ord(' ');
      assert(afreq <= HIGH(ant),'Frequency out of range');
      ant[afreq]^.pushBack(new(PAntenna,init(pos)));
    end;
end;

function countResonances(it   : PDeQueueIterator;
                         var occ  : TOccupancyMap;
                         const max: TPos): word;
var count : word;
    it2   : PDeQueueIterator;
    reso  : array [0..1] of TPos;
    a1    : PAntenna;
    i     : integer;
begin
  count := 0;
  while it <> nil do begin
   it2:= it^.next;
   a1 := PAntenna(it^.at);
   while it2 <> nil do begin
     a1^.resonance(PAntenna(it2^.at),reso);

     for i:= 0 to HIGH(reso) do
       if inArea(reso[i], LowerPos, max) and
          (not (reso[i].x in occ[reso[i].y])) then begin

         inc(count);
         occ[reso[i].y] := occ[reso[i].y] + [reso[i].x];
       end;
     it2:=it2^.next;
   end;
   it := it^.next;
  end;
  countResonances:= count;
end;

function countHarmonics(it   : PDeQueueIterator;
                         var occ  : TOccupancyMap;
                         const max: TPos): word;
var count : word;
    it2   : PDeQueueIterator;
    harmo : array [0..63] of TPos;
    a1    : PAntenna;
    i     : integer;
    htype : HarmonicType;
begin
  count := 0;
  while it <> nil do begin
   it2:= it^.next;
   a1 := PAntenna(it^.at);
   while it2 <> nil do begin
     for htype := Positiv to Negative do begin
       a1^.harmonics(PAntenna(it2^.at),htype, harmo);
       assert(not inArea(harmo[HIGH(harmo)],LowerPos,max), 'Harmonic longer than expected');

       for i:= 0 to HIGH(harmo) do
         if inArea(harmo[i], LowerPos, max) and
            (not (harmo[i].x in occ[harmo[i].y])) then begin

           inc(count);
           occ[harmo[i].y] := occ[harmo[i].y] + [harmo[i].x];
       end;
     end;
     it2:=it2^.next;
   end;
   it := it^.next;
  end;
  countHarmonics:= count;
end;

function part1(var input: Text):comp; far;
var antList : TAntenaList;
    max     : TPos;
    occ     : TOccupancyMap;
    freq    : integer;
    count   : word;
begin
  count := 0;
  fillchar(occ,sizeof(occ),0);
  loadAntennaPos(input, antList, max);

  for freq := 0 to HIGH(antList) do begin
    count := count + countResonances(antList[freq]^.first ,occ,max);
  end;

  cleanup(antList);
  part1 := count;
end;

function part2(var input: Text):comp; far;
var antList : TAntenaList;
    max     : TPos;
    occ     : TOccupancyMap;
    freq    : integer;
    count   : word;
begin
  count := 0;
  fillchar(occ,sizeof(occ),0);
  loadAntennaPos(input, antList, max);

  for freq := 0 to HIGH(antList) do begin
    count := count + countHarmonics(antList[freq]^.first ,occ,max);
  end;

  cleanup(antList);
  part2 := count;
end;

begin
  runAoc(InputFileName, 8, part1, part2, nil, nil);
end.
