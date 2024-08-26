program day3;
(* This is the implementation for the advent of code 2023 day 3 *)

type TCluster = record
       line  : integer;
       pos   : integer;
       length: integer;
     end;

     TGear    = record
       line  : integer;
       pos   : integer;
       ratio : longint;
     end;

const
  InputFileName : string = 'DAY3_INP.TXT';
  Space         : char =  '.';
  Number        : set of char = ['0'..'9'];
  MaxX          = 140;
  MaxY          = 140;
var
  schematics : array[1..MaxY, 1..MaxX] of char;

procedure loadSchematics;
var  line  : string;
     x,y   : integer;
     input : Text;
begin
  assign(input, InputFileName);
  reset(input);
  for y:= 1 to MaxY do begin
    readln(input, line);
    for x:= 1 to MaxX do
      schematics[y,x]:= line[x];
  end;
  close(input);
end;

function isValidCluster(var cluster:TCluster): boolean;
begin
  isValidCluster := (cluster.line > 0) and
                    (cluster.pos > 0) and
                    (cluster.length > 0) and
                    (cluster.line <= MaxY) and
                    ((cluster.pos + cluster.length) <= (MaxX + 1));
end;

function clusterHasSymbol(var cluster: TCluster): boolean;
var result : boolean;
    x      : integer;
    c      : char;
begin
  result := false;
  if isValidCluster(cluster) then begin
     for x:= cluster.pos to cluster.pos + cluster.length - 1 do begin
       c := schematics[cluster.line,x];
       result := result or ((not(c in Number)) and (c <> Space));
     end;
  end;
  clusterHasSymbol := result;
end;

procedure lowerCluster(var cluster: TCluster);
begin
  with cluster do begin
    if pos > 1 then begin
      dec(pos);
      inc(length);
    end;
    if pos + length < MaxX then inc(length);

    inc(line);
  end;
end;

procedure upperCluster(var cluster: TCluster);
begin
  with cluster do begin
    if pos > 1 then begin
      dec(pos);
      inc(length);
    end;
    if pos + length < MaxX then inc(length);

    dec(line);
  end;
end;

procedure leftCluster(var cluster: TCluster);
begin
  with cluster do begin
    dec(pos);
    length := 1;
  end;
end;

procedure rightCluster(var cluster: TCluster);
begin
  with cluster do begin
    pos := pos + length;
    length := 1;
  end;
end;

function findCluster(var cluster: TCluster): boolean;
var done : boolean;
    c    : char;
begin
  with cluster do begin
    pos := pos + length;
    if pos < 1 then pos := 1; (* Make sure we start inside the array *)
    length := 0;
    done := false;

    while (pos + length <= MaxX) and (line <= MaxY) and not done do begin
     c:= schematics[line, pos + length];
     if (length = 0) and (not (c in Number)) then inc(pos) else
     if c in Number then inc(length) else
     done := true;
    end;

    (* Numbers at the End need special handling *)
    if (pos + length >MaxX) and (length > 0) then
      done := true;

    findCluster := isValidCluster(cluster);
 end;
end;

function clusterToNumber(var cluster: TCluster): integer;
var code: integer;
    s   : string;
    x   : integer;
begin
  with cluster do begin
    s[0] := chr(length);
    for x:=1 to length do
     s[x] := schematics[line,pos + x - 1];
    val(s,x,code);
  end;
  clusterToNumber := x;
end;

function sumAllIds:longint;

var cnumber                   : TCluster;
    up, down, left, right     : TCluster;
    sum                       : longint;
    num                       : integer;

begin

  sum := 0;

  for cnumber.line := 1 to MaxY do begin
    writeln;
    write(cnumber.line,': ');
    cnumber.pos := 1;
    cnumber.length := 0;
    while findCluster(cnumber) do begin
      up   := cnumber; down := cnumber;
      left := cnumber; right:= cnumber;
      upperCluster(up);
      lowerCluster(down);
      leftCluster(left);
      rightCluster(right);

      num := clusterToNumber(cnumber);

      if clusterHasSymbol(up) or
         clusterHasSymbol(down) or
         clusterHasSymbol(left) or
         clusterHasSymbol(right) then begin
           sum := sum + num;
           write(num,' ');
         end;
    end;
  end;
  writeln;
  writeln('-----------------------------------------------------------');
  sumAllIds := sum;
end;

function isClusterNeighbour(const pos :integer; cluster:TCluster): boolean;
begin
  isClusterNeighbour:= pos in [cluster.pos-1..cluster.pos+cluster.length];
end;

function findNeighbouringCluster(
                 const line, pos: integer;
                 var cluster:TCluster
                 ):boolean;
var result : boolean;
begin
  result := false;

  if (line > 0) and (line <= MaxY) then begin
    if cluster.length = 0 then begin
      cluster.pos := 0;
      cluster.line:= line;
    end;

    while not result and findCluster(cluster) do begin
      result := isClusterNeighbour(pos,cluster);
    end;
  end;

  findNeighbouringCluster := result;
end;

function findGearRatio(var gear: TGear): boolean;
var
   result    : boolean;
   cluster   : array [0..3] of TCluster;
   tmpCluster: TCluster;
   numCluster: integer;
begin
  result := false;

  with gear do begin
    ratio := 0;
    while (line <= MaxY) and (pos < MaxX) and not result do begin
      inc(pos);
      if Schematics[line, pos] = '*' then begin
        cluster[0].length := 0;
        numCluster := 0;

        (* Look in the lines above, on and below for clusters neighbouring the '*' *)
        while (numCluster < 3) and findNeighbouringCluster(line - 1, pos, cluster[numCluster]) do begin
          cluster[numCluster+1]:=cluster[numCluster];
          inc(numCluster);
        end;

        cluster[numCluster].length := 0;
        while (numCluster < 3) and findNeighbouringCluster(line, pos, cluster[numCluster]) do begin
          cluster[numCluster+1]:=cluster[numCluster];
          inc(numCluster);
        end;

        cluster[numCluster].length := 0;
        while (numCluster < 3) and findNeighbouringCluster(line + 1, pos, cluster[numCluster]) do  begin
          cluster[numCluster+1]:=cluster[numCluster];
          inc(numCluster);
        end;

        (* Only if it is exactly 2 *)
        if numCluster = 2 then begin
          ratio := clusterToNumber(cluster[0]);
          ratio := ratio * clusterToNumber(cluster[1]);
          result:= true;
        end;
      end;
    end;
  end;

  findGearRatio := result;
end;

function sumAllGearRatios:longint;
var gear : TGear;
    sum  : longint;
begin
  sum := 0;
  for gear.line:=1 to MaxY do begin
    gear.pos := 0;
    writeln;
    write(gear.line,': ');
    while findGearRatio(gear) do begin
      write(gear.pos,' ');
      sum := sum + gear.ratio;
      if sum < 0 then
        halt(1);
    end;
  end;
  writeln;
  writeln('-----------------------------------------------------------');

  sumAllGearRatios := sum;
end;

var  result1 : longint;
     result2 : longint;
begin
  loadSchematics;
  writeln;

  writeln;
  result1 := sumAllIds;
  result2 := sumAllGearRatios;
  writeln('Sum of all ids:',result1);
  writeln('Sum of all ratios:',result2);
  writeln('===========================================================');
end.
