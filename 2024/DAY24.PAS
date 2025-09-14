program day24;
(*This is the implementation of the aoc24 day 24*)

uses aoc, stdint, itemhandler, SparsArray, cassert, Dequeue, utils;
const InputFileName = 'INP\DAY24_IN.TXT';

type PGate  = ^TGate;
     PWire = ^TWire;
     TWireId    = string[3];
     TWireState = (WireLow, WireHigh, WireThreeState);
     TWire = object(ItemType)
         input_ : PGate;
         state_ : TWireState;

         constructor init(const input: PGate);
         destructor done; virtual;

         procedure setInput(const input: PGate);
         procedure update;
     end;
     
     TGate = object(ItemType)
         inputs_ : array[1..2] of PWire;

         constructor init(const in1, in2: PWire);
         destructor done; virtual;
         function getOutput: TWireState; virtual;

         private
            function getInputState(const index: byte): TWireState;
     end;
     
     PAndGate = ^TAndGate;
     TAndGate = object(TGate)
         function getOutput: TWireState; virtual;
     end;

     POrGate = ^TOrGate;
     TOrGate = object(TGate)
         function getOutput: TWireState; virtual;
     end;

     PXorGate = ^TXorGate;
     TXorGate = object(TGate)
         function getOutput: TWireState; virtual;
     end;

     PConstGate = ^TConstGate;
     TConstGate = object(TGate)
         constState_ : TWireState;
         constructor init(const state: TWireState);
         function getOutput: TWireState; virtual;
     end;

constructor TWire.init(const input: PGate);
begin
  ItemType.init;
  input_ := input;
  state_ := WireThreeState;
end;

destructor TWire.done;
begin
    ItemType.done;
end;

procedure TWire.setInput(const input: PGate);
begin
    input_ := input;
    state_ := WireThreeState;
end;

procedure TWire.update;
begin
    if input_ <> nil then
        state_ := input_^.getOutput;
end;

constructor TGate.init(const in1, in2: PWire);
begin
    ItemType.init;
    inputs_[1] := in1;
    inputs_[2] := in2;
end;

destructor TGate.done;
begin
    ItemType.done;
end;

function TGate.getInputState(const index: byte): TWireState;
begin
    assert((index = 1) or (index = 2), 'Invalid input index');
    if inputs_[index] = nil then
        getInputState := WireThreeState
    else if (inputs_[index]^.state_ = WireThreeState) then
        inputs_[index]^.state_ := inputs_[index]^.input_^.getOutput;
    getInputState := inputs_[index]^.state_;
end;

function TGate.getOutput: TWireState;
begin
  assert(false, 'Base class getOutput called');
  getOutput := WireThreeState;
end;

function TAndGate.getOutput: TWireState;
var w1, w2 : TWireState;
begin
  w1 := getInputState(1);
  w2 := getInputState(2);

  assert((w1 <> WireThreeState) and (w2 <> WireThreeState), 'Input not ready');

  if (w1 = WireHigh) and (w2 = WireHigh) then
    getOutput := WireHigh
  else
    getOutput := WireLow;
end;

function TOrGate.getOutput: TWireState;
var w1, w2 : TWireState;
begin
  w1 := getInputState(1);
  w2 := getInputState(2);

  assert((w1 <> WireThreeState) and (w2 <> WireThreeState), 'Input not ready');

  if (w1 = WireHigh) or (w2 = WireHigh) then
    getOutput := WireHigh
  else
    getOutput := WireLow;
end;

function TXorGate.getOutput: TWireState;
var w1, w2 : TWireState;
begin
  w1 := getInputState(1);
  w2 := getInputState(2);

  assert((w1 <> WireThreeState) and (w2 <> WireThreeState), 'Input not ready');

  if (w1 = w2) then
    getOutput := WireLow
  else
    getOutput := WireHigh;
end;

constructor TConstGate.init(const state: TWireState);
begin
    assert(state <> WireThreeState, 'Const gate cannot be three state' );
    ItemType.init;
    constState_ := state;
end;

function TConstGate.getOutput: TWireState;
begin
    getOutput := constState_;
end;

function getWireHash(const id : TWireId): word;
 function myOrd(c: char): word;
 begin
   myOrd := 0;
   if c in ['0'..'9'] then
     myOrd := ord(c) - ord('0')
   else if c in ['a'..'z'] then
     myOrd := ord(c) - ord('a') + 10
   else assert(false, 'Invalid character in wire ID');
 end;

begin
    assert(length(id) = 3, 'Invalid Wire ID');
    getWireHash := myOrd(id[1]) * 36 * 36 +
                   myOrd(id[2]) * 36 +
                   myOrd(id[3]);
end;

var wireStorage : TSparseArray;
    gateStorage : TDequeue;

procedure parseCircuit(var input: Text);
var
  line: string;
  w1, w2, w3: TWireId;
  wire1, wire2, wire3: PWire;
  g: PGate;
  pos1, pos2: integer;
  gateType: string;
  i: integer;
begin
  wireStorage.init;
  gateStorage.init;
  g := nil;

  while not eof(input) do
  begin
    readln(input, line); (* Read the entire line *)
    if line = '' then continue; (* Skip empty lines *)

    (* Check if it's a constant gate definition *)
    pos1 := Pos(':', line);
    if pos1 > 0 then
    begin
      (* Extract wire ID *)
      w1 := Copy(line, 1, pos1 - 1);

      (* Extract constant value *)
      Val(Copy(line, pos1 + 1, Length(line) - pos1), i, pos2);
      assert((i >= 0) and (i <= 1), 'Invalid constant gate state');
      assert(pos2 = 0, 'Invalid constant gate state');

      if i = 0 then
        g := new(PConstGate, init(WireLow))
      else
        g := new(PConstGate, init(WireHigh));

      wire1 := new(PWire, init(g));
      wireStorage.setValue(getWireHash(w1), wire1);
      gateStorage.pushBack(g);
    end
    else
    begin
      (* It's a logic gate definition *)
      (* Find the gate type (AND, OR, XOR) *)
      pos1 := Pos(' AND ', line);
      if pos1 > 0 then gateType := 'AND'
      else begin
        pos1 := Pos(' OR ', line);
        if pos1 > 0 then gateType := 'OR'
        else begin
          pos1 := Pos(' XOR ', line);
          if pos1 > 0 then gateType := 'XOR'
          else gateType := ''; (* Unknown gate type *)
        end;
      end;

      if gateType <> '' then
      begin
        (* Extract wire IDs *)
        w1 := Copy(line, 1, pos1 - 1);
        w2 := Copy(line, pos1 + Length(gateType) + 2, 3); (* Assuming 3-char wire IDs *)
        w3 := Copy(line, pos1 + Length(gateType) + 9, 3); (* Assuming 3-char wire IDs *)

        wire1 := PWire(wireStorage.at(getWireHash(w1)));
        wire2 := PWire(wireStorage.at(getWireHash(w2)));
        wire3 := PWire(wireStorage.at(getWireHash(w3)));

        if wire1 = nil then begin
          wire1 := new(PWire, init(nil));
          wireStorage.setValue(getWireHash(w1), wire1);
        end;

        if wire2 = nil then begin
          wire2 := new(PWire, init(nil));
          wireStorage.setValue(getWireHash(w2), wire2);
        end;

        if gateType = 'AND' then
          g := new(PAndGate, init(wire1, wire2))
        else if gateType = 'OR' then
          g := new(POrGate, init(wire1, wire2))
        else if gateType = 'XOR' then
          g := new(PXorGate, init(wire1, wire2))
        else
          assert(false, 'Unknown gate type');

        if wire3 = nil then begin
          wire3 := new(PWire, init(g));
          wireStorage.setValue(getWireHash(w3), wire3);
        end else wire3^.setInput(g);
      end;
    end;
  end;
end;


function part1(var input: Text):comp; far;
var result : comp;
    s      : string;
    i      : Integer;
    wire   : PWire;
begin
  parseCircuit(input);
  result := 0;
  for i:= 63 downto 0 do
  begin
    str(i, s);
    result := result * 2;
    if i < 10 then s:= 'z0' + s else s := 'z' + s;
    wire := PWire(wireStorage.at(getWireHash(s)));
    if wire <> nil then begin
      if wire^.state_ = WireThreeState then
        wire^.update;
      if wire^.state_ = WireHigh then
        result := result + 1;
    end;
  end;

  part1 := result;
  wireStorage.done;
  gateStorage.done;
end;

function part2(var input: Text):comp; far;
begin
  part2 := 0;
end;

begin
  runAoc(InputFileName, 24, part1, part2, nil, nil);
end.
