program testAtariASM;
(* This is a test program for Atari ASM code execution *)
uses stdint, cassert;

procedure shiftRight64(count: byte; var a: Uint64_t);
begin
asm
    move.l a, A0  ; Load address of a into A0
    moveq #0, D0  ; Clear D0
    move.b count, D0      ; Load count into D0 (lower 8 bits only)
    subq.b #1, D0  ; Decrement count to match the loop condition
    ; Load the data into D1 and D2
    
    ; Load the significant qword into D1
    move.l 4(A0), D1
    move.l 0(A0), D2 
    ror.w #8, D1 
    ror.w #8, D2
    swap D1
    swap D2
    ror.w #8, D1
    ror.w #8, D2
   
    @shift_loop:
    lsr.l #1, D1
    roxr.l #1, D2
    dbra D0, @shift_loop; Decrement D0 and loop if not zero
    ; Store the result back into a
    ror.w #8, D1
    ror.w #8, D2
    swap D1
    swap D2
    ror.w #8, D1
    ror.w #8, D2

    move.l D1, 4(A0)
    move.l D2, 0(A0)
end ['D0', 'D1', 'D2', 'A0'];
end;

const
    TestValue: Uint64_t = ($aa, $aa, $aa, $aa, $aa, $aa, $aa, $aa);
    ExpectedResult: Uint64_t = ($55, $55, $55, $55, $55, $55, $55, $55);
var a: Uint64_t;

begin
  a := TestValue; // Initialize with all bits set
  writeln(Uint64ToStr(a));
  shiftRight64(1, a); (* Shift right by 1 *)
  writeln(Uint64ToStr(a));
  writeln('Expected: ', Uint64ToStr(ExpectedResult));
  assert(isEqual64(a,ExpectedResult), 'Shift right by 1 failed');
  ReadLn;
end.