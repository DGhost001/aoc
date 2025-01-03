unit utils;
interface

uses DeQueue,JString,stdint,cassert;

type
    TParity = (Odd, Even);

function parseUintArray(it : PDeQueueIterator; var numbers: array of Uint64_t) : word;
function countLines(var input : Text): longint;

function getParity(const a: longint) : TParity;
function isParity(const a: longint; const p: TParity):boolean;
function reverseParity(const a: TParity) : TParity;

function readInteger(var input: Text) : integer;


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

begin
end.