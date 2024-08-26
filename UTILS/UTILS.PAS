unit utils;
interface

uses DeQueue,JString,stdint;

function parseUintArray(it : PDeQueueIterator; var numbers: array of Uint64_t) : word;

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

begin
end.