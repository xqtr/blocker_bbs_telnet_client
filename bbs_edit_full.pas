Unit bbs_Edit_Full;

// ====================================================================
// Mystic BBS Software               Copyright 1997-2013 By James Coyle
// ====================================================================
//
// This file is part of Mystic BBS.
//
// Mystic BBS is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Mystic BBS is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Mystic BBS.  If not, see <http://www.gnu.org/licenses/>.
//
// ====================================================================

{$I M_OPS.PAS}

Interface

Uses
  m_output,
  m_input;
  
Const
  iMaxLines = 65535;

Var
  Screen   : TOutput;
  Keyboard : TInput;
  MsgText  : Array[1..iMaxLines] Of String[80];

Function FullEditor (Var Lines: Integer; WrapPos: Byte; MaxLines: Integer; Forced: Boolean; Template: String; Var Subj: String) : Boolean;

Implementation

Uses
  m_Strings;
  
Procedure OutBS (Num: Byte; Del: Boolean);
Var
  A   : Byte;
  Str : String[7];
Begin
  If Del Then Str := #8#32#8 Else Str := #8;

  For A := 1 to Num Do Begin
      Screen.SetRawMode(True);
      Screen.WriteStr(Str);
      Screen.SetRawMode(False);
  End;
End;  

Procedure PrintLn (S: String);
Begin
  Screen.WriteLine(S);
End;

Function FullEditor (Var Lines: Integer; WrapPos: Byte; MaxLines: Integer; Forced: Boolean; Template: String; Var Subj: String) : Boolean;
Const
  MaxCutText = 100;
Type
  CutTextPtr = ^CutTextRec;
  CutTextRec = String[79];
Var
  WinStart     : Byte    = 2;
  WinEnd       : Byte    = 22;
  WinText      : Byte    = 7;
  InsertMode   : Boolean = True;
  CutPasted    : Boolean = False;
  CutTextPos   : Word    = 0;
  CutText      : Array[1..MaxCutText] of CutTextPTR;
  Done         : Boolean;
  Save         : Boolean;
  Ch           : Char;
  CurX         : Byte;
  CurY         : Integer;
  CurLine      : Integer;
  TotalLine    : Integer;

Procedure UpdatePosition;
Begin
  If CurLine > TotalLine Then TotalLine := CurLine;
  If CurX > Length(MsgText[CurLine]) Then CurX := Length(MsgText[CurLine]) + 1;

  Screen.CursorXY (CurX, CurY);
End;

Procedure TextRefreshPart;
Var
  A,
  B : Integer;
Begin
  Screen.CursorXY (1, CurY);

  A := CurY;
  B := CurLine;

  Repeat
    If B <= TotalLine Then Screen.WriteStr(MsgText[B]);
    If B <= TotalLine + 1 Then Begin
      Screen.ClearEOL;
      PrintLn('');
    End;

    Inc (A);
    Inc (B);
  Until A > WinEnd;

  UpdatePosition;
End;

Procedure TextRefreshFull;
Var
  A,
  B  : Integer;
Begin
  CurY := WinStart + 5;
  B    := CurLine  - 5;

  If B < 1 Then Begin
    CurY := WinStart + (5 + B - 1);
    B    := 1;
  End;

  Screen.CursorXY (1, WinStart);

  A := WinStart;

  Repeat
    If B <= TotalLine Then Screen.WriteStr(MsgText[B]);
    Screen.ClearEOL;
    PrintLn('');
    Inc (A);
    Inc (B);
  Until A > WinEnd;

  UpdatePosition;
End;

Procedure InsertLine (Num: Integer);
Var
  A : Integer;
Begin
  Inc (TotalLine);

  For A := TotalLine DownTo Num + 1 Do
    MsgText[A] := MsgText[A - 1];

  MsgText[Num] := '';
End;

Procedure DeleteLine (Num: Integer);
Var
  Count : Integer;
Begin
  For Count := Num To TotalLine - 1 Do
    MsgText[Count] := MsgText[Count + 1];

  MsgText[TotalLine] := '';

  Dec (TotalLine);
End;

Procedure TextReformat;
Var
  OldStr  : String;
  NewStr  : String;
  Line    : Integer;
  A       : Integer;
  NewY    : Integer;
  NewLine : Integer;
  Moved   : Boolean;
Begin
  If TotalLine = MaxLines Then Exit;

  Line    := CurLine;
  OldStr  := MsgText[Line];
  NewY    := CurY;
  NewLine := CurLine;
  Moved   := False;

  Repeat
    If Pos(' ', OldStr) = 0 Then Begin
      Inc        (Line);
      InsertLine (Line);

      MsgText[Line]      := Copy(OldStr, CurX, Length(OldStr));
      MsgText[Line-1][0] := Chr(CurX - 1);

      If CurX > WrapPos Then Begin
        Inc (NewLine);
        Inc (NewY);

        CurX := 1;
      End;

      If NewY <= WinEnd Then TextRefreshPart;

      CurY    := NewY;
      CurLine := NewLine;

      If CurY > WinEnd Then TextRefreshFull Else UpdatePosition;

      Exit;
    End Else Begin
      Screen.BufFlush;

      A := strWrap (OldStr, NewStr, WrapPos + 1);

      If (A > 0) And (Not Moved) And (CurX > Length(OldStr) + 1) Then Begin
        CurX  := CurX - A;
        Moved := True;

        Inc (NewLine);
        Inc (NewY);
      End;

      MsgText[Line] := OldStr;
      Inc (Line);

      If (MsgText[Line] = '') or ((Pos(' ', MsgText[Line]) = 0) And (Length(MsgText[Line]) >= WrapPos)) Then Begin
        InsertLine(Line);

        OldStr := NewStr;
      End Else
        OldStr := NewStr + ' ' + MsgText[Line];
    End;
  Until Length(OldStr) <= WrapPos;

  MsgText[Line] := OldStr;



      If NewY <= WinEnd Then TextRefreshPart;

      CurY    := NewY;
      CurLine := NewLine;

      If CurY > WinEnd Then TextRefreshFull Else UpdatePosition;

(*
  If NewY <= WinEnd Then Begin
    Screen.CursorXY(1, CurY);

    A := CurLine;

    Repeat
      If (CurY + (A - CurLine) <= WinEnd) and (A <= TotalLine) Then Begin
        Screen.WriteStr(MsgText[A]);
        Screen.ClearEOL;
        PrintLn('');
      End Else
        Break;

      Inc (A);
    Until False;
  End;

  Session.io.BufFlush;

  CurY    := NewY;
  CurLine := NewLine;

  If CurY > WinEnd Then TextRefreshFull Else UpdatePosition;
*)
End;

Procedure keyEnter;
Begin
  If TotalLine = MaxLines Then Exit;

  InsertLine (CurLine + 1);

  If CurX < Length(MsgText[CurLine]) + 1 Then Begin
    MsgText[CurLine+1] := Copy(MsgText[CurLine], CurX, Length(MsgText[CurLine]));
    Delete (MsgText[CurLine], CurX, Length(MsgText[CurLine]));
  End;

  If CurY + 1 > WinEnd Then TextRefreshFull Else TextRefreshPart;

  CurX := 1;

  Inc(CurY);
  Inc(CurLine);

  UpdatePosition;
End;

Procedure keyDownArrow;
Begin
  If CurLine = TotalLine Then Exit;

  If CurY = WinEnd Then
    TextRefreshFull
  Else Begin
    Inc (CurY);
    Inc (CurLine);

    UpdatePosition;
  End;
End;

Procedure keyUpArrow (MoveToEOL: Boolean);
Begin
  If CurLine > 1 Then Begin
    If MoveToEOL Then Begin
      CurX := Length(MsgText[CurLine - 1]) + 1;
      If CurX > WrapPos Then CurX := WrapPos + 1;
    End;

    If CurY = WinStart Then
      TextRefreshFull
    Else Begin
      Dec (CurY);
      Dec (CurLine);

      UpdatePosition;
    End;
  End;
End;

Procedure keyBackspace;
Var
  Count : Integer;
Begin
  If CurX > 1 Then Begin
    OutBS(1, True);

    Dec    (CurX);
    Delete (MsgText[CurLine], CurX, 1);

    If CurX < Length(MsgText[CurLine]) + 1 Then Begin
      Screen.WriteStr (Copy(MsgText[CurLine], CurX, Length(MsgText[CurLine])) + ' ');
      UpdatePosition;
    End;
  End Else
  If CurLine > 1 Then Begin
    If Length(MsgText[CurLine - 1]) + Length(MsgText[CurLine]) <= WrapPos Then Begin

      CurX := Length(MsgText[CurLine - 1]) + 1;

      MsgText[CurLine - 1] := MsgText[CurLine - 1] + MsgText[CurLine];

      DeleteLine (CurLine);
      Dec        (CurLine);
      Dec        (CurY);

      If CurY < WinStart Then TextRefreshFull Else TextRefreshPart;
    End Else
    If Pos(' ', MsgText[CurLine]) > 0 Then Begin

      For Count := Length(MsgText[CurLine]) DownTo 1 Do
        If (MsgText[CurLine][Count] = ' ') and (Length(MsgText[CurLine - 1]) + Count - 1 <= WrapPos) Then Begin
          CurX := Length(MsgText[CurLine - 1]) + 1;

          MsgText[CurLine - 1] := MsgText[CurLine - 1] + Copy(MsgText[CurLine], 1, Count - 1);

          Delete (MsgText[CurLine], 1, Count);
          Dec    (CurLine);
          Dec    (CurY);

          If CurY < WinStart Then TextRefreshFull Else TextRefreshPart;

          Exit;
        End;

      keyUpArrow(True);
    End;
  End;
End;

Procedure keyLeftArrow;
Begin
  If CurX > 1 Then Begin
    Dec (CurX);

    UpdatePosition;
  End Else
    keyUpArrow(True);
End;

Procedure keyRightArrow;
Begin
  If CurX < Length(MsgText[CurLine]) + 1 Then Begin
    Inc (CurX);

    UpdatePosition;
  End Else Begin
    {If CurY < TotalLine Then} CurX := 1;

    keyDownArrow;
  End;
End;

Procedure keyPageUp;
Begin
  If CurLine > 1 Then Begin
    If LongInt(CurLine - (WinEnd - WinStart)) >= 1 Then
      Dec (CurLine, (WinEnd - WinStart))
    Else
      CurLine := 1;

    TextRefreshFull;
  End;
End;

Procedure keyPageDown;
Begin
  If CurLine < TotalLine Then Begin

    If CurLine + (WinEnd - WinStart) <= TotalLine Then
      Inc (CurLine, (WinEnd - WinStart))
    Else
      CurLine := TotalLine;

    TextRefreshFull;
  End;
End;

Procedure keyEnd;
Begin
  CurX := Length(MsgText[CurLine]) + 1;

  If CurX > WrapPos Then CurX := WrapPos + 1;

  UpdatePosition;
End;

Procedure AddChar (Ch: Char);
Begin
  If InsertMode Then Begin
    Insert (Ch, MsgText[Curline], CurX);
    Screen.WriteStr  (Copy(MsgText[CurLine], CurX, Length(MsgText[CurLine])));
  End Else Begin
    If CurX > Length(MsgText[CurLine]) Then
      Inc(MsgText[CurLine][0]);

    MsgText[CurLine][CurX] := Ch;
    Screen.WriteStr (Ch);
  End;

  Inc (CurX);

  UpdatePosition;
End;

Procedure ToggleInsert (Toggle: Boolean);
Begin
  If Toggle Then InsertMode := Not InsertMode;

  
  Screen.CursorXY (1,25);

  If InsertMode Then Screen.WriteStr('INS') else Screen.WriteStr('OVR'); { ++lang }

  Screen.CursorXY (CurX, CurY);
  Screen.WriteStr(Screen.AttrToAnsi(WinText));
End;

Procedure FullReDraw;
Begin
  //Session.io.PromptInfo[2] := Subj;

  //Session.io.OutFile (Template, True, 0);

  WinStart := 1;
  WinEnd   := 25;
  WinText  := Screen.TextAttr;

  ToggleInsert (False);

  TextRefreshFull;
End;


Procedure Commands;
Var
  Ch  : Char;
  Str : String;
Begin
  Done := False;
  Save := False;

  Repeat

    Ch := Keyboard.ReadKey;

    Case Ch of
      
      'A' : If Forced Then Begin
              //Session.io.OutFull (Session.GetPrompt(307));
              Exit;
            End Else Begin
              //Done := Session.io.GetYN(Session.GetPrompt(356), False);
              Exit;
            End;
      'C' : Exit;
      'H' : Begin
              //Session.io.OutFile ('fshelp', True, 0);
              Exit;
            End;
      'R' : Exit;
      'S' : Begin
              Save := True;
              Done := True;
            End;
    End;
  Until Done;
End;

Var
  A : Integer;
Begin
  QuoteCurLine := 0;
  QuoteTopPage := 1;
  CurLine      := Lines;

  If Lines = 0 Then CurLine := 1;

  Done      := False;
  CurX      := 1;
  CurY      := WinStart;
  TotalLine := CurLine;

  Dec (WrapPos);

  For A := Lines + 1 to iMaxLines Do MsgText[A] := '';

  FullReDraw;

  //Session.io.AllowArrow := True;

  Repeat
    Ch := Keyboard.Readkey;

    If Ch = #0 Then Begin
      Ch := Keyboard.Readkey;
      Case Ch of
        #71 : Begin
                CurX := 1;
                UpdatePosition;
              End;
        #72 : keyUpArrow(False);
        #73 : keyPageUp;
        #75 : keyLeftArrow;
        #77 : keyRightArrow;
        #79 : keyEnd;
        #80 : keyDownArrow;
        #81 : keyPageDown;
        #82 : ToggleInsert(True);
        #83 : If CurX <= Length(MsgText[CurLine]) Then Begin
                Delete (MsgText[CurLine], CurX, 1);
                Screen.WriteStr (Copy(MsgText[CurLine], CurX, Length(MsgText[CurLine])) + ' ');
                UpdatePosition;
              End Else
              If CurLine < TotalLine Then
                If (MsgText[CurLine] = '') and (TotalLine > 1) Then Begin
                  DeleteLine (CurLine);
                  TextRefreshPart;
                End Else
                If TotalLine > 1 Then
                  If Length(MsgText[CurLine]) + Length(MsgText[CurLine + 1]) <= WrapPos Then Begin
                    MsgText[CurLine] := MsgText[CurLine] + MsgText[CurLine + 1];
                    DeleteLine (CurLine + 1);
                    TextRefreshPart;
                  End Else
                    For A := Length(MsgText[CurLine + 1]) DownTo 1 Do
                      If (MsgText[CurLine + 1][A] = ' ') and (Length(MsgText[CurLine]) + A <= WrapPos) Then Begin
                        MsgText[CurLine] := MsgText[CurLine] + Copy(MsgText[CurLine + 1], 1, A - 1);
                        Delete (MsgText[CurLine + 1], 1, A);
                        TextRefreshPart;
                      End;
      End;
    End Else
    Case Ch of
      ^A  : Begin
              Done := True;
              Save := False;
            End;
      ^B  : FullReDraw;
      ^D  : keyRightArrow;
      ^E  : keyUpArrow(False);
      ^F  : Begin
              CurX := 1;
              UpdatePosition;
            End;
      ^G  : keyEnd;
      ^H  : keyBackspace;
      ^I  : If CurX <= WrapPos Then Begin
              Repeat
                If (CurX < WrapPos) and (CurX = Length(MsgText[CurLine]) + 1) Then
                  MsgText[CurLine] := MsgText[CurLine] + ' ';

                Inc (CurX);
              Until (CurX MOD 5 = 0) or (CurX = WrapPos);

              UpdatePosition;
            End;
      ^J  : Begin
              MsgText[CurLine] := '';

              CurX := 1;

              UpdatePosition;

              Screen.ClearEOL;
            End;
      ^K  : Begin
              If CutPasted Then Begin
                For A := CutTextPos DownTo 1 Do
                  Dispose (CutText[A]);

                CutTextPos := 0;
                CutPasted  := False;
              End;

              If CutTextPos < MaxCutText Then Begin
                Inc (CutTextPos);

                New (CutText[CutTextPos]);

                CutText[CutTextPos]^ := MsgText[CurLine];

                DeleteLine(CurLine);

                TextRefreshPart;
              End;
            End;
      ^L,
      ^M  : Begin
              //Session.io.PurgeInputBuffer;
              keyEnter;
            End;
      ^N  : keyPageDown;
      ^O  : Begin
              //Session.io.OutFile('fshelp', True, 0);
              FullReDraw;
            End;
      ^P  : keyPageUp;
      ^R  : Begin
              While CurX < Length(MsgText[CurLine]) + 1 Do Begin
                Inc (CurX);

                If MsgText[CurLine][CurX] = ' ' Then Begin
                  If CurX < Length(MsgText[CurLine]) + 1 Then Inc(CurX);
                  Break;
                End;
              End;

              UpdatePosition;
            End;
      ^T  : Begin
              While CurX > 1 Do Begin
                Dec (CurX);

                If MsgText[CurLine][CurX] = ' ' Then Break;
              End;

              UpdatePosition;
            End;
      ^U  : If CutTextPos > 0 Then Begin
              CutPasted := True;

              For A := CutTextPos DownTo 1 Do
                If TotalLine < iMaxLines Then Begin
                  InsertLine(CurLine);
                  MsgText[CurLine] := CutText[A]^;
                End;

              TextRefreshPart;
            End;
      ^V  : ToggleInsert (True);
      ^W  : While (CurX > 1) Do Begin
              keyBackSpace;
              If MsgText[CurLine][CurX] = ' ' Then Break;
            End;
      ^X  : keyDownArrow;
      ^Y  : Begin
              DeleteLine (CurLine);
              TextRefreshPart;
            End;
      ^Z,
      ^[  : Begin
              Commands;

              If (Not Save) and (Not Done) Then FullReDraw;

              //Session.io.AllowArrow := True;
            End;
      #32..
      #254: Begin
              If Length(MsgText[CurLine]) >= WrapPos Then begin
                If TotalLine < MaxLines Then Begin
                  AddChar (Ch);
                  TextReformat;
                End;
              End Else
              If (CurX = 1) and (Ch = '/') Then Begin
                Commands;

                If (Not Save) and (Not Done) Then FullReDraw;

                
              End Else
                AddChar (Ch);
            End;
    End;
  Until Done;

  //Session.io.AllowArrow := False;

  If Save Then Begin
    A := TotalLine;

    While (MsgText[A] = '') and (A > 1) Do Begin
      Dec (A);
      Dec (TotalLine);
    End;

    Lines := TotalLine;
  End;

  Result := Save;

  Screen.CursorXY (1, 25);

  For A := CutTextPos DownTo 1 Do
    Dispose (CutText[A]);
End;

End.
