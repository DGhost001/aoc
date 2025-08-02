program day7;
uses itemhandler,jstring,dequeue;
type TDecks=(
              HighCard,    (* 23456 *)
              OnePair,     (* A23A4 *)
              TwoPair,     (* 23432 *)
              ThreeOfAKind,(* TTT89 *)
              FullHouse,   (* 23332 *)
              FourOfAKind, (* AA8AA *)
              FiveOfAKind  (* AAAAA *)
           );
      TCards   = (Two,Three,Four,Five,Six,Seven,Eight,Nine,Ten,Junge,Queen,King,Ass);
      TCardSet = array [1..5] of TCards;
      PHand = ^THand;
      THand = object(ItemType)
       deck_ : TDecks;
       cards_: TCardSet;
       bid_  : word;

       constructor init(cards:TCardSet; bid : word);
       destructor done;virtual;

       function compare(other:PItemType):TRelation;virtual;
      end;

const
  CardValues : set of char = ['2'..'9','T','J','Q','K','A'];
  InputFile = '..\INP\DAY7_INP.TXT';
constructor THand.init(cards:TCardSet; bid : word);
var histogram : array[Two..Ass] of byte;
    sets      : array[1..5] of byte;
    i         : integer;
    card      : TCards;
begin
  cards_ := cards;
  bid_ := bid;

  for i:= LOW(sets) to HIGH(sets) do
   sets[i]:=0;

  for card:=LOW(histogram) to HIGH(histogram) do
   histogram[card]:=0;

  for i:=LOW(cards) to HIGH(cards) do begin
    card:=cards[i];
    if histogram[card] >0 then dec(sets[histogram[card]]);
    inc(histogram[card]);
    inc(sets[histogram[card]]);
  end;

  if sets[5] = 1 then deck_ := FiveOfAKind else
  if sets[4] = 1 then deck_ := FourOfAKind else
  if (sets[3] = 1) and (sets[2] = 1) then deck_ := FullHouse else
  if sets[3] = 1 then deck_ := ThreeOfAKind else
  if sets[2] = 2 then deck_ := TwoPair else
  if sets[2] = 1 then deck_ := OnePair else
  deck_ := HighCard;
end;

destructor THand.done;
begin
end;

function THand.compare(other:PItemType):TRelation;
var otherHand : PHand;
    result    : TRelation;
    i         : integer;
begin

  result:=Equal;

  otherHand := PHand(other);

  if otherHand = NIL then runError(204);

  with otherHand^ do begin
    if deck_ > self.deck_ then result := Smaller else
    if deck_ < self.deck_ then result := Bigger else
    begin
      for i:= 1 to 5 do begin
        if cards_[i] > self.cards_[i] then result:= Smaller else
        if cards_[i] < self.cards_[i] then result:= Bigger else
        continue;
        break;
      end;
    end;
  end;
  compare := result;
end;
function charToCard(c: char) : TCards;
begin
 case c of
   '2': charToCard := Two;
   '3': charToCard := Three;
   '4': charToCard := Four;
   '5': charToCard := Five;
   '6': charToCard := Six;
   '7': charToCard := Seven;
   '8': charToCard := Eight;
   '9': charToCard := Nine;
   'T': charToCard := Ten;
   'J': charToCard := Junge;
   'Q': charToCard := Queen;
   'K': charToCard := King;
   'A': charToCard := Ass;
   else RunError(300);
 end;
end;

function parseHand(line: PJString) : PHand;
var items : PDeQueue;
    result: PHand;
    i     : integer;
    tmp   : string;
    cards : TCardSet;
    bid   : word;
    data  : PJString;
begin
  result := NIL;

  data  := line^.stripWhiteSpace;
  items := data^.split(' ');

  if items^.size = 2 then begin
    tmp := PJString(items^.at(0))^.toString;
    if length(tmp) = HIGH(cards) then begin
     for i:= 1 to HIGH(cards) do begin
      cards[i]:= charToCard(tmp[i]);
     end;
     tmp:= PJString(items^.at(1))^.toString;
     val(tmp,bid,i);

     result := new(PHand,init(cards,bid));
    end;
  end;
  parseHand := result;
  data^.dispose;
end;

procedure sort(queue : PDeQueue);
var  it1, it2: PDeQueueIterator;
     change : boolean;
begin
  change := True;
  if queue^.size > 1 then begin
    while change do begin
      it1 := queue^.first;
      it2 := it1 ^.next;
      change := false;
      write('.');

      while (it1 <> NIL) and (it2 <> NIL) do begin
        if it1^.at^.compare(it2^.at) = Bigger then begin
          it1^.swap(it2);
          change := True;
        end;
        it1:= it2;
        it2:= it2^.next;
      end;
    end;
  end;
end;

var input : Text;
    data  : PDeQueue;
    tmp   : PHand;
    line  : PJString;
    sum   : longint;
    i     : integer;
    it    : PDeQueueIterator;
begin
  assign(input,InputFile);
  reset(input);

  data := new(PDeQueue,init);

  Writeln('Loading Data...');
  while not eof(input) do begin
    line := ReadLine(input);
    tmp:= parseHand(line);
    if tmp <> NIL then data^.pushBack(tmp);
    line^.dispose;
  end;

  close(input);

  writeln('Sorting ',data^.size,' Datasets');

  sort(data);

  writeln;

  i:=1;
  it := data^.first;
  sum := 0;
  while it <> NIL do begin
    sum := sum + PHand(it^.at)^.bid_*i;
    inc(i);
    it:=it^.next;
  end;

  writeln('Day 7 Part1 Points: ',sum);

  data^.dispose;
end.