program division;

uses stdint,crt;

procedure divmnu(var q,r: uint64_t; u, v : uint64_t);

  (* Helper to get the number of leeding zeros *)
  function nlz(x : byte) : byte;
  var n : byte;
      y : byte;
  begin
    n := 8;

    y := x shr 4; if( y <> 0) then begin dec(n,4); x:= y; end;
    y := x shr 2; if( y <> 0) then begin dec(n,2); x:= y; end;
    y := x shr 1; if( y <> 0) then nlz := n - 2 else nlz := n - x;
  end;

var   vn             : uint64_t; (* Normalized u and v *)
      un             : array[0..8] of byte;
      qHat           : word;     (* Estimate of the quotient *)
      rHat           : word;     (* Reminder *)
      p              : word;     (* Product of two numbers *)
      tmp            : word;
      s,sHat,i,j,t,k,m,n,t1  : integer;  (* Looping Counters *)
      a,b            : byte;
begin
  m:=HIGH(u) + 1;
  n:=HIGH(v) + 1;
  (* Cleanout the result buffer *)
  q:= zero64;
  r:= zero64;

  (* Find the highest non zero part *)
  while (m > 0) and (u[m - 1] = 0) do dec(m);
  while (n > 0) and (v[n - 1] = 0) do dec(n);

  if (n = 0) then runError(200); (* Division by 0 is bad *)
  if (n > m) then exit;          (* if n > m the result is 0 *)

  if n = 1 then begin            (* Single digit divisor is a special case*)
                                 (* handle it here *)
     k := 0;
     for j:= m -1 downto 0 do begin
       tmp  := ((k shl 8) or u[j]);
       q[j] := tmp div v[0];
       k    := tmp mod v[0];
     end;
     r[0] := k and $ff;          (* k can never be > 255, so we don't loose anything by converting it here *)
  end else begin                 (* We have always a divisor with more than 1 digit *)
    s    := nlz(v[n-1]);         (* We need the number of bits to shift left, so that the highest bit of v is set *)
    shat := 8 - s;
    vn := v;
    rotateLeft64(s,vn);

    (* Shift left u, therefor un can have up to 8 bits more than u *)
    un[m] := u[m - 1] shr shat;
    for i:= m - 1 downto 1 do begin
      un[i] := ((u[i] shl s) and $ff) or ((u[i-1] shr shat) and $ff);
    end;
    un[0] := (u[0] shl s) and $ff;

    (* Main division is here *)
    for j := m - n downto 0 do begin
      tmp  := (un[j + n] shl 8) or (un[j + n - 1]);
      qhat := tmp div vn[n - 1];
      rhat := tmp mod vn[n - 1];

      repeat
        if (qhat >= 256) or (qhat * vn[n-2] > ((rhat shl 8) or (un[j+n-2]))) then begin
          dec(qhat);
          inc(rhat, vn[n-1]);
        end else break;
      until rhat >= 256;

      (* Multiply and subtract *)
      k:= 0;
      for i:=0 to n-1 do begin
        p := qhat * vn[i];
        t := un[i+j] - k - (p and $ff);
        un[i+j] := (t and $ff);
        k := ((p shr 8) and $ff) - (shortInt(t shr 8));
      end;

      q[j] := qhat;


      t1:= un[j+n] - k;
      if t1 < 0 then begin
        dec(q[j]);
        k := 0;
        for i:= 0 to n-1 do begin
          t := un[i+j] + vn[i] + k;
          un[i+j] := t;
          k := t shr 8;
        end;
        un[j+n] := (t1 + k) and $ff;
      end else
        un[j+n] := t1 and $ff;
    end;
    for i:= 0 to n-1 do begin
      r[i] := (un[i] shr s) or ( (un[i+1] shl shat) and $ff);
    end;
  end;
end;

var a,b,c,d : uint64_t;
begin
  clrscr;
  fromLongInt64(1234567890,a);
  fromLongInt64(654321,b);

  divmnu(a,d,a,b);

  writeln('----==== Results ====----');
  writeln('Div: ',uint64ToStr(a), '; 1886');
  writeln('Mod: ',uint64ToStr(d), '; 518484');

end.
