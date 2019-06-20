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
Unit m_Output_ScrollBack;

{$I M_OPS.PAS}

Interface

Uses
  m_Types,
  m_Output,
  m_fileio;

Const
  MaxScrollBufferSize = 1000;

Type
  TConsoleScrollback = Class(TOutput)
    ScrollBuf : Array[1..MaxScrollBufferSize] of TConsoleLineRec;
    ScrollPos : SmallInt;
    Capture   : Boolean;
    CaptureFile : Boolean;
    CaptureFilename : String;

    Constructor Create (A: Boolean);
    Destructor  Destroy; Override;

    Procedure   ClearBuffer;
    Procedure   AddLine     (Line: Word);
    Function    IsBlankLine (Line: Word) : Boolean;
    Procedure   ClearScreen; Override;
    Procedure   ScrollWindow; Override;
    Procedure   AppendANSILine(Line:Word);
    Function    Ansi_Color (B : Byte) : String;
  End;

Implementation

Function TConsoleScrollback.Ansi_Color (B : Byte) : String;
  Var
    S : String;
  Begin
    S          := '';
    Ansi_Color := '';

    Case B of
      00: S := #27 + '[0;30m';
      01: S := #27 + '[0;34m';
      02: S := #27 + '[0;32m';
      03: S := #27 + '[0;36m';
      04: S := #27 + '[0;31m';
      05: S := #27 + '[0;35m';
      06: S := #27 + '[0;33m';
      07: S := #27 + '[0;37m';
      08: S := #27 + '[1;30m';
      09: S := #27 + '[1;34m';
      10: S := #27 + '[1;32m';
      11: S := #27 + '[1;36m';
      12: S := #27 + '[1;31m';
      13: S := #27 + '[1;35m';
      14: S := #27 + '[1;33m';
      15: S := #27 + '[1;37m';
    End;

    If B in [00..07] Then B := (TextAttr SHR 4) and 7 + 16;

    Case B of
      16: S := S + #27 + '[40m';
      17: S := S + #27 + '[44m';
      18: S := S + #27 + '[42m';
      19: S := S + #27 + '[46m';
      20: S := S + #27 + '[41m';
      21: S := S + #27 + '[45m';
      22: S := S + #27 + '[43m';
      23: S := S + #27 + '[47m';
    End;

    Ansi_Color := S;
  End;  


Constructor TConsoleScrollback.Create (A: Boolean);
Begin
  Inherited Create(A);

  ClearBuffer;

  Capture := False;
  CaptureFile := False;
  CaptureFilename := 'capture.ans';
End;

Destructor TConsoleScrollback.Destroy;
Begin
  Inherited Destroy;
End;

Procedure TConsoleScrollback.AppendANSILine(Line:Word);
  Var
    Count1,Count2:integer;
    Outfile : Text;
    OutName : String;
    OldAt   : Byte;
    FG      : Byte;
    BG      : Byte;
  Begin
    if CaptureFilename <> '' then Begin
      Assign     (OutFile, CaptureFilename);
      //SetTextBuf (OutFile, Buffer);
      If FileExist(CaptureFilename) then Append(OutFile) else Rewrite(OutFile);
      //If IoResult<>0 then Rewrite(OutFile);
      OldAt:=0;
      
        For Count2 := 1 to 79 Do Begin
          If OldAt <> ScrollBuf[Line][Count2].Attributes then Begin
            FG := ScrollBuf[Line][Count2].Attributes mod 16;
            BG := 16 + (ScrollBuf[Line][Count2].Attributes div 16);
            Write(Outfile,Ansi_Color(FG));
            Write(Outfile,Ansi_Color(BG));
          End;
          Write(Outfile,ScrollBuf[Line][Count2].UnicodeChar);
          OldAt := ScrollBuf[Line][Count2].Attributes 
        End;
        Writeln(Outfile,'');
      End;
      close(Outfile);
  End;

Procedure TConsoleScrollback.ClearBuffer;
Var
  Count1 : LongInt;
  Count2 : LongInt;
Begin
  ScrollPos := 0;

  For Count1 := 1 to MaxScrollBufferSize Do
    For Count2 := 1 to 80 Do Begin
      ScrollBuf[Count1][Count2].Attributes  := 7;
      ScrollBuf[Count1][Count2].UnicodeChar := ' ';
    End;
End;

Procedure TConsoleScrollback.AddLine (Line: Word);
Begin
  If ScrollPos = MaxScrollBufferSize Then Begin
    Move(ScrollBuf[2][1], ScrollBuf[1][1], SizeOf(TConsoleLineRec) * (MaxScrollBufferSize - 1));
    Dec(ScrollPos);
  End;

  Inc  (ScrollPos);
  Move (Buffer[Line][1], ScrollBuf[ScrollPos][1], SizeOf(TConsoleLineRec));
  
  If CaptureFIle then AppendANSILine(ScrollPos);
    
End;

Function TConsoleScrollback.IsBlankLine (Line: Word) : Boolean;
Var
  Count : LongInt;
Begin
  Result := True;

  For Count := 1 to 80 Do
//    If (Buffer[Line][Count].UnicodeChar <> #0) and ((Buffer[Line][Count].UnicodeChar <> ' ') and (Buffer[Line][Count].Attributes <> 7)) Then Begin
    If (Buffer[Line][Count].UnicodeChar <> #0) and ((Buffer[Line][Count].UnicodeChar <> ' ') or (Buffer[Line][Count].Attributes <> 7)) Then Begin
      Result := False;

      Exit;
    End;
End;

Procedure TConsoleScrollback.ClearScreen;
Var
  Line  : LongInt;
  Count : LongInt;
Begin
  If Capture Then Begin
    {$IFDEF WIN32}
      Line := Window.Bottom + 1;
    {$ELSE}
      Line := FWinBot;
    {$ENDIF}

    While Line > 0 Do Begin
      If Not IsBlankLine(Line) Then Break;

      Dec(Line);
    End;

    If Line <> 0 Then
      For Count := 1 to Line Do
        AddLine(Count);
  End;

  Inherited ClearScreen;
End;

Procedure TConsoleScrollBack.ScrollWindow;
Begin
  If Capture Then AddLine(1);

  Inherited ScrollWindow;
End;

End.
