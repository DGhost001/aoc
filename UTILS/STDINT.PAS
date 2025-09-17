unit STDINT;

interface

    type Uint64_t = array[0..7] of byte;
         Uint32_t = array[0..3] of byte;
         Uint16_t = word;
         Uint8_t  = byte;

    const neg64 : Uint64_t = ($ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);
          zero64: Uint64_t = ($00,$00,$00,$00,$00,$00,$00,$00);
          one64 : Uint64_t = ($01,$00,$00,$00,$00,$00,$00,$00);


    procedure shiftLeft64(count: byte; var a: Uint64_t);
    procedure shiftRight64(count: byte; var a: Uint64_t); (* a := a shr count *)

    procedure rotateLeft64(count: byte; var a: Uint64_t); (* a:= a rol c *)
    procedure rotateLeft32(count: byte; var a: Uint32_t);

    procedure xor64(var a,b: Uint64_t);                   (* a:= a xor b *)
    procedure xor32(var a,b: Uint32_t);

    procedure and64(var a: Uint64_t; const b: Uint64_t);                   (* a:= a and b *)
    procedure or64(var a: Uint64_t; const b: Uint64_t);                    (* a:= a or b *)
    function test64Bit(const a: Uint64_t; const b: Uint64_t): boolean;          (* (a and b) <> 0 *)

    procedure add64(var a,b: Uint64_t);                   (* a:= a + b *)
    procedure add64LongInt(var a: Uint64_t; const b: longint);

    procedure add32(var a,b: Uint32_t);

    procedure sub64(var a,b: Uint64_t);                   (* a:= a - b *)
    procedure sub64LongInt(var a : Uint64_t; const b : longint);

    procedure sub32(var a,b: Uint32_t);

    procedure mul64(var a: Uint64_t; const b: Uint64_t);                   (* a:= a * b *)
    procedure mul64LongInt(var a: Uint64_t; const b: longint);

    procedure div64(var a, b, r : Uint64_t);              (* a:= a div b, r:= a mod b *)

    function isNull64(const a: Uint64_t): boolean;          (* a == 0 *)
    function isNull32(var a: Uint32_t): boolean;

    function isGreater64(const a,b: Uint64_t): boolean;     (* a > b  *)
    function isGreater32(var a,b: Uint32_t): boolean;

    function isLess64(const a,b: Uint64_t):boolean;         (* a < b  *)
    function isLess32(var a,b: Uint32_t): boolean;

    function isEqual64(const a,b: Uint64_t): boolean;       (* a == b *)
    function isEqual32(var a,b: Uint32_t): boolean;

    procedure fromLongInt64(i : LongInt; var a: Uint64_t);
    procedure fromLongInt32(i : LongInt; var a: Uint32_t);

    function  toLongInt64(a: Uint64_t): LongInt;
    function  toLongInt32(a: Uint32_t): LongInt;

    function strToUint64(s: string; var a : Uint64_t): boolean;
    function Uint64ToStr(var a: Uint64_t): string;

    procedure min64(var a,b,c : Uint64_t);
    procedure max64(var a,b,c : Uint64_t);

    procedure uint64FromComp(const a: comp; var b: Uint64_t);
    function uint64ToComp(var b: Uint64_t) : comp;

    function ilog10(const a : Uint64_t) : integer;
    procedure pow10(const n : integer; var a : uint64_t);

implementation
uses cassert;

{$IFNDEF FPC}
procedure shiftLeft64; assembler;
asm
  les di, [a]
  xor cx, cx
  mov cl, count
  @1:
     clc
     rcl WORD [es: di + 0],1
     rcl WORD [es: di + 2],1
     rcl WORD [es: di + 4],1
     rcl WORD [es: di + 6],1
  loop @1
end;

procedure shiftRight64; assembler;
asm
  les di, [a]
  xor cx, cx
  mov cl, count
  @1:  
    sar WORD [es: di + 6],1
    rcr WORD [es: di + 4],1
    rcr WORD [es: di + 2],1
    rcr WORD [es: di + 0],1
  loop @1
end;

procedure rotateLeft64; assembler;
asm
    (*Setup the pointer to the array*)
    les di, [a]

    (* Load the count into the CX register *)
    xor cx, cx
    xor bx, bx
    mov cl, count
    mov bl, cl
    and bl, 0f8h
    and cl, 07h

    jz @shuffle

    mov ax, [es:di+6] (* Get the highest bits in ax, for looping the carry *)
    @1:
        cmp ah, 80h (* Setup the carray correctly *)
        cmc
        rcl WORD [es: di + 0],1
        rcl WORD [es: di + 2],1
        rcl WORD [es: di + 4],1
        rcl ax               ,1
    loop @1
    mov [es:di + 6], ax (* Save the highest bits also ... *)

    @shuffle:

    mov si, bx

    mov ax, [es: di + 0]
    mov bx, [es: di + 2]
    mov cx, [es: di + 4]
    mov dx, [es: di + 6]

    @56:
    cmp si,56
    jl @48
                     (* dh dl ch cl bh bl ah al *)
        xchg al, dh  (*  x  -  -  -  -  -  -  - *)
        xchg bl, ah  (*  x  -  -  -  -  -  x  - *)
        xchg cl, bh  (*  x  -  -  -  x  -  x  - *)
        xchg dl, ch  (*  x  -  x  -  x  -  x  - *)

        xchg al, dl  (*  x  x  x  -  x  -  x  - *)
        xchg al, cl  (*  x  -  x  x  x  x  x  - *)
        xchg al, bl  (*  x  x  x  x  x  x  x  x *)
        jmp @0
    @48:
    cmp si,48
    jl @40
        xchg ax, dx
        xchg ax, cx
        xchg ax, bx

        jmp @0
    @40:
    cmp si,40
    jl @32
                     (* dh dl ch cl bh bl ah al *)
        xchg al, ch  (*  -  -  x  -  -  -  -  - *)
        xchg bl, dh  (*  x  -  x  -  -  -  -  - *)
        xchg cl, ah  (*  x  -  x  -  -  -  x  - *)
        xchg dl, bh  (*  x  -  x  -  x  -  x  - *)

        xchg al, bl  (*  x  -  x  -  x  x  x  - *)
        xchg al, cl  (*  x  -  x  x  x  x  x  - *)
        xchg al, dl  (*  x  x  x  x  x  x  x  x *)
        jmp @0
    @32:
    cmp si,32
    jl @24
        xchg ax, cx
        xchg bx, dx
        jmp @0
    @24:
    cmp si,24
    jl @16
        (* al -> bh, ah -> cl, bl -> ch, bh -> dl, cl -> dh, dl-> ah, dh -> al *)
                     (* dh dl ch cl bh bl ah al *)
        xchg al, bh  (*  -  -  -  -  x  -  -  - *)
        xchg bl, ch  (*  -  -  x  -  x  -  -  - *)
        xchg cl, dh  (*  x  -  x  -  x  -  -  - *)
        xchg dl, ah  (*  x  -  x  -  x  -  x  - *)

        xchg al, dl  (*  x  x  x  -  x  -  x  - *)
        xchg al, cl  (*  x  x  x  x  x  -  x  - *)
        xchg al, bl  (*  x  x  x  x  x  x  x  x *)

        jmp @0
    @16:
    cmp si,16
    jl @8
        xchg ax, bx
        xchg ax, cx
        xchg ax, dx

        jmp @0
    @8:
        cmp si,  8
        jl @0
        (* al -> ah, ah -> bl, bl -> bh, bh -> cl, ch -> dl, dl -> dh, dh -> al*)
        xchg al, ah
        xchg bl, bh
        xchg cl, ch
        xchg dl, dh

        xchg al, bl
        xchg al, cl
        xchg al, dl
    @0:
        mov [es: di + 0], ax
        mov [es: di + 2], bx
        mov [es: di + 4], cx
        mov [es: di + 6], dx
end;

procedure rotateLeft32; assembler;
asm
    (*Setup the pointer to the array*)
    les di, [a]

    (* Load the count into the CX register *)
    xor cx, cx
    xor bx, bx
    mov cl, count
    mov bl, cl
    and bl, 0f8h
    and cl, 07h

    jz @shuffle

    mov ax, [es:di+2] (* Get the highest bits in ax, for looping the carry *)
    @1:
        cmp ah, 80h (* Setup the carray correctly *)
        cmc
        rcl WORD [es: di + 0],1
        rcl ax               ,1
    loop @1
    mov [es:di + 2], ax (* Save the highest bits also ... *)

    @shuffle:

    mov si, bx

    mov ax, [es: di + 0]
    mov bx, [es: di + 2]

    cmp si,24
    jl @16
              (* bl ah al bh  *)
              (* v  v  v  v   *)
              (* ah al bh bl  *)
          xchg bl, ah
          xchg al, bh
          xchg al, bl
        jmp @0
    @16:
    cmp si,16
    jl @8
        xchg ax, bx
        jmp @0
    @8:
        cmp si,  8
        jl @0
        (* al -> ah, ah -> bl, bl -> bh *)
        xchg al, ah
        xchg bl, bh
        xchg al, bl
    @0:
        mov [es: di + 0], ax
        mov [es: di + 2], bx
end;

procedure xor64(var a,b: Uint64_t);assembler;
asm
    push ds (* DS is the only register we need to save *)
    (* Load a and b into es:si and ds:di *)
    les di, [a]
    lds si, [b]

    lodsw
    xor [es:di + 0], ax
    lodsw
    xor [es:di + 2], ax
    lodsw
    xor [es:di + 4], ax
    lodsw
    xor [es:di + 6], ax

    pop ds
end;

procedure xor32;assembler;
asm
    push ds (* DS is the only register we need to save *)
    (* Load a and b into es:si and ds:di *)
    les di, [a]
    lds si, [b]

    lodsw
    xor [es:di + 0], ax
    lodsw
    xor [es:di + 2], ax

    pop ds
end;


procedure add64; assembler;
asm
   push ds
   les di,[a]
   lds si,[b]

   lodsw
   add [es:di + 0], ax
   lodsw
   adc [es:di + 2], ax
   lodsw
   adc [es:di + 4], ax
   lodsw
   adc [es:di + 6], ax

   pop ds
end;

procedure add32; assembler;
asm
   push ds
   les di,[a]
   lds si,[b]

   lodsw
   add [es:di + 0], ax
   lodsw
   adc [es:di + 2], ax

   pop ds
end;

procedure sub64;assembler;
asm
   push ds
   les di,[a]
   lds si,[b]

   lodsw
   sub [es:di + 0], ax
   lodsw
   sbb [es:di + 2], ax
   lodsw
   sbb [es:di + 4], ax
   lodsw
   sbb [es:di + 6], ax

   pop ds
end;

procedure sub32;assembler;
asm
   push ds
   les di,[a]
   lds si,[b]

   lodsw
   add [es:di + 0], ax
   lodsw
   sub [es:di + 2], ax

   pop ds
end;



function isNull64(const a: Uint64_t): boolean; assembler; (* a == 0 *)
asm
    push ds

    lds si,[a]
    xor bx,bx

    lodsw
    or bx, ax
    lodsw
    or bx, ax
    lodsw
    or bx, ax
    lodsw
    or bx, ax

    lahf       (* Copy FLAGS => AH*)
    shl ah,1   (* Get ZF in CF *)
    shl ah,1
    sbb ax,ax  (* IF CF = 1 THEN ax = 0xffff else ax = 0 *)
    and ax,1

    pop ds
end;

function isNull32; assembler; (* a == 0 *)
asm
    push ds

    lds si,[a]
    xor bx,bx

    lodsw
    or bx, ax
    lodsw
    or bx, ax

    lahf       (* Copy FLAGS => AH*)
    shl ah,1   (* Get ZF in CF *)
    shl ah,1
    sbb ax,ax  (* IF CF = 1 THEN ax = 0xffff else ax = 0 *)
    and ax,1

    pop ds
end;
{ not working as planned
function isGreater64; assembler;
asm
    push ds

    les di,[a]
    lds si,[b]

    xor bx,bx

    lodsw
    sub ax, WORD [es:di + 0]
    lodsw
    sbb ax, WORD [es:di + 2]
    lodsw
    sbb ax, WORD [es:di + 4]
    lodsw
    sbb ax, WORD [es:di + 6]

    shl ax,1  (* Push the Sign into CF *)
    sbb ax,ax (* if CF = 1 then ax = 0xffff else ax = 0 *)
    and ax,1

    pop ds
end;
}
function isGreater32; assembler;
asm
    push ds

    les di,[a]
    lds si,[b]

    xor bx,bx

    lodsw
    sub ax, WORD [es:di + 0]
    lodsw
    sbb ax, WORD [es:di + 2]

    shl ax,1  (* Push the Sign into CF *)
    sbb ax,ax (* if CF = 1 then ax = 0xffff else ax = 0 *)
    and ax,1

    pop ds
end;

function isEqual64; assembler;
asm
  push ds
  les di,[a]
  lds si,[b]

  mov cx,4

  repe cmpsw

  lahf       (* Copy FLAGS => AH*)
  shl ah,1   (* Get ZF in CF *)
  shl ah,1
  sbb ax,ax  (* IF CF = 1 THEN ax = 0xffff else ax = 0 *)
  and ax,1

  pop ds
end;

function isEqual32; assembler;
asm
  push ds
  les di,[a]
  lds si,[b]

  mov cx,2

  repe cmpsw

  lahf       (* Copy FLAGS => AH*)
  shl ah,1   (* Get ZF in CF *)
  shl ah,1
  sbb ax,ax  (* IF CF = 1 THEN ax = 0xffff else ax = 0 *)
  and ax,1

  pop ds
end;
{$ELSE}
procedure swap(var a,b: byte);
var tmp : byte;
begin
  tmp := a;
  b   := a;
  a   := tmp;
end;

procedure rotateLeft64(count: byte; var a: Uint64_t); (* a:= a rol c *)
  procedure rotateFullByte;
  var tmp : byte;
  begin
    tmp := a[7];
    swap(tmp, a[0]); swap(tmp, a[1]); swap(tmp, a[2]); swap(tmp, a[3]);
    swap(tmp, a[4]); swap(tmp, a[5]); swap(tmp, a[6]);
    a[7]:=tmp;
  end;

  procedure rotateBits(count: byte);
    function rotate(count: byte; var data: byte; carry : byte): byte;
    var tmp : word;
    begin
     tmp := data;
     tmp := tmp shl count;
     data := tmp or carry;
     rotate := (tmp shr 8) and $ff;
    end;

  var carry, tmp : byte;
  begin
    tmp := a[7];
    carry := rotate(count, tmp, 0);
    carry := rotate(count, a[0], carry);
    carry := rotate(count, a[1], carry);
    carry := rotate(count, a[2], carry);
    carry := rotate(count, a[3], carry);
    carry := rotate(count, a[4], carry);
    carry := rotate(count, a[5], carry);
    carry := rotate(count, a[6], carry);
    rotate(count, a[7], carry);
  end;

var bits, bytes : byte;
begin
  bits := count and 7;
  bytes:= count shr 3;

  rotateBits(bits);
  while bytes > 0 do begin
   rotateFullByte;
   dec(bytes)
  end;
end;

procedure rotateLeft32(count: byte; var a: Uint32_t);
begin
  halt(-1); (*Not implemented yet...*)
end;

procedure xor64(var a,b: Uint64_t);                   (* a:= a xor b *)
begin
  a[0] := a[0] xor b[0]; a[1] := a[1] xor b[1]; a[2] := a[2] xor b[2]; a[3] := a[3] xor b[3];
  a[4] := a[4] xor b[4]; a[5] := a[5] xor b[5]; a[6] := a[6] xor b[6]; a[7] := a[7] xor b[7];
end;

procedure xor32(var a,b: Uint32_t);
begin
   halt(-1); (*Not implemented yet...*)
end;

procedure add64(var a,b: Uint64_t);                   (* a:= a + b *)
 function add(var a: byte; b: byte; carry: byte): byte;
 var tmp : word;
 begin
   tmp := a; inc(tmp,b); inc(tmp,carry);
   a := tmp and $ff;
   add := (tmp shr 8) and $ff;
 end;
var carry : byte;
begin
  carry := add(a[0], b[0], 0 );
  carry := add(a[1], b[1], carry );
  carry := add(a[2], b[2], carry );
  carry := add(a[3], b[3], carry );
  carry := add(a[4], b[4], carry );
  carry := add(a[5], b[5], carry );
  carry := add(a[6], b[6], carry );
  carry := add(a[7], b[7], carry );
end;

procedure add32(var a,b: Uint32_t);
begin
   halt(-1); (*Not implemented yet...*)
end;

procedure sub64(var a,b: Uint64_t);                   (* a:= a - b *)
var   c : Uint64_t;
begin
  c:= b;
  xor64(c,neg64);
  add64(c,one64);
  add64(a,c);
end;

procedure sub32(var a,b: Uint32_t);
begin
   halt(-1); (*Not implemented yet...*)
end;

function isNull64(const a: Uint64_t): boolean;          (* a == 0 *)
begin
  isNull64 := (a[0] = 0) and (a[1] = 0) and (a[2] = 0) and (a[3] = 0) and
              (a[4] = 0) and (a[5] = 0) and (a[6] = 0) and (a[7] = 0);

end;

function isNull32(var a: Uint32_t): boolean;
begin
   halt(-1); (*Not implemented yet...*)
end;


function isGreater32(var a,b: Uint32_t): boolean;
begin
   halt(-1); (*Not implemented yet...*)
end;

function isEqual64(const a,b: Uint64_t): boolean;       (* a == b *)
begin
  isEqual64 := (a[0] = b[0]) and (a[1] = b[1]) and (a[2] = b[2]) and (a[3] = b[3]) and
               (a[4] = b[4]) and (a[5] = b[5]) and (a[6] = b[6]) and (a[7] = b[7]);
end;

function isEqual32(var a,b: Uint32_t): boolean;
begin
   halt(-1); (*Not implemented yet...*)
end;

{$IFDEF cpum68k}
procedure shiftLeft64(count: byte; var a: Uint64_t);
begin  
asm
    move.l a, A0  ; Load address of a into A0
    moveq #0, D0  ; Clear D0
    move.b count, D0      ; Load count into D0 (lower 8 bits only)
    sub.b #1, D0  ; Decrement count to match the loop condition
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
    ; Shift the data
    @shift_loop:
    lsl.l #1, D2
    roxl.l #1, D1
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
end['D0', 'D1', 'D2', 'A0'];
end;


procedure shiftRight64(count: byte; var a: Uint64_t);
begin
asm
    move.l a, A0  ; Load address of a into A0
    moveq #0, D0  ; Clear D0
    move.b count, D0      ; Load count into D0 (lower 8 bits only)
    subq.b #1, D0         ; Adjust for DBRA loop (runs count times)
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
    asr.l #1, D1
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

{$ELSE}
procedure shiftLeft64(count: byte; var a: Uint64_t);
var buffer, carry : word;
                i : integer;
begin
  while count >= 8 do begin
    a[7]  := a[6]; a[6] := a[5]; a[5] := a[4]; a[4] := a[3];
    a[3]  := a[2]; a[2] := a[1]; a[1] := a[0];
    a[0]  := 0;
    dec(count,8);
  end;

  while count > 0 do begin
    carry := 0;
    for i:= 0 to 7 do begin
      buffer := a[i];
      buffer := buffer shl 1;
      a[i] := (buffer and $ff) or carry;
      carry := buffer shr 7;
    end;
    dec(count);
  end;
end;

procedure shiftRight64(count: byte; var a: Uint64_t);
begin
  while count >= 8 do begin
    a[0]  := a[1]; a[1] := a[2]; a[2] := a[3]; a[3] := a[4];
    a[4]  := a[5]; a[5] := a[6]; a[6] := a[7];
    a[7]  := 0;
    dec(count,8);
  end;

  while count > 0 do begin
    carry := 0;
    for i:= 7 downto 0 do begin
      buffer := a[i];
      a[i] := (a[i] shr 1) or carry;
      carry := (buffer and 1) shl 7;
    end;
    dec(count);
  end;
end;
{$ENDIF}
{$ENDIF}

  procedure and64(var a: Uint64_t; const b: Uint64_t);
  begin
    a[0] := a[0] and b[0];
    a[1] := a[1] and b[1];
    a[2] := a[2] and b[2];
    a[3] := a[3] and b[3];
    a[4] := a[4] and b[4];
    a[5] := a[5] and b[5];
    a[6] := a[6] and b[6];
    a[7] := a[7] and b[7];
  end;
  
  procedure or64(var a: Uint64_t; const b: Uint64_t); 
  begin
    a[0] := a[0] or b[0];
    a[1] := a[1] or b[1];
    a[2] := a[2] or b[2];
    a[3] := a[3] or b[3];
    a[4] := a[4] or b[4];
    a[5] := a[5] or b[5];
    a[6] := a[6] or b[6];
    a[7] := a[7] or b[7];
  end;
  
  function test64Bit(const a: Uint64_t; const b: Uint64_t): boolean;
  begin
    test64Bit := ((a[0] and b[0]) <> 0) or ((a[1] and b[1]) <> 0) or
                 ((a[2] and b[2]) <> 0) or ((a[3] and b[3]) <> 0) or
                 ((a[4] and b[4]) <> 0) or ((a[5] and b[5]) <> 0) or
                 ((a[6] and b[6]) <> 0) or ((a[7] and b[7]) <> 0);
  end;


function isGreater64(const a,b: Uint64_t): boolean;     (* a > b  *)
var result: boolean;
       pos: integer;
begin
  result := true;
  pos:= 7;
  while result and (pos >=0) do begin
    if a[pos] = b[pos] then dec(pos) else
    if a[pos] > b[pos] then break else
    result := false;
  end;
  isGreater64 := result and (pos >= 0);
end;

procedure mul64x8(var result, a: Uint64_t; b: byte);
var tmp    : Uint64_t;
    i      : integer;
    m      : word;
begin
  result := zero64;
  for i:= 0 to 7 do begin
    m := a[i];
    m := m * b;
    tmp := zero64;
    tmp[i] := m and $ff;
    if i < 7 then tmp[i+1] := (m shr 8) and $ff;
    add64(result, tmp);
  end;
end;
{$IFNDEF FPC}
procedure mul64(var a:uint64_t; const b : uint64_t);
procedure mulx16(var   a: uint64_t;
                 const b: word);
(*This sub function is required, as there is no i32 = i16*i16 multiplication*)
function imul(const a,b : word) : longint; assembler;
asm
  mov ax, [a]
  mov dx, [b]
  mul dx
end;

var m      : longint;
    result : uint64_t;
    tmp    : uint64_t;
    a1     : array[0..3] of word absolute a;
    t1     : array[0..3] of word absolute tmp;
    m1     : array[0..1] of word absolute m;
begin
   result := zero64;
   tmp    := zero64;

   m := imul(a1[0], b);
   t1[0] := m1[0];
   t1[1] := m1[1];
   add64(result, tmp);
   t1[0] := 0;

   m := imul(a1[1], b);
   t1[1] := m1[0];
   t1[2] := m1[1];
   add64(result, tmp);
   t1[1] := 0;

   m := imul(a1[2], b);
   t1[2] := m1[0];
   t1[3] := m1[1];
   add64(result, tmp);
   t1[2] := 0;

   m := imul(a1[3], b);
   t1[3] := m1[0];
   add64(result, tmp);

   a:= result;
end;
var tmp    : uint64_t;
    result : uint64_t;
    b1     : array[0..3] of word absolute b;
    t1     : array[0..3] of word absolute tmp;
begin
  result := a;
  mulx16(result, b1[0]);

  tmp := a;
  mulx16(tmp, b1[1]);
  t1[3] := t1[2]; t1[2] := t1[1]; t1[1] := t1[0]; t1[0] := 0;
  add64(result, tmp);

  tmp := a;
  mulx16(tmp, b1[2]);
  t1[3] := t1[1]; t1[2] := t1[0]; t1[1] := 0; t1[0] := 0;
  add64(result, tmp);

  tmp := a;
  mulx16(tmp, b1[3]);
  t1[3] := t1[0]; t1[2] := 0; t1[1] := 0; t1[0] := 0;
  add64(result, tmp);

  a:= result;
end;
{$ELSE}
procedure mul64(var a :Uint64_t; const b: Uint64_t);
var i,j    : integer;
    result : Uint64_t;
    tmp    : Uint64_t;
begin
  result := zero64;
  for i:=0 to 7 do begin
    mul64x8(tmp,a,b[i]);
    for j:=7 downto 0 do begin
      if j+i <=7 then tmp[j+i]:=tmp[j];
      if j < i then tmp[j] := 0;
    end;
    add64(result, tmp);
  end;
  a:= result;
end;
{$ENDIF}
procedure divmnu(var q,r: uint64_t; u, v : uint64_t);

  (* Helper to get the number of leeding zeros *)
  function nlz(x : byte) : byte;
  var n : byte;
      y : byte;
  begin
    n := 8;

    y := x shr 4; if( y <> 0) then begin dec(n,4); x:= y; end;
    y := x shr 2; if( y <> 0) then begin dec(n,2); x:= y; end;
    y := x shr 1; if( y <> 0) then nlz := n - 2 else nlz := n - x;
  end;

var   vn             : uint64_t; (* Normalized u and v *)
      un             : array[0..8] of byte;
      qHat           : word;     (* Estimate of the quotient *)
      rHat           : word;     (* Reminder *)
      p              : word;     (* Product of two numbers *)
      tmp            : word;
      s,sHat,i,j,t,k,m,n,t1  : integer;  (* Looping Counters *)
      a,b            : byte;
begin
  m:=HIGH(u) + 1;
  n:=HIGH(v) + 1;
  (* Cleanout the result buffer *)
  q:= zero64;
  r:= zero64;

  (* Find the highest non zero part *)
  while (m > 0) and (u[m - 1] = 0) do dec(m);
  while (n > 0) and (v[n - 1] = 0) do dec(n);

  if (n = 0) then runError(200); (* Division by 0 is bad *)
  if (n > m) then exit;          (* if n > m the result is 0 *)

  if n = 1 then begin            (* Single digit divisor is a special case*)
                                 (* handle it here *)
     k := 0;
     for j:= m -1 downto 0 do begin
       tmp  := ((k shl 8) or u[j]);
       q[j] := tmp div v[0];
       k    := tmp mod v[0];
     end;
     r[0] := k and $ff;          (* k can never be > 255, so we don't loose anything by converting it here *)
  end else begin                 (* We have always a divisor with more than 1 digit *)
    s    := nlz(v[n-1]);         (* We need the number of bits to shift left, so that the highest bit of v is set *)
    shat := 8 - s;
    vn := v;
    rotateLeft64(s,vn);

    (* Shift left u, therefor un can have up to 8 bits more than u *)
    un[m] := u[m - 1] shr shat;
    for i:= m - 1 downto 1 do begin
      un[i] := ((u[i] shl s) and $ff) or ((u[i-1] shr shat) and $ff);
    end;
    un[0] := (u[0] shl s) and $ff;

    (* Main division is here *)
    for j := m - n downto 0 do begin
      tmp  := (un[j + n] shl 8) or (un[j + n - 1]);
      qhat := tmp div vn[n - 1];
      rhat := tmp mod vn[n - 1];

      repeat
        if (qhat >= 256) or (qhat * vn[n-2] > ((rhat shl 8) or (un[j+n-2]))) then begin
          dec(qhat);
          inc(rhat, vn[n-1]);
        end else break;
      until rhat >= 256;

      (* Multiply and subtract *)
      k:= 0;
      for i:=0 to n-1 do begin
        p := qhat * vn[i];
        t := un[i+j] - k - (p and $ff);
        un[i+j] := (t and $ff);
        k := ((p shr 8) and $ff) - (shortInt(t shr 8));
      end;

      q[j] := qhat;


      t1:= un[j+n] - k;
      if t1 < 0 then begin
        dec(q[j]);
        k := 0;
        for i:= 0 to n-1 do begin
          t := un[i+j] + vn[i] + k;
          un[i+j] := t;
          k := t shr 8;
        end;
        un[j+n] := (t1 + k) and $ff;
      end else
        un[j+n] := t1 and $ff;
    end;
    for i:= 0 to n-1 do begin
      r[i] := (un[i] shr s) or ( (un[i+1] shl shat) and $ff);
    end;
  end;
end;
{$IFNDEF OLD_DIV}
procedure div64(var a,b,r :Uint64_t);
var q : Uint64_t;
begin
  divmnu(q,r,a,b);
  a:=q;
end;


{$ELSE}
procedure div64(var a, b, r : Uint64_t);
 function guessANumber(var a, b: Uint64_t): byte;
 var high, low, center : word;
     tmp : Uint64_t;
 begin
   high := $ff;
   low  := $00;

   while low + 1 < high do begin
     center := (high + low) shr 1;
     mul64x8(tmp,b,center);
     if isGreater64(tmp,a) then
       high := center
     else if isGreater64(a,tmp) then
       low  := center
     else begin
       low  := center;
       high := center;
     end;
   end;
   mul64x8(tmp,b,high);
   if isGreater64(a,tmp) then
    guessANumber := high
   else begin
    mul64x8(tmp,b,low);
    if isGreater64(a,tmp) or isEqual64(a,tmp) then
     guessANumber := low
    else
     guessANumber := low - 1;
   end;
 end;

var i,j,k  : integer;
    tmp,tmp2  : Uint64_t;
begin
  (* Check for the easy cases of devision *)
  if isNull64(b) then runError(200); (* Division by 0 *)
  if isNull64(a) then
     r:= zero64
  else
  if isGreater64(b,a) then begin
    r:=a;
    a:= zero64;
  end else begin
    i:= 7;
    j:= 7;
    r:= a;
    a:= zero64;
    while b[i] = 0 do dec(i); (* Find the most significant byte *)
    while r[j] = 0 do dec(j);

    while j >= i do begin
      tmp := zero64;
      for k:=0 to i do
        tmp[k] := r[j-i+k];
      while isGreater64(b,tmp) do begin
        dec(j);
        if j < i then break; (* No further devision possible *)
        for k:=0 to i+1 do
        tmp[k] := r[j-i+k];
      end;
      if i <= j then begin
        a[j-i] := guessANumber(tmp,b);
        mul64x8(tmp2,b,a[j-i]);
        tmp := zero64;
        for k:=0 to i+1 do
         if (j - i + k) < 8 then
          tmp[j - i + k]:=tmp2[k];
        sub64(r,tmp);
      end;
    end;
  end;
end;
{$ENDIF}

function isLess64;
begin
    isLess64 := isGreater64(b,a);
end;

function isLess32;
begin
    isLess32 := isGreater32(b,a);
end;


procedure fromLongInt64;
begin
    a[0] := byte(i); i := i shr 8;
    a[1] := byte(i); i := i shr 8;
    a[2] := byte(i); i := i shr 8;
    a[3] := byte(i);
    if i < 0 then begin
        a[4] := $ff;
        a[5] := $ff;
        a[6] := $ff;
        a[7] := $ff;
    end else begin
        a[4] := $0;
        a[5] := $0;
        a[6] := $0;
        a[7] := $0;
    end;
end;

procedure fromLongInt32;
begin
    a[0] := i and $ff;
    a[1] := (i shr 8) and $ff;
    a[2] := (i shr 16) and $ff;
    a[3] := (i shr 24) and $ff;
end;

function  toLongInt64;
var result : LongInt;
begin
    toLongInt64:= (LongInt(a[3]) shl 24) +
                 (LongInt(a[2]) shl 16) +
                 (LongInt(a[1]) shl 8) +
                  a[0];
end;

function  toLongInt32;
var result : LongInt;
begin
    toLongInt32:= (LongInt(a[3]) shl 24) +
                 (LongInt(a[2]) shl 16) +
                 (LongInt(a[1]) shl 8) +
                  a[0];
end;

function strToUint64(s: string; var a : Uint64_t): boolean;
const ten : Uint64_t = ($a,0,0,0,0,0,0,0);
var i,j : integer;
    tmp : Uint64_t;
begin
  j := 0;
  tmp := zero64;
  a:=zero64;
  for i:= 1 to ord(s[0]) do begin
    if (s[i] = ' ') and (j <> 0) then break
    else if (s[i] =  ' ') then continue
    else if (s[i] in ['0'..'9']) then begin
      inc(j);
      mul64(a, ten);
      tmp[0] := ord(s[i]) - ord('0');
      add64(a, tmp);
    end else break;
  end;
  strToUint64 := j > 0;
end;

function Uint64ToStr(var a: Uint64_t): string;
const ten : Uint64_t = ($a,0,0,0,0,0,0,0);
var result,reverse : string;
         i : integer;
       tmp : Uint64_t;
         r : Uint64_t;
begin
  tmp := a;

  if isNull64(a) then
   Uint64ToStr := '0'
  else begin
   i:= 0;
   while(not IsNull64(tmp)) do begin
     inc(i);
     div64(tmp, ten, r);
     reverse[i] := chr(r[0] + ord('0'));
   end;

   reverse[0]:=chr(i);
   result[0]:= reverse[0];
   for i:=1 to ord(reverse[0]) do
     result[i]:=reverse[ord(reverse[0]) - i + 1];
   Uint64ToStr := result;
  end;
end;

procedure min64(var a,b,c : Uint64_t);
begin
  if isLess64(a,b) then c:= a else c:= b;
end;

procedure max64(var a,b,c : Uint64_t);
begin
  if isGreater64(a,b) then c:= a else c:= b;
end;

{$IFDEF ATARI}

(*
 *  The ATARI ST has a Motorola 68k and is therefor a big endian system.
 *  Our uint64_t is little endian, so we need to swap the byte order
 *  when converting from/to comp.
 *)

procedure swapByteOrder(var a: Uint64_t);
  procedure swap(var a, b: byte);
  var tmp : byte;
  begin
    tmp := a;
    a   := b;
    b   := tmp;
  end;
begin
  Swap(a[0], a[7]);
  Swap(a[1], a[6]);
  Swap(a[2], a[5]);
  Swap(a[3], a[4]);
end;

procedure uint64FromComp(const a: comp; var b: Uint64_t);
type PUint64_t = ^Uint64_t;
begin
 b := PUint64_t(@a)^;
 swapByteOrder(b);
end;

function uint64ToComp(var b: Uint64_t) : comp;
type PComp = ^Comp;
var tmp: Uint64_t;
begin
  tmp := b;
  swapByteOrder(tmp);
  uint64ToComp := PComp(@tmp)^;
end;

{$ELSE}

procedure uint64FromComp(const a: comp; var b: Uint64_t);
type PUint64_t = ^Uint64_t;
begin
 b := PUint64_t(@a)^;
end;

function uint64ToComp(var b: Uint64_t) : comp;
type PComp = ^Comp;
begin
  uint64ToComp := PComp(@b)^;
end;

{$ENDIF}

procedure add64LongInt(var a: Uint64_t; const b: longint);
var t : Uint64_t;
begin
  fromLongInt64(b,t);
  add64(a,t);
end;

procedure sub64LongInt(var a : Uint64_t; const b : longint);
var t: Uint64_t;
begin
  fromLongInt64(b,t);
  sub64(a,t);
end;

procedure mul64LongInt(var a: Uint64_t; const b: longint);
var t: Uint64_t;
begin
  fromLongInt64(b,t);
  mul64(a,t);
end;

const LogMap : array[0..19] of Uint64_t = (
      (001, 000, 000, 000, 000, 000, 000, 000),
      (010, 000, 000, 000, 000, 000, 000, 000),
      (100, 000, 000, 000, 000, 000, 000, 000),
      (232, 003, 000, 000, 000, 000, 000, 000),
      (016, 039, 000, 000, 000, 000, 000, 000),
      (160, 134, 001, 000, 000, 000, 000, 000),
      (064, 066, 015, 000, 000, 000, 000, 000),
      (128, 150, 152, 000, 000, 000, 000, 000),
      (000, 225, 245, 005, 000, 000, 000, 000),
      (000, 202, 154, 059, 000, 000, 000, 000),
      (000, 228, 011, 084, 002, 000, 000, 000),
      (000, 232, 118, 072, 023, 000, 000, 000),
      (000, 016, 165, 212, 232, 000, 000, 000),
      (000, 160, 114, 078, 024, 009, 000, 000),
      (000, 064, 122, 016, 243, 090, 000, 000),
      (000, 128, 198, 164, 126, 141, 003, 000),
      (000, 000, 193, 111, 242, 134, 035, 000),
      (000, 000, 138, 093, 120, 069, 099, 001),
      (000, 000, 100, 167, 179, 182, 224, 013),
      (000, 000, 232, 137, 004, 035, 199, 138)
      );

function ilog10(const a: Uint64_t) : integer;
var lower, upper, middle : byte;
begin
  if isNull64(a) then ilog10 := -1 else begin
    lower := 0;
    upper := HIGH(LogMap);
    middle := (lower + upper) div 2;

    while lower < upper do begin
      if isGreater64(LogMap[middle], a) then begin
        upper := middle - 1;
      end else if isLess64(LogMap[middle],a) then begin
        lower := middle + 1;
      end else begin
        lower := middle;
        upper := middle;
      end;
      middle := (lower + upper) div 2;
    end;
    if isGreater64(LogMap[middle], a) then ilog10 := middle - 1 else
    ilog10 := middle;
  end;
end;

procedure pow10(const n : integer; var a : uint64_t);
begin
  assert(n >= 0, 'Negative Power not supported');
  assert(n <= HIGH(LogMap), 'Number overflow');
  a := LogMap[n];
end;

begin
end.
