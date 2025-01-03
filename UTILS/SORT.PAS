unit sort;
(* Implementation of a simple QSort for an integer array *)
interface
  uses DeQueue,ItemHandler;

  procedure sortQueue(queue : PDeQueue);
  procedure quickSort(var a: array of integer);
  function  binarySearch(const a: array of integer; what : integer) : integer;
implementation
uses cassert;

procedure sortQueue(queue : PDeQueue);
type TPartition = record
       first, last : PDeQueueIterator;
     end;

 procedure split(const p1    : TPartition;
                 var   p2,p3 : TPartition);
 var slow,fast : PDeQueueIterator;
 begin
   p2.first := p1.first;
   p3.last  := p1.last;
   slow:= p1.first;
   fast:= p1.first;

   while (fast <> nil) and
         (fast <> p1.last) do begin
     fast := fast^.next;
     if (fast <> Nil) and
        (fast <> p1.last) then begin
       fast := fast^.next;
       slow := slow^.next;
     end;
   end;

   p2.last  := slow;
   p3.first := slow;
 end;

 procedure merge(      p1, p2: TPartition;
                       queue : PDeQueue;
                 var   result: TPartition);
 var i1, i2, i3 : PDeQueueIterator;
 begin
   i1  := p1.first;
   i2  := p2.first;
   assert(p1.last = p2.first,'The partitions need to touch');
   result.first := NIL;
   result.last  := p2.last; (* P2 .last is always at the end,
                               as it is not part of the merging
                               elements *)
   while (i1 <> p1.last) and
         (i2 <> p2.last) do begin
     if i1^.at^.compare(i2^.at) = Bigger then begin
       if result.first = NIL then result.first := i2;
       i3 := i2^.next;

       (* It may happen that we need to adapt the partitions *)
       if i2 = p1.last then begin
         p1.last  := i3;
         p2.first := i3;
       end;
       if i1 = p1.first then p1.first := i2;

       queue^.moveBefore(i2, i1); (* Move i2 before i1 *)

       i2 := i3;

     end else begin
      if result.first = NIL then result.first := i1;
      i1 := i1^.next;
     end;
   end;
 end;

 procedure mergeSort(var p: TPartition; queue: PDeQueue);
 var p1, p2 : TPartition;
 begin
   if (p.first = NIL) or
      (p.first = p.last) or
      (p.first^.next = p.last) then exit; (* It is as sorted as possible *)

   split(p, p1, p2);

   assert(p1.last = p2.first,'Internal Error during sorting');

   mergeSort(p1, queue);
   mergeSort(p2, queue);

   p1.last := p2.first; (* p1 last never changes, but the first element of
                           the second partition most likely changes, so
                           get them in sync again *)
   merge(p1,p2,queue, p);
 end;
var p: TPartition;
begin
  p.first := queue^.first;
  p.last  := nil;

  mergeSort(p,queue);
end;

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

procedure quickSortLong(var a: array of longint);
    procedure qSort(low, high : word);
    var left, right : integer;
        tmp, pivot  : longint;
    begin
      if (high > low) then begin (* Make sure we have something to sort *)
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
