unit cassert;
interface
 procedure assert(const condition: boolean;
                  const text: string);
implementation

uses crt;

procedure assert(const condition: boolean;
                  const text: string);
begin
  if not condition then begin
    writeln;
    textColor(red);
    write('Assertion Failed: ');
    textColor(LightGray);
    write('"');
    textColor(White);
    write(text);
    textColor(lightGray);
    writeln('"');
    writeln('Aborting...');
    runError(300);
  end;
end;

begin
end.