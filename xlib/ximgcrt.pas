Unit xImgCrt;
{$mode objfpc}
{$PACKRECORDS 1}
{$H-}
{$V-}
{$codepage cp437}

Interface

Uses
  xcrt;
  
Procedure ImgWriteChar(var img: TConsoleImageRec; x, y, a: byte; c: char);
Procedure ImgWrite(var img: TConsoleImageRec; x, y, a: byte; s: string);
Procedure WriteXYPipe (var img:TConsoleImageRec; X, Y, Attr: Byte; Text: String);
Procedure ImgClrScr(var img: TConsoleImageRec);
Procedure ClearArea(var img: TConsoleImageRec; x1, y1, x2, y2, A: Byte; C: Char);
  
Implementation

Function Str2Int (Str: String): LongInt;
Var
  N : LongInt;
  T : LongInt;
Begin
  Val(Str, T, N);
  Str2Int := T;
End;

Procedure ImgWriteChar(var img: TConsoleImageRec; x, y, a: byte; c: char);
Begin
  If (x>80) or (y>25) Then Exit;
  img.data[y][x].Attributes:=a;
  img.data[y][x].UnicodeChar:=c;
End;

Procedure ImgWrite(var img: TConsoleImageRec; x, y, a: byte; s: string);
Var
  i:byte;
Begin
  For i:=1 to Length(s) Do
    ImgWriteChar(img,x+i-1,y,a,s[i]);
End;

Procedure ImgClrScr(var img:TConsoleImageRec);
Begin
  fillchar(img,sizeof(img),#0);
End;

Procedure WriteXYPipe (var img:TConsoleImageRec; X, Y, Attr: Byte; Text: String);
Var
  Count   : Byte;
  Code    : String[2];
  CodeNum : Byte;
  OldAttr : Byte;
Begin
  Count := 1;

  While Count <= Length(Text) Do Begin
    If Text[Count] = Screen.Seth Then Begin
      Code    := Copy(Text, Count + 1, 2);
      CodeNum := Str2Int(Code);

      If (Code = '00') or (CodeNum > 0) Then Begin
        Inc (Count, 2);
        If CodeNum in [00..15] Then
          OldAttr:= (CodeNum + ((Attr SHR 4) AND 7) * 16)
        Else
          OldAttr :=((Attr AND $F) + (CodeNum - 16) * 16);
      End;
    End Else Begin
      imgwritechar(img,x+count-1,y,oldattr,Text[Count]);
    End;
    Inc (Count);
  End;
End;

Procedure ClearArea(var img: TConsoleImageRec; x1, y1, x2, y2, A: Byte; C: Char);
Var
  i:Byte;
Begin
  For i := y1 to y2 Do
    ImgWrite(img,x1,i,a,StringOfChar(c,x2-x1));
End;

Begin
End.
