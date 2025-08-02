unit crt;

interface
  const 
    BLACK = 0;
    RED = 1;
    GREEN = 2;
    YELLOW = 3;
    BLUE = 4;
    MAGENTA = 5;
    CYAN = 6;
    WHITE = 7;
    LIGHTGRAY = 8;

    
  procedure clrscr;
  procedure TextColor (Color: byte);
  procedure gotoxy(x, y: byte);
  procedure delay (ms: word); 
  function keypressed: boolean;
  function readkey: char;

implementation

uses gemdos, sysutils;
procedure clrscr;
begin
  gemdos_cconws('\33E'); (* Clear screen command for Atari *)
end;

procedure TextColor (Color: byte);
begin
    gemdos_cconws('\33b');
    case color of
        0: gemdos_cconws('\0');  // Black
        1: gemdos_cconws('\1');  // Red
        2: gemdos_cconws('\2');  // Green
        3: gemdos_cconws('\3');  // Yellow
        4: gemdos_cconws('\4');  // Blue
        5: gemdos_cconws('\5');  // Magenta
        6: gemdos_cconws('\6');  // Cyan
        7: gemdos_cconws('\7');  // White
    else gemdos_cconws('\7'); // Default to White for invalid color
    end;
end;

procedure gotoxy(x, y: byte);
var s:string;
begin
  s:= '\33Y' + chr(y + 32) + chr(x + 32); (* Move cursor to (x,y) *)
  s:= s + chr(0); (* Null-terminate the string *)
  gemdos_cconws(@s[1]);
end;

function keypressed: boolean;
begin
  keypressed := gemdos_cconis <> 0; (* Check if a key is pressed *)
end;

function readkey: char;
begin
  if keypressed then
    readkey := chr(gemdos_cconin) (* Read a character from the console *)
  else
    readkey := #0;
end;

procedure delay(ms: word);
var biosTickCount: longint absolute $04ba;  (* 200Hz counter value *)
    ticksToWait: longint;
    oldStack: Pointer; 
begin
  ticksToWait := ms div 5;
  oldStack := Pointer(gemdos_super(nil));
  ticksToWait := ticksToWait + biosTickCount; (* Calculate target tick count *)
  while biosTickCount < ticksToWait do begin end;
  gemdos_super(oldStack);
end;

begin
end.