unit SparsArray;
(* This is an implementation for a sparse array 
   it will provide storage for up to 16384 non zero elements
   but it accepts an index of longint 
*)

interface
uses ItemHandler, BlockArray;

type
  PSparseElement = ^TSparseElement;
  TSparseElement = object(ItemType)
      index_ : longint;
      value_ : PItemType;

      constructor init(const index: longint; const item: PItemType);
      destructor done; virtual;
  end;

  PSparseArray = ^TSparseArray;
  TSparseArray = object
      storage_ : TBlockArray;
      length_  : word;
      constructor init;
      destructor done; 

      function  at(const index: longint): PItemType;
      procedure setValue(const index: longint; const item: PItemType);

      function getMax: PItemType;

      procedure dispose;   

      private
      function findIndex(const index: longint): word;
      procedure insert(const index: longint; const item: PItemType; const iindex: word);
  end;
implementation

uses cassert;

constructor TSparseElement.init(const index: longint; const item: PItemType);
begin
  ItemType.init;
  index_ := index;
  value_ := item;
end;

destructor TSparseElement.done;
begin
  ItemType.done;
  System.dispose(value_, done);
end;

constructor TSparseArray.init;
begin
  length_ := 0;
  storage_.init;
end;

destructor TSparseArray.done;
begin
  storage_.done;
  length_ := 0;
end;

function TSparseArray.at(const index: longint): PItemType;
var i : word;
    e : PSparseElement;
begin
  i := findIndex(index);
  e := PSparseElement(storage_.at(i));
  if (e <> nil) and (e^.index_ = index) then
    at := PSparseElement(storage_.at(i))^.value_
  else at := nil;
end;

procedure TSparseArray.setValue(const index: longint; const item: PItemType);
var i : word;
    e : PSparseElement;

begin
  i := findIndex(index);
  e:= PSparseElement(storage_.at(i));
  if (e <> nil) and (e^.index_ = index) then begin
    System.dispose(e^.value_, done);
    e^.value_ := item;
  end else begin
    insert(index, item, i);
  end;
end;

procedure TSparseArray.dispose;
begin
  System.dispose(PSparseArray(@self), done);
end;

function TSparseArray.findIndex(const index: longint): word;
var left, right, center, tmp : word;
    e: PSparseElement;
begin
  if length_ > 1 then begin
    left := 0;
    right := length_-1;
    center := 0;
    
    while left < right do begin
        center := (left + right)  div 2;
        e := PSparseElement(storage_.at(center));
        if (center = 0) or (center = length_-1) then break;
        if e^.index_ < index then left := center + 1
        else if e^.index_ > index then right := center - 1
        else begin
          left := center;
          right := center;
        end;
    end;
    
    center := (left + right)  div 2;
    e := PSparseElement(storage_.at(left));
    if (e <> nil) and (e^.index_ = index) then findIndex := left else begin
        if left > right then begin tmp := left; left := right; right := tmp; end;
        e := PSparseElement(storage_.at(center));
        if (e <> nil) and (e^.index_ < index) then findIndex := right else
        if (e <> nil) and (e^.index_ > index) then findIndex := left else
        findIndex := center;
    end;
  end else findIndex := 0;   
end;

procedure TSparseArray.insert(const index: longint; const item: PItemType; const iindex: word);
var i : word;
    e : PSparseElement;
begin
  assert(length_ < 65535, 'Out of Memory for the sparse array');
  inc(length_);

  if length_ = 1 then
    storage_.setValue(0, new(PSparseElement, init(index,item)))
  else begin
    e := PSparseElement(storage_.at(iindex));
    if (e <> nil) and (e^.index_ > index) then begin
        for i := length_ - 1 downto iindex + 1 do
            storage_.setValue(i, storage_.at(i-1));
        storage_.setValue(iindex, new(PSparseElement, init(index,item)));
    end else begin
        for i := length_ - 1 downto iindex + 2 do
            storage_.setValue(i, storage_.at(i-1));
        storage_.setValue(iindex+1, new(PSparseElement, init(index,item)));    
    end;
  end;
end;

function TSparseArray.getMax: PItemType;
var max : PItemType;
      e : PSparseElement;
      i : word;
begin
  max := nil;
  for i:= 0 to length_-1 do begin
    e := PSparseElement(storage_.at(i));
    if (max = nil) or (e^.value_^.compare(max) = Bigger) then
      max := e^.value_;
  end;
  getMax := max;
end;

begin
  
end.