program day24;
uses utils, matrix, crt, dequeue,ItemHandler;
const InputFileName = 'INP\DAY24_IN.TXT';

type PLine = ^TLine;
     TLine = object(ItemType)
       n_ : PMatrix;
       m_ : PMatrix;

       constructor init(n,m : PMatrix);
       destructor done; virtual;

     end;

constructor TLine.init(n,m : PMatrix);
begin
  n_ := n;
  m_ := m;
end;

destructor TLine.done;
begin
  n_^.dispose;
  m_^.dispose;
end;

function loadVector(var input : Text; const n : integer) : PMatrix;
var result : PMatrix;
         i : integer;
begin
  result := new(PMatrix,cZeroMatrix(n,1));

  for i:= 0 to n-1 do
      result^.setValue(i,0,readComp(input));

  loadVector := result;
end;

function loadLinePart1(var input : Text) : PLine;
var    n,m : PMatrix;
         c : char;
begin
  n := loadVector(input,2); readComp(input); read(input,c);
  m := loadVector(input,2); readComp(input); read(input,c);

  loadLinePart1 := new(PLine, init(m,n));
end;

function part1(var input : Text) : longint;
var lines : PDeQueue;
begin
  lines := new(PDeQueue,init);
  while not eof(input) do
    lines^.pushBack(loadLinePart1(input));

  part1 := 0;
  lines^.dispose;
end;

var input : Text;
    p1    : longint;
begin
  assign(input, InputFileName);
  reset(input);
  p1 := part1(input);

  writeln('The Answer to part1 is: ',p1);
  close(input);
end.