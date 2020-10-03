{
   ====================================================================
   xLib - xCrt                                                     xqtr
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

{$IFDEF FPC}
  {$mode objfpc}
  {$PACKRECORDS 1}
  {$H-}
  {$V-}
{$EndIF}

Unit fpc_xcrt;

interface
  uses
{$IFDEF WIN32}
    Windows;
{$EndIF}
{$IFDEF UNIX}
    Unix;
{$EndIF}

const
  {$IFDEF UNIX}
    PathSep = '/';
    PathChar = '/';
  {$ELSE}
    PathSep = '\';
    PathChar = '\';
  {$EndIF}
  EOL = #13#10;
  CRLF = #13#10;
  CSI = #27'[';
  AnsiColours: Array[0..7] of Integer = (0, 4, 2, 6, 1, 5, 3, 7);
  CHARS_ALL = '`1234567890-=\qwertyuiop[]asdfghjkl;''zxcvbnm,./~!@#$%^&*()_+|'+
              'QWERTYUIOP{}ASDFGHJKL:"ZXCVBNM<>? ';
  CHARS_ALPHA = 'qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM';
  CHARS_NUMERIC = '1234567890.,+-';
  CHARS_FILENAME = '1234567890-=\/qwertyuiop[]asdfghjkl;''zxcvbnm,.~!@#$%^&()_+'+
                   'QWERTYUIOP{}ASDFGHJKL:ZXCVBNM ';
  
  Black         = 0;
  Blue          = 1;
  Green         = 2;
  Cyan          = 3;
  Red           = 4;
  Magenta       = 5;
  Brown         = 6;
  LightGray     = 7;
  DarkGray      = 8;
  LightBlue     = 9;
  LightGreen    = 10;
  LightCyan     = 11;
  LightRed      = 12;
  LightMagenta  = 13;
  Yellow        = 14;
  White         = 15;


  keyHome          = #71;      
  keyCursorUp      = #72;     
  keyPgUp          = #73;
  keyCursorLeft    = #75;      
  KeyNum5          = #76;     
  keyCursorRight   = #77;
  keyEnd           = #79;
  keyCursorDown    = #80;
  keyPgDn          = #81;
  KeyIns           = #82;
  KeyDel           = #83;
  KeyBackSpace     = #8;
  KeyTab           = #9;
  KeyEnter         = #13;
  KeyEsc           = #27;
  Keyforwardslash  = #47;
  Keyasterisk      = #42;
  Keyminus         = #45;
  Keyplus          = #43;
  KeyF1            = #59;
  KeyF2            = #60;
  KeyF3            = #61;
  KeyF4            = #62;
  KeyF5            = #63;
  KeyF6            = #64;
  KeyF7            = #65;
  KeyF8            = #66;
  KeyF9            = #67;
  KeyF10           = #68;
  KeyF11           = #69;
  KeyF12           = #70;
  
  keyCtrlA  = #1; 
  keyCtrlB  = #2; 
  //CtrlC  = #3; 
  keyCtrlD  = #4; 
  keyCtrlE  = #5; 
  keyCtrlF  = #6; 
  keyCtrlG  = #7; 
  keyCtrlH  = #8; 
  keyCtrlI  = #9; 
  keyCtrlJ  = #10;
  keyCtrlK  = #11;
  keyCtrlL  = #12;
  keyCtrlM  = #13;
  keyCtrlN  = #14;
  keyCtrlO  = #15;
  keyCtrlP  = #16;
  keyCtrlQ  = #17;
  keyCtrlR  = #18;
  keyCtrlS  = #19;
  keyCtrlT  = #20;
  keyCtrlU  = #21;
  keyCtrlV  = #22;
  keyCtrlW  = #23;
  keyCtrlX  = #24;
  keyCtrlY  = #25;
  keyCtrlZ  = #26;
  
  keyAlt1 = #248;
  keyAlt2 = #249;
  keyAlt3 = #250;
  keyAlt4 = #251;
  keyAlt5 = #252;
  keyAlt6 = #253;
  keyAlt7 = #254;
  keyAlt8 = #255;
  keyAlt9 = #134;
  keyAlt0 = #135;
  
  keyALTA  = #30;
  keyALTB  = #48;
  keyALTC  = #46;
  keyALTD  = #32;
  keyALTE  = #18;
  keyALTF  = #33;
  keyALTG  = #34;
  keyALTH  = #35;
  keyALTI  = #23;
  keyALTJ  = #36;
  keyALTK  = #37;
  keyALTL  = #38;
  keyALTM  = #50;
  keyALTN  = #49;
  keyALTO  = #24;
  keyALTP  = #25;
  keyALTQ  = #16;
  keyALTR  = #19;
  keyALTS  = #31;
  keyALTT  = #20;
  keyALTU  = #22;
  KeyAltV  = #175;
  KeyAltW  = #17;
  keyALTX  = #45;
  keyALTY  = #21;
  keyALTZ  = #44;
  
  
type

  SmallWord = System.Word;
  TCharInfo = packed record
    Ch:   char;
    Attr: byte;
  End;
  
  TConsoleLineRec   = Array[1..80] of TCharInfo;
  TScreenBuf = Array[1..50] of TConsoleLineRec;
  
  TConTheme = Record
    FrameType  : Byte;
    BoxAttr    : Byte;
    Box3D      : Boolean;
    BoxAttr2   : Byte;
    BoxAttr3   : Byte;
    BoxAttr4   : Byte;
    Shadow     : Boolean;
    ShadowAttr : Byte;
    HeadAttr   : Byte;
    HeadType   : Byte;
    Emboss     : Boolean;
    ScrAttr    : Byte;
    GetStrBG   : Byte;
    GetStrFG   : Byte;
    GetStrCh   : Byte;
    
    HelpX       : Byte;
    HelpY       : Byte;
    HelpSize    : Byte;
    HelpColor   : Byte;
    cLo         : Byte;
    cHi         : Byte;
    cData       : Byte;
    cLoKey      : Byte;
    cHiKey      : Byte;
    cField1     : Byte;
    cField2     : Byte;
  End;
  
  var
    FileModeReadWrite: Integer;
    TextModeRead: Integer;
    TextModeReadWrite: Integer;
    Theme : TConTheme;
    Seth  : Char;
    
    WindMax:Byte;
    WindMin:Byte;
    ScreenHeight:Byte;
    ScreenWidth:Byte;
    Image  : TScreenBuf;
    Buffer : TScreenBuf;
    More:String;
    isUTF : Boolean = False;

Procedure RestoreScreen(screenBuf: TScreenBuf);
Procedure SaveScreen(var screenBuf: TScreenBuf);
Function  GetAttrAt(AX, AY: Byte): Byte;
Function  GetCharAt(AX, AY: Byte): Char;
Procedure SetAttrAt(AAttr, AX, AY: Byte);
Procedure SetCharAt(ACh: Char; AX, AY: Byte);
Procedure ClearEOL;
Procedure Delay (MS: Word);
Procedure LowVideo;
Procedure NormVideo;
Function  CurrentFG: Byte;
Function  CurrentBG: Byte;
Procedure TextBackground(CL: Byte);
Procedure HighVideo;
Procedure TextColor(CL: Byte);
Function  FgColor(Attr:Byte):Byte;
Function  BgColor(Attr:Byte):Byte;
Procedure GotoXY(X,Y:Byte);
Procedure GotoX(X:Byte);
Procedure GotoY(Y:Byte);
Procedure ClrScr;

Procedure WriteXY (X, Y, A: Byte; Text: String);
Procedure WriteXYPipe (X, Y, Attr:Byte; Text: String); OverLoad;
Procedure WriteXYPipe (X, Y, Attr,Len: Byte; Text: String); OverLoad;
Procedure WritePipe (Text: String);
Procedure WriteLn; Overload;
Procedure WriteLn(S:String); Overload;
Procedure Write(S:String);
Procedure WriteChar(Ch:Char);

Procedure CenterLine(S:String; L:byte);

Function UTF8Encode(Ch : LongInt) : String;
Procedure HalfBlock;
Procedure CursorBlock;

Procedure ClearArea(x1,y1,x2,y2:Byte;C:Char);

Function  CTRLC:Boolean;
Function  WhereY:Byte;
Function  WhereX:Byte;
Procedure SetTextAttr(A:Byte);
Function  GetTextAttr:Byte;
Function  KeyPressed : Boolean;
Function  ReadKey : Char;
Procedure ClearImage(Var Img:TScreenBuf);
procedure enable_ansi_unix;
procedure AppendText(Filename,S:String);
Function  FirstFileParam(Ind:Byte):Byte;

Function LoadTheme(Var Th:TConTheme; fn:string):Boolean;
Function SaveTheme(Th:TConTheme; fn:string):Boolean;

implementation

{$IFDEF FPC}
  uses
    keyboard,
    crt,
  {$IFDEF UNIX}
  baseunix,
  {$ENDIF}
  xdatetime,xstrings;
{$EndIF}

Function UTF8Encode(Ch : LongInt) : String;
Const
  CP437_Map : Array[0..255] of LongInt = (
    $2007, $263A, $263B, $2665, $2666, $2663, $2660, $2022,
    $25D8, $25CB, $25D9, $2642, $2640, $266A, $266B, $263C,
    $25BA, $25C4, $2195, $203C, $00B6, $00A7, $25AC, $21A8,
    $2191, $2193, $2192, $2190, $221F, $2194, $25B2, $25BC,
    $0020, $0021, $0022, $0023, $0024, $0025, $0026, $0027,
    $0028, $0029, $002a, $002b, $002c, $002d, $002e, $002f,
    $0030, $0031, $0032, $0033, $0034, $0035, $0036, $0037,
    $0038, $0039, $003a, $003b, $003c, $003d, $003e, $003f,
    $0040, $0041, $0042, $0043, $0044, $0045, $0046, $0047,
    $0048, $0049, $004a, $004b, $004c, $004d, $004e, $004f,
    $0050, $0051, $0052, $0053, $0054, $0055, $0056, $0057,
    $0058, $0059, $005a, $005b, $005c, $005d, $005e, $005f,
    $0060, $0061, $0062, $0063, $0064, $0065, $0066, $0067,
    $0068, $0069, $006a, $006b, $006c, $006d, $006e, $006f,
    $0070, $0071, $0072, $0073, $0074, $0075, $0076, $0077,
    $0078, $0079, $007a, $007b, $007c, $007d, $007e, $007f,
    $00c7, $00fc, $00e9, $00e2, $00e4, $00e0, $00e5, $00e7,
    $00ea, $00eb, $00e8, $00ef, $00ee, $00ec, $00c4, $00c5,
    $00c9, $00e6, $00c6, $00f4, $00f6, $00f2, $00fb, $00f9,
    $00ff, $00d6, $00dc, $00a2, $00a3, $00a5, $20a7, $0192,
    $00e1, $00ed, $00f3, $00fa, $00f1, $00d1, $00aa, $00ba,
    $00bf, $2310, $00ac, $00bd, $00bc, $00a1, $00ab, $00bb,
    $2591, $2592, $2593, $2502, $2524, $2561, $2562, $2556,
    $2555, $2563, $2551, $2557, $255d, $255c, $255b, $2510,
    $2514, $2534, $252c, $251c, $2500, $253c, $255e, $255f,
    $255a, $2554, $2569, $2566, $2560, $2550, $256c, $2567,
    $2568, $2564, $2565, $2559, $2558, $2552, $2553, $256b,
    $256a, $2518, $250c, $2588, $2584, $258c, $2590, $2580,
    $03b1, $00df, $0393, $03c0, $03a3, $03c3, $00b5, $03c4,
    $03a6, $0398, $03a9, $03b4, $221e, $03c6, $03b5, $2229,
    $2261, $00b1, $2265, $2264, $2320, $2321, $00f7, $2248,
    $00b0, $2219, $00b7, $221a, $207f, $00b2, $25a0, $00a0);

Begin
  If (Ch <= $FF) Then Begin
    Case Ch Of
       $00, $1B, $0D, $0A, $07, $08, $09 : { NOP } ;
    Else
      Ch := CP437_Map[Ch];
    End;
  End;

  If (Ch <= $7F) Then Begin
    Result := Chr(Ch);
    Exit;
  End;

  If (Ch <= $7FF) Then Begin
    Result := Chr($C0 or ((Ch shr  6) and $1F)) +
              Chr($80 or  (Ch         and $3F));
    Exit;
  End;

  If (Ch <= $FFFF) Then Begin
    Result := Chr($E0 or ((Ch shr 12) and $0F)) +
              Chr($80 or ((Ch shr  6) and $3F)) +
              Chr($80 or  (Ch         and $3F));
    Exit;
  End;

  If (ch <= $10FFFF) Then Begin
    Result := Chr($F0 or ((Ch shr 18) and $07)) +
              Chr($80 or ((Ch shr 12) and $3F)) +
              Chr($80 or ((Ch shr  6) and $3F)) +
              Chr($80 or  (Ch         and $3F));
    Exit;
  End;

  Result := ' ';
End;

Procedure ScrollBufferUp;
Var
  i:byte;
Begin
  For i:=2 to 25 Do Move(Buffer[i][1],Buffer[i-1][1],80 * Sizeof(TCharInfo));
  for i:=1 to 80 do begin
    buffer[25][i].ch:=#32;
    buffer[25][i].Attr:=7;
  end;
End;

Function ParseMCI (Code: String) : Boolean;
Var
  A : LongInt;
Begin
  Result       := True;

  Case Code[1] of
    '[' : Case Code[2] of
            'U' : GotoY(WhereY-1); // Cursor Up
            'D' : GotoY(WhereY+1); // Cursor Down
            'L' : GotoX(WhereX-1); //Cursor Left
            'R' : GotoX(WhereX+1); // Cursor Right
            'S' : GotoX(1); // Go to then begining of the line
            'C' : GotoX(ScreenWidth Div 2); // Go to center in line
          End;
    'B' : Case Code[2] of
            'E' : System.Write(^G);
          End;
    'C' : Case Code[2] of
            'L' : ClrScr;
            'R' : Writeln;
            'P' : ClearEOL;
          End;
    'D' : Case Code[2] of
            'E' : Delay(500);
            'S' : Delay(1000);
            'M' : Delay(70);
                  
          End;
    'O' : Case Code[2] of
            'S' : {$IFDEF LINUX}Write('Unix');{$ENDIF}{$IFDEF WINDOWS}Write('Windows');{$ENDIF}{$IFDEF ARM}Write('ARM');{$ENDIF}
          End;
    'P' : Case Code[2] of
            'A' : ReadKey;  // Pause
            'I' : Write(seth);  // Write Pipe symbol/seth
            'M' : Begin writepipe(More);ReadKey;End;  // Pause with More prompt
          End;
    'S' : Case Code[2] of
            'S' : SaveScreen(Image);
          End;
    'R' : Case Code[2] of
            'S' : RestoreScreen(Image);
          End;
    'T' : Case Code[2] of
            'D' : Write(FormatDate(CurDateDT , 'dd/mm/yyyy'));
            'T' : Write(FormatDate(CurDateDT , 'hh:II'));
          End;
    'X' : Case Code[2] of
            'X' : Write(' ');
          End;
  Else
    Result := False;
  End;
End;

Function strMCILen (Str: String) : Byte;
Var
  A : Byte;
Begin
  Repeat
    A := Pos(Seth, Str);
    If (A > 0) and (A < Length(Str) - 1) Then
      Delete (Str, A, 3)
    Else
      Break;
  Until False;

  strMCILen := Length(Str);
End;

Procedure WriteChar (Ch: Char);
Begin
  Case Ch of
    #10 : Begin
            If WhereY<25 Then WriteLn Else
              Begin
                ScrollBufferUp;
                WriteLn;
              End;
          End;
    #13 : GotoXY(1,WhereY);
  Else Begin
      Buffer[WhereY][WhereX].Attr  := CRT.TextAttr;
      Buffer[WhereY][WhereX].Ch := Ch;
      if isUTF then System.Write(UTF8Encode(ord(Ch))) else System.Write(Ch);
    End;
  End;
End;

Procedure WriteLn; Overload;
Begin
  System.WriteLn;
End;

Procedure WriteLn(S:String); Overload;
Begin
  Write(S+CRLF);
End;

Procedure Write(S:String);
Var
  d,l,y,x:byte;
Begin
  
  if WhereX+Length(S)+1 > 80 Then Begin 
    L:=80-WhereX+1;
      for d:=0 to l-1 Do Begin
        WriteChar(S[d+1]);
      End;
      If WhereY=25 Then Begin
        System.Writeln;
        ScrollBufferUp;
      End Else
        System.Writeln;
      for d:=l to Length(s) Do Begin
        WriteChar(S[d]);
      End;
    End Else Begin
      L:=Length(S);
      for d:=0 to l-1 Do Begin
        WriteChar(S[d+1]);
      End;  
    End; 
End;

Procedure ClrScr;
Var
  x,y:Byte;
Begin
  CRT.ClrScr;
  For y:=1 to 25 Do
    For x:=1 to 80 Do Begin
      Buffer[y][x].Ch:=' ';
      Buffer[y][x].Attr:=CRT.TextAttr;
    End;
End;

Function GetAttrAt(AX, AY: Byte): Byte;
Begin
  if ((AX < 1) OR (AX > 80) OR (AY < 1) OR (AY > 25)) then
  Begin
    Result := 7;
    Exit;
  End;
  Result:= Buffer[AY][AX].Attr;
End;

Function GetCharAt(AX, AY: Byte): Char;
Begin

  if ((AX < 1) OR (AX > 80) OR (AY < 1) OR (AY > 25)) then
  Begin
    GetCharAt := ' ';
    Exit;
  End;

  GetCharAt := Buffer[AY][AX].Ch;
End;

Procedure GotoXY(X,Y:Byte);
Begin
  Crt.GotoXY(x,y);
End;

Procedure GotoX(X:Byte);
Begin
  Crt.GotoXY(x,WhereY);
End;

Procedure GotoY(Y:Byte);
Begin
  Crt.GotoXY(WhereY,y);
End;

Function WhereX:Byte;
Begin
 Result := Crt.WhereX;
End;

Function WhereY:Byte;
Begin
 Result := Crt.WhereY;
End;

Procedure RestoreScreen(screenBuf: TScreenBuf);
Var
  x,y:Byte;
Begin
  For y:=1 to 25 Do
    For x:=1 to 80 Do Begin
      CRT.TextAttr:=screenBuf[y][x].Attr;
      gotoxy(x,y);
      if isUTF then System.Write(UTF8Encode(ord(screenBuf[y][x].Ch))) else System.Write(screenBuf[y][x].Ch);
    End;
End;

Procedure SaveScreen(var screenBuf: TScreenBuf);
Begin
  Move(Buffer,ScreenBuf,SizeOf(TScreenBuf));
End;

Procedure SetAttrAt(AAttr, AX, AY: Byte);
Begin
  if ((AX < 1) OR (AX > 80) OR (AY < 1) OR (AY > 25)) then Exit;
  Buffer[AY][AX].Attr := AAttr;
End;


Procedure SetCharAt(ACh: Char; AX, AY: Byte);
Begin
  if ((AX < 1) OR (AX > 80) OR (AY < 1) OR (AY > 25)) then Exit;
  Buffer[AY][AX].Ch := ACh;
End;

Function CurrentFG: Byte;
Begin
  CurrentFG := CRT.TextAttr and $0f;
End;

Function CurrentBG: Byte;
Begin
  CurrentBG := (CRT.TextAttr and $f0) shr 4;
End;

Procedure TextColor(CL: Byte);
Begin
  CRT.TextAttr := CRT.TextAttr and $F0;
  CRT.TextAttr := CRT.TextAttr or (CL and $0F);
End;

Procedure TextBackground(CL: Byte);
Begin
  Crt.TextAttr := CRT.TextAttr and $0F;
  CRT.TextAttr := CRT.TextAttr or (CL shl 4);
End;
  
Function BgColor(Attr:Byte):Byte;
Begin
  BgColor:=Attr div 16;
End;

Function FgColor(Attr:Byte):Byte;
Begin
  FgColor:=Attr mod 16;
End;

Procedure WriteXY (X, Y, A: Byte; Text: String);
Var
  d,l:Byte;
Begin
  GotoXY(X,Y);
  If WhereX+Length(Text)>80 Then l:=80-WhereX Else l:=Length(Text);
  
  For d:=0 to l-1 Do Begin
    Buffer[y][x+d].Ch:=Text[d+1];
    crt.textattr:=a;
    writechar(Text[d+1]);
  End;
End;

Procedure WriteXYPipe (X, Y, Attr: Byte; Text: String);
Var
  Count   : Byte;
  Code    : String[2];
  CodeNum : Byte;
  OldAttr : Byte;
  OldX    : Byte;
  OldY    : Byte;
Begin
  OldAttr := crt.TextAttr;
  OldX    := WhereX;
  OldY    := WhereY;

  GotoXY (X, Y);
  SetTextAttr (Attr);

  Count := 1;

  While Count <= Length(Text) Do Begin
    If Text[Count] = Seth Then Begin
      Code    := Copy(Text, Count + 1, 2);
      CodeNum := Str2Int(Code);

      If (Code = '00') or (CodeNum > 0) Then Begin
        Inc (Count, 2);
        If CodeNum in [00..15] Then
          SetTextAttr (CodeNum + ((CRT.TextAttr SHR 4) AND 7) * 16)
        Else
          SetTextAttr ((CRT.TextAttr AND $F) + (CodeNum - 16) * 16);
      End Else if parsemci(code)=false then 
      Begin
        writechar(Text[Count]);
        
      End Else Inc(Count,2);
    End Else Begin
      writechar(Text[Count]);
    End;
    Inc (Count);
  End;
  SetTextAttr(OldAttr);
  GotoXY (OldX, OldY);
End;


Procedure WriteXYPipe (X, Y, Attr,Len: Byte; Text: String); OverLoad;
Begin
  WriteXYPipe(X,Y,Attr,StrPadR(Text,Len+(Len-StrMCILen(Text)),' '));
End;

Procedure WritePipe (Text: String);
begin
  writexypipe(wherex,wherey,textattr,text);
end;

Procedure ClearEOL;
Var x:byte;
Begin
  Crt.ClrEOL;
  for x:=WhereX to 80 Do WriteChar(' ');
End;

Procedure CenterLine(S:String; L:byte);
Begin
  WriteXYPipe((40-strMCILen(s) div 2),L,7,strMCILen(s),S);
End;

Procedure CursorBlock;
Begin
  {$IFDEF Linux}
  Writeln (#27 + '[?112c'+#7);
  {$ENDIF}
End;

Procedure HalfBlock;
Begin
  {$IFDEF Linux}
  Writeln (#27 + '[?2c'+#7);
  {$ENDIF}
End;

Procedure SetTextAttr(A:Byte);
Begin
  CRT.TextAttr:=A;
End;

Function GetTextAttr:Byte;
Begin
  Result:=CRT.TextAttr;
End;

Function CTRLC:Boolean;
Begin
  CTRLC := False;
  if KeyPressed then            //  <--- CRT function to test key press
    if ReadKey = ^C then        // read the key pressed
      begin
        writeln('Ctrl-C pressed');
        CTRLC := True;
      end;
End;
{
Procedure WritePipe (Text: String);
Var
  Count   : Byte;
  Code    : String[2];
  CodeNum : Byte;

Begin
 

  Count := 1;

  While Count <= Length(Text) Do Begin
    If Text[Count] = Screen.Seth Then Begin
      Code    := Copy(Text, Count + 1, 2);
      CodeNum := Str2Int(Code);

      If (Code = '00') or (CodeNum > 0) Then Begin
        Inc (Count, 2);
        If CodeNum in [00..15] Then
          SetTextAttr (CodeNum + ((Screen.TextAttr SHR 4) AND 7) * 16)
        Else
          SetTextAttr ((Screen.TextAttr AND $F) + (CodeNum - 16) * 16);
      End Else if parsemci(code)=false then 
      Begin
        screen.BufAddStr(Text[Count]);
      End Else Inc(Count,2);
    End Else Begin
      screen.BufAddStr(Text[Count]);
    End;

    Inc (Count);
  End;
End;}

Procedure ClearArea(x1,y1,x2,y2:Byte;C:Char);
Var
  i,d:Byte;
Begin
  For i := y1 to y2 Do
    WriteXY(x1,i,CRT.TextAttr,StringOfChar(c,x2-x1));
End;

Function KeyPressed : Boolean;
Begin
  Result:=crt.KeyPressed
End;
{
Function KeyWait (MS: LongInt) : Boolean;
Begin
  Result:=Keyboard.KeyWait(MS);
End;}

Function ReadKey : Char;
Begin
  //Result:=Keyboard.ReadKey
  Result:=Crt.ReadKey;
End;
{
Function    FAltKey (Ch : Char) : Byte;    
Begin
  Result:=Keyboard.FAltKey(Ch);
End;}

Procedure Delay (MS: Word);
Begin
  {$IFDEF WIN32}
    Sleep(MS);
  {$ENDIF}

  {$IFDEF UNIX}
    fpSelect(0, Nil, Nil, Nil, MS);
  {$ENDIF}
End;

Procedure HighVideo;
Begin
  TextColor(TextAttr Or $08);
End;

Procedure LowVideo;
Begin
  TextColor(TextAttr And $77);
End;

Procedure NormVideo;
Begin
  TextColor(7);
  TextBackGround(0);
End;

procedure enable_ansi_unix;
begin
  Write(#27 + '(U' + #27 + '[0m');
end; 

procedure AppendText(Filename,S:String);
Var
  f:text;
Begin
  Assign(f,filename);
  {$I-}Append(f);{$I+}
  If IOResult<>0 THen Rewrite(f);
  System.WriteLn(F,S);
  Close(f);
End;

Function FirstFileParam(Ind:Byte):Byte;
Var
  i:byte;
  f:file;
begin
  Result:=0;
  If Paramcount=0 Then Exit;
  If Ind>=ParamCount Then Exit;
  i:=Ind;
  While i<=ParamCount Do Begin
    Assign(f,paramstr(1));
    {$I-}Reset(f);{$I+}
    If IoResult=0 Then Begin
      Close(f);
      Result:=i;
      Break;
    End;
  i:=i+1;
  End;
end;  

Procedure ClearImage(Var Img:TScreenBuf);
Var
  y,x:byte;
Begin
    For Y:=1 to 25 Do 
      For X:=1 to 80 Do Begin
        //nilchar(Data[y][x]);
        img[y][x].Ch:=chr(32);
        img[y][x].Attr:=7;
      End;
End;

Function LoadTheme(Var Th:TConTheme; fn:string):Boolean;
var
  f:file;
Begin
  result:=false;
  assign(f,fn);
  {$I-}reset(f,1);{$I+}
  if ioresult<>0 then exit;
  blockread(f,th,sizeof(th));
  close(f);
  result:=true;
End;

Function SaveTheme(Th:TConTheme; fn:string):Boolean;
var
  f:file;
Begin
  result:=false;
  assign(f,fn);
  {$I-}rewrite(f,1);{$I+}
  if ioresult<>0 then exit;
  blockwrite(f,th,sizeof(th));
  close(f);
  result:=true;
End;

procedure displayansi(fn:string;d:integer);
const
  AnsiColors: Array[0..7] of Integer = (0, 4, 2, 6, 1, 5, 3, 7);
var
  done:boolean;
  key:char;
  f:file;
  b:char;
  c:char;
  cnt:byte;
  savex:byte;
  savey:byte;
  lastch:char;
  
  procedure ansicoloring(s:string);
  var
    i:byte;
    cl:byte;
    w:byte;
    Colour:byte;
  begin
    for i:= 1 to cnt do begin
      w:=str2int(strwordget(i,s,';'));
      case w of
            0: TextAttr:=7;
            1: begin
                 cl:=textattr mod 16;
                 if cl < 8 then cl:=cl+8;
                 textcolor(cl);
               end;
            7: TextAttr:= ((TextAttr and $70) shr 4) + ((TextAttr and $07) 
                          shl 4);
            8: TextAttr:= 0; { Video Off }
       30..37: Begin
                    Colour := AnsiColors[w - 30];
                    if (TextAttr mod 16 > 7) then
                       Inc(Colour, 8);
                    TextColor(Colour);
               End;
       40..47: TextBackground(AnsiColors[w - 40]);
       End;
    end;
  end;
  
  procedure linesdown(s:string);
  var
    y:byte;
  begin
    try
      y:=str2int(s);
    except
      y:=1;
    end;
    gotoxy(1,wherey+y);
  end;
  
  procedure linesup(s:string);
  var
    y:byte;
  begin
    try
      y:=str2int(s);
    except
      y:=1;
    end;
    gotoxy(1,wherey-y);
  end;
  
  procedure cursorup(s:string);
  var
    y:byte;
  begin
    try
      y:=str2int(s);
    except
      y:=1;
    end;
    gotoxy(wherex,wherey-y);
  end;
  
  procedure cursordown(s:string);
  var
    y:byte;
  begin
    try
      y:=str2int(s);
    except
      y:=1;
    end;
    gotoxy(wherex,wherey+y);
  end;
  
  procedure cursorleft(s:string);
  var
    x:byte;
  begin
    try
      x:=str2int(s);
    except
      x:=1;
    end;
    gotoxy(wherex-x,wherey);
  end;
  
  procedure cursorright(s:string);
  var
    x:byte;
  begin
    try
      x:=str2int(s);
    except
      x:=1;
    end;
    gotoxy(wherex+x,wherey);
  end;
  
  procedure gotocol(s:string);
  var
    x:byte;
  begin
    try
      x:=str2int(s);
    except
      x:=wherex;
    end;
    gotoxy(x,wherey);
  end;
  
  procedure cursormove(s:string);
  Begin
    gotoxy(str2int(strwordget(2,s,';')),str2int(strwordget(1,s,';')));
  End;
  
  procedure insertspaces(s:string);
  var
    j,a:byte;
  begin
    try
      a:=str2int(strwordget(1,s,';'));
    except
      a:=1;
    end;
    for j:=1 to a do write(' ');
  end;
  
  procedure clearline(s:string);
  var j,a:byte;
  begin
    try
      a:=str2int(strwordget(1,s,';'));
    except
      a:=0;
    end;
    case a of
      0: for j:=wherex to 80 do write(' ');
      1: for j:=1 to wherex do write(' ');
      2: begin ClrEOL;Gotoxy(1,wherey);End;
    end;
  end;
  
  procedure erasechars(s:string);
  var
    j,a:byte;
  begin
    try
      a:=str2int(strwordget(1,s,';'));
    except
      a:=1;
    end;
    for j:=1 to a do write(' ');
  end;
  
  procedure repeatlastchar(s:string);
  var
    j,a:byte;
  begin
    try
      a:=str2int(strwordget(1,s,';'));
    except
      a:=1;
    end;
    for j:=1 to a do write(lastch);
  end;
  
  procedure gotoline(s:string);
  var
    j,a:byte;
  begin
    try
      a:=str2int(strwordget(1,s,';'));
    except
      a:=1;
    end;
    gotoxy(wherex,a);
  end;
  
  
  procedure doesc;
  var
    buf:string[255];
    j:byte;
  begin
    buf:='';
    blockread(f,b,1);
    while length(buf)<255 do begin
      blockread(f,b,1);
      buf:=buf+b;
      if b in 
      ['m','J','H','f','A','B','C','D','u','s','K','@','F','E','G','X','b','d'] 
      then break;
    end;
    if length(buf)<1 then exit;
    cnt:=strwordcount(buf,';');
    c:=buf[length(buf)];
    //writeln('C:> '+buf +'C: '+c);
    delete(buf,length(buf),1);
    //writeln(buf+'=='+int2str(cnt));
    case c of 
      'd': gotoline(buf);
      'b': repeatlastchar(buf);
      'X': erasechars(buf);
      'm': ansicoloring(buf);
      'K': clearline(buf);
      'A': cursorup(buf);
      'B': cursordown(buf);
      'C': cursorright(buf);
      'D': cursorleft(buf);
      'E': linesdown(buf);
      'F': linesup(buf);
      'G': gotocol(buf);
  'f','H': cursormove(buf);
      's': begin
            savex:=wherex;
            savey:=wherey;
           end;
      'u' : gotoxy(savex,savey);
      '@' : insertspaces(buf);
      'J' : begin
              if str2int(strwordget(1,buf,';')) = 2 then ClrScr;
            End;
    end;
  end;
  
  
begin
  savex:=1;
  savey:=1;
  assign(f,fn);
  reset(f,1);
  while (not eof(f)) and (done=false) do begin
    blockread(f,b,1);
    if keypressed then begin
      key:=readkey;
      Case key of
        '+' : d := d + 3;
        '-' : begin
                d := d - 3;
                if d<0 then d:=0;
              end;
        '*' : d := 20;
        '/' : d := 5;
        #27 : Done:=true;
      End;
    end;
    case b of
    #27: doesc;
    #13: delay(d);
    else 
        write(b);
        lastch:=b;
    end;
  end;
  close(f);
end;


Begin
  {$IFDEF UNIX}
  ScreenHeight:=Crt.ScreenHeight;
  ScreenWidth:=Crt.ScreenWidth;
  {$ELSE}
  ScreenHeight:=25;
  ScreenWidth:=80;
  {$ENDIF}
  WindMax:=Crt.WindMax;
  WindMin:=crt.WindMin;
  FillByte(Image,SizeOf(Image),0);
  FillByte(Buffer,SizeOf(Buffer),0);
  Seth := '|';
  With Theme Do Begin
    Shadow     := True;
    ShadowAttr := 8;
    FrameType  := 6;
    Box3D      := True;
    BoxAttr    := 15 + 7 * 16;
    BoxAttr2   := 8  + 7 * 16;
    BoxAttr3   := 15 + 7 * 16;
    BoxAttr4   := 8  + 7 * 16;
    HeadAttr   := 15 + 1 * 16;
    HeadType   := 0;
    Emboss     :=false;
    ScrAttr    :=7;
    GetStrBG   :=8;
    GetStrFG   :=7;
    GetStrCh   :=179;
    
    cLo          := 0  + 7 * 16;
    cHi          := 11 + 1 * 16;
    cData        := 1  + 7 * 16;
    cLoKey       := 15 + 7 * 16;
    cHiKey       := 15 + 1 * 16;
    cField1      := 15 + 1 * 16;
    cField2      := 7  + 1 * 16;
    HelpX        := 5;
    HelpY        := 25;
    HelpColor    := 15;
    HelpSize     := 79;
  End;
  More:='Press a Key to continue...';
End.
