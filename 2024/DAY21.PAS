program day21;
(*This is the implementation of the aoc24 day 21*)

uses aoc, utils, cassert, itemhandler, dequeue, sort;
const InputFileName = 'INP\DAY21_IN.TXT';
type TButton = (BT_NONE, BT_ACCEPT, BT_UP, BT_DOWN, BT_LEFT, BT_RIGHT,
                BT_ONE, BT_TWO, BT_THREE, BT_FOUR, BT_FIVE, BT_SIX,
                BT_SEVEN, BT_EIGHT, BT_NINE, BT_ZERO);
     TKey    = record
        available  : Boolean;
        neighbours : array [TDirection] of TButton;
     end;
     TKeyPad = array[TButton] of TKey;
     TKeySet = set of TButton;

     PButtonItem = ^TButtonItem;
     TButtonItem = object(ItemType)
       key_: TButton;

       constructor init(const key: TButton);
     end;
     PKeySequenceItem = ^TKeySequenceItem;
     TKeySequenceItem = object(ItemType)
       sequence_ : TDequeue;
       
       constructor init;
       constructor copy(const other: PKeySequenceItem);

       destructor done; virtual;

       function compare(other:PItemType):TRelation;virtual;
       function length: word;

       procedure pushBack(const button: TButton);
       procedure popBack;

       function append(const other: PKeySequenceItem): word;
       procedure remove(const length: word);

     end;
     PKeySequences = ^TKeySequences;
     TKeySequences = object(ItemType)
        keySequences_ : TDequeue;

        constructor init;
        destructor done;
        
        procedure addSequence(sequence: PKeySequenceItem);
        procedure sort;
        procedure keepOnlyShortest;
        procedure keepOnlyOne;
     end;
(*
+---+---+---+
| 7 | 8 | 9 |
+---+---+---+
| 4 | 5 | 6 |
+---+---+---+
| 1 | 2 | 3 |
+---+---+---+
    | 0 | A |
    +---+---+
*)
const NumericKeyPad : TKeyPad = (                   (*  North    East     West     South*)
      (*BT_NONE*)   (available: false; neighbours : (BT_NONE,  BT_NONE, BT_NONE, BT_NONE)),
      (*BT_ACCEPT*) (available: true;  neighbours : (BT_THREE, BT_NONE, BT_ZERO, BT_NONE)),
      (*BT_UP*)     (available: false; neighbours : (BT_NONE,  BT_NONE, BT_NONE, BT_NONE)),
      (*BT_DOWN*)   (available: false; neighbours : (BT_NONE,  BT_NONE, BT_NONE, BT_NONE)),
      (*BT_LEFT*)   (available: false; neighbours : (BT_NONE,  BT_NONE, BT_NONE, BT_NONE)),
      (*BT_RIGHT*)  (available: false; neighbours : (BT_NONE,  BT_NONE, BT_NONE, BT_NONE)),
      (*BT_ONE*)    (available: true;  neighbours : (BT_FOUR,  BT_TWO,  BT_NONE, BT_NONE)),
      (*BT_TWO*)    (available: true;  neighbours : (BT_FIVE,  BT_THREE, BT_ONE, BT_ZERO)),
      (*BT_THREE*)  (available: true;  neighbours : (BT_SIX,   BT_NONE, BT_TWO, BT_ACCEPT)),
      (*BT_FOUR*)   (available: true;  neighbours : (BT_SEVEN,  BT_FIVE, BT_NONE, BT_ONE)),
      (*BT_FIVE*)   (available: true;  neighbours : (BT_EIGHT,  BT_SIX, BT_FOUR, BT_TWO)),
      (*BT_SIX*)    (available: true;  neighbours : (BT_NINE,  BT_NONE, BT_FIVE,  BT_THREE)),
      (*BT_SEVEN*)  (available: true;  neighbours : (BT_NONE,  BT_EIGHT, BT_NONE, BT_FOUR)),
      (*BT_EIGHT*)  (available: true;  neighbours : (BT_NONE,  BT_NINE, BT_SEVEN, BT_FIVE)),
      (*BT_NINE*)   (available: true;  neighbours : (BT_NONE,  BT_NONE, BT_EIGHT, BT_SIX)),
      (*BT_ZERO*)   (available: true;  neighbours : (BT_TWO,  BT_ACCEPT, BT_NONE, BT_NONE)));
(*     
    +---+---+
    | ^ | A |
+---+---+---+
| < | v | > |
+---+---+---+
*)
     DirectionalKeyPad : TKeyPad = (                (*  North    East     West     South*)
      (*BT_NONE*)   (available: false; neighbours : (BT_NONE,  BT_NONE, BT_NONE, BT_NONE)),
      (*BT_ACCEPT*) (available: true;  neighbours : (BT_NONE,  BT_NONE, BT_UP, BT_RIGHT)),
      (*BT_UP*)     (available: true; neighbours :  (BT_NONE,  BT_ACCEPT, BT_NONE, BT_DOWN)),
      (*BT_DOWN*)   (available: true; neighbours :  (BT_UP,  BT_RIGHT, BT_LEFT, BT_NONE)),
      (*BT_LEFT*)   (available: true; neighbours :  (BT_NONE,  BT_DOWN, BT_NONE, BT_NONE)),
      (*BT_RIGHT*)  (available: true; neighbours :  (BT_ACCEPT,  BT_NONE, BT_DOWN, BT_NONE)),
      (*BT_ONE*)    (available: false;  neighbours : (BT_NONE,  BT_NONE, BT_NONE, BT_NONE)),
      (*BT_TWO*)    (available: false;  neighbours : (BT_NONE,  BT_NONE, BT_NONE, BT_NONE)),
      (*BT_THREE*)  (available: false;  neighbours : (BT_NONE,  BT_NONE, BT_NONE, BT_NONE)),
      (*BT_FOUR*)   (available: false;  neighbours : (BT_NONE,  BT_NONE, BT_NONE, BT_NONE)),
      (*BT_FIVE*)   (available: false;  neighbours : (BT_NONE,  BT_NONE, BT_NONE, BT_NONE)),
      (*BT_SIX*)    (available: false;  neighbours : (BT_NONE,  BT_NONE, BT_NONE, BT_NONE)),
      (*BT_SEVEN*)  (available: false;  neighbours : (BT_NONE,  BT_NONE, BT_NONE, BT_NONE)),
      (*BT_EIGHT*)  (available: false;  neighbours : (BT_NONE,  BT_NONE, BT_NONE, BT_NONE)),
      (*BT_NINE*)   (available: false;  neighbours : (BT_NONE,  BT_NONE, BT_NONE, BT_NONE)),
      (*BT_ZERO*)   (available: false;  neighbours : (BT_NONE,  BT_NONE, BT_NONE, BT_NONE)));

constructor TKeySequences.init;
begin
  keySequences_.init;
end;

destructor TKeySequences.done;
begin
  keySequences_.done;
end;
        
procedure TKeySequences.addSequence(sequence: PKeySequenceItem);
begin
  keySequences_.pushBack(sequence);
end;

procedure TKeySequences.sort;
begin
  sortQueue(@keySequences_);
end;

procedure TKeySequences.keepOnlyShortest;
begin
  sortQueue(@keySequences_);
  while (keySequences_.size > 0) and
        (PKeySequenceItem(keySequences_.front)^.length < PKeySequenceItem(keySequences_.back)^.length) do
        keySequences_.popBack;
end;

procedure TKeySequences.keepOnlyOne;
begin
  while keySequences_.size > 1 do keySequences_.popBack;
end;

constructor TButtonItem.init(const key: TButton);
begin
  key_ := key;
end;

constructor TKeySequenceItem.init;
begin
  sequence_.init;
end;

function TKeySequenceItem.compare(other:PItemType):TRelation;
var otherLength : word;
    ourLength   : word;
begin
  otherLength := PKeySequenceItem(other)^.sequence_.size;
  ourLength  := sequence_.size;
  
  if ourLength > otherLength then compare := BIGGER else 
  if ourLength < otherLength then compare := SMALLER else 
  compare := EQUAL;
end;

procedure TKeySequenceItem.pushBack(const button: TButton);
begin
  sequence_.pushBack(new(PButtonItem, init(button)));
end;

procedure TKeySequenceItem.popBack;
begin
  sequence_.popBack;
end;

function TKeySequenceItem.length: word;
begin
  length := sequence_.size;
end;

destructor TKeySequenceItem.done;
begin
  sequence_.done;
end;

constructor TKeySequenceItem.copy(const other: PKeySequenceItem);
var it : PDequeueIterator;
begin
  it := other^.sequence_.first;
  while it <> nil do begin
    sequence_.pushBack(new(PButtonItem, init(PButtonItem(it^.at)^.key_)));
    it := it^.next;
  end;
end;

function TKeySequenceItem.append(const other: PKeySequenceItem): word;
var it : PDeQueueIterator;
begin
  it := other^.sequence_.first;
  while it <> nil do begin
     sequence_.pushBack(new(PButtonItem, init(PButtonItem(it^.at)^.key_)));
     it := it^.next;
  end;
  append := other^.sequence_.size;
end;

procedure TKeySequenceItem.remove(const length: word);
var dropped : word;
begin
  dropped := 0;
  while (dropped < length) and (sequence_.size > 0) do begin
    sequence_.popBack;
    inc(dropped);
  end;
end;

procedure buildKeySequence(const keyMap: TKeyPad;
                           const startKey: TButton;
                           const targetKey: TButton;
                           var sequences : TKeySequences);
    function mapDirToButton(const dir: TDirection) : TButton;
    begin
      case dir of
        North: mapDirToButton := BT_UP;
        South: mapDirToButton := BT_DOWN;
        East:  mapDirToButton := BT_RIGHT;
        West:  mapDirToButton := BT_LEFT;
      else assert(false, 'Invalid direction');
      end 
    end;
    
    procedure recurseSteps(const currentKey: TButton;
                           visited : TKeySet;
                           sequence : PKeySequenceItem
                          );
    var dir : TDirection;  
    begin
      if sequence^.length > 6 then exit; (* The longest shortest sequence has 5 steps *)
      if currentKey = targetKey then begin
        sequences.addSequence(new(PKeySequenceItem, copy(sequence)));
        PKeySequenceItem(sequences.keySequences_.back)^.pushBack(BT_ACCEPT);
      end else begin
        visited := visited + [currentKey];
        for dir := North to South do begin
          if not(keyMap[currentKey].neighbours[dir] in visited) then begin
            sequence^.pushBack(mapDirToButton(dir));
            recurseSteps(keyMap[currentKey].neighbours[dir],
                         visited,
                         sequence);
            sequence^.popBack;
          end;
        end;
      end;
    end;
var sequence : PKeySequenceItem;
begin
  sequence := new(PKeySequenceItem, init);
  recurseSteps(startKey, [BT_NONE, startKey], sequence);
  Dispose(sequence, done);

  (* Drop all longer sequences than the shortests ones *)
  sequences.keepOnlyShortest;

end;

procedure printKeySequence(const sequence: PKeySequenceItem);
var it : PDequeueIterator;
begin
  it := sequence^.sequence_.first;
  while it <> nil do begin
    case PButtonItem(it^.at)^.key_ of
      BT_ACCEPT : write('A');
      BT_NONE   : write('N');
      BT_UP     : write('^');
      BT_DOWN   : write('v');
      BT_LEFT   : write('<');
      BT_RIGHT  : write('>');
      BT_ONE    : write('1');
      BT_TWO    : write('2');
      BT_THREE  : write('3');
      BT_FOUR   : write('4');
      BT_FIVE   : write('5');
      BT_SIX    : write('6');
      BT_SEVEN  : write('7');
      BT_EIGHT  : write('8');
      BT_NINE   : write('9');
      BT_ZERO   : write('0');
    end;
    it := it^.next;
  end;
  writeln;
end;

procedure mapKeySequence(const keyMap: TKeyPad;
                         const sequence: PKeySequenceItem;
                         var   mapedSequences : PKeySequences;
                         const skipPermutation: boolean;
                         const limit          : word);
var
    backLog   : PDeQueue;

    procedure permutateBackLog(backLogIt: PDequeueIterator;
                               currentSequence: PKeySequenceItem);
    var sequenceIt : PDequeueIterator;
        length     : word;
    begin
      if backLogIt = nil then begin
         mapedSequences^.addSequence(new(PKeySequenceItem,copy(currentSequence)));
      end else begin
         sequenceIt := PKeySequences(backLogIt^.at)^.keySequences_.first;
         while sequenceIt <> nil do begin
           length := currentSequence^.append(PKeySequenceItem(sequenceIt^.at));
           permutateBackLog(backLogIt^.next, currentSequence);
           currentSequence^.remove(length);
           sequenceIt := sequenceIt^.next;
         end;
      end;    
    end;

var sequences  : PKeySequences;
    currentKey : TButton;
    nextKey    : TButton;
    it         : PDequeueIterator;
    tempSeqItem: PKeySequenceItem;
    currentLength: word;
begin
  currentKey := BT_ACCEPT;
  it := sequence^.sequence_.first;
  backLog := new(PDeQueue, init);
  currentLength := 0;

  while it <> nil do begin
    sequences := new(PKeySequences, init);
    nextKey := PButtonItem(it^.at)^.key_;
    buildKeySequence(keyMap, currentKey, nextKey, sequences^);
    if skipPermutation then sequences^.keepOnlyOne; (* No permutation needed keep only the best one *)
    inc(currentLength, PKeySequenceItem(sequences^.keySequences_.front)^.length);
    if currentLength > limit then begin
      backLog^.done;
      Dispose(sequences, done);
      mapedSequences := nil;
      exit;
    end;
    backLog^.pushBack(sequences);
    it := it^.next;
    currentKey := nextKey;
  end;
  tempSeqItem := new(PKeySequenceItem, init);
  
  mapedSequences := new(PKeySequences, init);
  if not skipPermutation then
    permutateBackLog(backLog^.first, tempSeqItem)
  else begin
    it := backLog^.first;
    while it <> nil do begin
      tempSeqItem^.append(PKeySequenceItem(PKeySequences(it^.at)^.keySequences_.front));
      it := it^.next;
    end;
    mapedSequences^.addSequence(new(PKeySequenceItem, copy(tempSeqItem)));
  end;
  Dispose(tempSeqItem, done); 
  backLog^.dispose;
end;

function buildKeySequenceFromString(const s: string;
                                     var sequence: PKeySequenceItem): word;
var i     : integer;
    number: word;
begin
  number := 0;
  sequence := new(PKeySequenceItem, init);

  for i:= 1 to length(s) do
     case s[i] of
     'A' : sequence^.pushBack(BT_ACCEPT);
     '^' : sequence^.pushBack(BT_UP);
     'v' : sequence^.pushBack(BT_DOWN);
     '<' : sequence^.pushBack(BT_LEFT);
     '>' : sequence^.pushBack(BT_RIGHT);
     '1' : begin 
            number := number * 10; 
            inc(number,1);
            sequence^.pushBack(BT_ONE);
           end;
     '2' : begin 
            number := number * 10; 
            inc(number,2);
            sequence^.pushBack(BT_TWO);
           end;
     '3' : begin 
            number := number * 10; 
            inc(number,3);
            sequence^.pushBack(BT_THREE);
           end;
     '4' : begin 
            number := number * 10; 
            inc(number,4);
            sequence^.pushBack(BT_FOUR);
           end;
     '5' : begin 
            number := number * 10; 
            inc(number,5);
            sequence^.pushBack(BT_FIVE);
           end;
     '6' : begin 
            number := number * 10; 
            inc(number,6);
            sequence^.pushBack(BT_SIX);
           end;
     '7' : begin 
            number := number * 10; 
            inc(number,7);
            sequence^.pushBack(BT_SEVEN);
           end;
     '8' : begin 
            number := number * 10; 
            inc(number,8);
            sequence^.pushBack(BT_EIGHT);
           end;
     '9' : begin 
            number := number * 10; 
            inc(number,9);
            sequence^.pushBack(BT_NINE);
           end;
     '0' : begin 
            number := number * 10; 
            inc(number,0);
            sequence^.pushBack(BT_ZERO);
           end;
     else assert(false, 'Invalid character in input string');
     end;
  buildKeySequenceFromString := number;
end;

function shortestControlSequence(numericPad: PKeySequenceItem): word;
var controlPad1 : PKeySequences;
    controlPad2 : PKeySequences;
    controlPad3 : PKeySequences;
    it          : PDequeueIterator;
    it2         : PDeQueueIterator;
    it3         : PDequeueIterator;
    minLength   : word;
begin
  mapKeySequence(NumericKeyPad, numericPad, controlPad1, false, $ffff);
  it := controlPad1^.keySequences_.first;
  minLength := $ffff;

  while it <> nil do begin
    mapKeySequence(DirectionalKeyPad, PKeySequenceItem(it^.at), controlPad2, false, $ffff);
    it2 := controlPad2^.keySequences_.first;
    while it2 <> nil do begin
      (* To conserve memory and cpu time, no permutation of the last one needed, we only
         need the fastest sequence 
       *)
      mapKeySequence(DirectionalKeyPad, PKeySequenceItem(it2^.at), controlPad3, true, minLength);
      it2 := it2^.next;
      if controlPad3 = nil then continue;
      it3 := controlPad3^.keySequences_.first;
      while it3 <> nil do begin
        if minLength > PKeySequenceItem(it3^.at)^.length then begin
           minLength := PKeySequenceItem(it3^.at)^.length;
           printKeySequence(PKeySequenceItem(it3^.at));
        end;
        it3 := it3^.next;
      end;
      Dispose(controlPad3, done);
    end;
    Dispose(controlPad2, done);
    it := it^.next;
  end;
  Dispose(controlPad1, done);
  shortestControlSequence := minLength;
end;

function part1(var input: Text):comp; far;
var pad         : PKeySequenceItem;
    sum, tmp    : comp;
    s           : string;
    number      : comp;
begin
  sum := 0;
  while not eof(input) do begin
    readln(input,s);
    number := buildKeySequenceFromString(s,pad);
    write(number:1);
    write(' ');
    printKeySequence(pad);

    tmp := shortestControlSequence(pad);
    Write('Shortest sequence: ');
    writeln(tmp:1);
    sum := sum + number*tmp;
    Dispose(pad, done);
  end;
  part1 := sum;
end;

function part2(var input: Text):comp; far;
begin
  part2 := 0;
end;

begin
  runAoc(InputFileName, 21, part1, part2, nil, nil);
end.
