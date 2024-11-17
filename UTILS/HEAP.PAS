unit Heap;
interface
uses Itemhandler;
const MaxHeapItems = 1024;
type  PMinHeap = ^TMinHeap;
      TMinHeap = object
       private
         heap_ : array[0..MaxHeapItems - 1] of PItemType;
         last_ : word;

         procedure swap(const index1,index2 : word);

       public
         constructor init;
         destructor done;

         procedure push(item : PItemType);
         function pop : PItemType;
         function size: word;
     end;
implementation

constructor TMinHeap.init;
var i: word;
begin
  for i:=0 to MaxHeapItems-1 do
    heap_[i] := NIL;
  last_ := 0;
end;

destructor TMinHeap.done;
var i: word;
begin
 if last_ > 0 then
   for i:=0 to last_ - 1 do
     SYSTEM.dispose(heap_[i], done);
end;

function TMinHeap.size : word;
begin
  size := last_;
end;

procedure TMinHeap.push(item: PItemType);
var i1, i2 : word;
begin
  if last_ = MaxHeapItems then runError(201); (* OOM Check *)
  heap_[last_] := item; (* Store the item in the last place *)
  i1 := last_;
  inc(last_);
  (* If we have more than one element we need to check the tree *)
  while i1 > 0 do begin
    i2 := (i1 - 1) div 2; (* This is the index of the parent *)
    if heap_[i1]^.compare(heap_[i2]) = Smaller then begin
      swap(i1,i2);
      i1 := i2;
    end else break;
  end;
end;

function TMinHeap.pop: PItemType;
var i1, i2, i3, i4 : word;
begin
  pop := heap_[0];
  if last_ > 0 then dec(last_);
  heap_[0] := heap_[last_];
  heap_[last_] := NIL;
  i1 := 0;
  (* We take the last element and trickle it down the tree *)

  while i1 < last_ do begin
    i2 := i1 * 2 + 1;  (* Left Node *)
    i3 := i1 * 2 + 2;  (* Right Node *)

    if heap_[i2] <> NIL then begin (* If there is no left, there is no right *)
       (* Find the smaller child *)
       if heap_[i3] <> NIL then begin
          if heap_[i2]^.compare(heap_[i3]) = Smaller then
            i4 := i2
          else
            i4 := i3;
       end else i4 := i2;
       (* Compare with the smaller child and potentially swap *)
       if heap_[i4]^.compare(heap_[i1]) = Smaller then begin
         swap(i4,i1);
         i1:=i4;
       end else break; (* We found the place and can abort here *)
    end else break;
  end;
end;

procedure TMinHeap.swap(const index1, index2: word);
var tmp : PItemType;
begin
  tmp := heap_[index2];
  heap_[index2] := heap_[index1];
  heap_[index1] := tmp;
end;

begin
end.
