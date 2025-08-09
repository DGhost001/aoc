unit UintItem;
interface
uses ItemHandler, stdint;

type 
    PUintItem = ^TUintItem;
    TUintItem = object(ItemType)
        value_ : Uint64_t;

        constructor init(const i : Uint64_t);
        constructor copy(const other : PUintItem);
        function compare(other:PItemType):TRelation;virtual;
    end;

implementation

constructor TUintItem.init(const i : Uint64_t);
begin
    value_ := i;
end;

constructor TUintItem.copy(const other : PUintItem);
begin
    value_ := other^.value_;
end;

function TUintItem.compare(other:PItemType):TRelation;
var otherUint : PUintItem;
begin
    otherUint := PUintItem(other);
    if isLess64(value_, otherUint^.value_) then  compare := Smaller
    else if isGreater64(value_, otherUint^.value_) then   compare := Bigger
    else compare := Equal;
end;

begin

end.
