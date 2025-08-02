program day6;
(*This is the solution for day 6 of the advent of code 2023*)
uses crt, math, utils, stdint, jstring;

type TRace = record
       time     : real;
       distance : real;
     end;

const Records : array[0..3] of TRace =
       ( ( time: 56.0; distance: 499.0),
         ( time: 97.0; distance: 2210.0),
         ( time: 77.0; distance: 1097.0),
         ( time: 93.0; distance: 1440.0));
     LongRace: TRace =
         ( time: 56977793.0; distance: 499221010971440.0);
(*
  The required race timing soultions can be computed from
  t1 = ceil(0.5*(g - sqrt(g^2-4*s))), g^2 >= 4s
  t2 = floor(0.5*(g + sqrt(g^2-4*s)))
*)
procedure getBoatTimings( raceLength   : real;
                          raceDistance : real;
                          var t1       : longint;
                          var t2       : longint );
var wurzel : real;
    s      : real;
    g      : real;
begin
  s      := raceDistance;
  g      := raceLength;
  wurzel := sqrt( (g*g) - (4*s));
  t1 := ceil (0.5 * (g - wurzel)); (* Lower boundary *)
  t2 := floor(0.5 * (g + wurzel)); (* Upper boundary *)
end;

function getCertanty(  raceLength  : real;
                       raceDistance: real): longint;
var t1,t2: longint;
begin
  getBoatTimings(raceLength, raceDistance, t1, t2);
  getCertanty := (t2 - t1) + 1;
end;

var i   : integer;
    sum : longint;
begin
  sum := 1;
  for i:=0 to HIGH(Records) do
    sum:= sum * getCertanty(Records[i].time,Records[i].distance);

  writeln('Race Certanty: ',sum);
  writeln('Long Race: ',getCertanty(LongRace.time, LongRace.distance));
end.
