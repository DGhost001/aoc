unit Heap;
interface
uses Itemhandler,crt, BlockArray;
type  PMinHeap = ^TMinHeap;
      TMinHeap = object
       private
         heap_ : PBlockArray;
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
  heap_ := new(PBlockArray, init);
  last_ := 0;
end;

destructor TMinHeap.done;
var i: word;
begin
  SYSTEM.dispose(heap_, done);
end;

function TMinHeap.size : word;
begin
  size := last_;
end;

procedure TMinHeap.push(item: PItemType);
var i1, i2 : word;
begin
  heap_^.setValue(last_,item); (* Store the item in the last place *)
  i1 := last_;
  inc(last_);
  (* If we have more than one element we need to check the tree *)
  while i1 > 0 do begin
    i2 := (i1 - 1) div 2; (* This is the index of the parent *)
    if heap_^.at(i1)^.compare(heap_^.at(i2)) = Smaller then begin
      swap(i1,i2);
      i1 := i2;
    end else break;
  end;
end;

function TMinHeap.pop: PItemType;
var i1, i2, i3, i4 : word;
begin
  pop := heap_^.at(0);
  if last_ > 0 then dec(last_);
  heap_^.setValue(0, heap_^.at(last_));
  heap_^.setValue(last_, NIL);
  i1 := 0;
  (* We take the last element and trickle it down the tree *)

  while i1 < last_ do begin
    if keypressed then runError(300);
    i2 := i1 * 2 + 1;  (* Left Node *)
    i3 := i1 * 2 + 2;  (* Right Node *)

    if (i1 < 32768 ) and (heap_^.at(i2) <> NIL) then begin (* If there is no left, there is no right *)
       (* Find the smaller child *)
       if (heap_^.at(i3) <> NIL) then begin
          if heap_^.at(i2)^.compare(heap_^.at(i3)) = Smaller then
            i4 := i2
          else
            i4 := i3;
       end else i4 := i2;
       (* Compare with the smaller child and potentially swap *)
       if heap_^.at(i4)^.compare(heap_^.at(i1)) = Smaller then begin
         swap(i4,i1);
         i1:=i4;
       end else break; (* We found the place and can abort here *)
    end else break;
  end;
end;

procedure TMinHeap.swap(const index1, index2: word);
var tmp : PItemType;
begin
  tmp := heap_^.at(index2);
  heap_^.setValue(index2, heap_^.at(index1));
  heap_^.setValue(index1, tmp);
end;

begin
end.
