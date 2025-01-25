unit utils;
interface

uses DeQueue,JString,stdint,cassert;

type
    TParity = (Odd, Even);
    TPos    = record
           x, y : longint;
    end;

    TDirection = (North, East, West, South);

function parseUintArray(it : PDeQueueIterator; var numbers: array of Uint64_t) : word;
function countLines(var input : Text): longint;

function getParity(const a: longint) : TParity;
function isParity(const a: longint; const p: TParity):boolean;
function reverseParity(const a: TParity) : TParity;

function readInteger(var input: Text) : integer;
function readComp(var input: Text) : comp;

procedure loadCharMap(var input: Text; var map; var maxX, maxY : word);

function advancePos(var pos: TPos; const dir : TDirection; const min, max: TPos): boolean;
function posEqual(const p1, p2 : TPos): boolean;

function nextDirection(const origin : TDirection; dir : TDirection): TDirection;
function reverseDirection(const dir: TDirection): TDirection;

function dmax(const d1, d2: double): double;
function dmin(const d1, d2: double): double;

implementation

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

function readInteger(var input: Text) : integer;
var s  : string;
   code: integer;
   result: integer;
begin
  s[0] := #0;
  read(input, s[ord(s[0])+1]);
  while (s[ord(s[0])+1] in [' ','+','-',#13,#10,#9,'0'..'9']) do begin
    if s[ord(s[0])+1] in ['0'..'9'] then inc(s[0]) else
    if (ord(s[0]) = 0) and (s[ord(s[0])+1] in ['+','-']) then inc(s[0])
    else if (ord(s[0]) > 0) and (s[ord(s[0])+1] in ['+','-',' ',#13,#10,#9]) then
      break;
   if eof(input) then break;
   read(input, s[ord(s[0])+1]);
  end;

  val(s, result, code);
  readInteger := result;
  assert(code = 0, 'Invalide number format');
end;

function readComp(var input: Text) : comp;
var s  : string;
   code: integer;
   result: comp;
begin
  s[0] := #0;
  read(input, s[ord(s[0])+1]);
  while (s[ord(s[0])+1] in [' ','+','-',#13,#10,#9,'0'..'9']) do begin
    if s[ord(s[0])+1] in ['0'..'9'] then inc(s[0]) else
    if (ord(s[0]) = 0) and (s[ord(s[0])+1] in ['+','-']) then inc(s[0])
    else if (ord(s[0]) > 0) and (s[ord(s[0])+1] in ['+','-',' ',#13,#10,#9]) then
      break;
   if eof(input) then break;
   read(input, s[ord(s[0])+1]);
  end;

  val(s, result, code);
  readComp := result;
  assert(code = 0, 'Invalide number format');
end;

procedure loadCharMap(var input: Text; var map; var maxX, maxY : word);
type TCharArray = array[0..65534] of char;
     PCharArray = ^TCharArray;
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
     inc(y);
   end;

   maxX  := x;
   maxY  := y;
end;

function advancePos(var pos: TPos;
                    const dir : TDirection;
                    const min, max: TPos): boolean;
const Movment : array[TDirection] of TPos = (
                 (x: 0; y: -1),
                 (x: 1; y:  0),
                 (x:-1; y:  0),
                 (x: 0; y:  1));

begin
  inc(pos.x,Movment[dir].x);
  inc(pos.y,Movment[dir].y);

  advancePos := True;
  if pos.x < min.x then begin pos.x := min.x; advancePos := False; end;
  if pos.x > max.x then begin pos.x := max.x; advancePos := False; end;
  if pos.y < min.y then begin pos.y := min.y; advancePos := False; end;
  if pos.y > max.x then begin pos.x := max.y; advancePos := False; end;
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

function dmax(const d1, d2: double): double;
begin
  if d1 > d2 then dmax := d1 else dmax:= d2;
end;

function dmin(const d1, d2: double): double;
begin
  if d1 < d2 then dmin := d1 else dmin := d2;
end;

begin
end.