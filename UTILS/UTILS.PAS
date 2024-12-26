unit utils;
interface

uses DeQueue,JString,stdint;

type
    TParity = (Odd, Even);

function parseUintArray(it : PDeQueueIterator; var numbers: array of Uint64_t) : word;
function countLines(var input : Text): longint;

function getParity(const a: longint) : TParity;
function isParity(const a: longint; const p: TParity):boolean;

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
  if (a mod 2) = 0 then getParity := Even else getParity:= Odd;
end;

function isParity(const a: longint; const p: TParity): boolean;
begin
  isParity := getParity(a) = p;
end;

begin
end.