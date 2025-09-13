program day23;
(*This is the implementation of the aoc24 day 23*)

uses aoc, cassert;
const InputFileName = 'INP\DAY23_IN.TXT';
type TComputerName = string[2];
     TComputerHash = word;

     TComputer = object 
         hash_           : TComputerHash;
         connections_    : array[0..15] of TComputerHash;
         numConnections_ : byte;

         constructor init(const hash : TComputerHash);
         destructor done;

         procedure addConnection(var other : TComputer);
         function isConnected(const other: TComputer): Boolean;
     end;

var computers : array[0..26*26] of TComputer;

function hashComputerName(const s:TComputerName) : TComputerHash;
begin
  assert(length(s) = 2,'Invalid Name');
  hashComputerName := (ord(s[1]) - ord('a'))* 26 + (ord(s[2]) - ord('a'));
end;

constructor TComputer.init(const hash : TComputerHash);
var i: word;
begin
  numConnections_ := 0;
  hash_ := hash;
  for i := 0 to HIGH(connections_) do connections_[i] := 0;
end;

destructor TComputer.done;
begin
  numConnections_ := 0;
end;

procedure TComputer.addConnection(var other : TComputer);
begin
  assert(numConnections_ <= HIGH(connections_), 'Too many connections');
  assert(other.numConnections_ <= HIGH(connections_), 'Too many connections');
  
  connections_[numConnections_] := other.hash_;
  other.connections_[other.numConnections_] := hash_;

  inc(numConnections_);
  inc(other.numConnections_);
end;

function TComputer.isConnected(const other: TComputer): Boolean;
var i : word;
begin
  isConnected := false;
  for i:=0 to numConnections_ - 1 do begin
    if connections_[i] = other.hash_ then isConnected := true;
  end; 
end;

procedure setupComputerNetword(var input: Text); far;
var i: word;
    a,b : TComputerName;
    ah, bh : TComputerHash;
    c : char;
begin
  for i:=0 to HIGH(computers) do computers[i].init(i);

  while not eof(input) do begin
    read(input, a);
    read(input, c);
    read(input,b);
    readln(input);

    ah := hashComputerName(a);
    bh := hashComputerName(b);

    computers[ah].addConnection(computers[bh]);
  end;
end;

function part1(var input: Text):comp; far;
var hash, startHash, endHash : TComputerHash;
    n1, n2 : word;
    count  : longint;
begin
  startHash := hashComputerName('ta');
  endHash   := hashComputerName('tz');
  count := 0;

  for hash := startHash to endHash do with computers[hash] do begin
    for n1 := 0 to numConnections_ do begin
      for n2 := n1 + 1 to numConnections_ do begin
        if computers[connections_[n1]].isConnected(computers[connections_[n2]]) and
           ((connections_[n1] < startHash) or (connections_[n1] > hash)) and
           ((connections_[n2] < startHash) or (connections_[n2] > hash))
        then 
          inc(count);
      end;
    end;
  end;

  part1 := count;
end;

function part2(var input: Text):comp; far;
begin
  part2 := 0;
end;

begin
  runAoc(InputFileName, 23, part1, part2, setupComputerNetword, nil);
end.
