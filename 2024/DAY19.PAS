program day19;
(*This is the implementation of the aoc24 day 19*)

uses aoc, cassert, ItemHandler, heap, ProgressBar, utils;
const InputFileName = 'INP\DAY19_IN.TXT';
type TStripe  = (White, Blue, Black, Red, Green);
     
     TPattern = record
       stripes_: array[0..7] of TStripe;
       size_   : byte;
     end;

     TArtPattern = record
       pattern_ : array[0..64] of TStripe;
       size_    : byte;
     end;

     TTowels  = record
       towelPattern_ : array[0..512] of TPattern;
       size_         : word;
     end;

function stripFromChar(c: char): TStripe;
begin
    case c of
        'w': stripFromChar := White;
        'u': stripFromChar := Blue;
        'b': stripFromChar := Black;
        'r': stripFromChar := Red;
        'g': stripFromChar := Green;
    else
        assert(false, 'Unknown stripe character: "' + c + '"');
    end;
end;

procedure readPattern(var input: Text; var pattern : TPattern);
var c    : char;
    idx  : byte;
begin
  read(input, c);
  pattern.size_ := 0;
  while c in [' ','r','g','b','u','w'] do begin
    if c in ['r','g','b','u','w'] then begin
      assert(pattern.size_ < sizeof(pattern.stripes_), 'Pattern too large');
      pattern.stripes_[pattern.size_] := stripFromChar(c);
      inc(pattern.size_);
    end;
    read(input, c);
  end;
end;

procedure readTowelPatterns(var input: Text; var towels: TTowels);
begin
  fillchar(towels,sizeof(TTowels),0);
  while not Eoln(input) do begin
    assert(towels.size_ < sizeof(towels.towelPattern_), 'Too many towel patterns');
    readPattern(input, towels.towelPattern_[towels.size_]);
    if towels.towelPattern_[towels.size_].size_ > 0 then inc(towels.size_);
  end;
end;

procedure readArtPattern(var input: Text; var art: TArtPattern);
var s  : string;
    idx: byte;
begin
    readln(input, s);
    fillChar(art,sizeof(TArtPattern),0);
    art.size_ := 0;
    for idx := 0 to length(s) - 1 do begin
        if s[idx + 1] in ['r','g','b','u','w'] then begin
            assert(art.size_ <= sizeof(art.pattern_), 'Art pattern too large');
            art.pattern_[art.size_] := stripFromChar(s[idx + 1]);
            inc(art.size_);
        end;
    end;
end;

function isTowelMatching(const towel: TPattern; 
                         const art  : TArtPattern;
                         const idx  : word): Boolean;
var i: word;
begin
  isTowelMatching := false;
  if idx + towel.size_ <= art.size_ then begin
    isTowelMatching := true;
    for i := 0 to towel.size_ - 1 do
      if towel.stripes_[i] <> art.pattern_[idx + i] then begin
        isTowelMatching := false;
        break;
      end;
  end;
end;

function isArtPatternPossible(const towels: TTowels;
                              const art   : TArtPattern): Boolean;
var backlog: TMinHeap;
    idx    : word;
    tidx   : word;
    i      : word;
    result : Boolean;
    item   : PWordItem;
    impossibleIndex: set of 0..64;
    impossible: Boolean;
begin
  result := false;
  impossibleIndex := [];
  backlog.init;
  backlog.push(new(PWordItem, init(art.size_))); (* Start with the first index *)
  while (backlog.size > 0) and(not result) do begin
    item := PWordItem(backlog.pop);
    idx := art.size_ - item^.value;
    Dispose(item);
    if idx >= art.size_ then
      (* We have matched the entire art pattern *)
      result := true
    else begin
        impossible := true;
        for i:= 0 to towels.size_ - 1 do begin
            if isTowelMatching(towels.towelPattern_[i], art, idx) then begin
                (* If the towel matches, push the next index *)
                tidx := idx + towels.towelPattern_[i].size_;
                if (tidx < art.size_) and (not (tidx in impossibleIndex)) then begin
                    backlog.push(new(PWordItem, 
                       init(art.size_ - tidx)));
                    impossible := false;
                end
                else if tidx = art.size_ then
                    (* If it matches exactly, we can finish *)
                    result := true; 
            end;
        end;
        if impossible then
          impossibleIndex := impossibleIndex + [idx];
    end;
  end;
  isArtPatternPossible := result;
  backlog.done;
end;

function countPossibleArtPatterns(const towels: TTowels;
                                  const art   : TArtPattern): comp;
var countPerIndex: array[0..64] of comp;

function countFromIndex(index: byte): comp;
var i      : integer;
    result : comp;
    tmp    : comp;
begin
    result := 0;
    if index = art.size_ then
      result := 1
    else if index < art.size_ then begin
        if countPerIndex[index] >= 0 then
            result := countPerIndex[index]
        else begin
            for i:= 0 to towels.size_ - 1 do begin
                if isTowelMatching(towels.towelPattern_[i], art, index) then begin
                    (* comp is computed in the FPU ... we need to call first and than add else *)
                    (* a recursion may corrupt the FPU stack :( *)
                    tmp    := countFromIndex(index + towels.towelPattern_[i].size_);
                    result := result + tmp;
                end;
            end;
        end;
    end;
    countPerIndex[index] := result;
    countFromIndex := result;
end;

begin
    fillchar(countPerIndex, sizeof(countPerIndex), $ff);
    countPossibleArtPatterns := countFromIndex(0);
end;

function part1(var input: Text):comp; far;
var count: word;
    towels: TTowels;
    art   : TArtPattern;
    p     : TProgressBar;
begin
  count := 0;
  p.init(countLines(input)-2,'Count');
  readTowelPatterns(input, towels);
  skipLine(input); (* Read the empty line *)
  while not eof(input) do begin
    readArtPattern(input, art);
    if isArtPatternPossible(towels, art) then
      inc(count);
    p.step(1);
  end;
  p.done;
  part1 := count;
end;

function part2(var input: Text):comp; far;
const hexDigits: array[0..15] of char = '0123456789abcdef';
var count : word;
    result: comp;
    tmp   : comp;
    towels: TTowels;
    art   : TArtPattern;
    p     : TProgressBar;
    found : array[0..1024] of boolean;
    idx   : word;
    debug : byte;
begin
  count := 0;
  result := 0;
  p.init(countLines(input)-2,'Count');
  readTowelPatterns(input, towels);
  skipLine(input); (* Read the empty line *)
  FillChar(found, sizeof(found), 0);
  idx := 0;
  while not eof(input) do begin
    readArtPattern(input, art);
    tmp := countPossibleArtPatterns(towels, art);
    found[idx] := tmp > 0;
    if tmp > 0 then
      inc(count);
    result := result + tmp;
    p.step(1);
    inc(idx);
    assert(idx < sizeof(found), 'Too many art patterns found');
  end; 
  p.done; (*  *)
  writeln('Count of possible art patterns: ', count);
  debug := 0;
  for idx := 0 to high(found) do begin
    debug := debug shl 1;
    if found[idx] then inc(debug);
    if idx mod 8 = 7 then begin
      write(hexDigits[debug shr 4], hexDigits[debug and $0f], ' ');
      debug := 0;
    end;
    if idx mod 64 = 63 then writeln;
  end;
  WriteLn;
  part2 := result;
end;

begin
  runAoc(InputFileName, 19, part1, part2, nil, nil);
end.
