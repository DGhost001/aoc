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
begin
end.
