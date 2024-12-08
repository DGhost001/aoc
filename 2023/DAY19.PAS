program day19;
(* This is the implementation of the aoc 23 day 19 *)
uses crt, ItemHandler, DeQueue, Progressbar;
const InputFileName = 'INP\DAY19_IN.TXT';
type
      TCategories = (Extreme, Musical, Aerodynamic, Shiny);
      TRating  = array[Extreme .. Shiny] of word;

      PPart = ^TPart;
      TPart = object(ItemType)
        rating_ : TRating;

        constructor init(rating : TRating);
      end;

      PStep = ^TStep;

      TStep = object(ItemType)
        function getNextStep(const rating: TRating) :  PStep; virtual;
      end;

      PConditional  = ^TConditional;
      TConditional = object(TStep)
        cat_ : TCategories;
        rel_ : TRelation;
        val_ : word;
        yes_ : PStep;
        no_  : PStep;

        constructor init( cat : TCategories;
                          rel : TRelation;
                          val : word;
                          yes : PStep;
                          no  : PStep);

        function getNextStep(const rating: TRating) :  PStep; virtual;
      end;

      PAccept = ^TAccept;
      TAccept = object(TStep)
        total_ : longint;
        constructor init;
        function getNextStep(const rating: TRating) :  PStep; virtual;
      end;

      PReject = ^TReject;
      TReject = object(TStep)
        function getNextStep(const rating: TRating) :  PStep; virtual;
      end;

      TRuleId = string[3];

      PForward = ^TForward;
      TForward = object(TStep)
        id_  : TRuleId;
        next_: PStep;
        constructor init(const id : TRuleId);
        function getNextStep(const rating: TRating) :  PStep; virtual;
      end;

      TRules = record
        id       : TRuleId;
        steps    : array[0..7] of PStep;
      end;

var rules : array[0..511] of TRules;
    accept: TAccept;
    reject: TReject;

constructor TPart.init;
begin
 rating_ := rating;
end;

function TStep.getNextStep;
begin
 runError(211); (*Abstract function ... not to be called *)
end;

constructor TConditional.init;
begin
  cat_ := cat;
  rel_ := rel;
  val_ := val;
  yes_ := yes;
  no_  := no;
end;

function TConditional.getNextStep;
begin
  case rel_ of
     Bigger : if rating[cat_] > val_ then getNextStep := yes_ else getNextStep:= no_;
     Smaller: if rating[cat_] < val_ then getNextStep := yes_ else getNextStep:= no_;
     Equal  : if rating[cat_] = val_ then getNextStep := yes_ else getNextStep:= no_;
  end;
end;

constructor TAccept.init;
begin
  total_ := 0;
end;

function TAccept.getNextStep;
var i: TCategories;
begin
  getNextStep := Nil;
  for i:=Extreme to Shiny do inc(total_, rating[i]);
end;

function TReject.getNextStep;
begin
  getNextStep := Nil;
end;

constructor TForward.init;
begin
  id_ := id;
  next_ := NIL;
end;

function TForward.getNextStep;
var i : word;
begin
  if next_ = NIL then begin
    for i:=0 to HIGH(rules) do begin
      if rules[i].id = id_ then begin
        next_ := rules[i].steps[0];
        break;
      end;
    end;
    if next_ = NIL then runError(300); (* There is a missing link here *)
  end;
  getNextStep := next_;
end;

procedure runFilter(const rating:  TRating);
var cstep : PStep;
    i     : word;
begin
  for i:=0 to HIGH(rules) do
    if rules[i].id = 'in' then begin
      cstep := rules[i].steps[0];
      break;
    end;
  while cstep <> NIL do
    cstep:= cstep^.getNextStep(rating);
end;

procedure parseRules(var input: Text);

function stackPos(const s:string): byte;
var result, s1, s2 : byte;
begin
  result := 1;
  s1 := 0;
  s2 := 0;
  while result <= length(s) do begin
    if s[result] = ':' then begin inc(s1); inc(s2); end;
    if (s[result] = ',') and (s1 > 0) then begin
       dec(s2);
       if s2 = 0 then break;
    end;
    inc(result);
  end;

  stackPos:= result;
end;

function parseStep(const rule: word;
                   var step: byte;
                   const line: string): PStep;
var condition, yes, no : string;
    p1, p2, tmp : byte;
    value       : word;
    c           : integer;
    cat         : TCategories;
    rel         : TRelation;

begin
  if line = 'A' then parseStep := @accept else
  if line = 'R' then parseStep := @reject else
  if length(line) <= 3 then begin
    rules[rule].steps[step] := new(PForward, init(line));
    parseStep:= rules[rule].steps[step];
    inc(step);
  end else begin
    p1:=pos(':',line);
    p2:=stackPos(line);
    condition := copy(line,1,p1 - 1);
    yes       := copy(line,p1 + 1, p2 - p1-1);
    no        := copy(line,p2 + 1, length(line) - p2);

    val(copy(condition,3,length(condition)-2), value, c);

    case condition[1] of
      'a': cat := Aerodynamic;
      'm': cat := Musical;
      's': cat := Shiny;
      'x': cat := Extreme;
    end;

    case condition[2] of
      '<': rel := Smaller;
      '>': rel := Bigger;
      '=': rel := Equal;
    end;

    tmp := step;
    inc(step);

    rules[rule].steps[tmp] := new(PConditional,
                           init( cat, rel, value,
                           parseStep( rule, step, yes),
                           parseStep( rule, step, no)));

    parseStep := rules[rule].steps[tmp];
  end;
end;

var i, rule: word;
    line : string;
    steps: string;
    p, tmp: byte;
begin
  rule := 0;
  while not eof(input) do begin
    readln(input, line);
    if line = '' then break;
    i := 1;
    p := pos('{',line);
    rules[rule].id:= copy(line,1,p-1);
    steps := copy(line,p+1,pos('}',line)-p-1);
    tmp := 1;
    (*Step 0 is special ... it is always the first step in the rule set *)
    rules[rule].steps[0] := parseStep(rule, tmp, steps);
    inc(rule);
  end;
end;

procedure cleanUpRules;
var i,j: word;
begin
  for i:= 0 to HIGH(rules) do begin
    for j:=1 to HIGH(rules[i].steps) do begin
      if rules[i].steps[j] <> NIL then begin
        dispose(rules[i].steps[j], done);
        rules[i].steps[j] := NIL;
      end;
    end;
  end;
end;

function parseParts(var input: Text) : PDeQueue;
var result : PDeQueue;
    p      : byte;
    line   : string;
    tmp    : string;
    rating : TRating;
    value  : word;
    c      : integer;
begin
  result := new(PDeQueue, init);
  while not(eof(input)) do begin
    readln(input, line);
    if line <> '' then begin
      (* Remove the curly braces, no one needs them *)
      delete(line,1,1);
      delete(line,length(line),1);

      fillchar(rating,sizeof(rating),0);
      while length(line) > 0 do begin
        p := pos(',', line);
        if p = 0 then p := length(line) + 1;
        tmp := copy(line,1,p-1);
        delete(line,1, p);
        val(copy(tmp,3,length(tmp) - 2), value, c);
        case tmp[1] of
          'x': rating[Extreme] := value;
          's': rating[Shiny] := value;
          'm': rating[Musical] := value;
          'a': rating[Aerodynamic] := value;
        end;
      end;
      result^.pushBack(new(PPart,init(rating)));
    end;
  end;
  parseParts := result;
end;

function part1(var input: Text): longint;
var parts : PDeQueue;
    it    : PDeQueueIterator;
    p     : TProgressBar;
begin
  reject.init;
  accept.init;
  fillchar(rules,sizeof(rules),0);
  parseRules(input);
  parts := parseParts(input);
  p.init(parts^.size,'Filter..');
  it := parts^.first;

  while it <> NIL do begin
    runFilter(PPart(it^.at)^.rating_);
    it := it^.next;
    p.step(1);
  end;
  p.done;
  parts^.dispose;
  cleanUpRules;
  part1 := accept.total_;
end;

var input: Text;
      p1 : longint;
begin
  assign(input,InputFileName);
  reset(input);
  p1 := part1(input);
  writeln('The Answert to Part 1 is: ',p1);
end.
