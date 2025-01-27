program day24;
uses utils, matrix, crt, dequeue,ItemHandler,Progressbar;
const InputFileName = 'INP\DAY24_IN.TXT';
      MinBox : double =  200000000000000.0 (*7*);
      MaxBox : double =  400000000000000.0 (*27*);


type PLine = ^TLine;
     TLine = object(ItemType)
       n_ : PMatrix;
       m_ : PMatrix;

       constructor init(m,n : PMatrix);
       destructor done; virtual;
       function intersect(const other: PLine): PMatrix;

     end;

constructor TLine.init(m,n : PMatrix);
begin
  n_ := n;
  m_ := m;
end;

destructor TLine.done;
begin
  n_^.dispose;
  m_^.dispose;
end;

function Tline.intersect(const other: PLine):PMatrix;
var result  : PMatrix;
         x  : PMatrix;
         a  : PMatrix;
         idx: array [0..MatrixMaxDim] of word;
         d  : integer;

begin
  a      := new(PMatrix, cZeroMatrix(m_^.xdim_,m_^.xdim_));
  x      := new(PMatrix, copy(n_));

  x^.sub(other^.n_);

  a^.setCol(1,other^.m_);
  a^.mulV(-1);
  a^.setCol(0,m_);

  if a^.lu(idx,d) then begin
    a^.backSubstitution(idx,x);
    x^.mulv(-1); (* We solved A*x = b *)
                 (* Take x to the other side of the equation *)
                 (* So we can do m*x + n                     *)

    (* Only positiv collisions count *)
    if (x^.at(0,0) >= 0) and (x^.at(1,0) >=0) then begin
      result := new(PMatrix, copy(m_));
      result^.mulv(x^.at(0,0));
      result^.add(n_);
    end else result := NIL

  end else
    result := NIL;

  a^.dispose;
  x^.dispose;

  intersect := result;
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

function loadLinePart2(var input : Text) : PLine;
var    n,m : PMatrix;
         c : char;
begin
  n := loadVector(input,3); readComp(input); read(input,c);
  m := loadVector(input,3); readComp(input); read(input,c);

  loadLinePart2 := new(PLine, init(m,n));
end;

procedure buildRowOfA(const l1,l2 : PLine;
                      var   r     : PMatrix;
                      var   b     : double);
begin
  with l1^ do
    b := (m_^.at(1,0) * n_^.at(0,0)) -
         (m_^.at(0,0) * n_^.at(1,0));

  with l2^ do
    b:= b - ((m_^.at(1,0) * n_^.at(0,0)) -
             (m_^.at(0,0) * n_^.at(1,0)));

  r := new(PMatrix, cZeroMatrix(4,1));

  r^.setValue(0,0, -l1^.n_^.at(1,0) + l2^.n_^.at(1,0)); (* mx *)
  r^.setValue(1,0,  l1^.n_^.at(0,0) - l2^.n_^.at(0,0)); (* my *)
  r^.setValue(2,0,  l1^.m_^.at(1,0) - l2^.m_^.at(1,0)); (* nx *)
  r^.setValue(3,0, -l1^.m_^.at(0,0) + l2^.m_^.at(0,0)); (* ny *)
end;

function part1(var input : Text) : longint;
var lines   : PDeQueue;
    count   : word;
    it, it2 : PDeQueueIterator;
    l1,l2   : PLine;
    p       : PMatrix;
    x,y     : double;
     pr     : TProgressBar;
     n      : longint;
begin
  count := 0;
  lines := new(PDeQueue,init);
  while not eof(input) do
    lines^.pushBack(loadLinePart1(input));

  it := lines^.first;
  n := lines^.size;
  pr.init((n*(n+1)) div 2,'Calc');
  while it <> NIL do begin
    it2 := it^.next;
    l1 := PLine(it^.at);

    while it2 <> NIL do begin
      l2  := PLine(it2^.at);
      p :=l1^.intersect(l2);
      if p <> NIL then begin
         x := p^.at(0,0);
         y := p^.at(1,0);
         if (x >= MinBox) and (x <= MaxBox) and
            (y >= MinBox) and (y <= MaxBox) then inc(count);
         p^.dispose;
      end;

      it2 := it2^.next;
      pr.step(1);
    end;
    it := it^.next;
  end;
  pr.done;
  part1 := count;
  lines^.dispose;
end;

function part2(var input : Text): comp;
 function getTime (const l1, l2 : PLine) : double;
 begin
   getTime := (l2^.n_^.at(0,0) - l1^.n_^.at(0,0)) /
              (l1^.m_^.at(0,0) - l2^.n_^.at(0,0));
 end;

 function getMz( const l1, l2, l3 : PLine) : double;
 var t0, t1 : double;
 begin
   t0 := getTime(l1, l2);
   t1 := getTime(l1, l3);

   getMz := ( (l3^.n_^.at(3,0) + l3^.m_^.at(3,0)*t1) -
              (l2^.n_^.at(3,0) + l2^.m_^.at(3,0)*t0)) /
              (t1 - t0);
 end;

 function getNz(const l1, l2 : PLine): double;
 var t0 : double;
 begin
   t0 := getTime( l1, l2);
   getNZ := (l2^.m_^.at(3,0) - l1^.m_^.at(3,0)) * t0 + l2^.n_^.at(3,0);
 end;

var lines : array[0..5] of PLine;
        i : integer;
        b : PMatrix;
        A : PMatrix;
begin
  for i:= 1 to 5 do
   lines[i] := loadLinePart2(input);
  lines[0] :=new(PLine,init(new(PMatrix, cZeroMatrix(3,1)),
                            new(PMatrix, cZeroMatrix(3,1))));

end;

var input : Text;
    p1    : longint;
begin
  clrscr;
  assign(input, InputFileName);
  reset(input);
  p1 := part1(input);

  writeln('The Answer to part1 is: ',p1);
  close(input);
end.