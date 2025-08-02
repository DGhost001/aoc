
unit ProgressBar;
interface
{$N+} {$E+} (*Enable emulation and Co-Processor*)

uses clock;
type PProgressBar = ^TProgressBar;
     TProgressBar = object
       line            : word;    (* Window coordinates *)
       maxCount_       : longint; (* Maximum *)
       progress_       : longint;
       update_         : longint;
       lastUpdate_     : longint;
       start_          : TClock;
       lastUpdateTime_ : longint;

       title_     : string;

       constructor init(const max : longint; const title:string);
       destructor  done;

       procedure   draw;
       procedure   step(progress : longint);
       procedure   stepAbsolute(progress: longint);
       procedure   dispose;
     end;

implementation

{$IFDEF ATARI}
uses app, crt, stdint;
{$ELSE}
uses crt, fastout;
{$ENDIF}

constructor TProgressBar.init(const max : longint; const title:string);
var x,y : word;
begin
 progress_ := 0;
 maxCount_ := max;
 title_    := title;
 start_    := now;
 lastUpdateTime_ := getTickCount;

 if max > 100000 then
    update_   := max div 100000
 else if max > 10000 then
    update_   := max div 10000
 else if max > 1000 then
    update_   := max div 1000
 else if max > 100 then
    update_   := max div 100
 else
    update_  := 1;

 {$IFDEF ATARI}
 line := getSizeY - 16 + 1;
 window(1,line,getSizeX, line + 16 - 1);
 fillRectangle(0,0,getSizeX, 16-1,$0208,0); (* Clear the line *)
 window(1,1,getSizeX,getSizeY - 16);
 {$ELSE}
 line      := Hi(WindMax)+1;
 x := WhereX;
 y := WhereY;

 window(1,1,80,line-1);
 gotoxy(x,y);
 {$ENDIF}

 draw;
end;

destructor TProgressBar.done;
var oldWinMin, oldWinMax, x, y : word;
begin
 lastUpdate_ := progress_;

 {$IFDEF ATARI}
 window(1,line,getSizeX, line + 16 - 1);
 fillRectangle(0,0,getSizeX, 16-1,$0208,0);
 window(1,1,getSizeX, line + 16);
 {$ELSE}
 oldWinMin := WindMin;
 oldWinMax := WindMax;

 x := WhereX;
 y := WhereY;

 window(1,line,80,line);

 clrEol;

 window(Lo(oldWinMin)+1, Hi(oldWinMin)+1,
        Lo(oldWinMax)+1,line);

 gotoxy(x,y);
 {$ENDIF}
end;

{$IFDEF ATARI}
procedure TProgressBar.draw;
var st, tmp                    : string;
    i,j                        : longint;
    time,left                  : TClock;
    a, b, r                    : uint64_t;
    h,eh,m,em,s,es             : word;
    pr                         : real;
    x                          : word;
begin
   time := now - start_;
   if progress_ > 0 then begin
    uint64FromComp(time,a);
    fromLongInt64(progress_,b);
    mul64LongInt(a, maxCount_);
    div64(a, b, r);
    left := uint64ToComp(a) - time;
   end else
    left := 0;
   toHMS(h,m,s,left);
   toHMS(eh,em,es,time);
   pr := progress_*100  / maxCount_;

   window(1,line,getSizeX, line + 16 - 1);

   

   putText(1,1,title_ + ' '); x:= length(title_)*8+8;

   str(pr:2:2,tmp); st:= tmp + '% ';  
   str(eh:2, tmp);  st:= st + tmp + ':';
   str(em:2,tmp);   st:= st + tmp + ':';
   str(es:2,tmp);   st:= st + tmp + ' ';
   str(h:2,tmp);    st:= st + tmp + ':';
   str(m:2, tmp);   st:= st + tmp + ':';
   str(s:2, tmp);   st:= st + tmp + ' ';
   
   i:= ((progress_*40) div maxCount_) * 8;
   rectangle(x,2, x + 40*8, 10 );
   fillRectangle(x, 2, x + i, 10, $0208, 1);

   putText(x+40*8+8,1,st);

   window(1,1,getSizeX, line - 1 );
end;
{$ELSE}

procedure TProgressBar.draw;
var oldWinMin, oldWinMax, x, y : word;
    i,j                        : longint;
    time,left                  : TClock;
    h,eh,m,em,s,es             : word;
    pr                         : real;
    st,t                       : string;
begin
   time := now - start_;
   if progress_ > 0 then
    left := (time / progress_ ) * maxCount_ - time
   else
    left := 0.0;
   toHMS(h,m,s,left);
   toHMS(eh,em,es,time);
   lastUpdate_ := progress_;

   i:= (progress_*40) div maxCount_;

   x:= 0;
   fastWrite(x,line-1, lightGray, title_); inc(x,length(title_) + 1);

   st:=#$c3;

   for j:=1 to 40 do begin
     if j <= i then st:=st+#$c4 else st:=st+' ';
   end;

   if i = 40 then begin
     st:=st+#$b4;
     fastWrite(x,line-1,green,st);
   end else begin
     st:=st+#$b3;
     fastWrite(x,line-1,Magenta,st);
   end;
   inc(x,length(st));

   pr := progress_*100  / maxCount_;
   str(pr:2:2,st);
   st:=' '+st+'% ';

   fastWrite(x,line-1,green,st); inc(x,length(st));

   t:='';
   str(eh:2,st); t:=t+st+':';
   str(em:2,st); t:=t+st+':';
   str(es:2,st); t:=t+st+' ';
   str(h:2,st);  t:=t+st+':';
   str(m:2,st);  t:=t+st+':';
   str(s:2,st);  t:=t+st+'  ';

   fastWrite(x,line-1,lightGray,t);
end;
{$ENDIF}

procedure TProgressBar.step;
var ticks : longint;
begin
 ticks := getTickCount;
 inc(progress_,progress);
 if keypressed then
   if readkey = #27 then
     halt;
 if progress_ > maxCount_ then progress := maxCount_;
 {$IFDEF ATARI} 
 (* Update on the ATARI is super expansive ... so update only once per second *)
 if (progress_ = maxCount_) or
    (lastUpdateTime_ > ticks ) or
    ((ticks - lastUpdateTime_) > 200)
 {$ELSE}
 if (progress_ - lastUpdate_ >= update_) or
    (progress_ = maxCount_) or
    (lastUpdateTime_ > ticks ) or
    ((ticks - lastUpdateTime_) > 18)
 {$ENDIF}
  
 then begin
  draw;
  lastUpdateTime_ := ticks;
 end;
end;

procedure TProgressBar.stepAbsolute;
begin
 progress_ := progress;
 if progress_ < 0 then progress_ := 0;

 if progress_ > maxCount_ then progress := maxCount_;
 if (progress_ - lastUpdate_ >= update_) or
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
