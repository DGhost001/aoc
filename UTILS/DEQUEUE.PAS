unit DeQueue;

interface

uses ItemHandler, ProgressBar;

    type
        (* Type definiton for the dequeue iterator *)
        PDeQueueIterator = ^TDeQueueIterator;
        TQueueLambda     = procedure(it:PDeQueueIterator);
        TDeQueueIterator = object
            destructor done;

            function next: PDeQueueIterator;
            function prev: PDeQueueIterator;
            function at: PItemType;
            procedure swap(other: PDeQueueIterator);

            private
                value_ : PItemType;
                next_  : PDeQueueIterator;
                prev_  : PDeQueueIterator;

                constructor init(item: PItemType);
                constructor insertAfter(item: PItemType; other: PDeQueueIterator);
                constructor insertBefore(item: PItemType; other: PDeQueueIterator);

                procedure moveBefore(other: PDeQueueIterator);
        end;

        (* The actual DeQueue Object definition *)
        PDeQueue = ^TDeQueue;
        TDeQueue = object
            constructor init;
            destructor  done;
            procedure dispose;

            procedure pushBack(item : PItemType);
            procedure pushFront(item : PItemType);
            procedure popBack;
            procedure popFront;
            procedure remove(item: PDeQueueIterator);
            procedure insertBefore(item:PItemType; it : PDeQueueIterator);
            procedure insertAfter(item:PItemType; it : PDeQueueIterator);

            function  front: PItemType;
            function  back: PItemType;
            function  at(pos:word): PItemType;

            function first: PDeQueueIterator;
            function last: PDeQueueIterator;
            function size: word;

            procedure forEachP(lambda : TQueueLambda; progress : PProgressBar);
            procedure forEach(lambda : TQueueLambda);

            procedure moveBefore( a, b: PDeQueueIterator); (* Move a before b *)

            private
                first_ : PDeQueueIterator;
                last_  : PDeQueueIterator;
                length_: word;
        end;
implementation

uses cassert;

constructor TDeQueueIterator.init;
begin
    self.value_ := item;
    self.prev_ := NIL;
    self.next_ := NIL;
end;

constructor TDeQueueIterator.insertAfter;
begin
    self.value_ := item;
    self.prev_ := other;
    self.next_ := NIL;

    if other <> NIL then begin
        self.next_ := other^.next_;
        other^.next_ := @self;
        if self.next_ <> NIL then
            self.next_^.prev_ := @self;
    end;
end;

constructor TDeQueueIterator.insertBefore;
begin
    self.value_ := item;
    self.prev_ := NIL;
    self.next_ := other;

    if other <> NIL then begin
        self.prev_ := other^.prev_;
        other^.prev_ := @self;
        if self.prev_ <> NIL then
            self.prev_^.next_ := @self;
    end;
end;

destructor TDeQueueIterator.done;
begin
    if self.prev_ <> NIL then self.prev_^.next_ := self.next_;
    if self.next_ <> NIL then self.next_^.prev_ := self.prev_;
    self.prev_ := NIL;
    self.next_ := NIL;
    dispose(self.value_, done);
end;

function TDeQueueIterator.next;
begin
    next := self.next_;
end;

function TDeQueueIterator.prev;
begin
    prev := self.prev_;
end;

function TDeQueueIterator.at;
begin
    at := self.value_;
end;

procedure TDeQueueIterator.swap;
var t : PItemType;
begin
  t := value_;
  value_ := other^.value_;
  other^.value_ := t;
end;

procedure TDeQueueIterator.moveBefore;
begin
  (*  Remove this iterator from the chain *)
  if next_ <> NIL then next_^.prev_ := prev_;
  if prev_ <> NIL then prev_^.next_ := next_;

  (* No fiddle it back in *)
  next_  := other;
  prev_  := other^.prev_;
  other^.prev_ := @self;

  if prev_ <> NIL then prev_^.next_ := @self;
end;

constructor TDeQueue.init;
begin
    self.first_ := NIL;
    self.last_  := NIL;
    self.length_:= 0;
end;

destructor TDeQueue.done;
var
    next : PDeQueueIterator;
    it   : PDeQueueIterator;
begin
    it := self.first;

    while it <> NIL do begin
        next := it^.next;
        SYSTEM.dispose(it, done);
        it := next;
    end
end;

procedure TDeQueue.dispose;
begin
  SYSTEM.dispose(PDeQueue(@self),done);
end;

procedure TDeQueue.pushBack;
begin
    self.last_:= new(PDeQueueIterator, insertAfter(item, self.last_));
    if self.first_ = NIL then
        self.first_ := self.last_;
    inc(self.length_);
end;

procedure TDeQueue.pushFront(item : PItemType);
begin
    self.first_ := new(PDeQueueIterator, insertBefore(item, self.first_));
    if self.last_ = NIL then
        self.last_ := self.first_;
    inc(self.length_);
end;

procedure TDeQueue.popBack;
var it : PDeQueueIterator;
begin
    if self.last_ <> NIL then begin
        if self.first_ = self.last_ then self.first_ := NIL;
        it := self.last_;
        self.last_ := self.last_^.prev;

        SYSTEM.dispose(it, done);
        dec(self.length_);
    end;
end;

procedure TDeQueue.popFront;
var it : PDeQueueIterator;
begin
    if self.first_ <> NIL then begin
        if self.first_ = self.last_ then self.last_ := NIL;

        it := self.first_;
        self.first_ := self.first_^.next;

        SYSTEM.dispose(it, done);
        dec(self.length_);
    end;
end;

procedure TDeQueue.remove;
begin
    if item <> NIL then begin
        if item = self.first_ then
            self.popFront
        else if item = self.last_ then
            self.popBack
        else begin
            SYSTEM.dispose(item, done);
            dec(self.length_);
        end;
    end;
end;

procedure TDeQueue.insertBefore(item:PItemType; it : PDeQueueIterator);
var it2 : PDeQueueIterator;
begin
  assert(it <> nil, 'Invalid iterator supplied');

  it2 := new(PDequeueIterator,insertBefore(item,it));
  if self.first_ = it then self.first_ := it2;

  inc(self.length_);
end;

procedure TDeQueue.insertAfter(item:PItemType; it : PDeQueueIterator);
var it2 : PDeQueueIterator;
begin
  assert(it <> nil, 'Invalid iterator supplied');

  it2 := new(PDequeueIterator,insertAfter(item,it));
  if self.last_ = it then self.last_ := it2;

  inc(self.length_);
end;



function  TDeQueue.front: PItemType;
begin
    if self.first_ <> NIL then
        front:= self.first_^.at
    else
        front:= NIL
end;

function  TDeQueue.back: PItemType;
begin
    if self.last_ <> NIL then
        back:= self.last_^.at
    else
        back:= NIL;
end;

function  TDeQueue.at;
var it : PDeQueueIterator;
begin
    it := self.first_;
    while (pos > 0) and (it <> NIL) do begin
        dec(pos);
        it := it^.next;
    end;

    if it <> NIL then
        at := it^.at
    else
        at := NIL;
end;

function TDeQueue.first;
begin
    first := self.first_;
end;

function TDeQueue.last;
begin
    last := self.last_;
end;

function TDeQueue.size;
begin
    size:= self.length_;
end;

procedure TDeQueue.forEachP;
var it :PDeQueueIterator;
begin
  it := first;
  while it <> NIL do begin
    lambda(it);
    if progress <> NIL then progress^.step(1);
    it := it^.next;
  end;
end;

procedure TDeQueue.forEach;
var progress : PProgressBar;
begin
  progress := new(PProgressBar,init(size,'Calc..'));
  forEachP(lambda, progress);
  progress^.dispose;
end;

procedure TDeQueue.moveBefore;
begin
  if a = last_ then last_ := a^.prev_;
  if b = first_ then first_ := a;

  a^.moveBefore(b);
end;


begin
end.