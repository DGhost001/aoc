program day14;
(*This is the implementation of the aoc24 day 14*)

uses aoc, utils, math, cassert, progressbar, graph;
const InputFileName = 'INP\DAY14_IN.TXT';
      Width = 101(* 11 *);
      Height= 103(* 7 *);
type  TRobot = record
        p, v : TPos;
      end;

procedure predictPosition(const robot: TRobot;
                          const time : longint;
                          var   pos  : TPos);
begin
  pos := robot.v;
  scalePos(time,pos);
  addPos(pos, robot.p);
  pos.x := modulo(pos.x, Width);
  pos.y := modulo(pos.y, Height);
end;

function getQuadrant(const pos : TPos): byte;
var q1, q2, q3 : boolean;
begin
  q1 := pos.y < Height div 2;
  q2 := pos.x < Width div 2;
  q3 := (pos.x = Width div 2) or (pos.y = Height div 2);
  getQuadrant := 5;
  if not q3 then begin
    if q1 then
      if q2 then
        getQuadrant := 1
      else
        getQuadrant := 2
    else
      if q2 then
        getQuadrant := 3
      else
        getQuadrant := 4
  end;
end;

procedure parseRobot(var input: Text; var robot: TRobot);
var c: char;
begin
  c := #0;
  while c <> '=' do read(input,c);
  robot.p.x := readLong(input);
  robot.p.y := readLong(input);
  c := #0;
  while c <> '=' do read(input,c);
  robot.v.x := readLong(input);
  robot.v.y := readLong(input);
  read(input,c);
end;

function part1(var input: Text):comp; far;
var sum  : comp;
    robot: TRobot;
    pos  : TPos;
    q    : array[1..5] of longint;
begin
  sum := 0;
  fillchar(q,sizeof(q),0);

  while not eof(input) do begin
    parseRobot(input, robot);
    predictPosition(robot,100, pos);
    inc(q[getQuadrant(pos)]);
  end;
  part1 := q[1]*q[2]*q[3]*q[4];
end;

function getRobotVariance(const robotPos : array of TPos;
                          const center   : TPos) : double;
  function square(const a : longint) : longint;
  begin
    square := a * a;
  end;
var i      : word;
    result : double;
begin
  result := 0;
  for i := 0 to HIGH(robotPos) do begin
    result := result + (square(robotPos[i].x - center.x) + square(robotPos[i].y - center.y));
  end;
  getRobotVariance := result / HIGH(robotPos);
end;

procedure moveRobotsToTime(const robots : array of TRobot;
                           const time   : longint;
                           var      pos : array of TPos;
                           var   center : TPos);
var i : word;
begin
  center.x := 0; center.y := 0;
  for i := 0 to HIGH(robots) do begin
    predictPosition(robots[i], time, pos[i]);
    inc(center.x, pos[i].x);
    inc(center.y, pos[i].y);
  end;

  center.x := center.x div (HIGH(robots)+1);
  center.y := center.y div (HIGH(robots)+1);
end;

procedure drawRobots(const pos: array of TPos);
var i,j : integer;
begin
  i := 0;
  j := 0;
  initGraph(i,j,'c:\bp\bgi');
  assert(GraphResult = grOk, 'Graphics Error');

  SetFillStyle(SolidFill, White);

  for i:= 0 to HIGH(pos) do
    bar(pos[i].x*4,pos[i].y*4, pos[i].x*4 + 3, pos[i].y*4 + 3);

  readln;
  closeGraph;
end;


function part2(var input: Text):comp; far;
var robotPos : array [0..499] of TPos;
    robots   : array [0..499] of TRobot;
    time, i  : word;
    thMin,tmp: double;
    thMinIdx : word;
    center   : TPos;
    p        : TProgressBar;
begin
  i := 0;

  while not eof(input) do begin
    parseRobot(input, robots[i]);
    inc(i);
  end;

  assert(i = 500, 'Missing Robots');

  p.init(10000,'Search');

  thMinIdx := 7916;
  thMin    := 0;

  for time := 0 to 10000 do begin
    moveRobotsToTime(robots, time, robotPos, center);
    tmp       := getRobotVariance( robotPos, center);
    if (thMin > tmp) or ( time = 0) then begin
      thMin := tmp;
      thMinIdx := time;
      writeln(time,' => thMin: ',thMin:1:2);
    end;
    p.step(1);
  end;
  p.done;

  moveRobotsToTime(robots, thMinIdx, robotPos, center);
  drawRobots(robotPos);

  part2 := thMinIdx;
end;

begin
  runAoc(InputFileName, 14, part1, part2, nil, nil);
end.
