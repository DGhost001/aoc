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

function part1(var input: Text):comp; far;
var count: word;
    towels: TTowels;
    art   : TArtPattern;
    p     : TProgressBar;
begin
  count := 0;
  p.init(countLines(input)-2,'Count');
  readTowelPatterns(input, towels);
  readln(input); (* Read the empty line *)
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
begin
  part2 := 0;
end;

begin
  runAoc(InputFileName, 19, part1, part2, nil, nil);
end.
