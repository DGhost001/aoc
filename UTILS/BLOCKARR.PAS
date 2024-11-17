unit BlockArray;
interface

uses ItemHandler;

type TIndex      = word;
     PBlock      = ^TBlock;
     TBlock      = array[0..255] of PItemType;
     PBlockArray = ^TBlockArray;
     TBlockArray = object
       block_ : array[0..255] of PBlock;

       constructor init;
       destructor  done;

       procedure setValue(const index: TIndex; const value : PItemType);
       function at(const index: TIndex) : PItemType;
     end;

implementation

constructor TBlockArray.init;
var i,j : byte;
begin
  for i:= 0 to 255 do begin
    block_[i] := NIL;
  end;
end;

destructor TBlockArray.done;
var i,j : byte;
begin
  for i:= 0 to 255 do begin
    if block_[i] <> NIL then begin
      for j:= 0 to 255 do if block_[i]^[j] <> NIL then
        dispose(block_[i]^[j],done);
      dispose(block_[i]);
    end;
  end
end;

procedure TBlockArray.setValue(const index: TIndex; const value : PItemType);
var i : byte;
begin
  if block_[HI(index)] = NIL then begin
    block_[HI(index)] := new(PBlock);
    for i:= 0 to 255 do block_[HI(index)]^[i] := NIL;
  end;
  block_[HI(index)]^[LO(index)] := value;
end;

function TBlockArray.at(const index: TIndex) : PItemType;
begin
 if block_[HI(index)] = NIL then at := NIL
 else
   at := block_[HI(index)]^[LO(index)];
end;

begin
end.