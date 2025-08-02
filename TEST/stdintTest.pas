program stdintTest;
uses stdint, cassert, app;

var a : uint64_t;
    b : uint64_t;
    r : uint64_t;
    c : Comp;

begin
  startApplication;
  
  writeln('---=== stdint Test ===---');
  fromLongInt64($00aa55aa, a);
  assert(toLongInt64(a) = $00aa55aa, 'toLongInt64 failed');
  writeln('toLongInt64 OK');
  rotateLeft64(4, a);  
  assert(toLongInt64(a) = $0aa55aa0, 'rotateLeft64 failed');
  WriteLn('rotateLeft64 OK');
  fromLongInt64(12345, a);
  mul64LongInt(a, 100);
  assert(toLongInt64(a) = 1234500, 'mul64LongInt');  
  WriteLn('mul64LongInt OK');
  fromLongInt64(100, b);
  div64(a, b, r);
  assert(isNull64(r), 'div64 failed');
  WriteLn('div64 remainder OK');
  assert(toLongInt64(a) = 12345, 'div64 failed');
  WriteLn('div64 OK');
  c := uint64ToComp(a);
  assert(c = 12345, 'uint64ToComp failed');
  WriteLn('uint64ToComp OK');
  c := 54321;
  uint64FromComp(c, a);
  assert(toLongInt64(a) = 54321, 'compToUint64 failed');
  WriteLn('compToUint64 OK');
  WriteLn('All tests passed successfully!');

  endApplication;
end.