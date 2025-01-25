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

      procedure LUDecomposition(var L, U, P : PMatrix);

      procedure LU(var idx: array of word; var d: integer);

      procedure print;

      private

      procedure allocateMatrix(const sx,sy   : word;
                               const skipInit: boolean);

    end;

implementation
 uses cassert;

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
procedure TMatrix.LU(var idx: array of word; var d: integer);
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
      if mat^[i*n + j] > big then big := mat^[i*n + j];
    assert(big <> 0, 'Singular Matrix in LU Decompose');
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

    assert(mat^[j*n+j] <> 0,'Singular Matrix in LU Decompose');

    if j <> (n-1) then begin
      temp := 1.0 / (mat^[j*n + j]);
      for i:= j + 1 to n-1 do
        mat^[i*n+j] := mat^[i*n+j] * temp;
    end;
  end;
end;

procedure TMatrix.LUDecomposition(var L, U, P : PMatrix);
var n, i, j, k, r : word;
    mat           : PMatArray;
    max,tmp       : double;
    A             : PMatrix;
begin
  assert(xdim_ = ydim_, 'Matrix is not square');
  n   :=  xdim_ - 1; (* Define n,n to be the last element of the matrix ... *)

  P := new(PMatrix, cEye(n + 1)); (* Permutation matrix start with an indentiy matrix *)
  A := new(PMatrix, copy(@self));(* Create a copy, so this matrix stay as is *)
  L := new(PMatrix, cEye(n+1));

  mat := PMatArray(A^.matrix_);

  (* Find the pivot elements for the rows and rearange the matrix *)
  for k:= 0 to n do begin
    max := abs(mat^[k+xdim_*k]);
    r := k;
    for i:= k + 1 to n do
      if max < abs(mat^[k + xdim_*i]) then begin
        max := abs(mat^[k + xdim_*i]);
        r := i;
      end;

    (* Check for degenerated matrix ... can't LU decompose ... *)
    if max < 1e-15 then begin
      P^.dispose;
      A^.dispose;
      L^.dispose;
      P := NIL;
      U := NIL;
      exit;
    end;

    P^.swapRow(r,k);
    A^.swapRow(r,k);
  end;

  (* Pivoting done, compute the LU decomp now *)
  for i:=0 to n do begin
    (* Compute the non-diagonal elements of L *)
    for k:=i + 1 to n do begin
       tmp := mat^[xdim_*k + i] / mat^[xdim_ * i + i];
       PMatArray(L^.matrix_)^[xdim_*k + i] := tmp;
       for j:= i to n do begin
           mat^[xdim_ * k + j] := mat^[xdim_ * k + j] - tmp*mat^[xdim_*i+j]
       end;
    end;
  end;

  (* Clean the rounding errors in the lower halfe of A *)
  for i:=1 to n do
   for k:=0 to i-1 do
     mat^[xdim_*i+k] := 0;

  (* After all the math U is A *)
  U := A;
end;

begin
end.