program day15;
uses Itemhandler, Dequeue;

const InputFileName = 'INP\DAY15_IN.TXT';
type TOperation = (Insert, Remove);
     PLense = ^TLense;
     TLabel = string[8];

     TLense = object(ItemType)
        label_       : TLabel;
        hash_        : byte;
        focalLength_ : byte;

        constructor init(const l : TLabel; const focal: byte);
     end;

     TBox  = object
        lenses_ : PDequeue;

        constructor init;
        destructor done;

        procedure addLense(lense: PLense);
        procedure removeLense(const lense: TLabel);
        function focalPower: longint;
     end;

var boxes : array[0..255] of TBox;

procedure updateHash(const   c: char;
                     var  hash: byte);
var tmp : word;
begin
  tmp := ord(c) + hash;
  tmp := (tmp * 17) mod 256;
  hash := tmp;
end;

function hashLabel(const l : TLabel): byte;
var i: integer;
    h: byte;
begin
  h := 0;
  for i:=1 to length(l) do updateHash(l[i],h);
  hashLabel := h;
end;

constructor TLense.init;
var i: integer;
begin
  label_ := l;
  focalLength_ := focal;
  hash_  := hashLabel(l);
end;

constructor TBox.init;
begin
  lenses_ := new(PDequeue, init);
end;

destructor TBox.done;
begin
  lenses_^.dispose;
end;

procedure TBox.addLense;
var it : PDeQueueIterator;
begin
  it := lenses_^.first;
  while it <> NIL do begin
   if PLense(it^.at)^.label_ = lense^.label_ then break;
   it := it^.next;
  end;

  if it<> NIL then begin
   PLense(it^.at)^.focalLength_ := lense^.focalLength_;
   dispose(lense,done);
  end else lenses_^.pushBack(lense);
end;

procedure TBox.removeLense;
var it : PDeQueueIterator;
begin
  it := lenses_^.first;

  while it <> NIL do begin
    if PLense(it^.at)^.label_ = lense then begin
      lenses_^.remove(it);
      break;
    end;
    it := it^.next;
  end;
end;

function TBox.focalPower;
var
    it : PDeQueueIterator;
    result : longint;
    count  : word;
begin
  count := 0;
  result:= 0;
  it := lenses_^.first;
  while it <> NIL do begin
    inc(count);
    result := result + count*PLense(it^.at)^.focalLength_;
    it:= it^.next;
  end;
  focalPower := result;
end;


function part1(var input : Text): longint;
var sum : longint;
    hash: byte;
    c   : char;
begin
  sum := 0;
  hash:= 0;
  while not eof(input) do begin
    read(input, c);
    if not (c in [',',#13,#10]) then
      updateHash(c, hash)
    else begin
      inc(sum, hash);
      hash := 0;
    end;
  end;
  part1 := sum;
end;

function part2(var input: Text) : longint;
 procedure setupBoxes;
 var i: integer;
 begin
  for i:= LOW(boxes) to HIGH(boxes) do boxes[i].init;
 end;
 procedure finalizeBoxes;
 var i: integer;
 begin
   for i:= LOW(boxes) to HIGH(boxes) do boxes[i].done;
 end;

 function getLabel(var input:Text;
                   var operation: TOperation;
                   var parameter: byte): TLabel;
 var result : TLabel;
     c      : char;
 begin
   c:='z';
   result := '';
   while (not eof(input)) and (c in ['a'..'z']) do begin
     read(input,c);
     if c in ['a'..'z'] then result := result + c;
   end;
   if not (c in ['=','-']) then begin
     writeln('Unsupported operation "',c,'" for label "',result,'" detected');
     runError(300);
   end;
   if c='=' then begin
     operation := Insert;
     read(input, c);
     parameter := ord(c) - ord('0');
   end else begin
     operation := Remove;
     parameter := 255;
   end;
   read(input, c);
   if c=chr($0d) then read(input,c);
   getLabel := result;
 end;

 var l     : TLabel;
     op    : TOperation;
     param : byte;
     result: longint;
     i     : word;
 begin
  setupBoxes;
  while not eof(input) do begin
    l := getLabel(input, op, param);
    if op = Remove then
       boxes[hashLabel(l)].removeLense(l)
    else
       boxes[hashLabel(l)].addLense(new(PLense,init(l, param)));
  end;
  result := 0;
  for i:=0 to 255 do begin
    result := result + (i+1)*boxes[i].focalPower;
  end;

  finalizeBoxes;
  part2 := result;
 end;

var input : Text;
      p1  : longint;
      p2  : longint;
begin
  assign(input, InputFileName);
  reset(input);
  p1 := part1(input);
  reset(input);
  p2 := part2(input);
  close(input);

  writeln('Answer to part1 is: ', p1);
  writeln('Answer to part2 is: ', p2);
end.