program day20;
uses DeQueue, ItemHandler, Progressbar, crt;
(* This is the solution for day 20 of aoc 2023 *)
const InputFileName = 'INP\DAY20_IN.TXT';
type TSignal = (LowSignal, HighSignal);

     PEvents  = ^TEvents;
     TEvents = object(ItemType)
        src_    : word;
        dst_    : word;
        signal_ : TSignal;

        constructor init(const src, dst: word; const signal : TSignal);

     end;
     TModuleId= record
       id_  : word;
       ref_ : word;
     end;
     PModule = ^TModule;
     TModuleList = array[0..63] of PModule;
     TModule = object
        id_              : word;
        numberOfOutputs_ : byte;
        outputs_         : array[0..15] of TModuleId;
        state_           : TSignal;

        constructor init(const id: word);

        procedure addOutPut(const id : word); virtual;
        procedure addInput(const id : word); virtual;
        procedure connect(const modules: TModuleList); virtual;
        procedure trigger(const src: word; const signal: TSignal; outSignals: PDeQueue); virtual;
        function isDefault : boolean; virtual;
      end;

      PFlipFlop = ^TFlipFlop;
      TFlipFlop = object(TModule)
        constructor init(const id: word);
        procedure trigger(const src: word; const signal: TSignal; outSignals: PDeQueue); virtual;
      end;

      PNand = ^TNand;
      TNand = object(TModule)
        numberOfInputs_ : byte;
        inputs_ : array[0..15] of record
            id_   : word;
            state_: TSignal;
        end;

        constructor init(const id: word);
        procedure trigger(const src: word; const signal: TSignal; outSignals: PDeQueue); virtual;
        procedure addInput(const id : word); virtual;
        function isDefault : boolean; virtual;
      end;

      PBroadcast = ^TBroadcast;
      TBroadcast = object(TModule)
        constructor init(const id: word);
        procedure trigger(const src: word; const signal: TSignal; outSignals: PDeQueue); virtual;
      end;

var numberOfModules: byte;
    modules        : TModuleList;

constructor TEvents.init(const src, dst: word; const signal : TSignal);
begin
  src_ := src;
  dst_ := dst;
  signal_ := signal;
end;

constructor TModule.init(const id: word);
begin
  id_ := id;
  numberOfOutputs_ := 0;
  state_ := LowSignal;
  fillchar(outputs_,sizeof(outputs_),0);
end;

procedure TModule.addOutPut(const id : word);
begin
  if numberOfOutputs_ > HIGH(outputs_) then runError(300);
  outputs_[numberOfOutputs_].id_ := id;
  inc(numberOfOutputs_);
end;

procedure TModule.addInput(const id: word);
begin
  (* Nothing to be done here *)
end;

procedure TModule.connect(const modules: TModuleList);
var i,j : integer;
begin
  for i := 0 to numberOfOutputs_ - 1 do begin
    if outputs_[i].id_ = 465 (* rx *) then
      outputs_[i].ref_ := $fffe
    else
      outputs_[i].ref_ := $ffff;
    for j := 0 to HIGH(modules) do begin
      if (modules[j] <> NIL) and (modules[j]^.id_ = outputs_[i].id_) then begin
        outputs_[i].ref_ := j;
        modules[j]^.addInput(id_);
      end;
    end;
  end;
end;

procedure TModule.trigger(const src: word; const signal: TSignal; outSignals: PDeQueue);
begin
  state_ := signal;
end;

function TModule.isDefault: boolean;
begin
  isDefault := state_ = LowSignal;
end;

constructor TFlipFlop.init(const id : word);
begin
  TModule.init(id);
end;

procedure TFlipFlop.trigger(const src: word; const signal: TSignal; outSignals: PDeQueue);
var i : integer;
begin
  if (signal = LowSignal) then begin
    case state_ of
      LowSignal : state_ := HighSignal;
      HighSignal: state_ := LowSignal;
    end;

    for i := 0 to numberOfOutputs_ - 1 do begin
      outSignals^.pushBack(new(PEvents,init(id_, outputs_[i].ref_, state_)));
    end;
  end;
end;

constructor TNand.init(const id: word);
begin
  TModule.init(id);
  FillChar(inputs_, SizeOf(inputs_), 0);
  numberOfInputs_ := 0;
end;

procedure TNand.trigger(const src: word; const signal: TSignal; outSignals: PDeQueue);
var allHigh : boolean;
          i : integer;
begin
  allHigh := true;
  for i:=0 to numberOfInputs_ - 1 do begin
    if inputs_[i].id_ = src then inputs_[i].state_ := signal;
    allHigh := allHigh and (inputs_[i].state_ = HighSignal);
  end;

  if allHigh then state_ := LowSignal else state_ := HighSignal;

  for i:=0 to numberOfOutputs_ - 1 do begin
    outSignals^.pushBack(new(PEvents,init(id_, outputs_[i].ref_, state_)));
  end;
end;

procedure TNand.addInput(const id : word);
begin
  if numberOfInputs_ = HIGH(inputs_) then runError(300);
  inputs_[numberOfInputs_].id_ := id;
  inputs_[numberOfInputs_].state_ := LowSignal;

  inc(numberOfInputs_);
end;

function TNand.isDefault : boolean;
var i     : integer;
    allLow: boolean;
begin
  allLow := true;
  for i := 0 to numberOfInputs_ - 1 do
    allLow  := allLow and (inputs_[i].state_ = LowSignal);
  isDefault := allLow and TModule.isDefault;
end;

constructor TBroadcast.init(const id: word);
begin
  TModule.init(id);
end;

procedure TBroadcast.trigger(const src: word; const signal: TSignal; outSignals: PDeQueue);
var i: integer;
begin
  for i:= 0 to numberOfOutputs_ - 1 do begin
    outSignals^.pushBack(new(PEvents,init(id_, outputs_[i].ref_, signal)));
  end;
end;

function computeId(const s: string) : word;
var sum : word;
      i : integer;
begin
  sum := 0;
  if s = 'broadcaster' then sum := $ffff
  else for i := 1 to length(s) do
    sum := (sum * 26 + (ord(s[i]) - ord('a'))) and $ffff;

  computeId := sum;
end;
(* %bd -> lg, cm *)
procedure parseInputs(var input: Text);
  function createModule(const module: string) : byte;
  begin
    if numberOfModules > HIGH(modules) then runError(300);
    case module[1] of
         '%': modules[numberOfModules] :=
                 new(PFlipFlop, init(computeId(copy(module, 2, length(module) - 1))));
         '&': modules[numberOfModules] :=
                 new(PNand, init(computeId(copy(module, 2, length(module) - 1))));
         'b': modules[numberOfModules] :=
                 new(PBroadcast, init($ffff));
    else
        modules[numberOfModules] := new(PModule, init(computeId(module)));
    end;
    createModule := numberOfModules;
    inc(numberOfModules);
  end;

  procedure addOutputs(outputs: string; const module: byte);
  var p : byte;
  begin
    while length(outputs) > 0 do begin
      p := pos(',', outputs);
      if p = 0 then p := length(outputs) + 1;
      modules[module]^.addOutPut(computeId(copy(outputs,1, p - 1)));
      delete(outputs, 1, p + 1);
    end;
  end;

var line            : string;
    module, outputs : string;
    p               : byte;
begin
  while not eof(input) do begin
    readln(input, line);
    p := pos('->', line);
    if p <> 0 then begin
      module  := copy(line, 1, p - 2);
      outputs := copy(line, p+3, length(line));
      p:= createModule(module);
      addOutputs(outputs, p);
    end;
  end;
end;

procedure cleanup;
var i : integer;
begin
  for i:= 0 to numberOfModules - 1 do
    dispose(modules[i]);
end;

procedure connectAllModules;
var i : integer;
begin
  for i:=0 to numberOfModules - 1 do
    modules[i]^.connect(modules);
end;

function allDefault: boolean;
var result : boolean;
    i      : integer;
begin
  result := true;
  for i:=0 to numberOfModules - 1 do
    result := result and modules[i]^.isDefault;

  allDefault := result;
end;

procedure propagate(var lowSignals, highSignals: longint);
var list     : PDeQueue;
    start    : integer;

begin
  lowSignals  := 0;
  highSignals := 0;
  start := 0;
  while modules[start]^.id_ <> $ffff do inc(start);
  list  := new(PDeQueue,init);
  list^.pushBack(new(PEvents,init(start,start,LowSignal)));
  while list^.size > 0 do begin
    with PEvents(list^.front)^ do begin
      case signal_ of
           LowSignal : begin
              (* writeln(src_,' - low -> ',modules[dst_]^.id_); *)
              inc( lowSignals );
           end;
           HighSignal: begin
              (* writeln(src_,' - high -> ',modules[dst_]^.id_); *)
              inc( highSignals);
           end;
      end;

      if dst_ < numberOfModules then
        modules[dst_]^.trigger(src_, signal_, list)
    end;
    list^.popFront;
  end;
  list^.dispose;
end;

function propagate2: longint;
var list     : PDeQueue;
    start    : integer;
    count    : longint;
begin
  start := 0;
  count := 0;
  while modules[start]^.id_ <> $ffff do inc(start);
  list  := new(PDeQueue,init);
  list^.pushBack(new(PEvents,init(start,start,LowSignal)));
  while list^.size > 0 do begin
    with PEvents(list^.front)^ do begin
      if dst_  = $fffe then begin
        if signal_ = LowSignal then inc(count);
        if signal_ = HighSignal then inc(count,2);
      end;
      if dst_ < numberOfModules then
        modules[dst_]^.trigger(src_, signal_, list)
    end;
    list^.popFront;
  end;
  list^.dispose;
  propagate2 := count;
end;


function part1 : longint;
var count     : word;
    l, h      : longint;
    low, high : longint;
    p         : TProgressBar;
begin
  if not allDefault then runError(300); (* All Modules should be in default state *)
  p.init(1000,'count...');
  count := 1000;
  low   := 0;
  high  := 0;
  repeat
    propagate(l, h);
    low := low + l;
    high:= high + h;
    dec(count);
    p.step(1);
  until count = 0;
  p.done;
  part1 := low * high;
end;

function part2 : longint;
var count     : longint;
    l         : longint;
begin
  if not allDefault then runError(300); (* All Modules should be in default state *)
  count := 0;
  repeat
    l := propagate2;
    inc(count);
    if count mod 500 = 0 then
      write(#$0d,count,' ',l,'  ');
  until l = 1;
  part2 := count;
end;


var input  : Text;
    p1, p2 : longint;
begin
  clrscr;
  writeln(computeId('rx'));
  fillChar(modules, sizeof(modules), 0);
  assign(input, InputFileName);
  reset(input);
  parseInputs(input);
  connectAllModules;

  p1 := part1;
  writeln('Answer to part1 is:',p1);
  cleanup;

  numberOfModules := 0;
  fillChar(modules, sizeof(modules), 0);
  reset(input);
  parseInputs(input);
  connectAllModules;

  p2 := part2;
  writeln('Answer to part2 is:', p2);

end.
