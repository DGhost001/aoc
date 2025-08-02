program day4;
uses sort, jstring, dequeue, crt;

type TCard = record
       cardNumber    : integer;
       WinningNumber : array[1..10] of integer;
       MyNumbers     : array[1..25] of integer;
     end;

const InputFileName = 'DAY4_INP.TXT';

function loadNextGameCard(var input: Text; var playCard: TCard): boolean;
 function parseNumbers(numberString: PJString; var number: array of integer) : boolean;
 var data    : PJString;
     numList : PDeQueue;
     it      : PDeQueueIterator;
     result  : boolean;
     pos     : integer;
     code    : integer;
     tmp     : string;
 begin
   result := false;
   data := numberString^.stripWhiteSpace;
   numList := data^.split(' ');
   if (High(number) - Low(number))+1 = numList^.size then begin
      it := numList^.first;
      for pos:=Low(number) to High(number) do begin
        tmp := PJString(it^.at)^.toString;
        val(tmp, number[pos], code);
        it := it^.next;
      end;
      result := true;
   end;
   data^.dispose;
   numList^.dispose;
   parseNumbers := result;
 end;

 function getCardNumber(input : PJString): integer;
 var sections  : PDeQueue;
     tmp       : string;
     num, code : integer;
 begin
   sections := input^.split(' ');
   if sections^.size = 2 then begin
     tmp := PJString(sections^.at(1))^.toString;
     val(tmp,num,code);
     getCardNumber := num;
   end else
    getCardNumber := -1;
   sections^.dispose;
 end;

 function parseGameArrays(input: PJString; var card : TCard): boolean;
 var sections : PDeQueue;
 begin
   sections := input^.split('|');
   if sections^.size = 2 then begin
     parseGameArrays := true;
     parseNumbers(PJString(sections^.at(0)),card.WinningNumber);
     parseNumbers(PJString(sections^.at(1)),card.MyNumbers);
     QuickSort(card.MyNumbers);
   end else
     parseGameArrays := false;

   sections^.dispose;
 end;

var line: PJString;
    sections: PDequeue;
    result : boolean;
begin
  result := false;
  if not eof(input) then begin
     line := ReadLine(input);
     sections := line^.split(':');
     if sections^.size = 2 then begin
       result := true;
       playCard.cardNumber := getCardNumber(PJString(sections^.at(0)));
       parseGameArrays(PJString(sections^.at(1)), playCard);
     end;
     sections^.dispose;
  end;
  loadNextGameCard := result;
end;

function getNumberOfWinningNumbers(card: TCard): integer;
var result : integer;
    pos    : integer;
begin
  result := 0;
  for pos:= low(card.WinningNumber) to high(card.WinningNumber) do begin
    if binarySearch(card.MyNumbers, card.WinningNumber[pos])>=0 then begin
      write(card.WinningNumber[pos],' ');
      inc(result);
    end;
  end;

  getNumberOfWinningNumbers := result;
end;

function getCardPoints(const count : integer): integer;
var result : integer;
begin
  result := 0;
  if count > 0 then
    result := 1 shl (count-1);

  getCardPoints := result;
end;

var input     : Text;
    card      : TCard;
    sum       : longint;
    points    : integer;
    count,i   : integer;
    histogram : array [1..200] of longint;
begin
  clrscr;
  assign(input, InputFileName);
  reset(input);

  fillChar(histogram, sizeOf(histogram), 0);

  sum:= 0;

  while loadNextGameCard(input, card) do begin
    inc(histogram[card.CardNumber]); (* We have a real play card *)

    write(card.CardNumber,'(x',histogram[card.CardNumber],'): ');

    count  := getNumberOfWinningNumbers(card);
    for i:=1 to count do begin
     if i + card.CardNumber < High(histogram) then
       inc(histogram[card.CardNumber+i],histogram[card.CardNumber]); (* Increment by the copies *)
    end;
    points := getCardPoints(count);
    sum:=sum + points;
    writeln('= ',points);
  end;
  writeln('Total Points: ',sum);

  if(histogram[card.CardNumber+1] <> 0) then
    writeln('#### ERROR ### - Out of Table access detected!');

  sum :=0;
  for i:= low(histogram) to high(histogram) do
    sum:= sum + histogram[i];
  writeln('Number of Total Cards: ',sum);
  close(input);
end.
