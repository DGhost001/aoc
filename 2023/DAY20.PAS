program day20;
(* This is the solution for day 20 of aoc 2023 *)
type TSignal = (LowSignal, HighSignal);
     TModuleId= record
       id  : word;
       ref : word;
     end;
     PModule = ^TModule;
     TModuleList = array[0..63] of PModule;
     TModule = object
        id             : word;
        numberOfOutputs: byte;
        outputs        : array[0..15] of TModuleId;

        constructor init(const id: word);

        procedure addOutPut(const id : word); virtual;
        procedure addInput(const id : word); virtual;
        procedure connect(const modules: TModuleList); virtual;
        procedure trigger(const src: word; const signal: TSignal); virtual;
      end;

      PFlipFlop = ^TFlipFlop;
      TFlipFlop = object(TModule)
        constructor init(const id: word);
        procedure trigger(const src: word; const signal: TSignal); virtual;
      end;

      PNand = ^TNand;
      TNand = object(TModule)
        numberOfInputs : byte;
        input : array[0..15] of record
            id   : word;
            state: TSignal;
        end;

        constructor init(const id: word);
        procedure trigger(const src: word; const signal: TSignal); virtual;
        procedure addInput(const id : word); virtual;
      end;

      PBroadcast = ^TBroadcast;
      TBroadcast = object(TModule)
        constructor init(const id: word);
        procedure trigger(const src: word; const signal: TSignal); virtual;
      end;

var modules : TModuleList;

begin
end.
