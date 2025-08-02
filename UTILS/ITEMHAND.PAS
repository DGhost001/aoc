unit ItemHandler;

interface
    type 
        TRelation =(Smaller, Equal, Bigger);
        PItemType = ^ItemType;
        ItemType = object
            constructor init;
            destructor done; virtual;
            function compare(other:PItemType):TRelation;virtual;
        end;
        PLongItem = ^TLongItem;
        TLongItem = object(ItemType)
           value_ : longint;

           constructor init(const i : longint);
           constructor copy(const other : PLongItem);
           function compare(other:PItemType):TRelation;virtual;
           function value : longint;
        end;

implementation

constructor ItemType.init;
begin
end;

destructor ItemType.done;
begin
end;

function ItemType.compare;
begin
 runError(211); (* Default items are not comparable *)
end;

constructor TLongItem.init(const i : longint);
begin
  value_ := i;
end;

constructor TLongItem.copy(const other : PLongItem);
begin
  value_ := other^.value_;
end;

function TLongItem.compare(other:PItemType):TRelation;
var o : PLongItem;
begin
  o := PLongItem(other);
  if value_ > o^.value_ then compare := Bigger else
  if value_ < o^.value_ then compare := Smaller else
  compare := Equal;
end;

function TLongItem.value : longint;
begin
  value := value_;
end;

begin
end.
