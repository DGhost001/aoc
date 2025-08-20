unit utils;
interface

uses DeQueue,JString,stdint,cassert,itemhandler;

type
    TParity = (Odd, Even);
    PPos    = ^OPos;
    TPos    = record
           x, y : longint;
    end;

    OPos = object(ItemType)
           pos_ : TPos;
           constructor init(const pos : TPos);
           constructor initxy(const x,y : longint);
    end;

    TDirection = (North, East, West, South);
    TDirection8= (NO, NE, NW, ES, WE, SE, SW, SO);

const Movement : array[TDirection] of TPos =
      ((x: 0; y : -1), (x: 1; y : 0), (x: -1; y : 0), (x: 0; y: 1));
      Movement8: array[TDirection8] of TPos =
      ((x: 0; y : -1), (x: 1; y : -1), (x: -1; y: -1),
                       (x: 1; y :  0), (x: -1; y:  0),
       (x: 1; y :  1), (x: -1; y : 1), (x:  0; y:  1));

function parseUintArray(it : PDeQueueIterator; var numbers: array of Uint64_t) : word;
function countLines(var input : Text): longint;

function getParity(const a: longint) : TParity;
function isParity(const a: longint; const p: TParity):boolean;
function reverseParity(const a: TParity) : TParity;

function readInteger(var input: Text) : integer;
function readLong(var input: Text) : longint;
function readComp(var input: Text) : comp;
procedure readPos(var input: Text; var pos: TPos);

function readLongArray(var input : Text; var values : array of longint) : word;
function readUint64Array(var input : Text; var values: array of uint64_t) : word;

procedure loadCharMap(var input: Text; var map; var maxX, maxY : word);
procedure findFirstInMap(var map; const what: char; const max : TPos; const xDim : word; var pos: TPos);
function  countInMap(var map; const what: char; const max: TPos; const xDim : word) : word;

function advancePos (var pos: TPos; const dir : TDirection; const min, max: TPos): boolean;
function advancePos8(var pos: TPos; const dir : TDirection8; const min, max: TPos): boolean;
function posEqual(const p1, p2 : TPos): boolean;
procedure addPos(var pos : TPos; const delta: TPos);
procedure subPos(var pos : TPos; const delta: TPos);
procedure deltaPos(const p1, p2 : TPos; var delta : TPos);
procedure scalePos(const scale : longint; var p : TPos);

function nextDirection(const origin : TDirection; dir : TDirection): TDirection;
function reverseDirection(const dir: TDirection): TDirection;

function dmax(const d1, d2: double): double;
function dmin(const d1, d2: double): double;

function inRange(const value, lower, upper : longint) : boolean;
function inArea(const point, lower, upper : TPos) : boolean;

implementation

constructor OPos.init(const pos : TPos);
begin
  pos_ := pos;
end;

constructor OPos.initxy(const x,y : longint);
begin
  pos_.x := x;
  pos_.y := y;
end;


function parseUintArray(it : PDeQueueIterator; var numbers: array of Uint64_t) : word;
var count : word;
begin
  count := 0;
  while (it <> NIL) and (count <= HIGH(numbers)) do begin
    strToUint64(PJstring(it^.at)^.toString,numbers[count]);
    inc(count);
    it := it^.next;
  end;

  parseUintArray := count;
end;

function countLines(var input : Text): longint;
var count : longint;
begin
  count := 0;
  while not eof(input) do begin
    readln(input);
    inc(count);
  end;
  countLines := count;
  reset(input);
end;

function getParity(const a: longint) : TParity;
begin
  if (abs(a) mod 2) = 0 then getParity := Even else getParity:= Odd;
end;

function isParity(const a: longint; const p: TParity): boolean;
begin
  isParity := getParity(a) = p;
end;

function reverseParity(const a : TParity): TParity;
begin
  if a = Odd then
    reverseParity := Even
  else
    reverseParity := Odd;
end;

function readNumber(var input: Text; var eol :boolean) : string;
var s : string;
begin
  s[0] := #0;
  read(input, s[ord(s[0])+1]);
  eol:= false;
  while (s[ord(s[0])+1] in [' ','+','-',#13,#10,#9,'0'..'9']) do begin
    if s[ord(s[0])+1] in ['0'..'9'] then inc(s[0]) else
    if (ord(s[0]) = 0) and (s[ord(s[0])+1] in ['+','-']) then inc(s[0])
    else if (ord(s[0]) > 0) and (s[ord(s[0])+1] in ['+','-',' ',#13,#10,#9]) then
    begin
      eol := (s[ord(s[0])+1] in [#13,#10]);
      break;
    end;
   if eof(input) then begin
    eol := true;
    break;
   end;
   read(input, s[ord(s[0])+1]);
  end;
  readNumber := s;
end;


function readInteger(var input: Text) : integer;
var s    : string;
   code  : integer;
   result: integer;
   eol   : boolean;
begin
  s := readNumber(input,eol);
  val(s, result, code);
  readInteger := result;
  assert(code = 0, 'Invalide number format');
end;

function readLong(var input: Text) : longint;
var s    : string;
   code  : integer;
   result: longint;
   eol   : boolean;
begin
  s := readNumber(input, eol);
  val(s, result, code);
  readLong := result;
  assert(code = 0, 'Invalide number format');
end;

function readComp(var input: Text) : comp;
var s    : string;
   code  : integer;
   result: comp;
   eol   : boolean;
begin
  s := readNumber(input, eol);
  val(s, result, code);
  readComp := result;
  assert(code = 0, 'Invalide number format');
end;

procedure readPos(var input: Text; var pos: TPos);
begin
  pos.x := readLong(input);
  pos.y := readLong(input);
end;

function readLongArray(var input : Text; var values : array of longint) : word;
var idx : word;
    s   : string;
    code: integer;
    eol : boolean;
      c : char;
begin
  idx := 0;
  eol := false;
  while not eol do begin
    assert(idx <= HIGH(values),'Array to small');

    s := readNumber(input, eol);
    val(s, values[idx], code);
    inc(idx);
    if eol and not eof(input) then read(input,c);
  end;
  readLongArray := idx;
end;

function readUint64Array(var input : Text; var values: array of uint64_t) : word;
var idx  : word;
    s    : string;
    eol  : boolean;
      c  : char;
begin
  idx := 0;
  eol := false;
  while not eol do begin
    assert(idx <= HIGH(values),'Array to small');

    s := readNumber(input, eol);
    assert(strToUint64(s, values[idx]),'Invalid number');
    inc(idx);
    if eol and not eof(input) then read(input,c);
  end;
  readUint64Array := idx;
end;

type TCharArray = array[0..65534] of char;
     PCharArray = ^TCharArray;

procedure loadCharMap(var input: Text; var map; var maxX, maxY : word);
var x, y, sx : word;
    output   : PCharArray;
    c        : char;
begin
  sx := 0;
   y := 0;
   output := PCharArray(@Map);
   while (not eof(input)) and (y < maxY) do begin
     read(input,c);
     x:= 0;
     while (c<> #10) and not eof(input) do begin
       if ord(c) in [32..127] then begin
         assert((x < MaxX) and (y < MaxY), 'Not enougth memory for given input map');
         output^[x * maxX + y] := c;
         inc(x);
       end;
       read(input, c);
     end;
     if sx = 0 then sx := x;
     if x = 0 then break; (* Empty line also marks the end of a map *)
     inc(y);
   end;

   maxX  := sx;
   maxY  := y;
end;

procedure findFirstInMap(var map; const what: char; const max : TPos; const xDim: word; var pos: TPos);
var x,y,column  : word;
    pmap        : PCharArray;
begin
  pmap := PCharArray(@map);
  pos := max;

  for x:= 0 to max.x do begin
   column := x*xDim;
   for y:= 0 to max.y do
    if pmap^[column + y] = what then begin
      pos.x := x;
      pos.y := y;
      break;
    end;
   end;
end;

function  countInMap(var map; const what: char; const max: TPos; const xDim : word) : word;
var x,y,result,column : word;
    pmap       : PCharArray;
begin
  result := 0;
  pmap := PCharArray(@map);

  for x:= 0 to max.x do begin
   column := x*xdim;
   for y:= 0 to max.y do
    if pmap^[column+y] = what then inc(result);
  end;
  countInMap := result;
end;

function advancePos(var pos: TPos;
                    const dir : TDirection;
                    const min, max: TPos): boolean;
const Mapper : array [TDirection] of TDirection8 = (NO, ES, WE, SO);
begin
  advancePos := advancePos8(pos, Mapper[dir], min, max);
end;

function advancePos8(var pos: TPos;
                    const dir : TDirection8;
                    const min, max: TPos): boolean;
begin
  inc(pos.x,Movement8[dir].x);
  inc(pos.y,Movement8[dir].y);

  advancePos8 := True;
  if pos.x < min.x then begin pos.x := min.x; advancePos8 := False; end;
  if pos.x > max.x then begin pos.x := max.x; advancePos8 := False; end;
  if pos.y < min.y then begin pos.y := min.y; advancePos8 := False; end;
  if pos.y > max.x then begin pos.x := max.y; advancePos8 := False; end;
end;


function reverseDirection(const dir : TDirection): TDirection;
begin
   case dir of
       North: reverseDirection  := South;
       West : reverseDirection  := East;
       East : reverseDirection  := West;
       South: reverseDirection  := North;
  end;
end;

function nextDirection(const origin : TDirection; dir : TDirection): TDirection;
var noWay : TDirection;
begin

  noWay := reverseDirection(origin);

  repeat
    case dir of
         North : dir := East;
         East  : dir := South;
         South : dir := West;
         West  : dir := North;
    end;
  until noWay <> dir;

  nextDirection := dir;
end;

function posEqual(const p1, p2 : TPos): boolean;
begin
  posEqual:= (p1.x = p2.x) and (p1.y = p2.y);
end;

procedure addPos(var pos : TPos; const delta: TPos);
begin
  pos.x := pos.x + delta.x;
  pos.y := pos.y + delta.y;
end;

procedure subPos(var pos : TPos; const delta: TPos);
begin
  pos.x := pos.x - delta.x;
  pos.y := pos.y - delta.y;
end;

procedure deltaPos(const p1, p2 : TPos; var delta : TPos);
begin
  delta.x := p2.x - p1.x;
  delta.y := p2.y - p1.y;
end;

procedure scalePos(const scale : longint; var p : TPos);
begin
  p.x := p.x * scale;
  p.y := p.y * scale;
end;

function dmax(const d1, d2: double): double;
begin
  if d1 > d2 then dmax := d1 else dmax:= d2;
end;

function dmin(const d1, d2: double): double;
begin
  if d1 < d2 then dmin := d1 else dmin := d2;
end;

function inRange(const value, lower, upper : longint) : boolean;
begin
  inRange := (value >= lower) and ( value <= upper );
end;

function inArea(const point, lower, upper : TPos) : boolean;
begin
  inArea := inRange(point.x, lower.x, upper.x) and
            inRange(point.y, lower.y, upper.y);
end;
begin
end.