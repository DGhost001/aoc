program day21;
(* This is the implementation for day 21 of advent of code 2023 *)
uses crt, cassert, dequeue, progressbar, itemhandler;

const InputFileName= 'INP\DAY21_IN.TXT';
      MaxX = 130;
      MaxY = 130;

type  TDirection = (North, South, West, East);
      TPos = record
         x_ : byte;
         y_ : byte;
      end;

      PBacklog = ^TBacklog;
      TBacklog = object(ItemType)
        pos_ : TPos;
        constructor init(const pos : TPos);
      end;

      TOccupancy = set of 0..MaxX;
      TMap = array [0..MaxY] of TOccupancy;

function adjustPosition(var pos: TPos;
                        const direction: TDirection): boolean;
var result : boolean;
begin
  result := true;
  case direction of
     North: if pos.x_  > 0    then dec(pos.x_) else result := false;
     South: if pos.x_  < MaxX then inc(pos.x_) else result := false;
     West : if pos.y_  > 0    then dec(pos.y_) else result := false;
     East : if pos.y_  < MaxY then inc(pos.y_) else result := false;
  end;
  adjustPosition := result;
end;

constructor TBacklog.init(const pos: TPos);
begin
  pos_ := pos;
end;

procedure loadMap(var input: Text;
                  var map  : TMap;
                  var start: TPos);

var x,y : byte;
   line : string;
begin

  fillchar(map,sizeof(map),0);
  start.x_ := 0;
  start.y_ := 0;

  for y:= 0 to MaxY do begin
    assert(not eof(input),'Not enougth lines');
    readln(input, line);
    assert(length(line) = (MaxX + 1),'Line to short');
    for x:= 0 to MaxX do begin
      if line[x+1] = '#' then map[y]:=map[y]+[x];
      if line[x+1] = 'S' then begin
        start.x_ := x;
        start.y_ := y;
      end;
    end;
  end;
end;

procedure oneStepForElves(var positions: PDequeue;
                          const map      : TMap);
var newPositions : PDequeue;
           pods  : TMap;
           tmp   : TPos;
           it    : PDeQueueIterator;
           d     : TDirection;
           p     : TProgressBar;
begin

  fillchar(pods,sizeof(pods),0);
  newPositions := new(PDequeue, init);
  it := positions^.first;
  p.init(positions^.size,'comp...');
  while it <> NIL do begin
    for d:= North to East do begin
      tmp := PBacklog(it^.at)^.pos_;
      if adjustPosition(tmp,d) then begin
        if (not (tmp.x_ in pods[tmp.y_])) and
           (not (tmp.x_ in map[tmp.y_])) then begin
             pods[tmp.y_] := pods[tmp.y_] + [tmp.x_];
             newPositions^.pushBack(new(PBacklog,init(tmp)));
           end;
      end;
    end;
    p.step(1);
    it := it^.next;
  end;
  p.done;
  positions^.dispose;
  positions := newPositions;

end;

function part1(var input: Text) : longint;
var map : TMap;
   start: TPos;
     pos: PDeQueue;
       p: TProgressBar;
       c: word;
begin
  loadMap(input, map, start);
  pos  := new(PDeQueue,init);
  pos^.pushBack(new(PBacklog,init(start)));
  p.init(64,'Step...');
  for c:=0 to 64 do begin
      oneStepForElves(pos, map);
      p.step(1);
  end;
  p.done;
  part1 := pos^.size;
  pos^.dispose;
end;

var input : Text;
       p1 : longint;
begin
  clrscr;
  assign(input, InputFileName);
  reset(input);
  p1 := part1(input);
  writeln('Answert part1 is: ', p1);

  close(input);
end.
