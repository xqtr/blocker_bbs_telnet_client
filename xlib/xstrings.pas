{
   ====================================================================
   xLib - xStrings                                                 xqtr
   ====================================================================

   This file is part of xlib for FreePascal
   
   https://github.com/xqtr/xlib
    
   For contact look at Another Droid BBS [andr01d.zapto.org:9999],
   FSXNet and ArakNet.
   
   --------------------------------------------------------------------
   
   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.
   
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   
   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
   MA 02110-1301, USA.
   
}

Unit xStrings;
{$MODE objfpc}
{$H-}
Interface

Function LoCase (C: Char): Char;
Function AddSlash(ALine: String): String;
Function BoolToStr(AValue: Boolean; ATrue, AFalse: String): String;
Function ciPos(ASubStr, ALine: String): LongInt;
Function Center(ALine: String): String;
Function NoSlash(ALine: String): String;
Function PadLeft(ALine: String; ACh: Char; ALen: Integer): String;
Function PadRight(ALine: String; ACh: Char; ALen: Integer): String;
Function Replace(ALine, AOld, ANew: String): String;
Function Right(ALine: String): String;
Function StripChar(ALine: String; ACh: Char): String;
Function Upper   (Str : String) : String;
Function Lower (Str: String) : String;
Function strRep (Ch: Char; Len: Byte) : String;
Function strPadL (Str: String; Len: Byte; Ch: Char): String;
Function strPadC (Str: String; Len: Byte; Ch: Char) : String;
Function strPadR (Str: String; Len: Byte; Ch: Char) : String;
Function InString(Sub,Str:String):Boolean;
Function strWordGet   (Num: Byte; Str: String; Ch: Char) : String;
Function strWordBetween (Str,S1,S2: String) : String;
Function strWordPos   (Num: Byte; Str: String; Ch: Char) : Byte;
Function strResize    (Str: String) : String;
Function strWordCount (Str: String; Ch: Char) : Byte;
Function strStripL    (Str: String; Ch: Char) : String;
Function strStripR    (Str: String; Ch: Char) : String;
Function strStripB    (Str: String; Ch: Char) : String;
Function strStripLow  (Str: String) : String;
Function strStripPipe (Str: String) : String;
Function strStripMCI  (Str: String) : String;
Function strMCILen    (Str: String) : Byte;
Function strFMCILen   (Str: String; W:Byte) : Byte;
Function strZero      (Num: LongInt) : String;
Function strComma     (Num: LongInt) : String;
Function strYN        (Bol: Boolean) : String;
Function strWrap      (Var Str1, Str2: String; WrapPos: Byte) : Byte;
Function Int2Str (N : LongInt) : String;
Function Str2Int (Str : String) : LongInt;
Function Int2Hex (Num: LongInt; Idx: Byte) : String;
Function strWide2Str (Var Str: String; MaxLen: Byte) : String;
Function Button(S:String):String;
Function StrToIntDef(S:String; Def:Integer):Integer;
Function Byte2Hex     (Num: Byte) : String;
Function Wrap(Var st: String; maxlen: Byte; justify: Boolean): String;
Function Byte2Pipe(B:Byte):String; Overload;
Function Real2Str(R:Real; D:Byte):String;
Function Size2Str(SZ:LongInt):String;
function IsNumber(Value: string): Boolean;

function CharsToStr(src : array of char; len : integer) : string;
function CharsToStr(src : array of byte; len : integer) : string;

//Function Size2Str(SZ:LongInt):String;
{ Wrap example
begin
  S :=
'By Far the easiest way to manage a database is to create an '+
'index File. An index File can take many Forms and its size will depend '+
'upon how many Records you want in the db. The routines that follow '+
'assume no more than 32760 Records.';

While length(S) <> 0 do
  Writeln(Wrap(S,60,True));
end.
}
Implementation

  
const
  {$IFDEF UNIX}
    PathSep = '/';
    PathChar = '/';
  {$ELSE}
    PathSep = '\';
    PathChar = '\';
  {$EndIF}
  
Function Real2Str (R : Real; D:Byte) : String;
  Var S : String;
begin
 Str (R:10:d,S);
 
 Real2Str:=S;
end;
  
Function LoCase (C: Char): Char;
Begin
  If (C in ['A'..'Z']) Then
    LoCase := Chr(Ord(C) + 32)
  Else
    LoCase := C;
End; 

{
  Works like Pos(), only case insensitive
}
Function ciPos(ASubStr, ALine: String): LongInt;
Begin
     ciPos := Pos(Upper(ASubStr), Upper(ALine));
End;

Function InString(Sub,Str:String):Boolean;
Begin
  If Pos(Upper(Sub),Upper(Str))>0 Then InString := True Else InString := False;
End;
 
Function AddSlash(ALine: String): String;
Begin
     if (ALine[Length(ALine)] <> PathSep) then
        ALine := ALine + PathSep;
     AddSlash := ALine;
End;

{
  Return string ATRUE or AFALSE depEnding on the value of AVALUE
}
Function BoolToStr(AValue: Boolean; ATrue, AFalse: String): String;
Begin
     if (AValue) then
        BoolToStr := ATrue
     else
         BoolToStr := AFalse;
End;
 
Function Center(ALine: String): String;
var
  Width: Integer;
Begin
     //Width := Lo(WindMax) - Lo(WindMin) + 1;
     Width :=80;
     if (Length(ALine) < Width) then
        ALine := PadLeft(ALine, ' ', Length(ALine) + (Width - Length(ALine)) div 2);
     Center := ALine;
End;

{
  Return ALINE with no trailing backslash
}
Function NoSlash(ALine: String): String;
Begin
     if (ALine[Length(ALine)] = PathSep) then
        Delete(ALine, Length(ALine), 1);
     NoSlash := ALine;
End;

{
  Return ALINE padded on the left side with ACH until it is ALEN characters
  long.  Cut ALINE if it is more than ALEN characters
}
Function PadLeft(ALine: String; ACh: Char; ALen: Integer): String;
Begin
     while (Length(ALine) < ALen) do
           ALine := ACh + ALine;
     PadLeft := Copy(ALine, 1, ALen);
End;

{
  Same as PadLeft(), but pad the right of the string
}
Function PadRight(ALine: String; ACh: Char; ALen: Integer): String;
Begin
     while (Length(ALine) < ALen) do
           ALine := ALine + ACh;
     PadRight := Copy(ALine, 1, ALen)
End;

Function Replace(ALine, AOld, ANew: String): String;
var
  MatchPos: LongInt;
Begin
     if (ciPos(AOld, ANew) = 0) then
     Begin
          MatchPos := ciPos(AOld, ALine);
          while (MatchPos > 0) do
          Begin
               Delete(ALine, MatchPos, Length(AOld));
               Insert(ANew, ALine, MatchPos);
               MatchPos := ciPos(AOld, ALine);
          End;
     End;
     Replace := ALine;
End;

{
  Same as Center() but makes string right aligned
}
Function Right(ALine: String): String;
var
  Width: Integer;
Begin
     //Width := Lo(WindMax) - Lo(WindMin) + 1;
     Width := 80;
     Right := PadLeft(ALine, ' ', Width);
End;

Function StripChar(ALine: String; ACh: Char): String;
Begin
     while (Pos(ACh, ALine) > 0) do
           Delete(ALine, Pos(ACh, ALine), 1);
     StripChar := ALine;
End;


Function Upper (Str: String) : String;
Var
  A : Byte;
Begin
  For A := 1 to Length(Str) Do Str[A] := UpCase(Str[A]);
  Upper := Str;
End;

Function strRep (Ch: Char; Len: Byte) : String;
Var
  Count : Byte;
  Str   : String;
Begin
  Str := '';
  For Count := 1 to Len Do Str := Str + Ch;
  strRep := Str;
End;

Function Lower (Str: String) : String;
Var
  Count : Byte;
Begin
  For Count := 1 to Length(Str) Do
    Str[Count] := LoCase(Str[Count]);

  Lower := Str;
End;

Function strPadR (Str: String; Len: Byte; Ch: Char) : String;
Begin
  If Length(Str) > Len Then
    Str := Copy(Str, 1, Len)
  Else
    While Length(Str) < Len Do Str := Str + Ch;

  strPadR := Str;
End;

Function strPadC (Str: String; Len: Byte; Ch: Char) : String;
Var
  Space : Byte;
  Temp  : Byte;
Begin
  If Length(Str) > Len Then Begin
    Str[0] := Chr(Len);
    strPadC := Str;

    Exit;
  End;

  Space  := (Len - Length(Str)) DIV 2;
  Temp   := Len - ((Space * 2) + Length(Str));
  strPadC := strRep(Ch, Space) + Str + strRep(Ch, Space + Temp);
End;

Function strPadL (Str: String; Len: Byte; Ch: Char): String;
Var
  TStr : String;
Begin
  If Length(Str) >= Len Then
    strPadL := Copy(Str, 1, Len)
  Else Begin
    FillChar  (TStr[1], Len, Ch);
    SetLength (TStr, Len - Length(Str));

    strPadL  := TStr + Str;
  End;
End;

Function strStripL (Str: String; Ch: Char) : String;
Begin
  While ((Str[1] = Ch) and (Length(Str) > 0)) Do
    Str := Copy(Str, 2, Length(Str));

  strStripL := Str;
End;

Function strStripR (Str: String; Ch: Char) : String;
Begin
  While Str[Length(Str)] = Ch Do Dec(Str[0]);
  strStripR := Str;
End;

Function strResize    (Str: String) : String;
Begin
  While Str[Length(Str)] <> ' ' Do Dec(Str[0]);
  strResize := Str;
End;

Function strStripB (Str: String; Ch: Char) : String;
Begin
  strStripB := strStripR(strStripL(Str, Ch), Ch);
End;

Function strWordCount (Str: String; Ch: Char) : Byte;
Var
  Start : Byte;
  Res   : Byte;
Begin
  Res := 0;

  If Ch = ' ' Then
    While Str[1] = Ch Do
      Delete (Str, 1, 1);

  If Str = '' Then Exit;

  Res := 1;

  While Pos(Ch, Str) > 0 Do Begin
    Inc (Res);

    Start := Pos(Ch, Str);

    If Ch = ' ' Then Begin
      While Str[Start] = Ch Do
        Delete (Str, Start, 1);
    End Else
      Delete (Str, Start, 1);
  End;
  strWordCount := Res;
End;

Function strWordBetween (Str,S1,S2: String) : String;
Var
  d,i:word;
Begin
  d := Pos(S1,Str);
  i := Pos(S2,Str);
  If (d=0) or (i=0) Then Begin
    Result:='not found';
    Exit;
  End;
  d:=d+1+Length(s1)-1;
  strWordBetween:=Copy(Str,d,i-d);
End;

Function strWordPos (Num: Byte; Str: String; Ch: Char) : Byte;
Var
  Count : Byte;
  Temp  : Byte;
  Res   : Byte;
Begin
  Res := 1;
  Count  := 1;

  While Count < Num Do Begin
    Temp := Pos(Ch, Str);

    If Temp = 0 Then Exit;

    Delete (Str, 1, Temp);

    While Str[1] = Ch Do Begin
      Delete (Str, 1, 1);
      Inc (Temp);
    End;

    Inc (Count);

    Inc (Res, Temp);
    strWordPos := Res;
  End;
End;

Function strWordGet (Num: Byte; Str: String; Ch: Char) : String;
Var
  Count : Byte;
  Temp  : String;
  Start : Byte;
Begin
  strWordGet := '';
  Count  := 1;
  Temp   := Str;
  
  If Pos(Ch,Str)<=0 Then Begin
    Result:='';
    Exit;
  End;

  If Ch = ' ' Then
    While Temp[1] = Ch Do
      Delete (Temp, 1, 1);

  While Count < Num Do Begin
    Start := Pos(Ch, Temp);

    If Start = 0 Then Exit;

    If Ch = ' ' Then Begin
      While Temp[Start] = Ch Do
        Inc (Start);

      Dec(Start);
    End;

    Delete (Temp, 1, Start);
    Inc    (Count);
  End;

  If Pos(Ch, Temp) > 0 Then
    strWordGet := Copy(Temp, 1, Pos(Ch, Temp) - 1)
  Else
    strWordGet := Temp;
End;

Function strStripLow (Str: String) : String;
Var
  Count : Byte;
Begin
  Count := 1;

  While Count <= Length(Str) Do
   If Str[Count] in [#00..#31] Then
     Delete (Str, Count, 1)
   Else
     Inc(Count);

  strStripLow := Str;
End;

Function strStripPipe (Str: String) : String;
Var
  Count : Byte;
  Code  : String[2];
  Res   : String;
Begin
  Res := '';
  Count  := 1;

  While Count <= Length(Str) Do Begin
    If (Str[Count] = '|') and (Count < Length(Str) - 1) Then Begin
      Code := Copy(Str, Count + 1, 2);
      If (Code = '00') or ((Str2Int(Code) > 0) and (Str2Int(Code) < 24)) Then
      Else
        Res := Res + '|' + Code;

      Inc (Count, 2);
    End Else
      Res := Res + Str[Count];

    Inc (Count);
  End;
  strStripPipe := Res;
End;

Function Byte2Pipe(B:Byte):String;
Var
  tmp:String;
Begin
  Result:='|'+StrPadL(int2str(b mod 16),2,'0')+'|'+StrPadL(int2str((b div 16)+16),2,'0')
End;

Function strStripMCI (Str: String) : String;
Begin
  While Pos('|', Str) > 0 Do
    Delete (Str, Pos('|', Str), 3);

  strStripMCI := Str;
End;

Function strMCILen (Str: String) : Byte;
Var
  A : Byte;
Begin
  Repeat
    A := Pos('|', Str);
    If (A > 0) and (A < Length(Str) - 1) Then
      Delete (Str, A, 3)
    Else
      Break;
  Until False;

  strMCILen := Length(Str);
End;

Function Str2Int (Str: String): LongInt;
Var
  N : LongInt;
  T : LongInt;
Begin
  Val(Str, T, N);
  Str2Int := T;
End;

Function Int2Str (N: LongInt): String;
Var
  T : String;
Begin
  Str(N, T);
  Int2Str := T;
End;

Function strZero (Num: LongInt) : String;
Begin
  If Length(Int2Str(Num)) = 1 Then
    strZero := '0' + Int2Str(Num)
  Else
    strZero := Copy(Int2Str(Num), 1, 2);
End;

Function strComma (Num: LongInt) : String;
Var
  Res   : String;
  Count : Integer;
Begin
  Str (Num:0, Res);

  Count := Length(Res) - 2;

  While Count > 1 Do Begin
    Insert (',', Res, Count);
    Dec (Count, 3);
  End;

  strComma := Res;
End;

Function Int2Hex (Num: LongInt; Idx: Byte) : String;
Var
  Ch : Char;
Begin
  Int2Hex := strRep('0', Idx);

  While Num <> 0 Do Begin
    Ch := Chr(48 + Byte(Num) AND $0F);

    If Ch > '9' Then Inc (Ch, 39);

    Int2Hex[Idx] := Ch;
    Dec (Idx);
    Num := Num SHR 4;
  End;
End;

Function strWide2Str (Var Str: String; MaxLen: Byte) : String;
Var
  i: Word;
  TmpStr: String;
Begin
  Move(Str, TmpStr[1], MaxLen);
  TmpStr[0] := Chr(MaxLen);
  i := Pos(#0, TmpStr);
  If i > 0 Then TmpStr[0] := Chr(i - 1);
  strWide2Str := TmpStr;
End;

Function  Button(S:String):String;
Begin
  Button:='|00|23Ý'+S[1]+'Þ|07|16'+Copy(S,2,Length(s)-1);
End;

Function StrToIntDef(S:String; Def:Integer):Integer;
Begin
  Try
    Result:=Str2Int(S)
  Except
    Result:=Def;
  End;
End;

Function Byte2Hex (Num: Byte) : String;
Const
  HexChars : Array[0..15] of Char = '0123456789abcdef';
Begin
  Byte2Hex[0] := #2;
  Byte2Hex[1] := HexChars[Num SHR 4];
  Byte2Hex[2] := HexChars[Num AND 15];
End;
{
Function Size2Str(SZ:LongInt):String;
Var Z : String;
Var Y : Real;
Var S,Ti  : LongInt=1000;
Begin
  If SZ < Ti Then Begin
    Z:=strPadL(Int2Str(SZ),5,' ')+'b';
  End;
  If SZ > Ti Then Begin
    Y:=SZ/1000;
    Z:=strPadL(Real2Str(Y,0),5,' ')+'K';
  End;
    Ti:=Ti*S;
  If SZ > Ti Then Begin
    Y:=SZ/Ti;
    Z:=strPadL(Real2Str(Y,0),5,' ')+'M';
  End;
    Ti:=Ti*S;
  If SZ > Ti Then Begin
    Y:=SZ/Ti;
    Z:=strPadL(Real2Str(Y,0),5,' ')+'G';
  End;
  Size2Str:=Z;
End;}

Function Wrap(Var st: String; maxlen: Byte; justify: Boolean): String;
  { returns a String of no more than maxlen Characters With the last   }
  { Character being the last space beFore maxlen. On return st now has }
  { the remaining Characters left after the wrapping.                  }
  Const
    space = #32;
  Var
    len      : Byte Absolute st;
    x,
    oldlen,
    newlen   : Byte;

  Function JustifiedStr(s: String; max: Byte): String;

    { Justifies String s left and right to length max. if there is more }
    { than one trailing space, only the right most space is deleted. The}
    { remaining spaces are considered "hard".  #255 is used as the Char }
    { used For padding purposes. This will enable easy removal in any   }
    { editor routine.                                                   }

    Const
      softSpace = #255;
    Var
      jstr      : String;
      len       : Byte Absolute jstr;
    begin
      jstr := s;
      While (jstr[1] = space) and (len > 0) do   { delete all leading spaces }
        delete(jstr,1,1);
      if jstr[len] = space then
        dec(len);                                { Get rid of trailing space }
      if not ((len = max) or (len = 0)) then begin
        x := pos('.',jstr);     { Attempt to start padding at sentence break }
        if (x = 0) or (x =len) then       { no period or period is at length }
          x := 1;                                    { so start at beginning }
        if pos(space,jstr) <> 0 then Repeat        { ensure at least 1 space }
          if jstr[x] = space then                      { so add a soft space }
            insert(softSpace,jstr,x+1);
          x := succ(x mod len);  { if eoln is reached return and do it again }
        Until len = max;        { Until the wanted String length is achieved }
      end; { if not ... }
      JustifiedStr := jstr;
    end; { JustifiedStr }


  begin  { Wrap }
    if len <= maxlen then begin                       { no wrapping required }
      Wrap := st;
      len  := 0;
    end else begin
      oldlen := len;                { save the length of the original String }
      len    := succ(maxlen);                        { set length to maximum }
      Repeat                     { find last space in st beFore or at maxlen }
        dec(len);
      Until (st[len] = space) or (len = 0);
      if len = 0 then                   { no spaces in st, so chop at maxlen }
        len := maxlen;
      if justify then
        Wrap := JustifiedStr(st,maxlen)
      else
        Wrap := st;
      newlen :=  len;          { save the length of the newly wrapped String }
      len := oldlen;              { and restore it to original length beFore }
      Delete(st,1,newlen);              { getting rid of the wrapped portion }
    end;
  end; { Wrap }

Function strWrap (Var Str1, Str2: String; WrapPos: Byte) : Byte;
Var
  Count : Byte;
Begin
  Result := 0;
  Str2   := '';

  If (Pos(' ', Str1) = 0) or (Length(Str1) < WrapPos) Then Exit;

  For Count := Length(Str1) DownTo 1 Do
    If (Str1[Count] = ' ') and (Count < WrapPos) Then Begin
      Str2 := Copy(Str1, Succ(Count), Length(Str1));
      Delete (Str1, Count, Length(Str1));
      Result := Count;
      Exit;
    End;
End;

Function strFMCILen   (Str: String; W:Byte) : Byte;
Begin
  Result := W+(Length(Str)-StrMCILen(Str));
End;

Function strYN (Bol: Boolean) : String;
Begin
  If Bol Then Result := 'Yes' Else Result := 'No ';
End;

Function Size2Str(SZ:LongInt):String;
Var Z : String;
Var Y : Real;
Var S  : LongInt=1000;
Var Ti : LongInt=1000;
Begin
  If SZ < Ti Then Begin
    Z:=StrPadL(Int2Str(SZ),5,' ')+'b';
  End;
  If SZ > Ti Then Begin
    Y:=SZ/1000;
    Z:=StrPadL(Real2Str(Y,0),5,' ')+'K';
  End;
    Ti:=Ti*S;
  If SZ > Ti Then Begin
    Y:=SZ/Ti;
    Z:=StrPadL(Real2Str(Y,0),5,' ')+'M';
  End;
    Ti:=Ti*S;
  If SZ > Ti Then Begin
    Y:=SZ/Ti;
    Z:=StrPadL(Real2Str(Y,0),5,' ')+'G';
  End;
  Size2Str:=Z;
End;

function IsNumber(Value: string): Boolean;
var
  ValueInt: Integer;
  ErrCode: Integer;
begin
Value := strStripB(Value,' ');
Val(Value, ValueInt, ErrCode);
Result := ErrCode = 0;      // Val sets error code 0 if OK
end;

function CharsToStr(src : array of char; len : integer) : string;
var
  i : integer;
begin
  result := '';
  len := length(src);
  for i := 0 to len - 1 do
  begin
    if src[i] = #0 then
      break;
    result += src[i];
  end;
end;

function CharsToStr(src : array of byte; len : integer) : string;
var
  i : integer;
begin
  result := '';
  len := length(src);
  for i := 0 to len - 1 do
  begin
    if src[i] = 0 then
      break;
    result += char(src[i]);
  end;
end;

Begin
End.
