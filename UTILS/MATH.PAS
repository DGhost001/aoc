unit math;

interface

  function ceil(x: Real) : LongInt;
  function floor(x: Real) : LongInt;

implementation

function ceil(x: Real) : LongInt;
begin
 ceil :=trunc(x) + ord(frac(x) > 0);
end;

function floor(x: Real) : LongInt;
begin
 floor :=trunc(x) - ord(frac(x) < 0);
end;

begin
end.