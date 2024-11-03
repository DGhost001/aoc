program Day17;
type TDirection = (Up,Left,Right, Down);
const options : array[1..4] of TDirection = (Up,Left,Right,Down);
(*
  This day is a bit tricky, but can be solved by using the Dykstra Algorithm.
  We consider every step taken a node in a graph.
  Each node is connected to 9 other nodes (3 directions by 3 possible step
  sizes).

  We than run just the Dykstra and the requested answer will be generated.

  For the map data structure, we can reuse a lot from day16.
*)
var i : TDirection;
begin
 for i:= Up to Down do writeln('Hello');
end.
