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

Unit xcrt;

interface
  uses
{$IFDEF WIN32}
    Windows,
{$EndIF}
{$IFDEF UNIX}
    Unix,
{$EndIF}
  m_output,
  m_input,
  m_types;

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
  //KeyCtrlC  = #3; 
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
  
  
  TOutput = m_output.TOutput;  
  TInput  = m_input.Tinput;
  TConsoleImageRec = m_types.TConsoleImageRec;
  TScreenBuf = TConsoleImageRec;
  //TScreenBuf = m_types.TScreenBuf;
  
  var
    FileModeReadWrite: Integer;
    TextModeRead: Integer;
    TextModeReadWrite: Integer;
    Theme : TConTheme;
    
    Screen : TOutput;
    Keyboard : TInput;
    
    WindMax:Byte;
    WindMin:Byte;
    ScreenHeight:Byte;
    ScreenWidth:Byte;
    Image:TScreenBuf;
    More:String;

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
Procedure WriteStr(S:String);

Procedure CenterLine(S:String; L:byte);

Procedure HalfBlock;
Procedure CursorBlock;
Procedure BufFlush;
Procedure BufAddStr (Str: String);

Procedure ClearArea(x1,y1,x2,y2:Byte;C:Char);

Function  CTRLC:Boolean;
Function  WhereY:Byte;
Function  WhereX:Byte;
Procedure SetTextAttr(A:Byte);
Function  GetTextAttr:Byte;
Function  AttrToAnsi (Attr: Byte) : String;

Function  KeyWait (MS: LongInt) : Boolean;
Function  KeyPressed : Boolean;
Function  ReadKey : Char;
Function  FAltKey (Ch : Char) : Byte;
Procedure ClearImage(Var Img:TScreenBuf);
procedure enable_ansi_unix;
procedure AppendText(Filename,S:String);
Function  FirstFileParam(Ind:Byte):Byte;

Function LoadTheme(Var Th:TConTheme; fn:string):Boolean;
Function SaveTheme(Th:TConTheme; fn:string):Boolean;

implementation

{$IFDEF FPC}
  uses
    crt,
  {$IFDEF UNIX}
  baseunix,
  {$ENDIF}
  xdatetime,xstrings;
{$EndIF}

{$IFDEF WIN32}
  var
    StdOut: THandle;
{$EndIF}

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
            'I' : Write(Screen.seth);  // Write Pipe symbol/seth
            'M' : Begin screen.writepipe(More);ReadKey;End;  // Pause with More prompt
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
    A := Pos(Screen.Seth, Str);
    If (A > 0) and (A < Length(Str) - 1) Then
      Delete (Str, A, 3)
    Else
      Break;
  Until False;

  strMCILen := Length(Str);
End;

Function AttrToAnsi (Attr: Byte) : String;
Begin
  Result:=Screen.AttrToAnsi(Attr);
End;

Procedure WriteLn; Overload;
Begin
  Screen.WriteLine('');
End;

Procedure WriteLn(S:String); Overload;
Begin
  Screen.WriteLine(S);
End;

Procedure WriteStr(S:String);
Begin
  Screen.WriteStr(S);
End;

Procedure Write(S:String);
Begin
  Screen.WriteStr(S);
End;

Procedure ClrScr;
Begin
  Screen.ClearScreen
End;

Function GetAttrAt(AX, AY: Byte): Byte;
Begin
  Result:=Screen.ReadAttrXY (AX, AY);
End;

Function GetCharAt(AX, AY: Byte): Char;
Begin

  if ((AX < 1) OR (AX > 80) OR (AY < 1) OR (AY > 25)) then
  Begin
    GetCharAt := ' ';
    Exit;
  End;

  GetCharAt := Screen.Buffer.data[AY][AX].UnicodeChar;
End;

Procedure GotoXY(X,Y:Byte);
Begin
  Screen.GotoXY(x,y);
End;

Procedure GotoX(X:Byte);
Begin
  Screen.GotoXY(x,WhereY);
End;

Procedure GotoY(Y:Byte);
Begin
  Screen.GotoXY(WhereY,y);
End;

Function WhereX:Byte;
Begin
 Result := Screen.WhereX;
End;

Function WhereY:Byte;
Begin
 Result := Screen.WhereY;
End;

Procedure RestoreScreen(screenBuf: TScreenBuf);
Begin
  Screen.PutScreenImage(Screenbuf);
End;

Procedure SaveScreen(var screenBuf: TScreenBuf);
Begin
  Screen.GetScreenImage (screenBuf);
End;

Procedure SetAttrAt(AAttr, AX, AY: Byte);
Begin
  if ((AX < 1) OR (AX > 80) OR (AY < 1) OR (AY > 25)) then Exit;
  Screen.Buffer.data[AY][AX].Attributes := AAttr;
  BufFlush;
End;


Procedure SetCharAt(ACh: Char; AX, AY: Byte);
Begin
  if ((AX < 1) OR (AX > 80) OR (AY < 1) OR (AY > 25)) then Exit;
  Screen.Buffer.data[AY][AX].UnicodeChar := ACh;
  BufFlush;
End;

Function CurrentFG: Byte;
Begin
  CurrentFG := Screen.TextAttr and $0f
End;

Function CurrentBG: Byte;
Begin
  CurrentBG := (Screen.TextAttr and $f0) shr 4     { shift right beyotch }
End;

Procedure TextColor(CL: Byte);
  Begin
  With Screen Do Begin
  TextAttr := TextAttr and $F0;
  TextAttr := TextAttr or (CL and $0F);
  End;
End;

Procedure TextBackground(CL: Byte);
  Begin
  With Screen Do Begin
  TextAttr := TextAttr and $0F;
  TextAttr := TextAttr or (CL shl 4);
  End;
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
Begin
  Screen.WriteXY(X,Y,A,Text);
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
  OldAttr := Screen.TextAttr;
  OldX    := WhereX;
  OldY    := WhereY;

  GotoXY (X, Y);
  SetTextAttr (Attr);

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
        write(Text[Count]);
        
      End Else Inc(Count,2);
    End Else Begin
      write(Text[Count]);
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
Begin
  Screen.ClearEOL;
End;

Procedure SetWindow (X1, Y1, X2, Y2: Byte; Home: Boolean);
Begin
  Screen.SetWindow(x1,y1,x2,y2,home);
End;

Procedure CenterLine(S:String; L:byte);
Begin
 Screen.WriteXYPipe((40-strMCILen(s) div 2),L,7,strMCILen(s),S);
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
  Screen.TextAttr:=A;
End;

Function GetTextAttr:Byte;
Begin
  Result:=Screen.TextAttr;
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

Procedure BufFlush;
Begin
  Screen.BufFlush;
End;

Procedure BufAddStr (Str: String);
Begin
  Screen.BufAddStr (Str);
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
    Screen.WriteXY(x1,i,Screen.TextAttr,StringOfChar(c,x2-x1));
End;

Function KeyPressed : Boolean;
Begin
  Result:=Keyboard.KeyPressed
End;

Function KeyWait (MS: LongInt) : Boolean;
Begin
  Result:=Keyboard.KeyWait(MS);
End;

Function ReadKey : Char;
Begin
  Result:=Keyboard.ReadKey
  //Result:=Crt.ReadKey;
End;

Function    FAltKey (Ch : Char) : Byte;    
Begin
  Result:=Keyboard.FAltKey(Ch);
End;

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
  TextColor(Screen.TextAttr Or $08);
End;

Procedure LowVideo;
Begin
  TextColor(Screen.TextAttr And $77);
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
        img.data[y][x].UnicodeChar:=chr(32);
        img.data[y][x].Attributes:=7;
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
