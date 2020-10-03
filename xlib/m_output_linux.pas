Unit m_Output_Linux;
{$MEMORY 64000, 800000}
{$MODE DELPHI}
{$EXTENDEDSYNTAX ON}
{$PACKRECORDS 1}
{$VARSTRINGCHECKS OFF}
{$TYPEINFO OFF}
{$LONGSTRINGS OFF}
{$I-}
Interface

Uses
  BaseUnix,
  Termio,
  m_Types;

Const
  ConIn      = 0;
  ConOut     = 1;
  ConBufSize = 1024;

Type
  TOutputLinux = Class
  Private
    TermInfo   : TermIos;
    TermInRaw  : Boolean;
    TermOutRaw : Boolean;
    OutBuffer  : Array[1..ConBufSize] of Char;
    OutBufPos  : Word;
    FTextAttr  : Byte;
    FWinTop    : Byte;
    FWinBot    : Byte;
    FWhereX   : Byte;
    FWhereY   : Byte;
    FSeth     : Char;

    Procedure   SetTextAttr (Attr: Byte);
  Public
    ScreenSize : Byte;
    Buffer     : TConsoleImageRec;
    Active     : Boolean;

    Function    AttrToAnsi (Attr: Byte) : String;
    Procedure   BufFlush;
    Procedure   BufAddStr (Str: String);
    Procedure   SaveRawSettings (Const TIo: TermIos);
    Procedure   RestoreRawSettings (TIo: TermIos);
    Procedure   SetScreenSize (Mode: Byte);
    Procedure   SetRawMode (SetOn: Boolean);
    Procedure   WriteXY (X, Y, A: Byte; Text: String);
    Procedure   WriteXYPipe (X, Y, Attr, Pad: Integer; Text: String);
    Procedure   WritePipe (Str: String);
    Procedure   GetScreenImage (X1, Y1, X2, Y2: Byte; Var Image: TConsoleImageRec);
    Procedure   GetScreenImage (Var Image: TConsoleImageRec); Overload;
    Procedure   PutScreenImage (Image: TConsoleImageRec);
    Procedure   LoadScreenImage (Var DataPtr; Len, Width, X, Y: Integer);
    
    Procedure   ImageClear(Var Image: TConsoleImageRec);
    Procedure   ImageWriteXYChr(Var Image: TConsoleImageRec; x,y:integer; a:byte; c:char);
    Procedure   ImageWriteXYStr(Var Image: TConsoleImageRec; x,y:integer; a:byte; s:string);
    
    Procedure   CopyImage(Src:TConsoleImageRec; Var dest:TConsoleImageRec);
    Procedure   ImageCopyLine(Line: TConsoleLineRec; Var Image:TConsoleImageRec; pos:word);
    Procedure   PutScreenLine(Image:TConsoleImageRec; Pos:word);

    Constructor Create (A: Boolean);
    Destructor  Destroy; Override;
    Procedure   ClearScreen;
    Procedure   ClearEOL;
    Procedure   GotoXY (X, Y: Byte);
    Procedure   GotoY (Y: Byte);
    Procedure   GotoX (X: Byte);

    Procedure   SetWindow (X1, Y1, X2, Y2: Byte; Home: Boolean);
    Procedure   SetWindowTitle (Str: String);
    Procedure   WriteChar (Ch: Char);
    Procedure   WriteLine (Str: String);
    Procedure   WriteStr (Str: String);
    Procedure   RawWriteStr (Str: String);
    Function    ReadCharXY (X, Y: Byte) : Char;
    Function    ReadAttrXY (X, Y: Byte) : Byte;
    Procedure   ShowBuffer;

    Property TextAttr : Byte Read FTextAttr Write SetTextAttr;
    Property WhereX  : Byte Read FWhereX;
    Property WhereY  : Byte Read FWhereY;
    Property Seth     : Char Read FSeth Write FSeth;
  End;

Implementation

Uses
  xStrings,xDateTime;

Constructor TOutputLinux.Create (A: Boolean);
Begin
  Inherited Create;

  SetRawMode(True);

  Active     := A;
  OutBufPos  := 0;
  FTextAttr  := 7;
  FWinTop    := 1;
  FWinBot    := 25;
  ScreenSize := 25;
  FSeth :='|';
  RawWriteStr (#27 + '(U' + #27 + '[0m');

  ClearScreen;
End;

Destructor TOutputLinux.Destroy;
Begin
  BufFlush;

  SetRawMode(False);

  Inherited Destroy;
End;

Const
  AnsiTable : String[8] = '04261537';

Function TOutputLinux.AttrToAnsi (Attr: Byte) : String;
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

  If (OldFG <> 7) or (FG = 7) or ((OldFG > 7) and (FG < 8)) or ((OldBG > 7) and (BG < 8)) Then Begin
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

Procedure TOutputLinux.BufFlush;
Begin
  If (OutBufPos > 0) And Active Then Begin
    fpWrite (ConOut, OutBuffer[1], OutBufPos);
    OutBufPos := 0;
  End;
End;

Procedure TOutputLinux.SetScreenSize (Mode: Byte);
Begin
  FWinBot    := Mode;
  ScreenSize := Mode;

  BufFlush;
  RawWriteStr(#27 + '[8;' + Int2Str(Mode) + ';80t');
  SetWindow(1, 1, 80, Mode, False);
//need to figure this out.

//esc[8;h;w
End;

Procedure TOutputLinux.BufAddStr (Str: String);
Var
  Count : LongInt;
Begin
  For Count := 1 to Length(Str) Do Begin
    Inc (OutBufPos);
    OutBuffer[OutBufPos] := Str[Count];
    If OutBufPos = ConBufSize Then BufFlush;
  End;
End;

Procedure TOutputLinux.SetTextAttr (Attr: Byte);
Begin
  If Attr = FTextAttr Then Exit;

  BufAddStr(AttrToAnsi(Attr));

  FTextAttr := Attr;
End;

Procedure   TOutputLinux.GotoY (Y: Byte);
Begin
  GotoXY(WhereX,Y);
End;

Procedure TOutputLinux.GotoX (X: Byte);
Begin
  GotoXY(X,WhereY);
End;

Procedure TOutputLinux.GotoXY (X, Y: Byte);
Begin
  If (Y < 1)  Then Y := 1 Else
  If (Y > 25) Then Y := 25;
  If (X < 1)  Then X := 1 Else
  If (X > 80) Then X := 80;

  BufAddStr(#27 + '[' + Int2Str(Y) + ';' + Int2Str(X) + 'H');
  BufFlush;

  FWhereX := X;
  FWhereY := Y;
End;

Procedure TOutputLinux.ClearScreen;
Var
  Fill  : TCharInfo;
  Count : Byte;
Begin
  BufFlush;

  Fill.Attributes  := FTextAttr;
  Fill.UnicodeChar := ' ';

  If (FWinTop = 1) and (FWinBot = 25) Then Begin
    BufAddStr(#27 + '[2J');
    FillWord (Buffer, SizeOf(Buffer) DIV 2, Word(Fill));
  End Else Begin
    For Count := FWinTop to FWinBot Do Begin
      BufAddStr (#27 + '[' + Int2Str(Count) + ';1H' + #27 + '[K');
      FillWord (Buffer.data[Count][1], SizeOf(TConsoleLineRec) DIV 2, Word(Fill));
    End;
  End;

  GotoXY (1, FWinTop);
End;

Procedure TOutputLinux.SetWindow (X1, Y1, X2, Y2: Byte; Home: Boolean);
Begin
  // X1 and X2 are ignored in Linux and are only here for compatibility
  // reasons.

  FWinTop := Y1;
  FWinBot := Y2;

  BufAddStr (#27 + '[' + Int2Str(Y1) + ';' + Int2Str(Y2) + 'r');

  If Home or (FWhereY < Y1) or (FWhereY > Y2) Then GotoXY(1, Y1);
End;

Procedure TOutputLinux.SetWindowTitle (Str: String);
Begin
End;

Procedure TOutputLinux.ClearEOL;
Begin
  BufAddStr(#27 + '[K');
End;

Procedure TOutputLinux.WriteChar (Ch: Char);
Begin
  BufAddStr(Ch);

  Case Ch of
    #08 : If FWhereX > 1 Then
            Dec(FWhereX);
    #10 : Begin
            If FWhereY < FWinBot Then
              Inc (FWhereY);

            BufFlush;
          End;
    #13 : FWhereX := 1;
  Else
   Buffer.data[FWhereY][FWhereX].Attributes  := FTextAttr;
   Buffer.data[FWhereY][FWhereX].UnicodeChar := Ch;

    If FWhereX < 80 Then
      Inc (FWhereX)
    Else Begin
      FWhereX := 1;

      If FWhereY < FWinBot Then
        Inc (FWhereY);

      BufFlush;
    End;
  End;
End;

Procedure TOutputLinux.WriteStr (Str: String);
Var
  Count : Byte;
Begin
  For Count := 1 to Length(Str) Do
    WriteChar(Str[Count]);

  BufFlush;
End;

Procedure TOutputLinux.WriteLine (Str: String);
Var
  Count : Byte;
Begin
  Str := Str + #13#10;

  For Count := 1 To Length(Str) Do
    WriteChar(Str[Count]);
End;

Procedure TOutputLinux.RawWriteStr (Str: String);
Begin
  fpWrite (ConOut, Str[1], Length(Str));
End;

Procedure TOutputLinux.SaveRawSettings (Const TIo: TermIos);
Begin
  With TIo Do Begin
    TermInRaw :=
      ((c_iflag and (IGNBRK or BRKINT or PARMRK or ISTRIP or
                               INLCR or IGNCR or ICRNL or IXON)) = 0) and
      ((c_lflag and (ECHO or ECHONL or ICANON or ISIG or IEXTEN)) = 0);
    TermOutRaw :=
      ((c_oflag and OPOST) = 0) and
      ((c_cflag and (CSIZE or PARENB)) = 0) and
      ((c_cflag and CS8) <> 0);
  End;
End;

Procedure TOutputLinux.RestoreRawSettings (TIo: TermIos);
Begin
  With TIo Do Begin
    If TermInRaw Then Begin
      c_iflag := c_iflag and (not (IGNBRK or BRKINT or PARMRK or ISTRIP or
                 INLCR or IGNCR or ICRNL or IXON));
      c_lflag := c_lflag and
                 (not (ECHO or ECHONL or ICANON or ISIG or IEXTEN));
    End;

    If TermOutRaw Then Begin
      c_oflag := c_oflag and not(OPOST);
      c_cflag := c_cflag and not(CSIZE or PARENB) or CS8;
    End;
  End;
End;

Procedure TOutputLinux.SetRawMode (SetOn: Boolean);
Var
  Tio : TermIos;
Begin
  If SetOn Then Begin
    TCGetAttr(1, Tio);
    SaveRawSettings(Tio);
    TermInfo := Tio;
    CFMakeRaw(Tio);
  End Else Begin
    RestoreRawSettings(TermInfo);
    Tio := TermInfo;
  End;

  TCSetAttr(1, TCSANOW, Tio);
End;

Function TOutputLinux.ReadCharXY (X, Y: Byte) : Char;
Begin
  ReadCharXY := Buffer.data[Y][X].UnicodeChar;
End;

Function TOutputLinux.ReadAttrXY (X, Y: Byte) : Byte;
Begin
  ReadAttrXY := Buffer.data[Y][X].Attributes;
End;

Procedure TOutputLinux.WriteXY (X, Y, A: Byte; Text: String);
Var
  OldAttr : Byte;
  OldX    : Byte;
  OldY    : Byte;
Begin
  OldAttr := FTextAttr;
  OldX    := FWhereX;
  OldY    := FWhereY;

  GotoXY (X, Y);
  SetTextAttr (A);
  WriteStr (Text);


  SetTextAttr(OldAttr);
  GotoXY (OldX, OldY);
//  BufFlush;
End;

Procedure TOutputLinux.WriteXYPipe (X, Y, Attr, Pad: Integer; Text: String);
Var
  Count   : Byte;
  Code    : String[2];
  CodeNum : Byte;
  OldAttr : Byte;
  OldX    : Byte;
  OldY    : Byte;
Begin
  OldAttr := FTextAttr;
  OldX    := FWhereX;
  OldY    := FWhereY;

  GotoXY (X, Y);
  SetTextAttr (Attr);

  Count := 1;

  While Count <= Length(Text) Do Begin
    If Text[Count] = FSeth Then Begin
      Code    := Copy(Text, Count + 1, 2);
      CodeNum := Str2Int(Code);

      If (Code = '00') or (CodeNum > 0) Then Begin
        Inc (Count, 2);
        If CodeNum in [00..15] Then
          SetTextAttr (CodeNum + ((FTextAttr SHR 4) AND 7) * 16)
        Else
          SetTextAttr ((FTextAttr AND $F) + (CodeNum - 16) * 16);
      End Else 
      Begin
        BufAddStr(Text[Count]);
        Dec (Pad);
      End;
    End Else Begin
      BufAddStr(Text[Count]);
      Dec (Pad);
    End;

    If Pad = 0 Then Break;

    Inc (Count);
  End;

  If Pad > 1 Then BufAddStr(strRep(' ', Pad));

  SetTextAttr(OldAttr);
  GotoXY (OldX, OldY);

//  BufFlush;
End;

Procedure TOutputLinux.GetScreenImage (X1, Y1, X2, Y2: Byte; Var Image: TConsoleImageRec);
Var
  Count : Byte;
  Line  : Byte;
Begin
  Line := 1;

  FillChar(Image, SizeOf(Image), #0);

  For Count := Y1 to Y2 Do Begin
    Move (Buffer.data[Count][X1], Image.data[Line][1], (X2 - X1 + 1) * SizeOf(TCharInfo));
    Inc (Line);
  End;

End;

Procedure TOutputLinux.GetScreenImage (Var Image: TConsoleImageRec); Overload;
Var
  Count : Byte;
Begin
  FillChar(Image, SizeOf(Image), #0);

  For Count := 1 to 25 Do Begin
    Move (Buffer.data[Count][1], Image.data[Count][1], 80 * SizeOf(TCharInfo));
  End;
End;

Procedure TOutputLinux.PutScreenImage (Image: TConsoleImageRec);
Var
  CountX : Byte;
  CountY : Byte;
Begin
  For CountY := 1 to 25 Do Begin
    GotoXY (1, CountY);

    Move (Image.data[CountY][1], Buffer.data[CountY][1], (80) * SizeOf(TCharInfo));

    For CountX := 1 to 80 Do Begin
      SetTextAttr(Image.data[CountY][CountX].Attributes);
      BufAddStr(Image.data[CountY][CountX].UnicodeChar);
    End;
  End;

  //SetTextAttr (Image.CursorA);
  //GotoXY (Image.WhereX, Image.WhereY);
  
End;

Procedure TOutputLinux.LoadScreenImage (Var DataPtr; Len, Width, X, Y: Integer);
Var
  Image    : TConsoleImageRec;
  Data     : Array[1..8000] of Byte Absolute DataPtr;
  PosX     : Word;
  PosY     : Byte;
  Attrib   : Byte;
  Count    : Word;
  A        : Byte;
  B        : Byte;
  C        : Byte;
Begin
  PosX     := 1;
  PosY     := 1;
  Attrib   := 7;
  Count    := 1;

  FillChar(Image, SizeOf(Image), #0);

  While (Count <= Len) Do begin
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
                Image.data[PosY][PosX].UnicodeChar := ' ';
                Image.data[PosY][PosX].Attributes  := Attrib;

                Inc (PosX);
              End;
            End;
      26  : Begin
              A := Data[Count + 1];
              B := Data[Count + 2];

              Inc (Count, 2);

              For C := 0 to A Do Begin
                Image.data[PosY][PosX].UnicodeChar := Char(B);
                Image.data[PosY][PosX].Attributes  := Attrib;

                Inc (PosX);
              End;
            End;
      27..
      31  : ;
    Else
      Image.data[PosY][PosX].UnicodeChar := Char(Data[Count]);
      Image.data[PosY][PosX].Attributes  := Attrib;

      Inc (PosX);
    End;

    Inc(Count);
  End;

  If PosY > ScreenSize Then PosY := ScreenSize;

  PutScreenImage(Image);
End;

Procedure TOutputLinux.ImageWriteXYChr(Var Image: TConsoleImageRec; x,y:integer; a:byte; c:char);
begin
   Image.data[y][x].attributes:=a;
   Image.data[y][x].UnicodeChar:=c;
end;

Procedure  TOutputLinux.ImageWriteXYStr(Var Image: TConsoleImageRec; x,y:integer; a:byte; s:string);
Var
  i:integer;
Begin
  for i:=1 to length(s) do
    ImageWriteXYChr(Image,x+i-1,y,a,s[i]);
End;

Procedure TOutputLinux.ImageClear(Var Image: TConsoleImageRec);
Var
  Fill:Tcharinfo;
Begin
  FillChar(Image, SizeOf(Image), #0);

  Fill.Attributes := FTextAttr;
  Fill.UnicodeChar := ' ';
  FillWord (Buffer, SizeOf(Buffer) DIV 2, Word(Fill));

End;

Procedure TOutputLinux.CopyImage(Src:TConsoleImageRec; Var dest:TConsoleImageRec);
Begin 
  dest:=src;
End;

Procedure TOutputLinux.ImageCopyLine(Line: TConsoleLineRec; Var Image:TConsoleImageRec; pos:word);
Begin
  move(line,image.data[pos],sizeof(TConsoleLineRec));
End;

Procedure TOutputLinux.PutScreenLine(Image:TConsoleImageRec; Pos:word);
Begin  
      //SetTextAttr(Image.Data[pos][CountX].Attributes);
      //BufAddStr(Image.Data[CountY][CountX].UnicodeChar);
      Buffer.data[Pos] := Image.data[Pos];

End;

Procedure TOutputLinux.WritePipe (Str: String);

  Procedure AddChar (Ch: Char);
  Begin
    If WhereX > 80 Then Exit;

    Buffer.data[WhereY][WhereX].Attributes  := FTextAttr;
    Buffer.data[WhereY][WhereX].UnicodeChar := Ch;

    BufAddStr(Ch);

    Inc (FWhereX);
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
  OldX    := FWhereX;
  OldY    := FWhereY;
}
  //GotoXYRaw (X, Y);
  //SetTextAttr (Attr);
  text:=str;
  Count := 1;

  While Count <= Length(text) Do Begin
    If text[Count] = FSeth Then Begin
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
  //GotoXYRaw (OldX, OldY);

  BufFlush;
End;

Procedure TOutputLinux.ShowBuffer;
Begin
End;

End.
