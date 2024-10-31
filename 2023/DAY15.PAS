program day15;
const InputFileName = 'INP\DAY15_IN.TXT';

procedure updateHash(const   c: char;
                     var  hash: byte);
var tmp : word;
begin
  tmp := ord(c) + hash;
  tmp := (tmp * 17) mod 256;
  hash := tmp;
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
var input : Text;
      p1  : longint;
begin
  assign(input, InputFileName);
  reset(input);
  p1 := part1(input);
  close(input);

  writeln('Answert to part1 is: ', p1);
end.