unit aoc;

interface
type
  FAocFunction = function (var input : Text) : comp;
  FAocSetupTeardown = procedure(var input : Text);

procedure runAoc(fileName : string;
         const day      : word;
         part1 : FAocFunction;
         part2 : FAocFunction;
         setup : FAocSetupTeardown;
         tearDown : FAocSetupTeardown);
implementation

{$IFDEF ATARI}
uses app, crt, cassert;
{$ELSE}
uses crt, cassert;
{$ENDIF}

procedure runAoc(fileName : string;
                 const day      : word;
                 part1 : FAocFunction;
                 part2 : FAocFunction;
                 setup : FAocSetupTeardown;
                 tearDown : FAocSetupTeardown);
var input : Text;
    result: comp;
begin
  {$IFDEF ATARI}
  startApplication;
  {$ELSE}
  clrscr;
  {$ENDIF}
  {$IFDEF LINUX}
   (* On Unix style platforms a \ is equal to an / *)
   while pos('\',fileName) > 0 do
     fileName[pos('\',fileName)] := '/';
  {$ENDIF}
  assign(input, fileName);
  
  writeln('Starting Day ',day:2, '...');

  if @setup<>Nil then begin
    {$I-}
    reset(input);
    assert(IOResult = 0, 'Inputfile "'+fileName+'" not found');
    {$I+}
    setup(input);
  end;
  
  if @part1 <> NIL then begin
    {$I-}
    reset(input);
    assert(IOResult = 0, 'Inputfile "'+fileName+'" not found');
    {$I+}
    result := part1(input);
    {$IFDEF ATARI}
    writeln('Answer to Part 1 is: ', result:1);
    {$ELSE}
    writeln('Answer to Part 1 is: ', result:1:0);
    {$ENDIF}
  end;

  if @part2 <> NIL then begin
    {$I-}
    reset(input);
    assert(IOResult = 0, 'Inputfile "'+fileName+'" not found');
    {$I+}
    result := part2(input);
    {$IFDEF ATARI}
    writeln('Answer to Part 2 is: ', result:1);
    {$ELSE}
    writeln('Answer to Part 2 is: ', result:1:0);
    {$ENDIF}
  end;
  
  if @tearDown <> NIL then begin
    {$I-}
    reset(input);
    assert(IOResult = 0, 'Inputfile "'+fileName+'" not found');
    {$I+}
    tearDown(input);
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