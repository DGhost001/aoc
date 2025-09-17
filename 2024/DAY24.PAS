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
         id_    : TWireId;

         constructor init(const input: PGate);
         destructor done; virtual;

         procedure setInput(const input: PGate);
         procedure update;

         procedure print(var output: Text);
     end;
     
     TGate = object(ItemType)
         inputs_ : array[1..2] of PWire;
         id_     : word;
         printed : boolean;

         constructor init(const in1, in2: PWire);
         destructor done; virtual;
         function getOutput: TWireState; virtual;
         procedure print(var output: Text); virtual;
         procedure checkGate; virtual;

         private
            function getInputState(const index: byte): TWireState;
     end;
     
     PAndGate = ^TAndGate;
     TAndGate = object(TGate)
         function getOutput: TWireState; virtual;
         procedure print(var output: Text); virtual;
         procedure checkGate; virtual;
     end;

     POrGate = ^TOrGate;
     TOrGate = object(TGate)
         function getOutput: TWireState; virtual;
         procedure print(var output: Text); virtual;
         procedure checkGate; virtual;
     end;

     PXorGate = ^TXorGate;
     TXorGate = object(TGate)
         function getOutput: TWireState; virtual;
         procedure print(var output: Text); virtual;
         procedure checkGate; virtual;
     end;

     PConstGate = ^TConstGate;
     TConstGate = object(TGate)
         constState_ : TWireState;
         constructor init(const state: TWireState);
         function getOutput: TWireState; virtual;
         procedure print(var output: Text); virtual;
         procedure checkGate; virtual;
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

procedure TWire.print(var output: Text);
begin
   if input_ <> nil then
     input_^.print(output);
   Write(output, '--> |', id_,'|');
end;

constructor TGate.init(const in1, in2: PWire);
begin
    ItemType.init;
    inputs_[1] := in1;
    inputs_[2] := in2;
    printed := false;
end;

destructor TGate.done;
begin
    ItemType.done;
end;

procedure TGate.checkGate;
begin
  assert(false, 'Base class checkGate called');
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

procedure TGate.print(var output: Text);
begin
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

procedure TAndGate.print(var output: Text);
var s : string;
begin
  str(id_, s);
  s := ' AND_'+s+'(AND) ';
  if not printed then begin
    inputs_[1]^.print(output); writeln(output, s);
    inputs_[2]^.print(output); writeln(output, s);
    printed := true;
  end;  
  write(output, s);
end;

procedure TAndGate.checkGate;
var i: integer;
begin
  i := 0;
  (* We have two types of ands*)
  if (inputs_[1] = nil) or (inputs_[2] = nil) then begin
      assert(false, 'And gate with missing input');
  end;

  (* Check first AND Type: The Carry Propagate Generate AND *)
  if (typeOf(inputs_[1]^.input_^) = typeOf(TConstGate)) and
     (typeOf(inputs_[2]^.input_^) = typeOf(TConstGate)) then i := 3 else
  if (typeOf(inputs_[1]^.input_^) = typeOf(TConstGate)) and
     (typeOf(inputs_[2]^.input_^) <> typeOf(TConstGate)) then i := 2 else
  if (typeOf(inputs_[2]^.input_^) = typeOf(TConstGate)) and
     (typeOf(inputs_[1]^.input_^) <> typeOf(TConstGate)) then i := 1 else
  
  (* Check second AND Type: The Sum AND *)
  if (typeOf(inputs_[1]^.input_^) = typeOf(TXorGate)) and
     (typeOf(inputs_[2]^.input_^) = typeOf(TOrGate)) then i := 3 else
  if (typeOf(inputs_[2]^.input_^) = typeOf(TXorGate)) and
     (typeOf(inputs_[1]^.input_^) = typeOf(TOrGate)) then i := 3 else

  if (typeOf(inputs_[1]^.input_^) = typeOf(TXorGate)) and
     (typeOf(inputs_[2]^.input_^) <> typeOf(TOrGate)) then i := 2 else

  if (typeOf(inputs_[1]^.input_^) = typeOf(TOrGate)) and
     (typeOf(inputs_[2]^.input_^) <> typeOf(TXorGate)) then i := 2 else

  if (typeOf(inputs_[2]^.input_^) = typeOf(TXorGate)) and
     (typeOf(inputs_[1]^.input_^) <> typeOf(TOrGate)) then i := 1 else

  if (typeOf(inputs_[2]^.input_^) = typeOf(TOrGate)) and
     (typeOf(inputs_[1]^.input_^) <> typeOf(TXorGate)) then i := 1;

  case i of
    0: begin
         WriteLn('AND input 1: ', inputs_[1]^.id_, ' is wrong');
         WriteLn('AND input 2: ', inputs_[2]^.id_, ' is wrong');
       end;
    1: begin
         WriteLn('AND input 1: ', inputs_[1]^.id_, ' is wrong');
       end;
    2: begin
         WriteLn('AND input 2: ', inputs_[2]^.id_, ' is wrong');
       end;
  end;
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

procedure TOrGate.print(var output: Text);
var s : string;
begin
  str(id_, s);
  s := ' OR_'+s+'(OR) ';
  if not printed then begin
    inputs_[1]^.print(output); writeln(output, s);
    inputs_[2]^.print(output); writeln(output, s);
    printed := true;
  end;
  write(output, s);
end;

procedure TOrGate.checkGate;
var i: integer;
begin
  i := 0;
  
  if (inputs_[1] = nil) or (inputs_[2] = nil) then begin
      assert(false, 'Or gate with missing input');
  end;

  if typeOf(inputs_[1]^.input_^) <> typeOf(TAndGate) then i := 1 else
  if typeOf(inputs_[2]^.input_^) <> typeOf(TAndGate) then i := 2 else
  if (typeOf(inputs_[1]^.input_^) = typeOf(TAndGate)) and
     (typeOf(inputs_[2]^.input_^) = typeOf(TAndGate)) then i := 3;
  
  case i of
  0: begin
        WriteLn('OR input 1: ', inputs_[1]^.id_, ' is wrong');
        WriteLn('OR input 2: ', inputs_[2]^.id_, ' is wrong');
      end;
  1: begin
        WriteLn('OR input 1: ', inputs_[1]^.id_, ' is wrong');
      end;
  2: begin
        WriteLn('OR input 2: ', inputs_[2]^.id_, ' is wrong');
      end;
  end;
  
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

procedure TXorGate.print(var output: Text);
var s : string;
begin
  str(id_, s);
  s := ' XOR_'+s+'(XOR) ';
  if not printed then begin
    inputs_[1]^.print(output); writeln(output, s);
    inputs_[2]^.print(output); writeln(output, s);
    printed := true;
  end;  
  write(output, s);
end;

procedure TXorGate.checkGate;
var i: integer;
begin
  i := 0;
  
  if (inputs_[1] = nil) or (inputs_[2] = nil) then begin
      assert(false, 'Xor gate with missing input');
  end;

  if (typeOf(inputs_[1]^.input_^) = typeOf(TXorGate)) and
      (typeOf(inputs_[2]^.input_^) = typeOf(TOrGate)) then i := 3 else
  if (typeOf(inputs_[2]^.input_^) = typeOf(TXorGate)) and
      (typeOf(inputs_[1]^.input_^) = typeOf(TOrGate)) then i := 3 else
  if (typeOf(inputs_[1]^.input_^) = typeOf(TXorGate)) and
      (typeOf(inputs_[2]^.input_^) <> typeOf(TOrGate)) then i := 2 else
  if (typeOf(inputs_[1]^.input_^) = typeOf(TOrGate)) and
      (typeOf(inputs_[2]^.input_^) <> typeOf(TXorGate)) then i := 2 else
  if (typeOf(inputs_[1]^.input_^) <> typeOf(TXorGate)) and
      (typeOf(inputs_[2]^.input_^) = typeOf(TOrGate)) then i := 1 else
  if (typeOf(inputs_[1]^.input_^) <> typeOf(TOrGate)) and
      (typeOf(inputs_[2]^.input_^) = typeOf(TXorGate)) then i := 1 else
  if (typeOf(inputs_[1]^.input_^) = typeOf(TConstGate)) and
      (typeOf(inputs_[2]^.input_^) = typeOf(TConstGate)) then i := 3 else
  if (typeOf(inputs_[1]^.input_^) = typeOf(TConstGate)) and
      (typeOf(inputs_[2]^.input_^) <> typeOf(TConstGate)) then i := 2 else
  if (typeOf(inputs_[1]^.input_^) <> typeOf(TConstGate)) and
      (typeOf(inputs_[2]^.input_^) = typeOf(TConstGate)) then i := 1;

  case i of
  0: begin
        WriteLn('XOR input 1: ', inputs_[1]^.id_, ' is wrong');
        WriteLn('XOR input 2: ', inputs_[2]^.id_, ' is wrong');
      end;
  1: begin
        WriteLn('XOR input 1: ', inputs_[1]^.id_, ' is wrong');
      end;
  2: begin
        WriteLn('XOR input 2: ', inputs_[2]^.id_, ' is wrong');
      end;
  end;
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

procedure TConstGate.print(var output: Text);
var s: string;
begin
    str(id_, s);
    write(output, ' CONST_',s,'(', constState_,') ');
end;

procedure TConstGate.checkGate;
begin
  
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
  id: word;
begin
  wireStorage.init;
  gateStorage.init;
  g := nil;
  id := 0;

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
      g^.id_ := id; inc(id);
      wire1^.id_ := w1;
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
          wire1^.id_ := w1;
        end;

        if wire2 = nil then begin
          wire2 := new(PWire, init(nil));
          wireStorage.setValue(getWireHash(w2), wire2);
          wire2^.id_ := w2;
        end;

        if gateType = 'AND' then
          g := new(PAndGate, init(wire1, wire2))
        else if gateType = 'OR' then
          g := new(POrGate, init(wire1, wire2))
        else if gateType = 'XOR' then
          g := new(PXorGate, init(wire1, wire2))
        else
          assert(false, 'Unknown gate type');
        
        g^.id_ := id; inc(id);
        gateStorage.pushBack(g);

        if wire3 = nil then begin
          wire3 := new(PWire, init(g));
          wireStorage.setValue(getWireHash(w3), wire3);
          wire3^.id_ := w3;
        end else wire3^.setInput(g);
      end;
    end;
  end;
end;

procedure getNumberFromOutput(var number : Uint64_t);
var i: integer;
    s: string;
    wire: PWire;
begin
  number := zero64;
  for i := 63 downto 0 do
  begin
    shiftLeft64(1, number);
    str(i, s);
    if i < 10 then s := 'z0' + s else s := 'z' + s;
    wire := PWire(wireStorage.at(getWireHash(s)));
    if wire <> nil then
    begin
      if wire^.state_ = WireThreeState then wire^.update;
      if wire^.state_ = WireHigh then or64( number, one64);
    end;
  end;
end;

procedure setNumberToInput(number : Uint64_t; const input: char);
var i: integer;
    s: string;
    wire: PWire;
begin
  assert(input in ['x','y'], 'Invalid input wire prefix');
  for i := 0 to 63 do
  begin
    str(i, s);
    if i < 10 then s := input+'0' + s else s := input + s;
    wire := PWire(wireStorage.at(getWireHash(s)));
    if wire <> nil then begin
      if test64(number, one64) then
        wire^.state_ := WireHigh
      else
        wire^.state_ := WireLow;
    end;
    shiftRight64(1, number);
  end;
end;

procedure resetWireLambda(const index: longint; const item: PItemType); far;
begin
  PWire(item)^.state_ := WireThreeState;
end;

procedure resetWires;
begin
  wireStorage.forEach(resetWireLambda);
end;

function part1(var input: Text):comp; far;
var result : Uint64_t;
    s      : string;
    i      : Integer;
    wire   : PWire;
begin
  parseCircuit(input);
  result := zero64;

  getNumberFromOutput(result);

  part1 := uint64ToComp(result);

  wireStorage.done;
  gateStorage.done;
end;

type TBrokenBits = set of 0..63;

function checkAddition: TBrokenBits;
var
  i: Integer;
  a, result : Uint64_t;
  failedBits : TBrokenBits;
begin
  failedBits := [];
  a := one64;
  for i:= 0 to 44 do begin (* The adder has only 45 bits ...*)
    resetWires;
    setNumberToInput(a, 'x');
    setNumberToInput(zero64, 'y');
    getNumberFromOutput(result);
    if not isEqual64(a, result) then begin 
        failedBits:= failedBits + [i];
        writeln('Failed at bit ', i, ' on x expected: ', Uint64ToStr(a), ' got: ', Uint64ToStr(result));
    end;

    resetWires;
    setNumberToInput(zero64, 'x');
    setNumberToInput(a, 'y');
    getNumberFromOutput(result);
        if not isEqual64(a, result) then begin 
        failedBits:= failedBits + [i];
        writeln('Failed at bit ', i, ' on y expected: ', Uint64ToStr(a), ' got: ', Uint64ToStr(result));
    end;

    resetWires;
    setNumberToInput(a, 'x');
    setNumberToInput(a, 'y');
    getNumberFromOutput(result);

    shiftLeft64(1, a);
        if not isEqual64(a, result) then begin 
        failedBits:= failedBits + [i];
        writeln('Failed at bit ', i, ' on carry expected: ', Uint64ToStr(a), ' got: ', Uint64ToStr(result));
    end;
  end;
  checkAddition := failedBits;
end;

procedure checkGates(it: PDeQueueIterator); far;
var g: PGate;
begin
  g := PGate(it^.at);
  g^.checkGate;
end;

procedure swapInputs(id1, id2: word);
var w1, w2: PWire;
    tmp: PGate;
begin
  w1 := PWire(wireStorage.at(id1));
  w2 := PWire(wireStorage.at(id2));

  if (w1 <> NIL) and (w2 <> NIL) then begin
    tmp := w1^.input_;
    w1^.setInput(w2^.input_);
    w2^.setInput(tmp);
  end else
    writeln('One of the wires does not exist');
end;


function part2(var input: Text):comp; far;
var output: Text;
    s,s2 : string;
    i      : Integer;
    wire   : PWire;
    failures: TBrokenBits;
begin
  parseCircuit(input);
  failures := checkAddition;

  assign(output, 'output.txt');
  rewrite(output);

  writeln(output,'flowchart LR');
  for i:= 63 downto 0 do
  begin
    str(i, s);
    if i < 10 then s:= 'z0' + s else s := 'z' + s;
    wire := PWire(wireStorage.at(getWireHash(s)));
    if wire <> nil then begin
        wire^.print(output);
        writeln(output, 'OUT_',i,'( Bit ',i,' )');
        if (i < 45) and (typeof(wire^.input_^) <> typeof(TXorGate)) then 
          writeln('Wire ', wire^.id_, ' has wrong input type');
    end;
  end;

  for i := 0 to 63 do begin
    if i in failures then begin
        writeln(output, 'style OUT_',i,' color:#FFFFFF, fill:#AA00FF, stroke:#AA00FF');
        writeln(output, 'style OUT_',i+1,' color:#FFFFFF, fill:#AA00FF, stroke:#AA00FF');
        writeln(output, 'style CONST_',i,' color:#FFFFFF, fill:#AA00FF, stroke:#AA00FF');
        writeln(output, 'style CONST_',i+45,' color:#FFFFFF, fill:#AA00FF, stroke:#AA00FF');
    end;
    
  end;
  close(output);
  gateStorage.forEach(checkGates);

  repeat
    write('Wire1: '); readln(s);
    write('Wire2: '); readln(s2);

    if (length(s) = 3) or (length(s2) = 3) then begin
      swapInputs(getWireHash(s), getWireHash(s2));
    end;
    writeln('--- Rechecking ---');
    checkAddition;
    for i:= 63 downto 0 do
    begin
      str(i, s);
      if i < 10 then s:= 'z0' + s else s := 'z' + s;
        wire := PWire(wireStorage.at(getWireHash(s)));
        if wire <> nil then begin
          if (i < 45) and (typeof(wire^.input_^) <> typeof(TXorGate)) then 
            writeln('Wire ', wire^.id_, ' has wrong input type');
        end;
    end;
    gateStorage.forEach(checkGates);
  until (length(s) <> 3) or (length(s2) <> 3);
  part2 := 0;
  
  wireStorage.done;
  gateStorage.done;
end;

begin
  runAoc(InputFileName, 24, part1, part2, nil, nil);
end.
