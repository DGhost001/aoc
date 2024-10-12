unit ProgressBar;

interface
type PProgressBar = ^TProgressBar;
     TProgressBar = object
       line       : byte;    (* Window coordinates *)
       maxCount_  : longint; (* Maximum *)
       progress_  : longint;
       update_    : longint;
       lastUpdate_: longint;

       title_     : string;

       constructor init(const max : longint; const title:string);
       destructor  done;

       procedure   draw;
       procedure   step(progress : longint);
       procedure   stepAbsolute(progress: longint);
       procedure   dispose;
     end;

implementation

uses crt;

constructor TProgressBar.init(const max : longint; const title:string);
var x,y : word;
begin
 progress_ := 0;
 maxCount_ := max;
 line      := Hi(WindMax)+1;
 title_    := title;
 update_   := max div 100;
 x := WhereX;
 y := WhereY;

 window(1,1,80,line-1);
 gotoxy(x,y);

 draw;
end;

destructor TProgressBar.done;
var oldWinMin, oldWinMax, x, y : word;
    i,j                        : longint;
begin
 lastUpdate_ := progress_;

 oldWinMin := WindMin;
 oldWinMax := WindMax;
 x := WhereX;
 y := WhereY;

 window(1,line,80,line);

 clrEol;

 window(Lo(oldWinMin)+1, Hi(oldWinMin)+1,
        Lo(oldWinMax)+1,line);

 gotoxy(x,y);
end;

procedure TProgressBar.draw;
var oldWinMin, oldWinMax, x, y : word;
    i,j                        : longint;
begin
 lastUpdate_ := progress_;

 oldWinMin := WindMin;
 oldWinMax := WindMax;
 x := WhereX;
 y := WhereY;

 window(1,line,80,line);


 i:= (progress_*40) div maxCount_;

 textBackground(0);
 textColor(lightGray);

 write(title_,' ');


 textColor(Magenta);
 write(#$c3);

 if i<>40 then textColor(lightMagenta) else textColor(green);

 for j:=1 to 40 do begin
   if j <= i then write(#$c4) else write(' ');
 end;

 textColor(Magenta);
 if i = 40 then write(#$b4) else write(#$b3);

 textColor(green);

 i:= (progress_*100) div maxCount_;
 write(' ',i,'%');
 clrEol;

 window(Lo(oldWinMin)+1, Hi(oldWinMin)+1,
        Lo(oldWinMax)+1, Hi(oldWinMax)+1);
 gotoxy(x,y);
 textColor(lightGray);
end;

procedure TProgressBar.step;
begin
 inc(progress_,progress);

 if progress_ > maxCount_ then progress := maxCount_;
 if (progress_ - lastUpdate_ > update_) or
    (progress_ = maxCount_)
 then
  draw;
end;

procedure TProgressBar.stepAbsolute;
begin
 progress_ := progress;
 if progress_ < 0 then progress_ := 0;

 if progress_ > maxCount_ then progress := maxCount_;
 if (progress_ - lastUpdate_ > update_) or
    (progress_ = maxCount_)
 then
  draw;
end;

procedure TProgressBar.dispose;
begin
 system.dispose(PProgressBar(@self),done);
end;

begin
end.
