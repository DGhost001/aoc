unit clock;
interface
{$N+} {$E+} (*Enable emulation and Co-Processor*)
type TClock = comp; (* The only availble 64bit data type*)

function now : TClock; (*Return a unix timestamp*)
procedure toHMS(var h,m,s : word; time: TClock);
function getTickCount : longint;

implementation

{$IFDEF ATARI}

(**
 * TOS specific code to get the tick count.
 * This uses the GEMDOS super mode to read the BIOS tick count.
 *)

uses gemdos, stdint, dos;

function getTickCount: longint;
var biosTickCount: longint absolute $04ba;  (* 200Hz counter value *)
    result: longint;
    oldStack: Pointer; 
begin
  oldStack := Pointer(gemdos_super(nil));
  result := biosTickCount; (* Read the 200Hz counter in super mode *)
  gemdos_super(oldStack);
  getTickCount := result;
end;
{$ELSE}
{$IFDEF LINUX}
uses dos,linux, stdint, sysutils;

function getTickCount : longint;
begin
  getTickCount := getTickCount64 and $7fffffff;
end;

{$ELSE}
uses dos, stdint;
(**
 * DOS specific code to get the tick count.
 * This uses the BIOS tick count stored at $40:$6C.
 *)
function getTickCount : longint;
var biosTicks : longint absolute $40:$6c;
begin
  asm
   cli
  end;

  getTickCount := biosTicks;

  asm
   sti
  end;
end;

{$ENDIF}
{$ENDIF}

function gregorianToJulian(year, month, day : longint): longint;
const D0 : longint =    1461;
      D1 : longint =  146097;
      D2 : longint = 1721119;
var century, xyear : longint;
begin
  if month <= 2 then begin
   dec(year);
   inc(Month,12);
  end;
  dec(month,3);
  century :=(longint(year div 100) * D1) shr 2;
  xyear   :=(longint(year mod 100)* D0) shr 2;
  gregorianToJulian := ((((Month * 153) + 2) div 5) + day) + D2 + xyear + century;
end;

function universalToEpoch(year, month, day     :word;
                          const hour, minute, second :word) : TClock;
const c1970 : longint = 2440588;
var   julian: TClock;
      time  : TClock;
begin
 julian := gregorianToJulian(year, month, day) - c1970;
 {$ifdef ATARI}
 time   := comp(hour) * 3600 + comp(minute) * 60 + comp(second);
 universalToEpoch := comp(julian) * 86400 + time;
 {$ELSE}
 time   := hour * 3600.0 + minute * 60.0 + second;
 universalToEpoch := julian * 86400.0 + time;
 {$ENDIF}
 
end;

function now;
var year, month, day, hour, minutes, seconds, tmp: word;
begin
 getDate(year, month, day, tmp);
 getTime(hour, minutes, seconds, tmp);
 now := universalToEpoch(year, month, day, hour, minutes, seconds);
end;

procedure toHMS(var h,m,s : word; time: TClock);
const Sixty : Uint64_t = ($3c,0,0,0,0,0,0,0);
var tmp, remain : Uint64_t;
begin
  uint64FromComp(time, tmp);
  div64(tmp, Sixty, remain);
  s := remain[0];
  div64(tmp, Sixty, remain);
  m := remain[0];
  h := toLongInt64(tmp) and $ffff;
end;

begin
end.