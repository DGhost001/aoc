uses sort, dequeue, ItemHandler,crt;
type PValue = ^TValue;
     TValue = object(ItemType)
       i_ : integer;
       constructor init(i: integer);
       function compare(other:PItemType):TRelation;virtual;
     end;
constructor TValue.init(i: integer);
begin
 i_ := i;
end;

function TValue.compare(other:PItemType):TRelation;
var result : TRelation;
begin
  with PValue(other)^ do begin
    if self.i_ > i_ then result := Bigger else
    if self.i_ < i_ then result := Smaller else
    result := Equal;
  end;
  compare := result;
end;

procedure print(it:PDeQueueIterator); far;
begin
  write(' ',PValue(it^.at)^.i_);
end;

var q : PDeQueue;
begin
  q:= new(PDeQueue,init);
  q^.pushBack(new(PValue,init(5)));
  q^.pushBack(new(PValue,init(1)));
  q^.pushBack(new(PValue,init(2)));
  q^.pushBack(new(PValue,init(6)));
  q^.pushBack(new(PValue,init(9)));
  q^.pushBack(new(PValue,init(4)));
  q^.pushBack(new(PValue,init(5)));
  q^.pushBack(new(PValue,init(3)));
  q^.pushBack(new(PValue,init(7)));

  clrscr;
  q^.forEach(print); writeln;

  sortQueue(q);

  q^.forEach(print);
  q^.dispose;

end.
