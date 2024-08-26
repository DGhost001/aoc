program day2;
uses JString, ItemHandler, DeQueue, crt;
(* This is the advent of code 2023 implementation DAY 2 *)

type
     PGame = ^TGame;
     PPlay = ^TPlay;
     TPlay = object(ItemType)
       red_   : integer;
       green_ : integer;
       blue_  : integer;

       constructor init(red, green, blue : integer);
       destructor done; virtual;

       procedure dispose;
       function isGoodPlay(const red, green, blue : integer):boolean;
       procedure updateMax(var red, green, blue: integer);
     end;

     TGame = object(ItemType)
       plays_  : PDeQueue;
       gameNr_ : integer;

       constructor init(gameNr: integer);
       destructor  done; virtual;

       procedure dispose;
       procedure append(game : PPlay);
       function isGoodGame(const red, green, blue: integer):boolean;
       procedure updateMax(var red, green, blue: integer);
     end;

const
     InputFileName : string = 'DAY2_INP.TXT';
     MaxRedCubes   = 12;
     MaxGreenCubes = 13;
     MaxBlueCubes  = 14;

constructor TPlay.init;
begin
  red_   := red;
  green_ := green;
  blue_  := blue;
end;

destructor TPlay.done;
begin
  (* Intentionally Empty *)
end;

procedure TPlay.dispose;
begin
  SYSTEM.dispose(PPlay(@self), done);
end;

function TPlay.isGoodPlay;
begin
  isGoodPlay := (red_ <= red) and (green_ <= green) and (blue_ <= blue);
end;

procedure TPlay.updateMax;
begin
  if red < red_ then red := red_;
  if green < green_ then green := green_;
  if blue < blue_ then blue:= blue_;
end;

constructor TGame.init;
begin
  plays_ := new(PDequeue, init);
  gameNr_:= gameNr;
end;

destructor TGame.done;
begin
  SYSTEM.dispose(plays_,done);
end;

procedure TGame.dispose;
begin
  SYSTEM.dispose(PGame(@self),done);
end;

procedure TGame.append;
begin
  plays_^.pushBack(game);
end;

function TGame.isGoodGame;
var result : boolean;
    it     : PDeQueueIterator;
begin
  result := True;
  it := plays_^.first;

  while (it <> nil) and result do begin
    result := result and PPlay(it^.at)^.isGoodPlay(red, green, blue);
    it := it^.next;
  end;
  isGoodGame := result;
end;

procedure TGame.updateMax;
var it : PDeQueueIterator;
begin
  red   := -1;
  green := -1;
  blue  := -1;
  it    := plays_^.first;
  while (it <> nil) do begin
    PPlay(it^.at)^.updateMax( red, green, blue);
    it := it^.next;
  end;
end;
function ReadLine(var f: Text) : PJString;
var c      : char;
    result : PJString;
begin
  c:= #0;
  result := cJString(''); (* Create Empty String *)
  while (not eof(f)) and (c <> #10) do begin
    read(f,c);
    result^.pushBack(c);
  end;
  ReadLine := result;
end;

(* One line is encoded as: *)
(* Game 1: 1 green, 2 blue; 15 blue, 12 red, 2 green; *)

function parseGame(s : PJString): PGame;
  function getGameNumber(gameStr: PJString): integer;
  var data    : PDequeue;
      striped : PJString;
      code    : integer;
      result  : integer;
  begin
    striped := gameStr^.stripWhiteSpace;
    data    := striped^.split(' ');
    result  := -1;

    if data^.size = 2 then begin
      if PJString(data^.at(0))^.toString = 'Game' then
         val(PJString(data^.at(1))^.toString, result, code)
      else
         writeln('Line with "Game" Keyword missing ... skipping');
    end else
      writeln('Invalid Game Format ... skipping');

    getGameNumber := result;
    data^.dispose;
    striped^.dispose;
  end;

  function getColorCode(colorStr: PJString; var color: string): integer;
  var data   : PDequeue;
      striped: PJString;
      code   : integer;
      result : integer;
  begin
    striped := colorStr^.stripWhiteSpace;
    data    := striped^.split(' ');
    result  := -1;
    color   := '';

    if data^.size = 2 then begin
      color := PJString(data^.at(1))^.toString;
      val(PJString(data^.at(0))^.toString, result, code);
    end else
      writeln('Invalid Color Coding found ... skipping');

    getColorCode := result;
    data^.dispose;
    striped^.dispose;
  end;

  function getPlay(draw : PJString): PPlay;
  var
     red,green,blue,tmp: integer;
     data              : PDeQueue;
     it                : PDeQueueIterator;
     color             : string;
  begin
    data := draw^.split(',');
    it   := data^.first;

    red   := 0;
    green := 0;
    blue  := 0;

    while it <> NIL do begin
      tmp := getColorCode(PJstring(it^.at), color);
      if color = 'red' then  red   := tmp else
      if color = 'green' then green := tmp else
      if color = 'blue' then blue  := tmp else
        writeln('Invalid Color Code');
      it:=it^.next;
    end;

    data^.dispose;
    getPlay := new(PPlay, init(red,green,blue));
  end;

var data   : PDequeue;
    plays  : PDequeue;
    playIt : PDeQueueIterator;
    result : PGame;
    play   : PPlay;
    nr     : integer;
begin
  data := s^.split(':');
  result := NIL;

  if data^.size = 2 then begin
    nr := getGameNumber(PJString(data^.at(0)));
    if nr >= 0 then begin
      result := new(PGame,init(nr));

      plays := PJString(data^.at(1))^.split(';');
      playIt := plays^.first;
      while playIt <> NIL do begin
        play := getPlay(PJString(playIt^.at));
        result^.append(play);
        playIt := playIt^.next;
      end;
      plays^.dispose;
    end;
  end else
    writeln('Invalid line encoding detected ... skipping');

  data^.dispose;
  parseGame := result;
end;

var game                      : PGame;
    input                     : Text;
    line                      : PJString;
    sum, sumPower             : longint;
    minRed, minBlue, minGreen : integer;
begin
  sum := 0;
  sumPower := 0;
  assign(input,InputFileName);
  reset(input);

  while not eof(input) do begin
    line := ReadLine(input);
    game := parseGame(line);
    if game <> NIL then begin
      if game^.isGoodGame(MaxRedCubes, MaxGreenCubes, MaxBlueCubes) then begin
        textColor(green);
        sum := sum + game^.gameNr_;
      end else
        textColor(red);
      write(game^.gameNr_,' ');
      game^.updateMax(minRed,minGreen, minBlue);

      sumPower := sumPower + minRed*minGreen*minBlue;

      game^.dispose;
    end;
    line^.dispose;
  end;
  close(input);
  textColor(lightGray);
  writeln;
  writeln('Sum of all good games:',sum);
  writeln('Sum of all powers:',sumPower);
end.
