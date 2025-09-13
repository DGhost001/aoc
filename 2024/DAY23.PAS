program day23;
(*This is the implementation of the aoc24 day 23*)

uses aoc, cassert, ProgressBar;
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

function unhashComputerName(const h:TComputerHash) : TComputerName;
begin
  assert((h < 26*26),'Invalid Hash');
  unhashComputerName := chr((h div 26) + ord('a')) + chr((h mod 26) + ord('a'));
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
type TNetwork = record
        computers : array[0..15] of TComputerHash;
        size : byte;
     end;
  function isCandidate(const net: TNetwork; const candidate: TComputer): Boolean;
  var i: integer;
  begin
    isCandidate := true;
    for i := 0 to net.size - 1 do begin
      if not candidate.isConnected(computers[net.computers[i]]) then begin
        isCandidate := false;
        exit;
      end;
    end;
  end;

  procedure addComputer(var net: TNetwork; const candidate: TComputer);
  begin
    assert(net.size <= HIGH(net.computers), 'Network too large');
    net.computers[net.size] := candidate.hash_;
    inc(net.size);
  end;

  procedure clearNetwork(var net: TNetwork);
  begin
    net.size := 0;
  end;

  procedure findBiggestNetwork(const computer: TComputer;
                               currentNeighbour: byte;
                               net: TNetwork;
                               var largestNetwork: TNetwork);
  begin
    if currentNeighbour >= computer.numConnections_ then begin
        if net.size > largestNetwork.size then largestNetwork := net;
    end else begin
        if isCandidate(net, computers[computer.connections_[currentNeighbour]]) then begin
           addComputer(net, computers[computer.connections_[currentNeighbour]]);
           findBiggestNetwork(computer, currentNeighbour + 1, net, largestNetwork);
           dec(net.size);
        end;
        findBiggestNetwork(computer, currentNeighbour + 1, net, largestNetwork);
    end;
  end;
  
  procedure removeComputer(var net: TNetwork; const index: byte);
  var j : byte;
  begin
    assert((index < net.size), 'Invalid index to remove');
    if net.size >= 2 then 
      for j := index to net.size - 2 do
          net.computers[j] := net.computers[j+1];
    dec(net.size);
  end;
  
  procedure printNetwork(net: TNetwork);
  var minHash: TComputerHash;
      index,i  : byte;
  begin
    while net.size > 0 do begin
      minHash := net.computers[0];
      index := 0;
      for i := 1 to net.size - 1 do begin
        if net.computers[i] < minHash then begin
          minHash := net.computers[i];
          index := i;
        end;
      end;
      write(unhashComputerName(minHash), ',');
      removeComputer(net, index);
    end;
    WriteLn;
  end; 

var largestNetwork: TNetwork;
    candidateNetwor: TNetwork;
    hash, startHash, endHash : TComputerHash;
    p : TProgressBar;
begin
  clearNetwork(largestNetwork);
  startHash := hashComputerName('ta');
  endHash   := hashComputerName('tz');
  p.init(endHash - startHash + 1,'Search');
  for hash := startHash to endHash do with computers[hash] do begin
    clearNetwork(candidateNetwor); (* Clear out the current network *)
    addComputer(candidateNetwor, computers[hash]); (* Add the current computer *)
    findBiggestNetwork(computers[hash], 0, candidateNetwor, largestNetwork);
    p.step(1);
   end;
  p.done;
  printNetwork(largestNetwork);
  part2 := largestNetwork.size;
end;

begin
  runAoc(InputFileName, 23, part1, part2, setupComputerNetword, nil);
end.
