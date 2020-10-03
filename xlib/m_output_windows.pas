{$MEMORY 64000, 800000}
{$MODE DELPHI}
{$EXTENDEDSYNTAX ON}
{$PACKRECORDS 1}
{$VARSTRINGCHECKS OFF}
{$TYPEINFO OFF}
{$LONGSTRINGS OFF}
{$I-}

Unit m_Output_Windows;

Interface

Uses
  Windows,
  m_Types;
  
Const
  ConIn      = 0;
  ConOut     = 1;
  ConBufSize = 1024;

Type
  TOutputWindows = Class
  Private
    ConOut      : THandle;
    Cursor      : TCoord;
    FScreenSize : Byte;

    Procedure   ScrollWindow;
  Public
    Active      : Boolean;
    FTextAttr   : Byte;
    Buffer      : TConsoleScreenRec;
    Window      : TSmallRect;
	OutBufPos   : Word;
	FCursorX    : Byte;
	FSeth       : Char;
	OutBuffer   : Array[1..ConBufSize] of Char;

    Constructor Create (A: Boolean);
    Destructor  Destroy; Override;
    Procedure   ClearScreen;
    Procedure   ClearEOL;
    Procedure   GotoXY (X, Y: Byte);
    Function    WhereX : Byte;
    Function    WhereY : Byte;
    Procedure   SetScreenSize (Mode: Byte);
    Procedure   SetWindowTitle (Title: String);
    Procedure   SetWindow (X1, Y1, X2, Y2: Byte; Home: Boolean);
    Procedure   GetScreenImage (X1, Y1, X2, Y2: Byte; Var Image: TConsoleImageRec);
	Procedure   GetScreenImage (Var Image: TConsoleImageRec); Overload;
    Procedure   PutScreenImage (Image: TConsoleImageRec);
    Procedure   LoadScreenImage (Var DataPtr; Len, Width, X, Y: Integer);
    Procedure   WriteXY (X, Y, A: Byte; Text: String);
    Procedure   WriteXYPipe (X, Y, Attr, Pad: Integer; Text: String);
    Function    ReadCharXY (X, Y: Byte) : Char;
    Function    ReadAttrXY (X, Y: Byte) : Byte;
    Procedure   WriteChar (Ch: Char);
    Procedure   WriteLine (Str: String);
    Procedure   WriteStr (Str: String);
    Procedure   ShowBuffer;
    Procedure   BufFlush; // Linux compatibility only
	Function    AttrToAnsi (Attr: Byte) : String;
	Procedure   BufAddStr (Str: String);
	Procedure   WritePipe (Str: String);
	Procedure   SetTextAttr (Attr: Byte);
	Property    Seth     : Char Read FSeth Write FSeth;

    Property ScreenSize : Byte Read FScreenSize;
    Property TextAttr   : Byte Read FTextAttr    Write FTextAttr;
  End;

Implementation

Uses
  xStrings;
  
Const
	AnsiTable : String[8] = '04261537';

Procedure TOutputWindows.SetWindow (X1, Y1, X2, Y2 : Byte; Home: Boolean);
Begin
  If (X1 > X2) or (X2 > 80) or
     (Y1 > Y2) or (Y2 > ScreenSize) Then Exit;

  Window.Left   := X1 - 1;
  Window.Top    := Y1 - 1;
  Window.Right  := X2 - 1;
  Window.Bottom := Y2 - 1;

  If Home Then GotoXY (X1, Y1) Else GotoXY (Cursor.X + 1, Cursor.Y + 1);
End;

Constructor TOutputWindows.Create (A: Boolean);
Var
  ScreenMode : TConsoleScreenBufferInfo;
  CursorInfo : TConsoleCursorInfo;
Begin
  Inherited Create;

  Active := A;
  ConOut := GetStdHandle(STD_OUTPUT_HANDLE);

  GetConsoleScreenBufferInfo(ConOut, ScreenMode);

  Case ScreenMode.dwSize.Y of
    25 : FScreenSize := 25;
    50 : FScreenSize := 50;
  Else
    SetScreenSize(25);
    FScreenSize := 25;
  End;

  CursorInfo.bVisible := True;
  CursorInfo.dwSize   := 15;

  SetConsoleCursorInfo(ConOut, CursorInfo);

  Window.Top    := 0;
  Window.Left   := 0;
  Window.Right  := 79;
  Window.Bottom := FScreenSize - 1;

  FTextAttr := 7;

  ClearScreen;
End;

Destructor TOutputWindows.Destroy;
Begin
  Inherited Destroy;
End;

Procedure TOutputWindows.BufAddStr (Str: String);
Var
  Count : LongInt;
Begin
  For Count := 1 to Length(Str) Do Begin
    Inc (OutBufPos);
    OutBuffer[OutBufPos] := Str[Count];
    If OutBufPos = ConBufSize Then BufFlush;
  End;
End;

Function TOutputWindows.AttrToAnsi (Attr: Byte) : String;
Var
  Str   : String[16];
  OldFG : LongInt;
  OldBG : LongInt;
  FG    : LongInt;
  BG    : LongInt;

  Procedure AddSep (Ch: Char);
  Begin
    If Length(Str) > 0 Then
      Str := Str + ';';
    Str := Str + Ch;
  End;

Begin
  If Attr = FTextAttr Then Begin
    AttrToAnsi := '';
    Exit;
  End;

  Str   := '';
  FG    := Attr and $F;
  BG    := Attr shr 4;
  OldFG := FTextAttr and $F;
  OldBG := FTextAttr shr 4;

  If (OldFG <> 7) or (FG = 7) or ((OldFG > 7) and (FG < 8)) or ((OldBG > 7) and (BG < 8)) Then
 Begin
    Str   := '0';
    OldFG := 7;
    OldBG := 0;
  End;

  If (FG > 7) and (OldFG < 8) Then Begin
    AddSep('1');
    OldFG := OldFG or 8;
  End;

  If (BG and 8) <> (OldBG and 8) Then Begin
    AddSep('5');
    OldBG := OldBG or 8;
  End;

  If (FG <> OldFG) Then Begin
    AddSep('3');
    Str := Str + AnsiTable[(FG and 7) + 1];
  End;

  If (BG <> OldBG) Then Begin
    AddSep('4');
    Str := Str + AnsiTable[(BG and 7) + 1];
  End;

  AttrToAnsi := #27 + '[' + Str + 'm';
End;

Procedure TOutputWindows.SetScreenSize (Mode: Byte);
Var
  Size : TCoord;
Begin
  If (Mode = FScreenSize) Or Not (Mode in [25, 50]) Then Exit;

  Size.X := 80;
  Size.Y := Mode;

  Window.Top    := 0;
  Window.Left   := 0;
  Window.Right  := Size.X - 1;
  Window.Bottom := Size.Y - 1;

  SetConsoleScreenBufferSize (ConOut, Size);
  SetConsoleWindowInfo       (ConOut, True, Window);
  SetConsoleScreenBufferSize (ConOut, Size);

  FScreenSize := Mode;
End;

Procedure TOutputWindows.SetTextAttr (Attr: Byte);
Begin
  If Attr = FTextAttr Then Exit;

  BufAddStr(AttrToAnsi(Attr));

  FTextAttr := Attr;
End;

Procedure TOutputWindows.GotoXY (X, Y: Byte);
Begin
  // don't move to x/y coordinate outside of window

  Cursor.X := X - 1;
  Cursor.Y := Y - 1;

  If Cursor.X < Window.Left   Then Cursor.X := Window.Left Else
  If Cursor.X > Window.Right  Then Cursor.X := Window.Right;
  If Cursor.Y < Window.Top    Then Cursor.Y := Window.Top Else
  If Cursor.Y > Window.Bottom Then Cursor.Y := Window.Bottom;

  If Active Then
    SetConsoleCursorPosition(ConOut, Cursor);
End;

Procedure TOutputWindows.WritePipe (Str: String);

  Procedure AddChar (Ch: Char);
  Begin
    If WhereX > 80 Then Exit;

    Buffer[WhereY][WhereX].Attributes  := FTextAttr;
    Buffer[WhereY][WhereX].UnicodeChar := Ch;

    BufAddStr(Ch);

    Inc (FCursorX);
  End;

Var
  Count   : Byte;
  Code    : String[2];
  CodeNum : Byte;
  OldAttr : Byte;
  OldX    : Byte;
  OldY    : Byte;
  text    : string;
Begin
  {OldAttr := FTextAttr;
  OldX    := FCursorX;
  OldY    := FCursorY;
}
  //GotoXYRaw (X, Y);
  //SetTextAttr (Attr);
  text:=str;
  Count := 1;

  While Count <= Length(text) Do Begin
    If text[Count] = '|' Then Begin
      Code    := Copy(text, Count + 1, 2);
      CodeNum := Str2Int(Code);

      If (Code = '00') or ((CodeNum > 0) and (CodeNum < 24) and (Code[1] <> '&') and (Code[1] <> '$')) Then Begin
        Inc (Count, 2);
        If CodeNum in [00..15] Then
          SetTextAttr (CodeNum + ((FTextAttr SHR 4) AND 7) * 16)
        Else
          SetTextAttr ((FTextAttr AND $F) + (CodeNum - 16) * 16);
      End Else Begin
        AddChar(text[Count]);
        writechar(text[Count]);
        //Dec (Pad);
      End;
    End Else Begin
      //AddChar(text[Count]);
      writechar(text[Count]);
      //Dec (Pad);
    End;

    //If Pad = 0 Then Break;

    Inc (Count);
  End;

  {While Pad > 0 Do Begin
    AddChar(' ');
    Dec(Pad);
  End;}

  //SetTextAttr (OldAttr);
  //CursorXYRaw (OldX, OldY);

  BufFlush;
End;

Procedure TOutputWindows.ClearEOL;
Var
  Buf      : Array[1..80] of TCharInfo;
  Count    : Byte;
  BufSize  : TCoord;
  BufCoord : TCoord;
  Region   : TSmallRect;
Begin
  Count := 0;

  While Count <= Window.Right - Cursor.X Do Begin
    Inc (Count);
    Buf[Count].Attributes  := TextAttr;
    Buf[Count].UnicodeChar := {$IFDEF FPC} ' ' {$ELSE} 32 {$ENDIF};
  End;

  Move(Buf[1], Buffer[Cursor.Y + 1][Cursor.X + 1], Count);

  If Active Then Begin
    BufSize.X     := Count;
    BufSize.Y     := 1;
    BufCoord.X    := 0;
    BufCoord.Y    := 0;
    Region.Left   := Cursor.X;
    Region.Top    := Cursor.Y;
    Region.Right  := Cursor.X + Count - 1;
    Region.Bottom := Cursor.Y;

    WriteConsoleOutput(ConOut, @Buf, BufSize, BufCoord, Region);
  End;
End;

Procedure TOutputWindows.ClearScreen;
Var
  Res   : ULong;
  Count : Byte;
  Size  : Byte;
  Cell  : TCharInfo;
Begin
  Size             := Window.Right - Window.Left + 1;
  Cursor.X         := Window.Left;
  Cell.Attributes  := FTextAttr;
  Cell.UnicodeChar := {$IFDEF FPC} ' ' {$ELSE} 32 {$ENDIF};

  If Active Then Begin
    For Count := Window.Top To Window.Bottom Do Begin
      Cursor.Y := Count;

      FillConsoleOutputAttribute(ConOut, Cell.Attributes, Size, Cursor, Res);
      FillConsoleOutputCharacter(ConOut, ' ', Size, Cursor, Res);
    End;
  End;

  FillChar (Buffer, SizeOf(Buffer), 0);

  GotoXY (Window.Left + 1, Window.Top + 1);
End;

Procedure TOutputWindows.SetWindowTitle (Title: String);
Begin
  Title := Title + #0;
  SetConsoleTitle(@Title[1]);
End;

Procedure TOutputWindows.WriteXY (X, Y, A: Byte; Text: String);
Var
  Buf      : Array[1..80] of TCharInfo;
  BufSize  : TCoord;
  BufCoord : TCoord;
  Region   : TSmallRect;
  Count    : Byte;
Begin
  Count := 1;

  While Count <= Length(Text) Do Begin
    Buf[Count].Attributes  := A;
    Buf[Count].UnicodeChar := {$IFDEF FPC} Text[Count]; {$ELSE} Byte(Text[Count]); {$ENDIF}
    Inc (Count);
  End;

  BufSize.X     := Count - 1;
  BufSize.Y     := 1;
  BufCoord.X    := 0;
  BufCoord.Y    := 0;
  Region.Left   := X - 1;
  Region.Top    := Y - 1;
  Region.Right  := X + Count - 1;
  Region.Bottom := Y - 1;

  If Region.Right > 79 Then Region.Right := 79;

//  Move (Buf[1], Buffer[Y][X], BufSize.X * SizeOf(TCharInfo));

  If Active Then
    WriteConsoleOutput(ConOut, @Buf, BufSize, BufCoord, Region);
End;

Procedure TOutputWindows.WriteXYPipe (X, Y, Attr, Pad: Integer; Text: String);
Var
  Buf      : Array[1..80] of TCharInfo;
  BufPos   : Byte;
  Count    : Byte;
  Code     : String[2];
  CodeNum  : Byte;
  BufSize  : TCoord;
  BufCoord : TCoord;
  Region   : TSmallRect;

  Procedure AddChar;
  Begin
    Inc (BufPos);

    Buf[BufPos].Attributes  := Attr;
    Buf[BufPos].UnicodeChar := {$IFDEF FPC} Text[Count]; {$ELSE} Byte(Text[Count]); {$ENDIF}
  End;

Begin
  FillChar(Buf, SizeOf(Buf), #0);

  Count  := 1;
  BufPos := 0;

  While Count <= Length(Text) Do Begin
    If Text[Count] = '|' Then Begin
      Code    := Copy(Text, Count + 1, 2);
      CodeNum := Str2Int(Code);

      If (Code = '00') or ((CodeNum > 0) and (Code[1] <> '$')) Then Begin
        Inc (Count, 2);
        If CodeNum in [00..15] Then
          Attr := CodeNum + ((Attr SHR 4) AND 7) * 16
        Else
          Attr := (Attr AND $F) + (CodeNum - 16) * 16;
      End Else
        AddChar;
    End Else
      AddChar;

    If BufPos = Pad Then Break;

    Inc (Count);
  End;

  Text[1] := #32;
  Count   := 1;

  While BufPos < Pad Do AddChar;

  BufSize.X     := Pad;
  BufSize.Y     := 1;
  BufCoord.X    := 0;
  BufCoord.Y    := 0;
  Region.Left   := X - 1;
  Region.Top    := Y - 1;
  Region.Right  := X + Pad;
  Region.Bottom := Y - 1;

  If Region.Right > 79 Then Region.Right := 79;

//  Move (Buf[1], Buffer[Y][X], BufSize.X * SizeOf(TCharInfo));

  If Active Then
    WriteConsoleOutput(ConOut, @Buf, BufSize, BufCoord, Region);
End;

Function TOutputWindows.WhereX : Byte;
Begin
  WhereX := Cursor.X + 1;
End;

Function TOutputWindows.WhereY : Byte;
Begin
  WhereY := Cursor.Y + 1;
End;

Procedure TOutputWindows.WriteChar (Ch: Char);
Var
  BufferSize,
  BufferCoord : TCoord;
  WriteRegion : TSmallRect;
  OneCell     : TCharInfo;
Begin
  Case Ch of
    #08 : If Cursor.X > Window.Left Then Dec(Cursor.X);
    #10 : Begin
            If Cursor.Y = Window.Bottom Then
              ScrollWindow
            Else
              Inc (Cursor.Y);

            If Active Then SetConsoleCursorPosition(ConOut, Cursor);
          End;
    #13 : Cursor.X := Window.Left;
  Else
    If Active Then Begin
      OneCell.UnicodeChar := {$IFDEF FPC} Ch; {$ELSE} Byte(Ch); {$ENDIF}
      OneCell.Attributes  := TextAttr;

      BufferSize.X  := 1;
      BufferSize.Y  := 1;
      BufferCoord.X := 0;
      BufferCoord.Y := 0;

      WriteRegion.Left   := Cursor.X;
      WriteRegion.Top    := Cursor.Y;
      WriteRegion.Right  := Cursor.X;
      WriteRegion.Bottom := Cursor.Y;

      WriteConsoleOutput (ConOut, @OneCell, BufferSize, BufferCoord, WriteRegion);
    End;

    Buffer[Cursor.Y + 1][Cursor.X + 1].UnicodeChar := {$IFDEF FPC} Ch; {$ELSE} Byte(Ch); {$ENDIF}
    Buffer[Cursor.Y + 1][Cursor.X + 1].Attributes  := TextAttr;

    If Cursor.X < Window.Right Then
      Inc (Cursor.X)
    Else Begin
      If (Cursor.X = Window.Right) And (Cursor.Y = Window.Bottom - 1) Then Begin
        Inc (Cursor.X);
        Exit;
      End;

      Cursor.X := Window.Left;

      If Cursor.Y = Window.Bottom Then
        ScrollWindow
      Else
        Inc (Cursor.Y);
    End;

    If Active Then SetConsoleCursorPosition(ConOut, Cursor);
  End;
End;

Procedure TOutputWindows.WriteLine (Str: String);
Var
  Count : Byte;
Begin
  Str := Str + #13#10;

  For Count := 1 to Length(Str) Do WriteChar(Str[Count]);
End;

Procedure TOutputWindows.WriteStr (Str: String);
Var
  Count : Byte;
Begin
  For Count := 1 to Length(Str) Do WriteChar(Str[Count]);
End;

Procedure TOutputWindows.ScrollWindow;
Var
  ClipRect,
  ScrollRect : TSmallRect;
  DestCoord  : TCoord;
  Fill       : TCharInfo;
Begin
  Fill.UnicodeChar := {$IFDEF FPC} ' ' {$ELSE} 32 {$ENDIF};
  Fill.Attributes  := FTextAttr;

  ScrollRect.Left   := Window.Left;
  ScrollRect.Top    := Window.Top;
  ScrollRect.Right  := Window.Right;
  ScrollRect.Bottom := Window.Bottom;

  // might not need cliprect... might be able to pass scrollrect twice

  ClipRect := ScrollRect;

  DestCoord.X := Window.Left;
  DestCoord.Y := Window.Top - 1;

  If Active Then
  {$IFDEF FPC}
    ScrollConsoleScreenBuffer(ConOut, ScrollRect, ClipRect, DestCoord, PCharInfo(@Fill)^);
  {$ELSE}
    ScrollConsoleScreenBuffer(ConOut, ScrollRect, @ClipRect, DestCoord, PCharInfo(@Fill)^);
  {$ENDIF}

  Move (Buffer[2][1], Buffer[1][1], SizeOf(TConsoleLineRec) * 49);
  FillChar(Buffer[Window.Bottom + 1][1], SizeOf(TConsoleLineRec), #0);
End;

Procedure TOutputWindows.GetScreenImage (X1, Y1, X2, Y2: Byte; Var Image: TConsoleImageRec);
Var
  BufSize  : TCoord;
  BufCoord : TCoord;
  Region   : TSmallRect;
//  x,y,cx,cy:byte;
Begin
  BufSize.X     := X2 - X1 + 1;
  BufSize.Y     := Y2 - Y1 + 1;
  BufCoord.X    := 0;
  BufCoord.Y    := 0;
  Region.Left   := X1 - 1;
  Region.Top    := Y1 - 1;
  Region.Right  := X2 - 1;
  Region.Bottom := Y2 - 1;
  Image.X1      := X1;
  Image.X2      := X2;
  Image.Y1      := Y1;
  Image.Y2      := Y2;
  Image.WhereX := WhereX;
  Image.WhereY := WhereY;
  Image.CursorA := TextAttr;

  If Active Then
    ReadConsoleOutput (ConOut, @Image.Data[1][1], BufSize, BufCoord, Region)
  Else
    Image.Data := Buffer;
End;

Procedure TOutputWindows.GetScreenImage (Var Image: TConsoleImageRec); Overload;
Var
  Count : Byte;
Begin
  FillChar(Image, SizeOf(Image), #0);

  For Count := 1 to 25 Do Begin
    Move (Buffer[Count][1], Image.Data[Count][1], 80 * SizeOf(TCharInfo));
  End;

  Image.WhereX := WhereX;
  Image.WhereY := WhereY;
  Image.CursorA := TextAttr;
  Image.X1      := 1;
  Image.X2      := 80;
  Image.Y1      := 1;
  Image.Y2      := 25;
End;

Procedure TOutputWindows.ShowBuffer;
Var
  BufSize  : TCoord;
  BufCoord : TCoord;
  Region   : TSmallRect;
Begin
  BufSize.X     := 80;
  BufSize.Y     := ScreenSize;
  BufCoord.X    := 0;
  BufCoord.Y    := 0;
  Region.Left   := 0;
  Region.Top    := 0;
  Region.Right  := 79;
  Region.Bottom := ScreenSize - 1;

  WriteConsoleOutput (ConOut, @Buffer[1][1], BufSize, BufCoord, Region);

  GotoXY (Cursor.X + 1, Cursor.Y + 1);
End;

Procedure TOutputWindows.PutScreenImage (Image: TConsoleImageRec);
Var
  BufSize  : TCoord;
  BufCoord : TCoord;
  Region   : TSmallRect;
Begin
  BufSize.X     := Image.X2 - Image.X1 + 1;
  BufSize.Y     := Image.Y2 - Image.Y1 + 1;
  BufCoord.X    := 0;
  BufCoord.Y    := 0;
  Region.Left   := Image.X1 - 1;
  Region.Top    := Image.Y1 - 1;
  Region.Right  := Image.X2 - 1;
  Region.Bottom := Image.Y2 - 1;

  WriteConsoleOutput (ConOut, @Image.Data[1][1], BufSize, BufCoord, Region);
//  WriteConsoleOutput (ConOut, @Image.Data[Image.Y1][Image.X1], BufSize, BufCoord, Region);

  GotoXY (Image.WhereX, Image.WhereY);

  TextAttr := Image.CursorA;
End;

Procedure TOutputWindows.LoadScreenImage (Var DataPtr; Len, Width, X, Y: Integer);
Var
  Screen   : TConsoleScreenRec;
  Data     : Array[1..8000] of Byte Absolute DataPtr;
  PosX     : Word;
  PosY     : Byte;
  Attrib   : Byte;
  Count    : Word;
  A        : Byte;
  B        : Byte;
  C        : Byte;
  BufSize  : TCoord;
  BufCoord : TCoord;
  Region   : TSmallRect;
Begin
  PosX   := 1;
  PosY   := 1;
  Attrib := 7;
  Count  := 1;

  FillChar(Screen, SizeOf(Screen), #0);

  While (Count <= Len) Do Begin
    Case Data[Count] of
      00..
      15  : Attrib := Data[Count] + ((Attrib SHR 4) and 7) * 16;
      16..
      23  : Attrib := (Attrib And $F) + (Data[Count] - 16) * 16;
      24  : Begin
              Inc (PosY);
              PosX := 1;
            End;
      25  : Begin
              Inc (Count);
              For A := 0 to Data[Count] Do Begin
                Screen[PosY][PosX].UnicodeChar := {$IFDEF FPC} ' ' {$ELSE} 32 {$ENDIF};
                Screen[PosY][PosX].Attributes  := Attrib;

                Inc (PosX);
              End;
            End;
      26  : Begin
              A := Data[Count + 1];
              B := Data[Count + 2];

              Inc (Count, 2);

              For C := 0 to A Do Begin
                Screen[PosY][PosX].UnicodeChar := {$IFDEF FPC} Char(B); {$ELSE} B; {$ENDIF}
                Screen[PosY][PosX].Attributes  := Attrib;

                Inc (PosX);
              End;
            End;
      27..
      31  : ;
    Else
      Screen[PosY][PosX].UnicodeChar := {$IFDEF FPC} Char(Data[Count]); {$ELSE} Data[Count]; {$ENDIF}
      Screen[PosY][PosX].Attributes  := Attrib;

      Inc (PosX);
    End;

    Inc (Count);
  End;

  If PosY > ScreenSize Then PosY := ScreenSize;

  BufSize.Y     := PosY - (Y - 1);
  BufSize.X     := Width;
  BufCoord.X    := 0;
  BufCoord.Y    := 0;
  Region.Left   := X - 1;
  Region.Top    := Y - 1;
  Region.Right  := Width - 1;
  Region.Bottom := PosY - 1;

  WriteConsoleOutput (ConOut, @Screen[1][1], BufSize, BufCoord, Region);
  GotoXY(PosX, PosY);
End;

Function TOutputWindows.ReadCharXY (X, Y: Byte) : Char;
Var
  Coord   : TCoord;
  WasRead : ULong;
Begin
  Coord.X := X;
  Coord.Y := Y - 1;

  // should use buffer instead

  ReadConsoleOutputCharacter(ConOut, @Result, 1, Coord, WasRead);
End;

Function TOutputWindows.ReadAttrXY (X, Y: Byte) : Byte;
Var
  Coord   : TCoord;
  WasRead : ULong;
Begin
  Coord.X := X;
  Coord.Y := Y - 1;

  // should use buffer instead

  ReadConsoleOutputAttribute(ConOut, @Result, 1, Coord, WasRead);
End;

Procedure TOutputWindows.BufFlush;
Begin
End;

End.
