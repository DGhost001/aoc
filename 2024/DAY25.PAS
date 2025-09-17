program day25;
(*This is the implementation of the aoc24 day 25*)

uses aoc, cassert;
const InputFileName = 'INP\DAY25_IN.TXT';
      MaxHeight = 7;

type TKeyLockType = (Key, Lock);
     TKeyLock = array[0..4] of byte;
     TKeys = record
         keys : array[0..255] of TKeyLock;
         count: byte;
     end;
     
     TLocks = record
         locks : array[0..255] of TKeyLock;
         count: byte;
     end;

function matchKeyLock(const key, lock: TKeyLock): boolean;
begin
  matchKeyLock := (key[0] + lock[0] <= MaxHeight) and
                  (key[1] + lock[1] <= MaxHeight) and
                  (key[2] + lock[2] <= MaxHeight) and
                  (key[3] + lock[3] <= MaxHeight) and
                  (key[4] + lock[4] <= MaxHeight);
end;

function parseKeyLock(var input: Text; var keyLock: TKeyLock): TKeyLockType;
var s: string;
    i: integer;
begin
  FillChar(keyLock, SizeOf(keyLock), 0);
  for i:= 1 to MaxHeight do begin
    ReadLn(input, s);
    if (i = 1) then begin 
      if (s[1] = '#') then 
        parseKeyLock := Lock else parseKeyLock := Key;
    end;
    if s[1] = '#' then inc(keyLock[0]);
    if s[2] = '#' then inc(keyLock[1]);
    if s[3] = '#' then inc(keyLock[2]);
    if s[4] = '#' then inc(keyLock[3]);
    if s[5] = '#' then inc(keyLock[4]);
  end;
  if not eof(input) then ReadLn(input,s); // empty line
end;

procedure loadKeysAndLocks(var input: Text; var keys: TKeys; var locks: TLocks);
var keyLock: TKeyLock;
    keyLockType: TKeyLockType;
begin
    keys.count := 0;
    locks.count := 0;
    while not eof(input) do begin
        keyLockType := parseKeyLock(input, keyLock);
        case keyLockType of
        Key: begin
                 assert(keys.count < 255, 'Too many keys');
                 keys.keys[keys.count] := keyLock;
                 inc(keys.count);
             end;
        Lock: begin
                assert(locks.count < 255, 'Too many locks');
                locks.locks[locks.count] := keyLock;
                inc(locks.count);
                end;
        end;
    end;
end;

function countMatches(const keys: TKeys; const locks: TLocks): word;
var result: word;
    i,j: integer;
begin
  result := 0;
  for i := 0 to keys.count - 1 do
    for j := 0 to locks.count - 1 do
      if matchKeyLock(keys.keys[i], locks.locks[j]) then
        inc(result);
  countMatches := result;
end;

var keys: TKeys;
    locks: TLocks;
function part1(var input: Text):comp; far;
begin
  loadKeysAndLocks(input, keys, locks);
  part1 := countMatches(keys, locks);
end;

function part2(var input: Text):comp; far;
begin
  part2 := 0;
end;

begin
  runAoc(InputFileName, 25, part1, part2, nil, nil);
end.
