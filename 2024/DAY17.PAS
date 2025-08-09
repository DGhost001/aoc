program day17;
(*This is the implementation of the aoc24 day 17*)
(* https://adventofcode.com/2024/day/17 *)

uses aoc, stdint, cassert, utils, dequeue, uintitem, sort;
const InputFileName = 'INP\DAY17_IN.TXT';
const MaxByte  : Uint64_t = ($ff,0,0,0,0,0,0,0);
      MaxUint64: Uint64_t = ($ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff);

type TRegisterFile = record
        ipc : word; (* instruction pointer *)
        a   : Uint64_t; (* accumulator *)
        b   : Uint64_t; (* general purpose register *)
        c   : Uint64_t; (* general purpose register *)
    end;
    TInstructions = ( ADV, BXL, BST, JNZ, BXC, OUTP, BDV, CDV );
    TMemory = array[0..128] of byte; (* 128 3 bit Memory cells *)
    TPrintFunction = procedure(const value: byte);

procedure printToConsole(const value: byte); far;
begin
    write(value,',');
end;

function decodeInstruction(const reg: TRegisterFile; const mem: TMemory): TInstructions;
var s: string;
begin
  case mem[reg.ipc] of
    0: decodeInstruction := ADV; (* Division with combo Operands *)
    1: decodeInstruction := BXL; (* Bitwise XOR with Literal *)
    2: decodeInstruction := BST; (* Combo Operand modulo a stor B *)
    3: decodeInstruction := JNZ; (* Jump if Not Zero *)
    4: decodeInstruction := BXC; (* Bitwise XOR of B and C to B, ignores Operand *)
    5: decodeInstruction := OUTP; (* Output the combo Operand Modulo 8 *)
    6: decodeInstruction := BDV; (* Division with combo Operand to B *)
    7: decodeInstruction := CDV; (* Division with combo Operand to C *)
  else begin
    str(reg.ipc, s);
    assert(false, 'Illegal instruction at "' + s +'"');
  end; end;
end;

function executeInstruction(var reg: TRegisterFile;
                            const mem: TMemory;
                            const size : Byte;
                            const printFunc: TPrintFunction) : Boolean;
  procedure getLiteralValue(const reg: TRegisterFile; const mem: TMemory; var result: Uint64_t);
  begin
    fromLongInt64(mem[reg.ipc + 1] and $07, result); (* 3 bit literal value *)
  end;

  procedure getComboOperand(const reg: TRegisterFile; const mem: TMemory; var result: Uint64_t);
  var s: string;
  begin
    case (mem[reg.ipc + 1]  and $07) of
        0: fromLongInt64(0, result);
        1: fromLongInt64(1, result);
        2: fromLongInt64(2, result);
        3: fromLongInt64(3, result);
        4: result := reg.a;
        5: result := reg.b;
        6: result := reg.c;
    else begin
      str(reg.ipc + 1, s);
      assert(false, 'Illegal combo Operand at ' + s);
    end; end;
  end;

  procedure iADV(var reg: TRegisterFile; const mem: TMemory);
  var tmp : Uint64_t;
  begin
    getComboOperand(reg, mem, tmp);
    if isGreater64(tmp, MaxByte) then begin
      if reg.a[7] >= $80 then
        reg.a := MaxUint64
      else
        reg.a := zero64;
    end else
      if tmp[0] > 0 then shiftRight64(tmp[0], reg.a);
    inc(reg.ipc, 2);
  end;

  procedure iBXL(var reg: TRegisterFile; const mem: TMemory);
  var tmp : Uint64_t;
  begin
    getLiteralValue(reg, mem, tmp);
    xor64(reg.b, tmp);
    inc(reg.ipc, 2);
  end;

  procedure iBST(var reg: TRegisterFile; const mem: TMemory);
  var tmp : Uint64_t;
  begin
    getComboOperand(reg, mem, tmp);
    FillChar(reg.b, SizeOf(reg.b), 0);
    reg.b[0] := tmp[0] and $07; (* modulo 8 *)
    inc(reg.ipc, 2);
  end;

  procedure iJNZ(var reg: TRegisterFile; const mem: TMemory);
  var tmp : Uint64_t;
  begin
    getLiteralValue(reg, mem, tmp);
    if isNull64(reg.a) then begin
        inc(reg.ipc, 2);
    end else begin
        reg.ipc := tmp[0] and $07; (* jump to address *)
    end;
  end;

  procedure iBXC(var reg: TRegisterFile; const mem: TMemory);
  var tmp : Uint64_t;
  begin
    xor64(reg.b, reg.c);
    inc(reg.ipc, 2);
  end;

  procedure iBDV(var reg: TRegisterFile; const mem: TMemory);
  var tmp : Uint64_t;
  begin
    getComboOperand(reg, mem, tmp);
    if isGreater64(tmp, MaxByte) then begin
      if reg.a[7] >= $80 then
        reg.b := MaxUint64
      else
        reg.b := zero64;
    end else begin
      reg.b := reg.a;
      if tmp[0] > 0 then shiftRight64(tmp[0], reg.b);
    end;
    inc(reg.ipc, 2);
  end;

  procedure iCDV(var reg: TRegisterFile; const mem: TMemory);
  var tmp : Uint64_t;
  begin
    getComboOperand(reg, mem, tmp);
    if isGreater64(tmp, MaxByte) then begin
      if reg.a[7] >= $80 then
        reg.c := MaxUint64
      else
        reg.c := zero64;
    end else begin
      reg.c := reg.a;
      if tmp[0] > 0 then shiftRight64(tmp[0], reg.c);
    end;
    inc(reg.ipc, 2);
  end;

  procedure iOutp(var reg: TRegisterFile; const mem: TMemory; const printFunc: TPrintFunction);
  var tmp : Uint64_t;
  begin
    getComboOperand(reg, mem, tmp);
    printFunc(tmp[0] and $07); (* output the combo Operand Modulo 8 *)
    inc(reg.ipc, 2);
  end;

begin
  assert(reg.ipc and $01 = 0, 'Instruction pointer not aligned');
  if reg.ipc < size then begin
    case decodeInstruction(reg, mem) of
        ADV: iADV(reg, mem);
        BXL: iBXL(reg, mem);
        BST: iBST(reg, mem);
        JNZ: iJNZ(reg, mem);
        BXC: iBXC(reg, mem);
        OUTP: iOutp(reg, mem, printFunc);
        BDV: iBDV(reg, mem);
        CDV: iCDV(reg, mem);
    end;
  end;
  executeInstruction := reg.ipc < size;
end;

procedure loadProgram(var input: Text; var reg: TRegisterFile; var mem: TMemory; var size: Byte);
 procedure skipLabel(var input: Text);
 var c: char;
 begin
   repeat
     read(input, c);
   until (c=':') or (eof(input));
 end;
var tmp : array[0..127] of longint;
      i : Byte;
begin
  FillChar(reg, SizeOf(reg), 0);

  skipLabel(input); fromLongInt64(readLong(input), reg.a); (* load the initial value into the accumulator *)
  skipLabel(input); fromLongInt64(readLong(input), reg.b); (* load the initial value into register B *)
  skipLabel(input); fromLongInt64(readLong(input), reg.c); (* load the initial value into register C *)
  skipLabel(input);  size:= readLongArray(input, tmp);
  
  FillChar(mem, SizeOf(mem), 0);
  for i := 0 to size - 1 do
    mem[i] := tmp[i] and $07; (* only the lower 3 bits are used *)
end;

function part1(var input: Text):comp; far;
var reg: TRegisterFile;
    mem: TMemory;
    size: Byte;
begin
  loadProgram(input, reg, mem, size);
  while executeInstruction(reg, mem, size, printToConsole) do begin end;
  writeln;
  writeln('A: ', Uint64ToStr(reg.a));
  writeln('B: ', Uint64ToStr(reg.b));
  writeln('C: ', Uint64ToStr(reg.c));
  part1 := 0;
end;

var printedValue : byte;
procedure printToGlobal(const value: byte); far;
begin
  printedValue := value;
end;


procedure reverseRegisterA(const startValue: Uint64_t;
                           const target: byte;
                           const mem: TMemory;
                           const size: Byte;
                           var candidates: PDeQueue);
var reg: TRegisterFile;
    i  : longint;
begin
  i:= 0;
  for i:=0 to 7 do begin
    FillChar(reg, SizeOf(reg), 0);
    reg.a := startValue;
    add64LongInt(reg.a, i);
    printedValue := $ff;
    while printedValue = $ff do executeInstruction(reg, mem, size, printToGlobal);
    if printedValue = target then candidates^.pushBack(new(PUintItem, init(reg.a)));
  end;
end;

function part2(var input: Text):comp; far;
var mem: TMemory;
    size: Byte;
    reg: TRegisterFile;
    i  : integer;
    c1, c2: PDeQueue;
begin
  loadProgram(input, reg, mem, size);
  FillChar(reg, SizeOf(reg), 0); (* reset the registers *)
  c1 := new(PDeQueue, init);
  c2 := new(PDeQueue, init);

  c1^.pushBack(new(PUintItem, init(reg.a))); (* set a starting value *)

  for i:= size -1 downto 0 do begin
    while c1^.size > 0 do begin
      reg.a := PUintItem(c1^.front)^.value_;
      c1^.popFront;
      shiftLeft64(3, reg.a); (* shift the value left by 3 bits *)
      reverseRegisterA(reg.a, mem[i], mem, size, c2);
    end;
    assert(c2^.size > 0, 'No candidates found');

    c1^.dispose;
    c1 := c2;
    c2 := new(PDeQueue, init);
  end;

  sortQueue(c1);
  reg.a := PUintItem(c1^.front)^.value_;

  c1^.dispose;
  c2^.dispose;
  part2 := uint64ToComp(reg.a);

  while executeInstruction(reg, mem, size, printToConsole) do begin end;
  writeln;
end;

begin
  runAoc(InputFileName, 17, part1, part2, nil, nil);
end.
