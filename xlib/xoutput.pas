Unit xoutput;
{$MODE DELPHI}
{$EXTENDEDSYNTAX ON}
{$PACKRECORDS 1}
{$VARSTRINGCHECKS OFF}
{$TYPEINFO OFF}
{$LONGSTRINGS OFF}
{$I-}
Interface

Const
  ConIn      = 0;
  ConOut     = 1;
  ConBufSize = 1024;
  
  Const
    // ASCII C0 Codes, etc
  _NUL     = $00;
  _SOH     = $01;
  _STX     = $02;
  _ETX     = $03;
  _EOT     = $04;
  _ENQ     = $05;
  _ACK     = $06;
  _BEL     = $07;
  _BS      = $08;
  _HT      = $09;
  _LF      = $0A;
  _VT      = $0B;
  _FF      = $0C;
  _CR      = $0D;
  _SO      = $0E;
  _SI      = $0F;
  _DLE     = $10;
  _DC1     = $11;  //   same
  _XON     = $11;  // values
  _DC2     = $12;
  _DC3     = $13;  //   same
  _XOFF    = $13;  // values
  _DC4     = $14;
  _NAK     = $15;
  _SYN     = $16;
  _ETB     = $17;
  _CAN     = $18;
  _EM      = $19;
  _SUB     = $1A;  //   same
  _CPMEOF  = $1A;  // values
  _ESC     = $1B;
  _FS      = $1C;
  _GS      = $1D;
  _RS      = $1E;
  _US      = $1F;
  _SPACE   = $20;
  _DEL     = $7F;
  _SHY     = $2010;  // similar character to replace soft-hyphen
  _EMPTY   = $DFFF;  // invalid character used to mark holes in objects
  
  CP437 : packed array [0..255] of UInt16 = (
      _SPACE, $263A, $263B, $2665, $2666, $2663, $2660, $2022,
      $25D8, $25CB, $25D9, $2642, $2640, $266A, $266B, $263C,
      $25BA, $25C4, $2195, $203C, $00B6, $00A7, $25AC, $21A8,
      $2191, $2193, $2192, $2190, $221F, $2194, $25B2, $25BC,
      $0020, $0021, $0022, $0023, $0024, $0025, $0026, $0027,
      $0028, $0029, $002A, $002B, $002C, $002D, $002E, $002F,
      $0030, $0031, $0032, $0033, $0034, $0035, $0036, $0037,
      $0038, $0039, $003A, $003B, $003C, $003D, $003E, $003F,
      $0040, $0041, $0042, $0043, $0044, $0045, $0046, $0047,
      $0048, $0049, $004A, $004B, $004C, $004D, $004E, $004F,
      $0050, $0051, $0052, $0053, $0054, $0055, $0056, $0057,
      $0058, $0059, $005A, $005B, $005C, $005D, $005E, $005F,
      $0060, $0061, $0062, $0063, $0064, $0065, $0066, $0067,
      $0068, $0069, $006A, $006B, $006C, $006D, $006E, $006F,
      $0070, $0071, $0072, $0073, $0074, $0075, $0076, $0077,
      $0078, $0079, $007A, $007B, $007C, $007D, $007E, $2302,
      $00C7, $00FC, $00E9, $00E2, $00E4, $00E0, $00E5, $00E7,
      $00EA, $00EB, $00E8, $00EF, $00EE, $00EC, $00C4, $00C5,
      $00C9, $00E6, $00C6, $00F4, $00F6, $00F2, $00FB, $00F9,
      $00FF, $00D6, $00DC, $00A2, $00A3, $00A5, $20A7, $0192,
      $00E1, $00ED, $00F3, $00FA, $00F1, $00D1, $00AA, $00BA,
      $00BF, $2310, $00AC, $00BD, $00BC, $00A1, $00AB, $00BB,
      $2591, $2592, $2593, $2502, $2524, $2561, $2562, $2556,
      $2555, $2563, $2551, $2557, $255D, $255C, $255B, $2510,
      $2514, $2534, $252C, $251C, $2500, $253C, $255E, $255F,
      $255A, $2554, $2569, $2566, $2560, $2550, $256C, $2567,
      $2568, $2564, $2565, $2559, $2558, $2552, $2553, $256B,
      $256A, $2518, $250C, $2588, $2584, $258C, $2590, $2580,
      $03B1, $00DF, $0393, $03C0, $03A3, $03C3, $00B5, $03C4,
      $03A6, $0398, $03A9, $03B4, $221E, $03C6, $03B5, $2229,
      $2261, $00B1, $2265, $2264, $2320, $2321, $00F7, $2248,
      $00B0, $2219, $00B7, $221A, $207F, $00B2, $25A0, _SPACE );

Type
  {$IFNDEF WINDOWS}
  TCharInfo = Record
    Attributes  : Byte;
    UnicodeChar : word;
  End;
  {$ENDIF}
  TConsoleLineRec   = Array[1..80] of TCharInfo;
  TConsoleScreenRec = Array[1..50] of TConsoleLineRec;

  TConsoleImageRec  = Record
    Data    : TConsoleScreenRec;
    WhereX : Byte;
    WhereY : Byte;
    CursorA : Byte;
    X1      : Byte;
    X2      : Byte;
    Y1      : Byte;
    Y2      : Byte;
  End;
  
  TOutputLinux = Class
  Private
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
    Buffer     : TConsoleScreenRec;
    Active     : Boolean;
    isUTF8     : Boolean;

    Function    AttrToAnsi (Attr: Byte) : String;
    Procedure   BufFlush;
    Procedure   BufAddStr (Str: String);
    
    Procedure   SetScreenSize (Mode: Byte);
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
    Procedure   ImageWriteChr(Var Image: TConsoleImageRec; a:byte; c:char);
    Procedure   ImageWriteStr(Var Image: TConsoleImageRec; a:byte; s:string);
    Procedure   ImageGotoXY(Var Image: TConsoleImageRec; x,y:integer);
    Procedure   ImageTextAttr(Var Image: TConsoleImageRec; a:byte);
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
  xStrings,xDateTime,LConvEncoding;

Constructor TOutputLinux.Create (A: Boolean);
Begin
  Inherited Create;

  Active     := A;
  OutBufPos  := 0;
  FTextAttr  := 7;
  FWinTop    := 1;
  FWinBot    := 25;
  ScreenSize := 25;
  FSeth :='|';
  system.Write(#27 + '(U' + #27 + '[0m');
  
  isUTF8 := Upper(GetConsoleTextEncoding)= 'UTF8';

  ClearScreen;
End;

Destructor TOutputLinux.Destroy;
Begin
  BufFlush;

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

Procedure TOutputLinux.BufFlush;
var
  d:word;
Begin
  If (OutBufPos > 0) And Active Then Begin
    for d:=1 to OutBufPos do write(Outbuffer[d]);
    OutBufPos := 0;
  End;
End;

Procedure TOutputLinux.SetScreenSize (Mode: Byte);
Begin
  FWinBot    := Mode;
  ScreenSize := Mode;

  BufFlush;
  Write(#27 + '[8;' + Int2Str(Mode) + ';80t');
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
  i,d:byte;
Begin
  BufFlush;

  Fill.Attributes  := FTextAttr;
  Fill.UnicodeChar := _space;

  
  BufAddStr(#27 + '[2J');
  
  FillByte (Buffer, SizeOf(Buffer) , FTextAttr);
  For i:=1 to 50 do
    For d:=1 to 80 do Buffer[i][d].UnicodeChar:=_Space;
  
  

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
   Buffer[FWhereY][FWhereX].Attributes  := FTextAttr;
   if isutf8 then 
    Buffer[FWhereY][FWhereX].UnicodeChar := cp437[ord(Ch)]
  else 
    Buffer[FWhereY][FWhereX].UnicodeChar := word(Ch);
    
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

Function TOutputLinux.ReadCharXY (X, Y: Byte) : Char;
Begin
  ReadCharXY := Char(Buffer[Y][X].UnicodeChar);
End;

Function TOutputLinux.ReadAttrXY (X, Y: Byte) : Byte;
Begin
  ReadAttrXY := Buffer[Y][X].Attributes;
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
    Move (Buffer[Count][X1], Image.Data[Line][1], (X2 - X1 + 1) * SizeOf(TCharInfo));
    Inc (Line);
  End;

  Image.WhereX := FWhereX;
  Image.WhereY := FWhereY;
  Image.CursorA := FTextAttr;
  Image.X1      := X1;
  Image.X2      := X2;
  Image.Y1      := Y1;
  Image.Y2      := Y2;
End;

Procedure TOutputLinux.GetScreenImage (Var Image: TConsoleImageRec); Overload;
Var
  Count : Byte;
Begin
  FillChar(Image, SizeOf(Image), #0);

  For Count := 1 to 25 Do Begin
    Move (Buffer[Count][1], Image.Data[Count][1], 80 * SizeOf(TCharInfo));
  End;

  Image.WhereX := FWhereX;
  Image.WhereY := FWhereY;
  Image.CursorA := FTextAttr;
  Image.X1      := 1;
  Image.X2      := 79;
  Image.Y1      := 1;
  Image.Y2      := 25;
End;

Procedure TOutputLinux.PutScreenImage (Image: TConsoleImageRec);
Var
  CountX : Byte;
  CountY : Byte;
Begin
  For CountY := 1 to (Image.Y2 - Image.Y1 + 1) Do Begin
    GotoXY (Image.X1, CountY + Image.Y1 - 1);

    Move (Image.Data[CountY][1], Buffer[CountY + Image.Y1 - 1][Image.X1], (Image.X2 - Image.X1 + 1) * SizeOf(TCharInfo));

    For CountX := 1 to (Image.X2 - Image.X1 + 1) Do Begin
      SetTextAttr(Image.Data[CountY][CountX].Attributes);
      BufAddStr(char(Image.Data[CountY][CountX].UnicodeChar));
    End;
  End;

  SetTextAttr (Image.CursorA);
  GotoXY (Image.WhereX, Image.WhereY);
  
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

  FillChar(Image.Data, SizeOf(Image.Data), #0);

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
                Image.Data[PosY][PosX].UnicodeChar := _space;
                Image.Data[PosY][PosX].Attributes  := Attrib;

                Inc (PosX);
              End;
            End;
      26  : Begin
              A := Data[Count + 1];
              B := Data[Count + 2];

              Inc (Count, 2);

              For C := 0 to A Do Begin
                Image.Data[PosY][PosX].UnicodeChar := B;
                Image.Data[PosY][PosX].Attributes  := Attrib;

                Inc (PosX);
              End;
            End;
      27..
      31  : ;
    Else
      Image.Data[PosY][PosX].UnicodeChar := Data[Count];
      Image.Data[PosY][PosX].Attributes  := Attrib;

      Inc (PosX);
    End;

    Inc(Count);
  End;

  If PosY > ScreenSize Then PosY := ScreenSize;

  Image.WhereX := PosX;
  Image.WhereY := PosY;
  Image.CursorA := Attrib;
  Image.X1      := X;
  Image.X2      := Width;
  Image.Y1      := Y;
  Image.Y2      := PosY;

  PutScreenImage(Image);
End;

Procedure TOutputLinux.ImageWriteXYChr(Var Image: TConsoleImageRec; x,y:integer; a:byte; c:char);
begin
   Image.data[y][x].attributes:=a;
   if isutf8 then 
      Image.data[y][x].UnicodeChar:=cp437[ord(c)]
   else
      Image.data[y][x].UnicodeChar:=word(c);
   Image.WhereX := x+1;
   Image.WhereY := y;
   Image.CursorA := a;
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
  i,d:byte;
Begin
  FillChar(Image, SizeOf(Image), #0);

  Fill.Attributes := FTextAttr;
  Fill.UnicodeChar := _SPACE;
  
  FillByte (Buffer, SizeOf(Buffer) , FTextAttr);
  For i:=1 to 50 do
    For d:=1 to 80 do Buffer[i][d].UnicodeChar:=_Space;

  Image.WhereX := 1;
  Image.WhereY := 1;
  Image.CursorA := 7;
  Image.X1      := 1;
  Image.X2      := 80;
  Image.Y1      := 1;
  Image.Y2      := 25;
End;

Procedure  TOutputLinux.ImageWriteChr(Var Image: TConsoleImageRec; a:byte; c:char);
Begin
  ImageWriteXYChr(image,image.WhereX,image.WhereY,a,c);
 // inc(Image.WhereX);
End;

Procedure  TOutputLinux.ImageWriteStr(Var Image: TConsoleImageRec; a:byte; s:string);
Var
  i:integer;
Begin
  for i:=1 to length(s) do
    ImageWriteChr(Image,a,s[i]);
End;

Procedure  TOutputLinux.ImageGotoXY(Var Image: TConsoleImageRec; x,y:integer);
Begin
  Image.WhereX:=x;
  image.WhereY:=y;
End;

Procedure  TOutputLinux.ImageTextAttr(Var Image: TConsoleImageRec; a:byte);
Begin
  Image.Cursora:=a;
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
      Buffer[Pos] := Image.Data[Pos];

End;

Procedure TOutputLinux.WritePipe (Str: String);

  Procedure AddChar (Ch: Char);
  Begin
    If WhereX > 80 Then Exit;

    Buffer[WhereY][WhereX].Attributes  := FTextAttr;
    if isutf8 then
      Buffer[WhereY][WhereX].UnicodeChar := cp437[ord(Ch)]
    else 
      Buffer[WhereY][WhereX].UnicodeChar := word(ch);

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
