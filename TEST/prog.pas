program Prog;

uses App, progressbar, crt;

var p: TProgressBar;
    i: integer;
begin
    startApplication;
    writeln('---=== Progress Bar Test ===---');
    p.init(100, 'Test');
    for i:= 1 to 100 do begin
        p.step(1);
        delay(50); // Simulate some work
    end;

    p.done;
    WriteLn(' Press Enter to exit...');
    ReadLn;
    endApplication;
end.