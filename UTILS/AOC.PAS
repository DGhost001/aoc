unit aoc;

interface
type FAocFunction = function (var input : Text) : comp;

     procedure runAoc(const fileName : string;
                      const day      : word;
                      part1 : FAocFunction;
                      part2 : FAocFunction);
implementation

{$IFDEF ATARI}
uses app, crt;
{$ELSE}
uses crt;
{$ENDIF}

procedure runAoc(const fileName : string;
                      const day      : word;
                      part1 : FAocFunction;
                      part2 : FAocFunction);
var input : Text;
    result: comp;
begin
  {$IFDEF ATARI}
  startApplication;
  {$ELSE}
  clrscr;
  {$ENDIF}
  assign(input, fileName);

  writeln('Starting Day ',day:2, '...');
  if @part1 <> NIL then begin
    reset(input);
    result := part1(input);
    {$IFDEF ATARI}
    writeln('Answer to Part 1 is: ', result:1);
    {$ELSE}
    writeln('Answer to Part 1 is: ', result:1:0);
    {$ENDIF}
  end;

  if @part2 <> NIL then begin
    reset(input);
    result := part2(input);
    {$IFDEF ATARI}
    writeln('Answer to Part 2 is: ', result:1);
    {$ELSE}
    writeln('Answer to Part 2 is: ', result:1:0);
    {$ENDIF}
  end;

  close(input);
  {$IFDEF ATARI}
  WriteLn('---=== Press Return to exit... ===---');
  ReadLn;
  endApplication;
  {$ENDIF}
end;
begin
end.