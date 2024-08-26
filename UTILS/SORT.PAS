unit sort;
(* Implementation of a simple QSort for an integer array *)

interface
  procedure quickSort(var a: array of integer);
  function  binarySearch(const a: array of integer; what : integer) : integer;
implementation
  procedure quickSort(var a: array of integer);
    procedure qSort(low, high : integer);
    var left, right : integer;
        tmp, pivot  : integer;
    begin
      if (high - low) >= 1 then begin (* Make sure we have something to sort *)
        left := low;
        right:= high;
        pivot:= a[ (left + right) div 2];
        while left < right do begin
          while a[left] < pivot do inc(left);
          while a[right] > pivot do dec(right);

          if left <= right then begin
            tmp := a[left];
            a[left] := a[right];
            a[right] := tmp;
            inc(left);
            dec(right);
          end;
        end;
        qSort(low, right);
        qSort(left, high);
      end;
    end;
  begin
    qSort(Low(a), High(a));
  end;

function binarySearch(const a: array of integer; what : integer) : integer;
var left, right, center, result : integer;
begin
  left := low(a);
  right:= high(a);
  result := -1;
  while left < right do begin
    center := (left + right) div 2;

    if what < a[center] then right := center - 1 else
    if what > a[center] then left  := center + 1 else
    begin
      left := center;
      right:= center;
    end;
  end;

  if a[left] = what then
    result := left;

  binarySearch := result;
end;

begin
end.
