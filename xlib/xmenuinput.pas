{
   ====================================================================
   xLib                                                            xqtr
   ====================================================================

   This file is part of xlib for FreePascal
   
   https://github.com/xqtr/xlib
    
   To use this Unit you need the source code of MysticBBS from here:
   https://github.com/fidosoft/mysticbbs, which is shared under GPL
    
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

Unit xMenuInput;
{$MODE objfpc}
Interface

Uses
 xCrt,xStrings;

Type
  MyString = String[80];
  
  
Var
  HiChars  : MyString;
  LoChars  : MyString;
  ExitCode : Char;
  Attr     : Byte;
  FillChar : Char;
  FillAttr : Byte;
  Changed  : Boolean;

  Function    GetStr (X, Y, Field, Len, Mode: Byte; Default: MyString) : MyString;
  Function    GetStr (X, Y, Field, Len, Mode,Attr,FillAttr : Byte; FillChar:Char; Default : MyString) : MyString; Overload;
  Function    GetNum (X, Y, Field, Len: Byte; Min, Max, Default: LongInt) : LongInt;
  Function    GetChar (X, Y : Byte; Default: Char) : Char;
  Function    GetEnter (X, Y, Len: Byte; Default : MyString) : Boolean;
  Function    GetYN (X, Y : Byte; Default: Boolean) : Boolean; Overload;
  Function    GetYN (X, Y, AttrTrue,AttrFalse,AttrOff: Byte; Default: Boolean) : Boolean; Overload;
  Function    GetYNC (X, Y, AttrTrue,AttrFalse,AttrOff: Byte; Default: Byte) : Byte;
  Function    Input(ADefault, AChars: String; APass: Char; AShowLen, AMaxLen, AAttr: Byte): String;
  Function    OneKey (S : String; Echo : Boolean) : Char;
  

Implementation

Function GetYN (X, Y : Byte; Default: Boolean) : Boolean;
Var
  Ch  : Char;
  Res : Boolean;
  YS  : Array[False..True] of String[3] = ('No ', 'Yes');
Begin
  ExitCode := #0;
  Changed  := False;

  GotoXY (X, Y);

  Res := Default;

  Repeat
    WriteXY (X, Y, Attr, YS[Res]);

    Ch := ReadKey;
    Case Ch of
      #00 : Begin
              Ch := ReadKey;
              Case Ch Of
                KeyCursorRight : Res := Not Res;
                KeyCursorLeft  : Res := Not Res;
              End;
            End;
      #13 : Break;
      #32 : Res := Not Res;
    Else
      If Pos(Ch, LoChars) > 0 Then Begin
        ExitCode := Ch;
        Break;
      End;
    End;
  Until False;

  Changed := (Res <> Default);
  GetYN   := Res;
End;

Function GetChar (X, Y : Byte; Default: Char) : Char;
Var
  Ch  : Char;
  Res : Char;
Begin
  ExitCode := #0;
  Changed  := False;
  Res      := Default;

  GotoXY (X, Y);

  Repeat
    WriteXY (X, Y, Attr, Res);

    Ch := ReadKey;

    Case Ch of
      #00 : Begin
              Ch := ReadKey;
              If Pos(Ch, HiChars) > 0 Then Begin
                ExitCode := Ch;
                Break;
              End;
            End;
    Else
      If Ch = #27 Then Res := Default;

      If Pos(Ch, LoChars) > 0 Then Begin
        ExitCode := Ch;
        Break;
      End;

      If Ord(Ch) > 31 Then Res := Ch;
    End;
  Until False;

  GetChar := Res;
End;

Function GetEnter (X, Y, Len: Byte; Default : MyString) : Boolean;
Var
  Ch  : Char;
  Res : Boolean;
Begin
  ExitCode := #0;
  Changed  := False;

  WriteXY (X, Y, Attr, strPadR(Default, Len, ' '));
  GotoXY (X, Y);

  Repeat
    Ch  := ReadKey;
    Res := Ch = #13;
    Case Ch of
      #00 : Begin
              Ch := ReadKey;
              If Pos(Ch, HiChars) > 0 Then Begin
                ExitCode := Ch;
                Break;
              End;
            End;
      Else
        If Pos(Ch, LoChars) > 0 Then Begin
          ExitCode := Ch;
          Break;
        End;
    End;
  Until Res;

  Changed  := Res;
  GetEnter := Res;
End;

{
* Attr     := 15 + 1 * 16;
  FillAttr := 7  + 1 * 16;
  FillChar := '°';
* }

Function GetStr (X, Y, Field, Len, Mode,Attr,FillAttr : Byte; FillChar:Char; Default : MyString) : MyString;
{ mode options:      }
{   0 = numbers only }
{   1 = as typed     }
{   2 = all caps     }
{   3 = date input   }
Var
  Ch     : Char;
  Str    : MyString;
  StrPos : Integer;
  Junk   : Integer;
  CurPos : Integer;

  Procedure ReDraw;
  Var
    T : MyString;
  Begin
    T := Copy(Str, Junk, Field);

    WriteXY  (X, Y, Attr, T);
    WriteXY  (X + Length(T), Y, FillAttr, strRep(FillChar, Field - Length(T)));
    GotoXY (X + CurPos - 1, WhereY);
  End;

  Procedure ReDrawPart;
  Var
    T : MyString;
  Begin
    T := Copy(Str, StrPos, Field - CurPos + 1);

    WriteXY  (WhereX, Y, Attr, T);
    WriteXY  (WhereX + Length(T), Y, FillAttr, strRep(FillChar, (Field - CurPos + 1) - Length(T)));
    GotoXY (X + CurPos - 1, Y);
  End;

  Procedure ScrollRight;
  Begin
    Inc (Junk);
    If Junk > Length(Str) Then Junk := Length(Str);
    If Junk > Len then Junk := Len;
    CurPos := StrPos - Junk + 1;
    ReDraw;
  End;

  Procedure ScrollLeft;
  Begin
    If Junk > 1 Then Begin
      Dec (Junk);
      CurPos := StrPos - Junk + 1;
      ReDraw;
    End;
  End;

  Procedure Add_Char (Ch : Char);
  Begin
    If Length(Str) >= Len Then Exit;

    If (CurPos >= Field) and (Field <> Len) Then ScrollRight;

    Insert (Ch, Str, StrPos);
    If StrPos < Length(Str) Then ReDrawPart;

    Inc (StrPos);
    Inc (CurPos);

    WriteXY  (WhereX, WhereY, Attr, Ch);
    GotoXY (WhereX+1 , WhereY);
  End;

Begin
  Changed := False;
  Str     := Default;
  StrPos  := Length(Str) + 1;
  Junk    := Length(Str) - Field + 1;

  If Junk < 1 Then Junk := 1;

  CurPos  := StrPos - Junk + 1;

  GotoXY (X, Y);
  Screen.TextAttr := Attr;

  ReDraw;

  Repeat
    Ch := Keyboard.ReadKey;

    Case Ch of
      #00 : Begin
              Ch :=  Keyboard.ReadKey;

              Case Ch of
                #77 : If StrPos < Length(Str) + 1 Then Begin
                        If (CurPos = Field) and (StrPos < Length(Str)) Then ScrollRight;
                        Inc (CurPos);
                        Inc (StrPos);
                        GotoXY (WhereX + 1, WhereY);
                      End;
                #75 : If StrPos > 1 Then Begin
                        If CurPos = 1 Then ScrollLeft;
                        Dec (StrPos);
                        Dec (CurPos);
                        GotoXY (WhereX - 1, WhereY);
                      End;
                #71 : If StrPos > 1 Then Begin
                        StrPos := 1;
                        Junk   := 1;
                        CurPos := 1;
                        ReDraw;
                      End;
                #79 : Begin
                        StrPos := Length(Str) + 1;
                        Junk   := Length(Str) - Field + 1;
                        If Junk < 1 Then Junk := 1;
                        CurPos := StrPos - Junk + 1;
                        ReDraw;
                      End;
                #83 : If (StrPos <= Length(Str)) and (Length(Str) > 0) Then Begin
                        Delete (Str, StrPos, 1);
                        ReDrawPart;
                      End;
                #115: Begin
                        If (StrPos > 1) and (Str[StrPos] = ' ') or (Str[StrPos - 1] = ' ') Then Begin
                          If CurPos = 1 Then ScrollLeft;
                          Dec(StrPos);
                          Dec(CurPos);

                          While (StrPos > 1) and (Str[StrPos] = ' ') Do Begin
                            If CurPos = 1 Then ScrollLeft;
                            Dec(StrPos);
                            Dec(CurPos);
                          End;
                        End;

                        While (StrPos > 1) and (Str[StrPos] <> ' ') Do Begin
                          If CurPos = 1 Then ScrollLeft;
                          Dec(StrPos);
                          Dec(CurPos);
                        End;

                        While (StrPos > 1) and (Str[StrPos] <> ' ') Do Begin
                          If CurPos = 1 Then ScrollLeft;
                          Dec(StrPos);
                          Dec(CurPos);
                        End;

                        If (Str[StrPos] = ' ') and (StrPos > 1) Then Begin
                          Inc(StrPos);
                          Inc(CurPos);
                        End;

                        ReDraw;
                      End;
                #116: Begin
                        While StrPos < Length(Str) + 1 Do Begin
                          If (CurPos = Field) and (StrPos < Length(Str)) Then ScrollRight;
                          Inc (CurPos);
                          Inc (StrPos);

                          If Str[StrPos] = ' ' Then Begin
                            If StrPos < Length(Str) + 1 Then Begin
                              If (CurPos = Field) and (StrPos < Length(Str)) Then ScrollRight;
                              Inc (CurPos);
                              Inc (StrPos);
                            End;
                            Break;
                          End;
                        End;
                        GotoXY (X + CurPos - 1, Y);
                      End;
              Else
                If Pos(Ch, HiChars) > 0 Then Begin
                  ExitCode := Ch;
                  Break;
                End;
              End;
            End;
      #08 : If StrPos > 1 Then Begin
              Dec (StrPos);
              Delete (Str, StrPos, 1);
              If CurPos = 1 Then
                ScrollLeft
              Else Begin
                GotoXY (WhereX - 1, WhereY);
                Dec (CurPos);
                ReDrawPart;
              End;
            End;
      ^Y  : Begin
              Str    := '';
              StrPos := 1;
              Junk   := 1;
              CurPos := 1;
              ReDraw;
            End;
      #32..
      #254: Case Mode of
              0 : If Ch in ['0'..'9', '-'] Then Add_Char(Ch);
              1 : Add_Char (Ch);
              2 : Add_Char (UpCase(Ch));
              3 : If (Ch > '/') and (Ch < ':') Then
                    Case StrPos of
                      2,5 : Begin
                              Add_Char (Ch);
                              Add_Char ('/');
                            End;
                      3,6 : Begin
                              Add_Char ('/');
                              Add_Char (Ch);
                            End;
                    Else
                      Add_Char (Ch);
                    End;
            End;
    Else
      If Pos(Ch, LoChars) > 0 Then Begin
        ExitCode := Ch;
        Break;
       End;
    End;
  Until False;

  Changed := (Str <> Default);
  Result  := Str;
End;

Function GetStr (X, Y, Field, Len, Mode : Byte; Default : MyString) : MyString;
{ mode options:      }
{   0 = numbers only }
{   1 = as typed     }
{   2 = all caps     }
{   3 = date input   }
Var
  Ch     : Char;
  Str    : MyString;
  StrPos : Integer;
  Junk   : Integer;
  CurPos : Integer;

  Procedure ReDraw;
  Var
    T : MyString;
  Begin
    T := Copy(Str, Junk, Field);

    WriteXY  (X, Y, Attr, T);
    WriteXY  (X + Length(T), Y, FillAttr, strRep(FillChar, Field - Length(T)));
    GotoXY (X + CurPos - 1, WhereY);
  End;

  Procedure ReDrawPart;
  Var
    T : MyString;
  Begin
    T := Copy(Str, StrPos, Field - CurPos + 1);

    WriteXY  (WhereX, Y, Attr, T);
    WriteXY  (WhereX + Length(T), Y, FillAttr, strRep(FillChar, (Field - CurPos + 1) - Length(T)));
    GotoXY (X + CurPos - 1, Y);
  End;

  Procedure ScrollRight;
  Begin
    Inc (Junk);
    If Junk > Length(Str) Then Junk := Length(Str);
    If Junk > Len then Junk := Len;
    CurPos := StrPos - Junk + 1;
    ReDraw;
  End;

  Procedure ScrollLeft;
  Begin
    If Junk > 1 Then Begin
      Dec (Junk);
      CurPos := StrPos - Junk + 1;
      ReDraw;
    End;
  End;

  Procedure Add_Char (Ch : Char);
  Begin
    If Length(Str) >= Len Then Exit;

    If (CurPos >= Field) and (Field <> Len) Then ScrollRight;

    Insert (Ch, Str, StrPos);
    If StrPos < Length(Str) Then ReDrawPart;

    Inc (StrPos);
    Inc (CurPos);

    WriteXY  (WhereX, WhereY, Attr, Ch);
    GotoXY (WhereX+1 , WhereY);
  End;

Begin
  Changed := False;
  Str     := Default;
  StrPos  := Length(Str) + 1;
  Junk    := Length(Str) - Field + 1;

  If Junk < 1 Then Junk := 1;

  CurPos  := StrPos - Junk + 1;

  GotoXY (X, Y);
  Screen.TextAttr := Attr;

  ReDraw;

  Repeat
    Ch := Keyboard.ReadKey;

    Case Ch of
      #00 : Begin
              Ch :=  Keyboard.ReadKey;

              Case Ch of
                #77 : If StrPos < Length(Str) + 1 Then Begin
                        If (CurPos = Field) and (StrPos < Length(Str)) Then ScrollRight;
                        Inc (CurPos);
                        Inc (StrPos);
                        GotoXY (WhereX + 1, WhereY);
                      End;
                #75 : If StrPos > 1 Then Begin
                        If CurPos = 1 Then ScrollLeft;
                        Dec (StrPos);
                        Dec (CurPos);
                        GotoXY (WhereX - 1, WhereY);
                      End;
                #71 : If StrPos > 1 Then Begin
                        StrPos := 1;
                        Junk   := 1;
                        CurPos := 1;
                        ReDraw;
                      End;
                #79 : Begin
                        StrPos := Length(Str) + 1;
                        Junk   := Length(Str) - Field + 1;
                        If Junk < 1 Then Junk := 1;
                        CurPos := StrPos - Junk + 1;
                        ReDraw;
                      End;
                #83 : If (StrPos <= Length(Str)) and (Length(Str) > 0) Then Begin
                        Delete (Str, StrPos, 1);
                        ReDrawPart;
                      End;
                #115: Begin
                        If (StrPos > 1) and (Str[StrPos] = ' ') or (Str[StrPos - 1] = ' ') Then Begin
                          If CurPos = 1 Then ScrollLeft;
                          Dec(StrPos);
                          Dec(CurPos);

                          While (StrPos > 1) and (Str[StrPos] = ' ') Do Begin
                            If CurPos = 1 Then ScrollLeft;
                            Dec(StrPos);
                            Dec(CurPos);
                          End;
                        End;

                        While (StrPos > 1) and (Str[StrPos] <> ' ') Do Begin
                          If CurPos = 1 Then ScrollLeft;
                          Dec(StrPos);
                          Dec(CurPos);
                        End;

                        While (StrPos > 1) and (Str[StrPos] <> ' ') Do Begin
                          If CurPos = 1 Then ScrollLeft;
                          Dec(StrPos);
                          Dec(CurPos);
                        End;

                        If (Str[StrPos] = ' ') and (StrPos > 1) Then Begin
                          Inc(StrPos);
                          Inc(CurPos);
                        End;

                        ReDraw;
                      End;
                #116: Begin
                        While StrPos < Length(Str) + 1 Do Begin
                          If (CurPos = Field) and (StrPos < Length(Str)) Then ScrollRight;
                          Inc (CurPos);
                          Inc (StrPos);

                          If Str[StrPos] = ' ' Then Begin
                            If StrPos < Length(Str) + 1 Then Begin
                              If (CurPos = Field) and (StrPos < Length(Str)) Then ScrollRight;
                              Inc (CurPos);
                              Inc (StrPos);
                            End;
                            Break;
                          End;
                        End;
                        GotoXY (X + CurPos - 1, Y);
                      End;
              Else
                If Pos(Ch, HiChars) > 0 Then Begin
                  ExitCode := Ch;
                  Break;
                End;
              End;
            End;
      #08 : If StrPos > 1 Then Begin
              Dec (StrPos);
              Delete (Str, StrPos, 1);
              If CurPos = 1 Then
                ScrollLeft
              Else Begin
                GotoXY (WhereX - 1, WhereY);
                Dec (CurPos);
                ReDrawPart;
              End;
            End;
      ^Y  : Begin
              Str    := '';
              StrPos := 1;
              Junk   := 1;
              CurPos := 1;
              ReDraw;
            End;
      #32..
      #254: Case Mode of
              0 : If Ch in ['0'..'9', '-'] Then Add_Char(Ch);
              1 : Add_Char (Ch);
              2 : Add_Char (UpCase(Ch));
              3 : If (Ch > '/') and (Ch < ':') Then
                    Case StrPos of
                      2,5 : Begin
                              Add_Char (Ch);
                              Add_Char ('/');
                            End;
                      3,6 : Begin
                              Add_Char ('/');
                              Add_Char (Ch);
                            End;
                    Else
                      Add_Char (Ch);
                    End;
            End;
    Else
      If Pos(Ch, LoChars) > 0 Then Begin
        ExitCode := Ch;
        Break;
       End;
    End;
  Until False;

  Changed := (Str <> Default);
  Result  := Str;
End;

Function GetNum (X, Y, Field, Len: Byte; Min, Max, Default: LongInt) : LongInt;
Var
  N : LongInt;
Begin
  N := Default;
  N := Str2Int(GetStr(X, Y, Field, Len, 0, Int2Str(N)));

  If N < Min Then N := Min;
  If N > Max Then N := Max;

  GetNum := N;
End;

{
  A fancy input routine

  ADefault - The text initially displayed in the edit box
  AChars   - The characters ALLOWED to be part of the string
             Look in MSTRINGS.PAS for some defaults
  APass    - The password character shown instead of the actual text
             Use #0 if you dont want to hide the text
  AShowLen - The number of characters big the edit box should be on screen
  AMaxLen  - The number of characters the edit box should allow
             AMaxLen can be larger than AShowLen, it will just scroll
             if that happens.
  AAttr    - The text attribute of the editbox's text and background
             Use formula Attr = Foreground + (Background * 16)

  If the user pressed ESCAPE then ADefault is returned.  If they hit enter
  the current string is returned.  They cannot hit enter on a blank line.
}
Function Input(ADefault, AChars: String; APass: Char; AShowLen, AMaxLen, AAttr: Byte): String;
var
   Ch: Char;
   S: String;
   SavedAttr: Byte;
   XPos: Byte;
   first : boolean;
   FC : Char = '°';

  Procedure UpdateText;
  Begin
       GotoX(XPos);
       if (Length(S) > AShowLen) then
       Begin
            if (APass = #0) then
               Write(Copy(S, Length(S) - AShowLen + 1, AShowLen))
            else
                Write(PadRight('', APass, AShowLen));
            GotoX(XPos + AShowLen);
       End else
       Begin
            if (APass = #0) then
               Write(S)
            else
                Write(PadRight('', APass, Length(S)));
            Write(PadRight('', FC, AShowLen - Length(S)));
            GotoX(XPos + Length(S));
       End;
  End;

Begin
    
    first:=true;
     if (Length(ADefault) > AMaxLen) then
        ADefault := Copy(ADefault, 1, AMaxLen);
     S := ADefault;

     SavedAttr := Screen.TextAttr;
     Screen.TextAttr:=AAttr;
     XPos := WhereX;

     UpdateText;

     repeat
           Ch := ReadKey;
           if (Ch = #8) and (Length(S) > 0) then
           Begin
                Delete(S, Length(S), 1);
                Write(#8 + FC + #8);
                if (Length(S) >= AShowLen) then
                   UpdateText;
           End else
           if (Ch = #25) and (S <> '') then {CTRL-Y}
           Begin
                S := '';
                UpdateText;
           End else
           if (Pos(Ch, AChars) > 0) and (Length(S) < AMaxLen) then
           Begin
                first:=false;
                S := S + Ch;
                if (Length(S) > AShowLen) then
                   UpdateText
                else
                if (APass = #0) then
                   Write(Ch)
                else
                    Write(APass);
           End;
     until (Ch = #27) or ((Ch = #13) and (S <> ''));
    FC:=' ';
    UpdateText;
     Screen.TextAttr:=SavedAttr;
     //Write(#13#10);
     

     if (Ch = #27) then
        S := ADefault;
     Input := S;
End;


Function GetYN (X, Y, AttrTrue,AttrFalse,AttrOff: Byte; Default: Boolean) : Boolean; Overload;
Var
  Ch  : Char;
  Res : Boolean;
  YS  : Array[False..True] of String[5];
  LoChars : String;
  HiChars : String;
  ExitCode : Char;
  CHanged : Boolean;
Begin
  ExitCode := #0;
  Changed  := False;
  YS[True] := ' Yes ';
  YS[False] := ' No ';
  LoChars := #13+' ';
  HiChars := ''+KeyCursorLeft+KeyCursorRight;

  GotoXY (X, Y);

  Res := Default;

  Repeat
    WriteXY (X, Y, AttrOff, YS[True]+Ys[False]);
    If Res Then
      WriteXY (X, Y, AttrTrue, YS[Res])
    Else
      WriteXY (X+5, Y, AttrFalse, YS[Res]);
    GotoXY(1,25);
    Ch := ReadKey;
    Case Ch of
      #00 : Begin
              Ch := ReadKey;
              Case Ch Of
                KeyCursorRight : Res := False;
                KeyCursorLeft  : Res := True;
              End;
            End;
      #13 : Break;
      #32 : Res := Not Res;
    Else
      If Pos(Ch, LoChars) > 0 Then Begin
        ExitCode := Ch;
        Break;
      End;
    End;
  Until False;

  Changed := (Res <> Default);
  GetYN   := Res;
End;

Function GetYNC (X, Y, AttrTrue,AttrFalse,AttrOff: Byte; Default: Byte) : Byte;
Var
  Ch  : Char;
  Res : Byte;
  YS  : Array[1..3] of String[8];
  LoChars : String;
  HiChars : String;
  ExitCode : Char;
  CHanged : Boolean;
Begin
  ExitCode := #0;
  Changed  := False;
  YS[1] := ' Yes ';
  YS[2] := ' No ';
  YS[3] := ' Cancel ';
  LoChars := #13+' ';
  HiChars := ''+KeyCursorLeft+KeyCursorRight;

  GotoXY (X, Y);

  Res := Default;

  Repeat
    WriteXY (X, Y, AttrOff, YS[1]+Ys[2]+Ys[3]);
    Case Res Of
      1:WriteXY (X, Y, AttrTrue, YS[1]);
      2:WriteXY (X+5, Y, AttrTrue, YS[2]);
      3:WriteXY (X+9, Y, AttrTrue, YS[3]);
    end;
    
    GotoXY(1,25);
    Ch := ReadKey;
    Case Ch of
      #00 : Begin
              Ch := ReadKey;
              Case Ch Of
                KeyCursorRight : Res := Res + 1;
                KeyCursorLeft  : Res := Res - 1;
              End;
            End;
      #13 : Break;
      #32 : Res := Res + 1;
    Else
      If Pos(Ch, LoChars) > 0 Then Begin
        ExitCode := Ch;
        Break;
      End;
    End;
    If Res = 4 Then Res := 1;
    If Res = 0 Then Res := 3;
  Until False;

  Changed := (Res <> Default);
  GetYNC  := Res;
End;

Function OneKey (S : String; Echo : Boolean) : Char;
Var
  Ch : Char;
Begin
  Repeat
    Ch := UpCase(ReadKey);
  Until Pos(Ch, S) > 0;
  If Echo Then WriteLn(Ch);
  OneKey := Ch;
End;

Begin
  LoChars  := #13;
  HiChars  := '';
  Attr     := 15 + 1 * 16;
  FillAttr := 7  + 1 * 16;
  FillChar := '°';
  Changed  := False;
End.
