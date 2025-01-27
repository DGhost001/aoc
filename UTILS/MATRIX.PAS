unit Matrix;
{$N+}
(*
   This unit is a matrix math implementation. It provides the most
   basic matrix functions needed to do some meaningfull computations
*)
interface
  uses itemhandler;

  const MatrixMaxDim = 90;
  type
    PMatrix = ^TMatrix;
    TMatrix = object(ItemType)
      matrix_ : Pointer;
      xdim_   : word;
      ydim_   : word;

      constructor cZeroMatrix (const sx, sy : word);
      constructor cEye (const dim : word);
      constructor cVector(const values: array of double);
      constructor copy(const other : PMatrix);

      destructor done; virtual;
      procedure dispose;

      procedure add(const other : PMatrix);
      procedure sub(const other : PMatrix);

      function mul(const other : PMatrix): PMatrix;

      procedure addV(const value: double);
      procedure subV(const value: double);
      procedure mulV(const value: double);
      procedure divV(const value: double);

      procedure setValue(const x,y: word; const value : double);
      function at(const x,y: word) : double;

      function transpose:PMatrix;
      procedure swapRow(const r1, r2: word);

      function LU(var idx: array of word; var d: integer): boolean;
      procedure backSubstitution(const idx: array of word;  b : PMatrix);

      function det: double;
      function inverse: boolean;


      procedure print;
      function isVector: boolean;

      procedure setCol(const col: word; const v : PMatrix);

      private

      procedure allocateMatrix(const sx,sy   : word;
                               const skipInit: boolean);

    end;

implementation
 uses cassert, utils;

type PMatArray = ^TMatArray;
     TMatArray = array[0..MatrixMaxDim*MatrixMaxDim] of double;

procedure TMatrix.allocateMatrix(const sx, sy  : word;
                                 const skipInit: boolean);
const max = MatrixMaxDim * MatrixMaxDim;
var size : word;
begin
  assert(sx * sy <= max,'Matrix does not fit into memory');
  xdim_ := sx;
  ydim_ := sy;

  size := xdim_ * ydim_ * sizeof(double);
  getMem(matrix_, size);

  if not skipInit then
    fillChar(matrix_^ ,size,0);
end;

constructor TMatrix.cZeroMatrix (const sx, sy : word);
begin
  allocateMatrix(sx,sy, false);
end;

constructor TMatrix.cEye (const dim : word);
var i : word;
begin
  allocateMatrix(dim, dim, false);
  for i:=0 to dim - 1 do
    PMatArray(matrix_)^[i + i*xdim_] := 1;
end;

constructor TMatrix.cVector(const values: array of double);
var i: word;
begin
  allocateMatrix(HIGH(values)+1, 1, true);
  for i:=0 to HIGH(values) do
    PMatArray(matrix_)^[i] := values[i];
end;

constructor TMatrix.copy(const other : PMatrix);
begin
  allocateMatrix(other^.xdim_, other^.ydim_, true);
  move(other^.matrix_^, matrix_^, xdim_ * ydim_ * sizeof(double));
end;

destructor TMatrix.done;
begin
  freeMem(matrix_, xdim_ * ydim_ * sizeof(double));
end;

procedure TMatrix.dispose;
begin
  SYSTEM.dispose(PMatrix(@self),done);
end;

procedure TMatrix.add(const other : PMatrix);
var x,y : word;
begin
  assert(xdim_ = other^.xdim_,'Matrix x dimensions missmatch');
  assert(ydim_ = other^.ydim_,'Matrix y dimensions missmatch');

  for y:= 0 to ydim_ - 1 do
   for x:= 0 to xdim_ - 1 do
     PMatArray(matrix_)^[y*xdim_ + x] :=
       PMatArray(matrix_)^[y*xdim_ + x] +
       PMatArray(other^.matrix_)^[y*xdim_ + x];
end;

procedure TMatrix.sub(const other : PMatrix);
var x,y : word;
begin
  assert(xdim_ = other^.xdim_,'Matrix x dimensions missmatch');
  assert(ydim_ = other^.ydim_,'Matrix y dimensions missmatch');

  for y:= 0 to ydim_ - 1 do
   for x:= 0 to xdim_ - 1 do
     PMatArray(matrix_)^[y*xdim_ + x] :=
       PMatArray(matrix_)^[y*xdim_ + x] -
       PMatArray(other^.matrix_)^[y*xdim_ + x];
end;

function TMatrix.mul(const other : PMatrix): PMatrix;
var   i,j,n,m : word;
        result: PMatrix;
          sum : double;
begin
  assert(xdim_ = other^.ydim_,'Matrix dimension mismatch');

  result := new(PMatrix, cZeroMatrix(other^.xdim_, ydim_));

  for i:=0 to other^.xdim_ - 1 do
    for j := 0 to ydim_ - 1 do begin
       sum := 0;
       for n:=0 to xdim_ - 1 do
         sum:=sum +
              PMatArray(matrix_)^[n+j*xdim_] *
              PMatArray(other^.matrix_)^[j+n*xdim_];

       PMatArray(result^.matrix_)^[j*result^.xdim_ + i] := sum;
    end;

  mul := result;
end;

procedure TMatrix.setValue(const x,y: word; const value : double);
begin
  assert(x < xdim_, 'X Index out of range');
  assert(y < ydim_, 'Y Index out of range');

  PMatArray(matrix_)^[y*xdim_ + x] := value;
end;

function TMatrix.at(const x,y: word) : double;
begin
  assert(x < xdim_,'X Index out of range');
  assert(y < ydim_,'Y Index out of range');

  at := PMatArray(matrix_)^[y*xdim_ + x];
end;

procedure TMatrix.print;
var x,y: word;
begin
  write('[');
  for y:= 0 to ydim_ - 1 do begin
   if y <> 0 then write(';');
   for x:= 0 to xdim_ - 1 do
     write(' ',PMatArray(matrix_)^[y*xdim_ + x]:1:2);
  end;
  writeln(']');
end;

procedure TMatrix.addV(const value: double);
var x,y : word;
begin
  for y:=0 to ydim_ - 1 do
   for x:=0 to xdim_ - 1 do
     PMatArray(matrix_)^[y*xdim_ + x] :=
       PMatArray(matrix_)^[y*xdim_ + x] + value;
end;

procedure TMatrix.subV(const value: double);
var x,y : word;
begin
  for y:=0 to ydim_ - 1 do
   for x:=0 to xdim_ - 1 do
     PMatArray(matrix_)^[y*xdim_ + x] :=
       PMatArray(matrix_)^[y*xdim_ + x] - value;
end;

procedure TMatrix.mulV(const value: double);
var x,y : word;
begin
  for y:=0 to ydim_ - 1 do
   for x:=0 to xdim_ - 1 do
     PMatArray(matrix_)^[y*xdim_ + x] :=
       PMatArray(matrix_)^[y*xdim_ + x] * value;
end;

procedure TMatrix.divV(const value: double);
var x, y: word;
begin
  for y:=0 to ydim_ - 1 do
   for x:=0 to xdim_ - 1 do
     PMatArray(matrix_)^[y*xdim_ + x] :=
       PMatArray(matrix_)^[y*xdim_ + x] / value;
end;

function TMatrix.transpose;
var x, y   : word;
    result : PMatrix;
begin
  result := new(PMatrix, cZeroMatrix(ydim_, xdim_));
  for y:=0 to ydim_ - 1 do
   for x:=0 to xdim_ - 1 do
     PMatArray(result^.matrix_)^[y + x*ydim_] := PMatArray(matrix_)^[x + y*xdim_];
  transpose := result;
end;

procedure TMatrix.swapRow(const r1, r2: word);
var i     : word;
    tmp   : double;
    y1, y2: word;
begin
  if r1 <> r2 then begin
    y1 := r1 * xdim_;
    y2 := r2 * xdim_;

    for i:=0 to xdim_ - 1 do begin
      tmp := PMatArray(matrix_)^[i + y1];
      PMatArray(matrix_)^[i + y1] := PMatArray(matrix_)^[i + y2];
      PMatArray(matrix_)^[i + y2] := tmp;
    end;
  end;
end;

(* This is he LU decomposition of a Matrix as given by
   the numerical recepies
   @param[out] idx This is the record of the row permuations
   @param[inout] d will be multiplied with -1 for every permutation
*)
function TMatrix.LU(var idx: array of word; var d: integer): boolean;
var vv              : array[0..MatrixMaxDim] of double;
    i, imax, j, k,n : integer;
    big, sum, temp  : double;
    mat             : PMatArray;
begin
  assert(xdim_ = ydim_, 'Matrix needs to be square');
  d := 1;
  n := xdim_;
  assert(HIGH(idx) >= n - 1, 'Not enougth space for index');

  mat := PMatArray(matrix_);

  (* Initialize the scaling factor *)
  for i:=0 to n - 1 do begin
    big := 0;
    for j:=0 to n - 1 do
      if abs(mat^[i*n + j]) > big then big := abs(mat^[i*n + j]);

    (* Sigular Matrix ... can't decompose *)
    if big = 0 then begin
      LU := false;
      exit;
    end;

    vv[i] := 1.0 / big;
  end;

  for j:=0 to n-1 do begin
    for i:=0 to j - 1 do begin
      sum := mat^[i*n+j];
      for k:= 0 to i-1 do
        sum := sum - mat^[i*n+k]*mat^[k*n+j];
      mat^[i*n+j] := sum;
    end;

    big := 0;
    for i:= j to n -1 do begin
      sum := mat^[i*n+j];
      for k:= 0 to j - 1 do
        sum := sum - mat^[i*n+k]*mat^[k*n+j];
      mat^[i*n+j] := sum;
      if vv[i]*abs(sum) >= big then begin
        big := vv[i] * abs(sum);
        imax:= i;
      end;
    end;

    if j <> imax then begin
      swapRow(imax, j);
      d := -d;
      vv[imax] := vv[j];
    end;

    idx[j] := imax;

    (* Singular Matrix ... cant decompose *)
    if mat^[j*n+j] = 0 then begin
       LU := false;
       exit;
    end;

    if j <> (n-1) then begin
      temp := 1.0 / (mat^[j*n + j]);
      for i:= j + 1 to n-1 do
        mat^[i*n+j] := mat^[i*n+j] * temp;
    end;
  end;
  LU := true;
end;

(* This is the backsubstitution as given by the numerical recepies.
   The matrix must be LU decomposed before calling this function.
   @param[in] idx This is the index as returned by the LU decompose
   @param[inout] b This is b from the Equation A*x=b and will contain x
                   after the execution of this function
*)
procedure TMatrix.backSubstitution(const idx: array of word;
                                          b : PMatrix);
var i,ii,ip,j,n : integer;
    sum         : double;
    mat         : PMatArray;
    bv          : PMatArray;
begin
  assert(xdim_ = ydim_, 'Matrix must be square');
  assert(b^.isVector, 'b needs to be a vector');
  assert(dmax(b^.xdim_, b^.ydim_) = xdim_,'Vector dimensions need to match');
  assert(HIGH(idx) >= xdim_ - 1,'Index does not match matrix');

  n   := xdim_;
  mat := PMatArray(matrix_);
  bv  := PMatArray(b^.matrix_);
  ii  := -1;

  for i := 0 to n-1 do begin
    ip := idx[i];
    sum := bv^[ip];
    bv^[ip] := bv^[i];
    if ii >= 0 then
      for j:=ii to i-1 do sum := sum - mat^[i*n+j]*bv^[j]
    else if sum <> 0 then ii := i;
    bv^[i] := sum;
  end;

  for i := n-1 downto 0 do begin
    sum := bv^[i];
    for j:= i+1 to n-1 do
      sum := sum - mat^[i*n+j]*bv^[j];
    bv^[i] := sum / mat^[i*n+i];
  end;
end;

function TMatrix.det: double;
var   tmp    : PMatrix;
      idx    : array[0..MatrixMaxDim] of word;
      d      : integer;
      i      : integer;
      m      : double;

begin
  tmp := new(PMatrix, copy(@self));

  if not tmp^.LU(idx, d) then begin
    det := 0;
    exit;
  end;

  m := d;

  for i:=0 to xdim_ - 1 do
    m:= m * PMatArray(tmp^.matrix_)^[i*xdim_+i];

  det := m;

  tmp^.dispose;
end;

function TMatrix.inverse: boolean;
var   result : PMatrix;
      col    : PMatrix;
      idx    : array[0..MatrixMaxDim] of word;
      d      : integer;
      i,j    : integer;
      tmp    : Pointer;
begin
  assert(xdim_ = ydim_, 'Matrix must be square');

  result := new(PMatrix, cZeroMatrix(xdim_, ydim_));
  col    := new(PMatrix, cZeroMatrix(xdim_,1));

  if not LU(idx, d) then begin
    inverse := false;
    exit;
  end;
  for j:=0 to xdim_ - 1 do begin

    for i:=0 to xdim_ -1 do PMatArray(col^.matrix_)^[i] := 0;
    PMatArray(col^.matrix_)^[j] := 1;

    backSubstitution(idx, col);

    for i:=0 to xdim_ - 1 do PMatArray(result^.matrix_)^[i*xdim_+j] :=
      PMatArray(col^.matrix_)^[i];
  end;

  (* Move the result into our own object *)
  tmp := matrix_;
  matrix_ := result^.matrix_;
  result^.matrix_ := tmp;

  result^.dispose;
  col^.dispose;
  inverse := true;
end;

function TMatrix.isVector: boolean;
begin
  isVector := (xdim_ = 1) or (ydim_ = 1);
end;

procedure TMatrix.setCol(const col: word; const v : PMatrix);
var i : integer;
begin
  assert(v^.isVector, 'Column vector required.');
  assert(v^.xdim_ = ydim_, 'Vector dimension need to match matrix y');

  for i:= 0 to ydim_-1 do
    PMatArray(matrix_)^[i*xdim_ + col] := PMatArray(v^.matrix_)^[i];
end;

begin
end.