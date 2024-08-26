unit JSTRING;
{$X+}

interface

uses DeQueue,ItemHandler;

type
    PJString = ^TJString;
    PJChar   = ^char;

    PJStringIterator = ^TJStringIterator;
    TJStringIterator = object
        constructor copy(other: PJStringIterator);
        destructor done;

        function valid: boolean;
        function next: boolean;
        function prev: boolean;
        function equal(other: PJStringIterator): boolean;
        function at: PJChar;
        procedure dispose;

        private
            inBlockPos_  : word;
            blockIt_     : PDeQueueIterator;
            constructor init(inBlockPos: word; blockIt : PDeQueueIterator);
    end;

    TJString = object(ItemType)
        constructor init(s:string);
        constructor copy(other: PJString);
        constructor copyIt(beginning, ending: PJStringIterator);

        destructor done; virtual;
        procedure dispose;

        procedure append(other: PJString);
        procedure pushBack(character: char);
        procedure capitalize;
        procedure casefold;
        procedure upper;

        function center(length:word; character:char): PJString;
        function expandTabs(tabsize: word): PJString;

        function equal(other: PJString): boolean;
        function equalIt(start, beginning, ending : PJStringIterator): boolean;
        function endsWith(other: PJString): boolean;
        function beginsWith(other: PJString): boolean;
        function count(other: PJString):word;

        function find(other: PJString; start: PJStringIterator): PJStringIterator;
        function first: PJStringIterator;
        function last: PJStringIterator;
        function isIn(other:PJString): boolean;

        function split(seperator: char): PDeQueue;
        function stripWhiteSpace: PJString;

        function toString: string;

        function size:word;

    private
        data_   : PDeQueue;
        length_ : word;

    end;

    function cJString(str:string): PJString;
    function ReadLine(var f: Text) : PJString;

implementation

const MaxStringBlockSize = 32;

type  PStringRecord = ^TStringRecord;
      TStringRecord = object(ItemType)
        stringData_ : array [0..MaxStringBlockSize-1] of char;
        fillLength_ : word;

        constructor init;
        constructor copy(other: PStringRecord);

        function isFull: boolean;
        function isEmpty: boolean;

        function pushBack(character: char):boolean;
        function popBack:boolean;

      end;

function isSpace(character: char): boolean;
begin
    isSpace :=  (ord(character) = $20) or
                (ord(character) = $0a) or
                (ord(character) = $0d) or
                (ord(character) = $09);
end;

constructor TStringRecord.init;
begin
    self.fillLength_ := 0;
end;

constructor TStringRecord.copy;
begin
    self.fillLength_ := other^.fillLength_;
    self.stringData_ := other^.stringData_;
end;

function TStringRecord.isFull;
begin
    isFull := self.fillLength_ >= MaxStringBlockSize;
end;

function TStringRecord.isEmpty;
begin
    isEmpty := self.fillLength_ = 0;
end;

function TStringRecord.pushBack;
begin

    if not self.isFull then begin
        self.stringData_[self.fillLength_] := character;
        inc(self.fillLength_);
        pushBack := true;
    end else
        pushBack := false;
end;

function TStringRecord.popBack;
begin
    if not self.isEmpty then begin
        dec(self.fillLength_);
        popBack := true;
    end else
        popBack := false;
end;

constructor TJStringIterator.init;
begin
    self.inBlockPos_ := inBlockPos;
    self.blockIt_ := blockIt;
end;

constructor TJStringIterator.copy;
begin
    self.inBlockPos_ := other^.inBlockPos_;
    self.blockIt_ := other^.blockIt_;
end;

destructor TJStringIterator.done;
begin
    (* Empty for now *)
end;

procedure TJStringIterator.dispose;
begin
    system.dispose(PJStringIterator(@self), done); (* self destruct ... *)
end;

function TJStringIterator.valid;
begin
    valid := (self.blockIt_ <> NIL) and (self.inBlockPos_ < PStringRecord(self.blockIt_^.at)^.fillLength_);
end;

function TJStringIterator.next;
begin
    with self do begin
        if valid then begin
            inc(inBlockPos_);
            if inBlockPos_ >= MaxStringBlockSize then begin
                inBlockPos_ := 0;
                blockIt_ := blockIt_^.next;
            end;
        end;
    end;
    next := valid;
end;

function TJStringIterator.prev;
begin
    with self do begin
        if valid then begin
            if inBlockPos_ > 0 then
                dec(inBlockPos_)
            else begin
                blockIt_ := blockIt_^.prev;
                if blockIt_ <> NIL then
                    inBlockPos_ := PStringRecord(blockIt_^.at)^.fillLength_ - 1
                else
                    inBlockPos_ := 0;
            end;
        end;
    end;
    prev := valid;
end;

function TJStringIterator.equal;
begin
    equal := (other^.valid) and
             (self.valid) and
             (other^.inBlockPos_ = self.inBlockPos_) and
             (other^.blockIt_ = self.blockIt_);
end;

function TJStringIterator.at;
begin
  if valid then
     at := @(PStringRecord(blockIt_^.at)^.stringData_[inBlockPos_])
  else
     at := NIL;
end;

constructor TJString.init;
var i           : integer;
    currentBlock: PStringRecord;
begin
    self.length_ := system.length(s);
    self.data_ := new(PDeQueue, init);
    currentBlock := new(PStringRecord,init);
    self.data_^.pushBack(currentBlock);

    for i:=0 to system.length(s) - 1 do begin
        if (not currentBlock^.pushBack(s[i+1]))
           then begin
            currentBlock := new(PStringRecord,init);
            self.data_^.pushBack(currentBlock);
            currentBlock^.pushBack(s[i+1]);
        end;
    end;
end;

constructor TJString.copy;
var it          : PDeQueueIterator;
begin
    self.length_ := other^.length_;
    self.data_ := new(PDeQueue, init);

    it := other^.data_^.first;
    while it <> NIL do begin
        self.data_^.pushBack(new(PStringRecord, copy(PStringRecord(it^.at))));
        it := it^.next;
    end;
end;

constructor TJString.copyIt;
var it: PJStringIterator;
begin
    self.length_ := 0;
    self.data_ := new(PDeQueue, init);
    self.data_^.pushBack(new(PStringRecord,init));

    (* Make a temporary copy of the provided iterator as we need to change it *)
    it := new(PJStringIterator, copy(beginning));

   while it^.valid and  not it^.equal(ending) do begin
        self.pushBack(it^.at^);
        it^.next;
    end;

    it^.dispose;
end;

destructor TJString.done;
begin
    self.length_ := 0;
    system.dispose(self.data_, done);
end;

procedure TJString.dispose;
begin
    system.dispose(PJString(@self),done);
end;

function TJString.first;
begin
    first := new(PJStringIterator, init(0, self.data_^.first));
end;

function TJString.last;
var it : PDeQueueIterator;
begin
    it := self.data_^.last;
    if it <> NIL then
        last:= new(PJStringIterator, init(PStringRecord(it^.at)^.fillLength_ -1, it))
    else
        last:= new(PJStringIterator, init(0,it));
end;

procedure TJString.append;
var  it          : PJStringIterator;
     currentBlock: PStringRecord;
     ch          : char;
begin
    it := other^.first;
    currentBlock := PStringRecord(self.data_^.last^.at);
    while it^.valid do begin
        ch := it^.at^;
        if not currentBlock^.pushBack(ch) then begin
            currentBlock := new(PStringRecord, init);
            self.data_^.pushBack(currentBlock);
            currentBlock^.pushBack(ch);
        end;
    end;

    it^.dispose;
    self.length_ := self.length_ + other^.length_;
end;

procedure TJString.capitalize;
var it : PJStringIterator;
    up : boolean;
    tmp: PJChar;
begin
    it := self.first;
    up := True;

    while it^.valid do begin
        tmp := it^.at;
        if isSpace(tmp^) then
            up:= true
        else if up then begin
            up := false;
            tmp^:= UpCase(tmp^);
        end;
        it^.next;
    end;

    it^.dispose;
end;

procedure TJString.casefold;
var it      : PJStringIterator;
    tmp     : PJChar;
    charcode: integer;
begin
    it := self.first;
    while it^.valid do begin
        tmp := it^.at;
        charcode := ord(tmp^);
        if (charcode >= ord('A')) and (charcode <= ord('Z')) then
            tmp^ := chr(charcode - ord('A') + ord('a'));
        it^.next;
    end;
    it^.dispose;
end;

procedure TJString.upper;
var it      : PJStringIterator;
    tmp     : PJChar;
begin
    it := self.first;
    while it^.valid do begin
        tmp^ := UpCase(tmp^);
        it^.next;
    end;

    it^.dispose;
end;

procedure TJString.pushBack;
var
    currentBlock: PStringRecord;
begin
    currentBlock := PStringRecord(self.data_^.last^.at);
    if not currentBlock^.pushBack(character) then begin
            currentBlock := new(PStringRecord, init);
            self.data_^.pushBack(currentBlock);
            currentBlock^.pushBack(character);
    end;
    inc(self.length_);
end;

function TJString.center;
var
    beginning       : PJStringIterator;
    ending          : PJStringIterator;
    spaceBefore     : word;
    spaceAfter      : word;
    insertBefore    : word;
    insertAfter     : word;
    cleanLength     : word;
    resultingString : PJString;
    i               : word;
begin
    beginning := self.first;
    ending    := self.last;

    while beginning^.valid and isSpace(beginning^.at^) do begin
        inc(spaceBefore);
        beginning^.next;
    end;

    while ending^.valid and isSpace(ending^.at^) do begin
        inc(spaceAfter);
        ending^.prev;
    end;

    ending^.next; (* Go one step back, so we mark the first char not belonging to the string we want *)

    if(spaceBefore + spaceAfter < self.length_) then begin

        cleanLength := self.length_ - spaceAfter - spaceBefore;

        if cleanLength < self.length_ then begin
            insertBefore := (self.length_ - cleanLength) div 2;
            insertAfter  := self.length_ - cleanLength - insertBefore;

            resultingString := new(PJString, init(''));

            for i:=1 to insertBefore do begin
                resultingString^.pushBack(character);
            end;

            while not beginning^.equal(ending) do begin
                resultingString^.pushBack(beginning^.at^);
                beginning^.next;
            end;

            for i:=1 to insertAfter do begin
                resultingString^.pushBack(character);
            end;

            center:=resultingString;

        end else
            center:= new(PJString, copyIt(beginning, ending));

    end else
        center := new(PJString, copy(@self));

    beginning^.dispose;
    ending^.dispose
end;

function TJString.equal(other: PJString): boolean;
var beginning : PJStringIterator;
    ending    : PJStringIterator;
begin
    beginning := other^.first;
    ending    := other^.last;

    ending^.next; (* Point one char after the string, so that we get the full string *)

    equal := (self.length_ = other^.length_) and self.equalIt(NIL, beginning, ending);

    ending^.dispose;
    beginning^.dispose;
end;

function TJString.equalIt;
var
    startIt : PJStringIterator;
    otherIt : PJStringIterator;
begin
    if start = NIL then
        startIt := self.first
    else
        startIt := new(PJStringIterator, copy(start));

    otherIt := new(PJStringIterator, copy(beginning));

    if not otherIt^.equal(ending) then begin (* Check if the string is empty ... they can't be equal *)
        while startIt^.valid and
            otherIt^.valid and
            not otherIt^.equal(ending) and
            (startIt^.at^ = otherIt^.at^)
        do begin
            startIt^.next;
            otherIt^.next;
        end;

        equalIt := otherIt^.equal(ending) or (* We consumed the full checking string *)
                 not otherIt^.valid;     (* We are at the end of the comparator *)
    end else
        equalIt := false;

    startIt^.dispose;
    otherIt^.dispose;
end;

function TJString.endsWith;
var     start                   : PJStringIterator;
        otherFirst, otherEnding : PJStringIterator;
         i : integer;
begin
        start      := self.last;
        otherFirst := other^.first;
        otherEnding:= other^.last;

        otherEnding^.next;

        for i := 2 to other^.length_ do
            start^.prev;

        endsWith := equalIt(start,otherFirst, otherEnding );

        otherEnding^.dispose;
        otherFirst^.dispose;
        start^.dispose;
end;

function TJString.beginsWith;
var     start                   : PJStringIterator;
        otherFirst, otherEnding : PJStringIterator;
begin
        start      := self.first;
        otherFirst := other^.first;
        otherEnding:= other^.last;

        otherEnding^.next;

        beginsWith := equalIt(start,otherFirst, otherEnding );

        otherEnding^.dispose;
        otherFirst^.dispose;
        start^.dispose;
end;

function TJString.count;
var     start,tmp               : PJStringIterator;
        resulting               : word;
begin
    resulting := 0;

    start := self.first;

    while(start^.valid) do begin
        tmp := find(other, start);
        if tmp^.valid then inc(resulting);
        start^.dispose;
        start:=tmp;
        start^.next;
    end;

    count := resulting;
end;

function TJString.expandTabs;
var resulting : PJString;
    it        : PJStringIterator;
    character : char;
    i         : integer;
begin
    resulting := new (PJString,init(''));

    it := self.first;

    while it^.valid do begin
        character := it^.at^;
        if ord(character) = $09 then begin
            for i:=1 to tabsize do
                resulting^.pushBack(' ');
        end else
            resulting^.pushBack(character);
    end;

    it^.dispose;
    expandTabs := resulting;
end;

function TJString.find;
var itStart      : PJStringIterator;
    itSearch     : PJStringIterator;
    otherIt      : PJStringIterator;
    jumpTable    : array [0..255] of word;
    found        : boolean;
    i            : word;

    procedure setupJumpTable(other: PJString);
    var     i   : integer;
            it  : PJStringIterator;
            jc  : word;
    begin
        for i:=0 to 255 do
            jumpTable[i] := other^.length_; (* Setup the jump table to be the length of the pattern *)

        it := other^.first;
        jc := 0;
        while it^.valid do begin
            jumpTable[ord(it^.at^)]:= other^.length_ - jc - 1;
            inc(jc);
            it^.next;
        end;
    end;


begin
    if start = NIL then
        itStart := self.first
    else
        itStart := new(PJStringIterator, copy(start));

    found := false;

    if other^.length_ > 0 then begin


        setupJumpTable(other);

        for i:=1 to other^.length_ do
            itStart^.next;

        while itStart^.valid and not found do begin

            otherIt := other^.last;
            itSearch := new(PJStringIterator, copy(itStart));

            while otherIt^.valid and itSearch^.valid and
                (otherIt^.at^ = itSearch^.at^) do begin
                otherIt^.prev;
                itSearch^.prev;
            end;

            if not otherIt^.valid then begin
                found := true;
                find := itSearch;
            end else begin
                for i:=1 to jumpTable[ord(itSearch^.at^)] do itStart^.next;
                itSearch^.dispose;
            end;

            otherIt^.dispose;
        end;
    end;

    if not found then begin
        itSearch := self.last;
        itSearch^.next;
        find:= itSearch;
    end;
end;

function TJString.isIn;
var   tmp : PJStringIterator;
begin
    tmp := other^.find(@self, NIL);
    isIn := tmp^.valid;
    tmp^.dispose;
end;

function TJString.stripWhiteSpace;
var
    its, ite  : PJStringIterator;
    removeStart : word;
    removeEnd   : word;
begin
    its := self.first;
    ite := self.last;
    removeStart := 0;
    removeEnd   := 0;

    while its^.valid and isSpace(its^.at^) do begin
        inc(removeStart);
        its^.next;
    end;

    while ite^.valid and isSpace(ite^.at^) do begin
        inc(removeEnd);
        ite^.prev;
    end;

    ite^.next; (* One Step back, so the it marks the first character to be removed *)

    if removeStart + removeEnd < self.length_ then begin
        stripWhiteSpace := new(PJString, copyIt(its, ite));
    end else
        stripWhiteSpace := new(PJString, init(''));

    its^.dispose;
    ite^.dispose;
end;

function TJString.split;
var its, ite : PJStringIterator;
    resulting: PDeQueue;
begin
    resulting := new(PDeQueue, init);

    its := self.first;
    ite := self.first;

    while its^.valid do begin
        while ite^.valid and (ite^.at^ <> seperator) do
            ite^.next;

        (* Push the substring into the queue *)
        resulting^.pushBack( new( PJString, copyIt( its, ite)));
        ite^.next; (* Skip the seperator *)

        (* Copy a new start iterator *)
        its^.dispose;
        its := new(PJStringIterator, copy(ite));

        (* Skip empty fields *)
        while its^.valid and ite^.valid and (its^.at^ = seperator) do begin
          its^.next;
          ite^.next;
        end;
    end;

    its^.dispose;
    ite^.dispose;

    split := resulting;

end;

function TJString.size;
begin
    size := length_;
end;

function TJString.toString;
var it     : PJStringIterator;
    result : string;
    i      : integer;
begin
    if length_ < 255 then begin
      it := self.first;
      i  := 1;
      result[0]:= chr (length_ and $ff);
      while it^.valid do begin
          result[i] := it^.at^;
          inc(i);
          it^.next;
      end;
      it^.dispose;
      toString := result;
    end else
      toString := '** String to long **';
end;

function cJString;
begin
    cJString := new(PJString, init(str));
end;

function ReadLine(var f: Text) : PJString;
var c      : char;
    result : PJString;
begin
  c:= #0;
  result := cJString(''); (* Create Empty String *)
  while (not eof(f)) and (c <> #10) do begin
    read(f,c);
    result^.pushBack(c);
  end;
  ReadLine := result;
end;

begin
end.
