program Ticker;

uses gemdos;

function getTickCount: longint;
var biosTickCount: longint absolute $04ba;  (* 200Hz counter value *)
    result: longint;
    oldStack: Pointer; 
begin
  oldStack := Pointer(gemdos_super(nil));
  result := biosTickCount; (* Read the 200Hz counter in super mode *)
  gemdos_super(oldStack);
  getTickCount := result;
end;

begin
    writeln('---=== Tick Count Test ===---');
    writeln('Current tick count: ', getTickCount);
    ReadLn;
    writeln('Current tick count: ', getTickCount);
    writeln('Press Enter to exit...');
    ReadLn;
end.