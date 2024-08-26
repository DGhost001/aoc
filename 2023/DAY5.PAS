program day5;

uses crt, stdint, jstring, itemhandler, dequeue, utils;

type PRange = ^TRange;
     TRange = object(ItemType)
        start_ : Uint64_t;
        range_ : Uint64_t;

        constructor init(var start, range: Uint64_t);
        constructor copy(other : PRange);

        destructor done; virtual;
        procedure dispose;

        function left(other: PRange): PRange;
        function right(other: PRange): PRange;

        function inRange(var a: Uint64_t):boolean;

        function intersect(other: PRange; var inside : PRange): boolean;
        procedure stop(var a: Uint64_t);

     end;

     PMapping = ^TMapping;
     TMapping = object(ItemType)
        range_       : TRange;
        destination_ : Uint64_t;

        constructor init(var source, destination, range : Uint64_t);
        destructor done; virtual;

        function mapValues(var a: Uint64_t): boolean;
        function mapRange(input: PRange; var left, center, right: PRange): boolean;
        procedure dispose;
     end;

     PMap = ^TMap;
     TMap = object(ItemType)
       mapper_ : PDeQueue;

       constructor init;
       destructor done; virtual;

       procedure dispose;

       procedure addMapping(mapping : PMapping);
       procedure mapValue(var a: Uint64_t);
       procedure mapRange(input: PDeQueueIterator; mapping: PDeQueue);
     end;

const InputFileName = 'DAY5_INP.TXT'(* 'DAY5_INP.TXT' *);

constructor TMapping.init;
begin
  range_.init(source, range);
  destination_ := destination;
end;

destructor TMapping.done;
begin
 (* Intentionally empty *)
end;

function TMapping.mapValues;
var stop: Uint64_t;
begin
  if range_.inRange(a) then begin
    add64(a, destination_); (* We add first so we don't get negative *)
    sub64(a, range_.start_);
    mapValues := true;
  end else
   mapValues := false;
end;

procedure TMapping.dispose;
begin
  SYSTEM.dispose(PMapping(@self),done);
end;

function TMapping.mapRange(input: PRange; var left, center, right: PRange): boolean;
begin
  if range_.intersect(input, center) then begin
    left := input^.left(center);
    right:= input^.right(center);
    mapValues(center^.start_); (*Perform the actual value transformation *)
  end else begin
    left   := NIL;
    right  := NIL;
    center := NIL;
  end;
  mapRange := center <> NIL;
end;

constructor TMap.init;
begin
  mapper_ := new(PDeQueue, init);
end;

destructor TMap.done;
begin
  mapper_^.dispose;
end;

procedure TMap.dispose;
begin
  SYSTEM.dispose(PMap(@self),done);
end;

procedure TMap.addMapping;
begin
  mapper_^.pushBack(mapping);
end;

procedure TMap.mapValue;
var it : PDeQueueIterator;
begin
  it := mapper_^.first;

  while (it <> NIL) and (not PMapping(it^.at)^.mapValues(a)) do it := it^.next;
end;

procedure TMap.mapRange(input: PDeQueueIterator; mapping: PDeQueue);
var backlog             : PDeQueue;
    it                  : PDeQueueIterator;
    left, right, center : PRange;

begin
  backlog := new(PDeQueue, init);
  while input <> NIL do begin
    it := mapper_^.first;
    while (it <> NIL) and (not PMapping(it^.at)^.mapRange(PRange(input^.at),left, center, right)) do
      it:= it^.next;

    if center <> NIL then begin
        mapping^.pushBack(center);
        if left   <> NIL then backlog^.pushBack(left);
        if right  <> NIL then backlog^.pushBack(right);
    end else (* Unmapped ranges get forwarded as is *)
      mapping^.pushBack(new(PRange, copy(PRange(input^.at))));
    input := input^.next;
  end;
  (* In case we have a backlog we need to process that too *)
  if backlog^.size > 0 then
    mapRange(backlog^.first, mapping);
  backlog^.dispose;
end;

constructor TRange.init;
begin
  start_ := start;
  range_ := range;
end;

constructor TRange.copy(other : PRange);
begin
  start_ := other^.start_;
  range_ := other^.range_;
end;

destructor TRange.done;
begin
end;

procedure TRange.dispose;
begin
  SYSTEM.dispose(PRange(@self),done);
end;

procedure TRange.stop(var a: Uint64_t);
begin
  a:= start_;
  add64(a, range_);
  sub64(a, one64 );
end;

function TRange.inRange(var a: Uint64_t):boolean;
var _stop : Uint64_t;
begin
  self.stop(_stop);
  inRange := (not isLess64(a,start_)) and (not isGreater64(a, _stop));
end;

function TRange.intersect(other: PRange; var inside : PRange): boolean;
var stopSelf     : Uint64_t;
    stopOther    : Uint64_t;
    istart, iend : Uint64_t;
begin
  stop(stopSelf);
  other^.stop(stopOther);

  if isGreater64(other^.start_, stopSelf) or
     isGreater64(self.start_, stopOther) then inside:= NIL
  else begin
    max64(self.start_, other^.start_, istart);
    min64(stopSelf, stopOther, iend);

    sub64(iend, istart);
    add64(iend, one64);

    inside := new(PRange, init(istart, iend));
  end;
  intersect := inside <> NIL;
end;

function TRange.left(other: PRange): PRange;
var result   : PRange;
    distance : Uint64_t;
    newRange : Uint64_t;
begin
  result := NIL;


  if isLess64(start_, other^.start_) then begin
    distance := other^.start_;
    sub64(distance, start_);
    min64(range_, distance, newRange);
    result := new(PRange, init(start_, newRange));
  end;

  left := result;
end;

function TRange.right(other: PRange): PRange;
var result : PRange;
    stopSelf : Uint64_t;
    stopOther: Uint64_t;
begin
  result := NIL;
  self.stop(stopSelf);
  other^.stop(stopOther);

  if isGreater64(stopSelf, stopOther) then begin
    sub64(stopSelf, stopOther);
    add64(stopSelf, one64);
    add64(stopOther, one64);
    result := new(PRange, init(stopOther, stopSelf));
  end;

  right  := result;
end;

procedure mapValue(var a: Uint64_t; mappings : PDeQueue);
var it : PDeQueueIterator;
begin
  it := mappings^.first;
  while it <> NIL do begin
    PMap(it^.at)^.mapValue(a);
    it:= it^.next;
  end;
end;

procedure mapRange(range: PRange; result : PDeQueue; mappings : PDeQueue);
var it : PDeQueueIterator;
    input: PDeQueue;
    output: PDeQueue;
begin
  it := mappings^.first;
  input := new(PDeQueue, init);
  input^.pushBack(new(PRange, copy(range)));
  while it <> NIL do begin
    output := new(PDeQueue, init);

    PMap(it^.at)^.mapRange(input^.first, output);

    input^.dispose;
    input:=output;

    it:= it^.next;
  end;

  it := output^.first;
  while it <> NIL do begin
    result^.pushBack(new(PRange,copy(PRange(it^.at))));
    it := it^.next;
  end;
  output^.dispose;
end;

function parseSeeds(var input: Text; var seeds : array of Uint64_t) : word;
var tmp  : PJstring;
    items: PDeQueue;
    it   : PDeQueueIterator;
    count: word;
begin
  tmp := ReadLine(input);
  items := tmp^.split(' ');
  count := 0;

  if (items^.size >=2) and (items^.size -1 < HIGH(seeds)) then begin
    it := items^.first;
    it := it^.next;
    count:=parseUintArray(it,seeds);
  end;

  items^.dispose;
  tmp^.dispose;
  parseSeeds := count;
end;

function parseMap(var input: Text):PMap;
var result : PMap;
    tmp    : PJString;
    items  : PDeQueue;
    it     : PDeQueueIterator;
    map    : array[0..2] of Uint64_t;
begin
  result := new(PMap,init);

  items := NIL;

  repeat
    tmp := ReadLine(input);
    if items <> NIL then items^.dispose;
    items := tmp^.split(' ');
    if items^.size = 3 then begin
      it := items^.first;
      if parseUintArray(it,map) <> 3 then begin writeln('Invalid input'); halt(1); end;
      result^.addMapping(new(PMapping, init(map[1], map[0], map[2]))); (*Mapping is  dest, src, range *)
    end else if items^.size = 2 then
      write('Loading ',tmp^.toString);
    tmp^.dispose;
  until items^.size < 2;
  items^.dispose;

  parseMap := result;
end;

var input: Text;
    seeds: array[0..255] of Uint64_t;
    count: word;
    i    : word;
    num,tmp  : Uint64_t;

    mapping: PDeQueue;
    range  : PRange;
    result : PDeQueue;

    it     : PDeQueueIterator;
begin
  clrscr;
  mapping := new(PDeQueue, init);
  assign(input, InputFileName);
  reset(input);

  count := parseSeeds(input,seeds);
  readln(input);

  while not eof(input) do begin
    mapping^.pushBack(parseMap(input));
  end;

  close(input);

  num:= zero64;
  sub64(num,one64);

  for i:=0 to count-1 do begin
    tmp := seeds[i];
    mapValue(tmp,mapping);
    if isLess64(tmp,num) then
      num:= tmp;
  end;

  writeln('The smallest part1 location is: ',Uint64ToStr(num));

  i:=0;
  result := new(PDeQueue,init);


  write('Mapping: ');
  while i < count-1 do begin
    write('.');
    range := new(PRange,init(seeds[i],seeds[i+1]));
    mapRange(range, result, mapping);
    range^.dispose;
    inc(i,2);
  end;
  writeln;
  writeln('Number of ranges: ',result^.size);

  num:= zero64;
  sub64(num,one64);
  it:=result^.first;
  while it <> NIL do begin
    tmp := PRange(it^.at)^.start_;

    if isLess64(tmp,num) then
      num:= tmp;
    it:=it^.next;
  end;

  writeln('The smallest part2 location is: ',Uint64ToStr(num));

  mapping^.dispose;
  result^.dispose;
end.
