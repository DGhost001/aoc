unit cassert;
interface
 procedure assert(const condition: boolean;
                  const text: string);
implementation

 procedure assert(const condition: boolean;
                  const text: string);
begin
  if not condition then begin
    writeln('Assertion Failed: ',text);
    runError(300);
  end;
end;

begin
end.