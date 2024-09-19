program day10;
type TPos = record
       x : byte;
       y : byte;
     end;

     TField = array[0..139,0..139] of char;
     TPosTuple = array[1..2] of TPos;

const NullPos : TPos = (x : 255; y : 255);
      InputFile = 'INP\DAY10_IN.TXT';
procedure west(pos: TPos; var result : TPos);
begin
 if pos.x > 0 then begin
  result := pos;
  dec(result.x);
 end else
  result := NullPos;
end;

procedure east(pos: TPos; var result : TPos);
begin
 if pos.x < 139 then begin
  result := pos;
  inc(result.x);
 end else
  result := NullPos;
end;

procedure north(pos: TPos; var result : TPos);
begin
 if pos.y > 0 then begin
  result := pos;
  dec(result.y);
 end else
  result := NullPos;
end;

procedure south(pos: TPos; var result : TPos);
begin
 if pos.y < 139 then begin
  result := pos;
  inc(result.y);
 end else
  result := NullPos;
end;

function pequal(pos1, pos2 : TPos) : boolean;
begin
  pequal  := (pos1.x = pos2.x) and (pos1.y = pos2.y);
end;


procedure getPositions(pos     : TPos;
                      var field: TField;
                      var next : TPosTuple
                      );
begin
  if not pequal(pos, NullPos) then
     case field[pos.x,pos.y] of
          '-': begin west(pos,next[1]);   east(pos,next[2]);   end;
          '|': begin north(pos, next[1]); south(pos, next[2]); end;
          'L': begin north(pos, next[1]); east(pos, next[2]);  end;
          'J': begin north(pos, next[1]); west(pos, next[2]);  end;
          '7': begin south(pos, next[1]); west(pos, next[2]);  end;
          'F': begin south(pos, next[1]); east(pos, next[2]);  end;
     else begin next[1] := NullPos; next[2]:= NullPos; end;
  end else begin
    next[1] := NullPos; next[2]:= NullPos;
  end;
end;

procedure findStart(var field : TField; var pos : TPos);
var x,y : byte;
begin
  for x:=0 to 139 do
   for y:=0 to 139 do begin
     if field[x,y] = 'S' then begin
       pos.x := x;
       pos.y := y;
     end;
   end;
end;

function runPart1(var field : TField ) : word;
var steps : word;
    start : TPos;
    pos   : TPos;
    npos  : TPos;
    inital: array[1..4] of TPosTuple;
    i,j   : integer;
    options: TPosTuple;
begin
  findStart(field,start);
  pos:=start;
  north(pos,npos); getPositions(npos, field, inital[1]);
  south(pos,npos); getPositions(npos, field, inital[2]);
  west(pos, npos); getPositions(npos, field, inital[3]);
  east(pos, npos); getPositions(npos, field, inital[4]);

  i := 1;
  npos := NullPos;
  while pequal(npos, NullPos) do begin
    for j:= 1 to 2 do
      if pequal(inital[i][j], start) then
        case i of
            1:north(start,npos);
            2:south(start,npos);
            3:west(start,npos);
            4:east(start,npos);
        else runError(300);
        end;
    inc(i);
  end;

  steps := 1;
  while not pequal(npos, start) do begin
    inc(steps);
    if steps > 140*140 then runError(300);
    if (steps mod 500)=0 then write('.');
    getPositions(npos, field, options);

    if pequal(pos,options[1]) then begin
      pos := npos;
      npos:= options[2];
    end else begin
      pos := npos;
      npos := options[1];
    end;
  end;
  writeln;
  runPart1 := (steps+1) div 2;
end;

procedure loadField(var input: Text; var field: TField);
var x,y : byte;
    tmp : char;
begin
  for y:=0 to 139 do begin
   for x:=0 to 139 do read(input,field[x,y]);
   read(input,tmp); read(input,tmp);
  end;
end;

var field : TField;
    input : Text;
    result: word;
begin
  assign(input,InputFile);
  reset(input);
  loadField(input,field);
  close(input);
  result := runPart1(field);
  writeln('Part 1 Answer: ',result);
end.