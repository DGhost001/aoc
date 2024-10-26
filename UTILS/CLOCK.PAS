unit clock;
interface
{$N+} {$E+} (*Enable emulation and Co-Processor*)
type TClock = comp; (* The only availble 64bit data type*)

function now : TClock; (*Return a unix timestamp*)
procedure toHMS(var h,m,s : word; time: TClock);
implementation

uses dos;

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
 time   := hour * 3600.0 + minute * 60.0 + second;
 universalToEpoch := julian * 86400.0 + time;
end;

function now;
var year, month, day, hour, minutes, seconds, tmp: word;
begin
 getDate(year, month, day, tmp);
 getTime(hour, minutes, seconds, tmp);
 now := universalToEpoch(year, month, day, hour, minutes, seconds);
end;

procedure toHMS(var h,m,s : word; time: TClock);
var tmp : TClock;
begin
  tmp := int(time / 60) * 60;
  s := trunc(time - tmp);
  time := time / 60;

  tmp := int(time / 60) * 60;
  m := trunc(time - tmp);
  time := time / 60;

  tmp := int(time / 60) * 60;
  h := trunc(time);

end;

begin
end.