unit math;

interface

  function ceil(x: Real) : LongInt;
  function floor(x: Real) : LongInt;
  function modulo(const x,m : longint) : longint;
implementation

function ceil(x: Real) : LongInt;
begin
 ceil :=trunc(x) + ord(frac(x) > 0);
end;

function floor(x: Real) : LongInt;
begin
 floor :=trunc(x) - ord(frac(x) < 0);
end;

function modulo(const x,m : longint) : longint;
var result : longint;
begin
  result := x mod m;
  if result < 0 then modulo := m + result else modulo := result;
end;
begin
end.