unit STDINT;

interface

    type Uint64_t = array[0..7] of byte;
         Uint32_t = array[0..3] of byte;
         Uint16_t = word;
         Uint8_t  = byte;

    const neg64 : Uint64_t = ($ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);
          zero64: Uint64_t = ($00,$00,$00,$00,$00,$00,$00,$00);
          one64 : Uint64_t = ($01,$00,$00,$00,$00,$00,$00,$00);


    procedure rotateLeft64(count: byte; var a: Uint64_t); (* a:= a rol c *)
    procedure rotateLeft32(count: byte; var a: Uint32_t);

    procedure xor64(var a,b: Uint64_t);                   (* a:= a xor b *)
    procedure xor32(var a,b: Uint32_t);

    procedure add64(var a,b: Uint64_t);                   (* a:= a + b *)
    procedure add32(var a,b: Uint32_t);

    procedure sub64(var a,b: Uint64_t);                   (* a:= a - b *)
    procedure sub32(var a,b: Uint32_t);

    procedure mul64(var a,b: Uint64_t);                   (* a:= a * b *)
    procedure div64(var a, b, r : Uint64_t);              (* a:= a div b, r:= a mod b *)

    function isNull64(var a: Uint64_t): boolean;          (* a == 0 *)
    function isNull32(var a: Uint32_t): boolean;

    function isGreater64(var a,b: Uint64_t): boolean;     (* a > b  *)
    function isGreater32(var a,b: Uint32_t): boolean;

    function isLess64(var a,b: Uint64_t):boolean;         (* a < b  *)
    function isLess32(var a,b: Uint32_t): boolean;

    function isEqual64(var a,b: Uint64_t): boolean;       (* a == b *)
    function isEqual32(var a,b: Uint32_t): boolean;

    procedure fromLongInt64(i : LongInt; var a: Uint64_t);
    procedure fromLongInt32(i : LongInt; var a: Uint32_t);

    function  toLongInt64(a: Uint64_t): LongInt;
    function  toLongInt32(a: Uint32_t): LongInt;

    function strToUint64(s: string; var a : Uint64_t): boolean;
    function Uint64ToStr(var a: Uint64_t): string;

    procedure min64(var a,b,c : Uint64_t);
    procedure max64(var a,b,c : Uint64_t);

implementation

{$IFNDEF FPC}
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



function isNull64(var a: Uint64_t): boolean; assembler; (* a == 0 *)
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

function isNull64(var a: Uint64_t): boolean;          (* a == 0 *)
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

function isEqual64(var a,b: Uint64_t): boolean;       (* a == b *)
begin
  isEqual64 := (a[0] = b[0]) and (a[1] = b[1]) and (a[2] = b[2]) and (a[3] = b[3]) and
               (a[4] = b[4]) and (a[5] = b[5]) and (a[6] = b[6]) and (a[7] = b[7]);
end;

function isEqual32(var a,b: Uint32_t): boolean;
begin
   halt(-1); (*Not implemented yet...*)
end;

{$ENDIF}

function isGreater64(var a,b: Uint64_t): boolean;     (* a > b  *)
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

procedure mul64(var a,b: Uint64_t);
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
  end;
  Uint64ToStr := result;
end;

procedure min64(var a,b,c : Uint64_t);
begin
  if isLess64(a,b) then c:= a else c:= b;
end;

procedure max64(var a,b,c : Uint64_t);
begin
  if isGreater64(a,b) then c:= a else c:= b;
end;

begin
end.
