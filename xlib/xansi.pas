Unit xANSI;

{$MODE DELPHI}
{$EXTENDEDSYNTAX ON}
{$PACKRECORDS 1}

Interface
Uses xCrt;

Type
  TCoord=Record
    X:Byte;
    Y:Byte;
    A:Byte;
    W:Byte;
  End;
   
  
Type
  {RecSauceInfo = Record
    ID       : Array[1..5] of Char;
    Version  : Array[1..2] of Char;
    Title    : Array[1..35] of Char;
    Author   : Array[1..20] of Char;
    Group    : Array[1..20] of Char;
    Date     : Array[1..8] of Char;
    FileSize : Longint;
    DataType : Byte;
    FileType : Byte;
    TInfo1   : Word;
    TInfo2   : Word;
    TInfo3   : Word;
    TInfo4   : Word;
    Comments : Byte;
    Flags    : Byte;
    Filler   : Array[1..22] of Char;
  End;}
  
  RecSauceInfo = packed record
    ID:             array [1..5] of char; // "SAUCE"
    Version:        array [1..2] of byte;
    Title:          array [1..35] of char;
    Author:         array [1..20] of char;
    Group:          array [1..20] of char;
    Date:           array [1..8] of char;   // YYMMDD
    FileSIze :      Uint32;

    DataFileType :  UInt16;
    // see SAUCE_ below
    // if = SAUCE_CHAR_ANSI / ANSIMATION / ASCII
    // then
    //    TInfo1 = cols (0=use default)
    //    TInfo2 = rows (0=use default)
    //    TFlags = SAUSE_FLAG_*
    //    TInfoS = Font name (from SauceFonts pattern)

    TInfo1 :        Uint16;
    TInfo2 :        Uint16;
    TInfo3 :        Uint16;
    TInfo4 :        Uint16;
    Comments:       Byte;
    TFlags:         Byte;
    TInfoS:         array [1..22] of char;  // null terminated - FontName
  end;

  TSauceCommentHeader = packed record
    ID:         array [1..5] of char;   // "COMNT"
  end;

  TSauceComment = packed record
    ID:         array [1..64] of char;
  end;  
  
Var
  TemplatePos : Array of TCoord;

Procedure ANSIDisplay(F:string); Overload;
Procedure ANSIDisplay(S:String; BaudEmu:Integer); Overload;

procedure DispFile(fn:string); Overload;
procedure DispFile(fn:string;d:integer); Overload;

Procedure SaveScreenANSI(Filename: String; Image: TScreenBuf);
Function  ReadSauceInfo (FN: String; Var Sauce: RecSauceInfo) : Boolean;
Function  isSauce(S:RecSauceInfo):Boolean;

Function Pipe2Ansi (Color: Byte) : String;

Procedure GetTemplate(TC,TE,Rep:Char);
Procedure GetTemplateSimple(TC,Rep:Char);
Procedure FreeTemplate;
Procedure WriteTemplate(P:Byte; S:String);

Function stripc (Str: String) : String;

Implementation

Uses
  xfileio,xstrings,classes;
  
Var
  AnsiBracket: Boolean;
  AnsiBuffer: String;
  AnsiCnt: Byte;
  AnsiEscape: Boolean;
  AnsiParams: Array[1..10] of Integer;
  AnsiXY: Word;
  CC : Char;
  
Function AstrWordGet (Num: Byte; Str: String; Ch: Char) : String;
Var
  Count : Byte;
  Temp  : String;
  Start : Byte;
Begin
  astrWordGet := '';
  Count  := 1;
  Temp   := Str;
  
  If Pos(Ch,Str)<=0 Then Begin
    astrWordGet:=str;
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
    astrWordGet := Copy(Temp, 1, Pos(Ch, Temp) - 1)
  Else
    astrWordGet := Temp;
End;

procedure DispFile(fn:string); Overload;
Begin
  DispFile(fn,0);
End;

procedure DispFile(fn:string;d:integer); Overload;
const
  AnsiColors: Array[0..7] of Integer = (0, 4, 2, 6, 1, 5, 3, 7);
var
  done:boolean;
  f:file;
  b:char;
  c:char;
  cnt:byte;
  savex:byte;
  savey:byte;
  lastch:char;
  key:char;
  
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
            0: Screen.TextAttr:=7;
            1: begin
                 cl:=Screen.textattr mod 16;
                 if cl < 8 then cl:=cl+8;
                 textcolor(cl);
               end;
            7: Screen.TextAttr:= ((Screen.TextAttr and $70) shr 4) + ((Screen.TextAttr and $07) shl 4); { Reverse Video }
            8: Screen.TextAttr:= 0; { Video Off }
       30..37: Begin
                    Colour := AnsiColors[w - 30];
                    if (Screen.TextAttr mod 16 > 7) then
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
      2: begin ClearEOL;Gotoxy(1,wherey);End;
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
      if b in ['m','J','H','f','A','B','C','D','u','s','K','@','F','E','G','X','b','d'] then break;
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
  done:=false;
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
  
Procedure AnsiCommand(Cmd: Char);
var
  I: Integer;
  Colour: Integer;
Begin
     case Cmd of
          'A': Begin { Cursor Up }
                    if (AnsiParams[1] < 1) then
                       AnsiParams[1] := 1;
                    I := WhereY - AnsiParams[1];
                    if (I < 1) then
                       I := 1;
                    GotoXY(WhereX, I);
               End;
          'B': Begin { Cursor Down }
                    if (AnsiParams[1] < 1) then
                       AnsiParams[1] := 1;
                    I := WhereY + AnsiParams[1];
                    if (I > Hi(WindMax) - Hi(WindMin)) then
                       I := Hi(WindMax) - Hi(WindMin) + 1;
                    GotoXY(WhereX, I);
               End;
          'C': Begin { Cursor Right }
                    if (AnsiParams[1] < 1) then
                       AnsiParams[1] := 1;
                    I := WhereX + AnsiParams[1];
                    if (I > Lo(WindMax) - Lo(WindMin)) then
                       I := Lo(WindMax) - Lo(WindMin) + 1;
                    GotoXY(I, WhereY);
               End;
          'D': Begin { Cursor Left }
                    if (AnsiParams[1] < 1) then
                       AnsiParams[1] := 1;
                    I := WhereX - AnsiParams[1];
                    if (I < 1) then
                       I := 1;
                    GotoXY(I, WhereY);
               End;
     'f', 'H': Begin { Cursor Placement }
                    if (AnsiParams[1] < 1) then
                       AnsiParams[1] := 1;
                    if (AnsiParams[2] < 1) then
                       AnsiParams[2] := 1;
                    GotoXY(AnsiParams[2], AnsiParams[1]);
               End;
          'J': if (AnsiParams[1] = 2) then { Clear Screen }
                  ClrScr;
          'K': ClearEOL; { Clear To End Of Line }
          'm': Begin { Change Text Appearance }
                    if (AnsiParams[1] < 1) then
                       AnsiParams[1] := 0;
                    I := 0;
                    while (AnsiParams[I + 1] <> -1) do
                    Begin
                         Inc(I);
                         case AnsiParams[I] of
                              0: Screen.TextAttr:=7; { Normal Video }
                              1: HighVideo; { High Video }
                              7: Screen.TextAttr:= ((Screen.TextAttr and $70) shr 4) + ((Screen.TextAttr and $07) shl 4); { Reverse Video }
                              8: Screen.TextAttr:= 0; { Video Off }
                         30..37: Begin
                                      Colour := AnsiColours[AnsiParams[I] - 30];
                                      if (Screen.TextAttr mod 16 > 7) then
                                         Inc(Colour, 8);
                                      TextColor(Colour);
                                 End;
                         40..47: TextBackground(AnsiColours[AnsiParams[I] - 40]);
                         End;
                    End;
               End;
          's': AnsiXY := WhereX + (WhereY shl 8);
          'u': GotoXY(AnsiXY and $00FF, (AnsiXY and $FF00) shr 8);
     End;
End;
  
Procedure aWrite(ALine: String);
var
  Buf: String;
  I, J: Integer;
 
Begin
     Buf := '';
     for I := 1 to Length(ALine) do
     Begin
          if (ALine[I] = #27) then
          Begin
               AnsiBracket := False;
               AnsiEscape := True;
          End else
          if (AnsiEscape) and (ALine[I] = '[') then
          Begin
               AnsiBracket := True;
               AnsiBuffer := '';
               AnsiCnt := 1;
                 AnsiEscape := False;
               for J := Low(AnsiParams) to High(AnsiParams) do
                   AnsiParams[J] := -1;
          End else
          if (AnsiBracket) then
          Begin
               if (ALine[I] in ['?', '=', '<', '>', ' ']) then
                  { ignore these characters }
               else
               if (ALine[I] in ['0'..'9']) then
                  AnsiBuffer := AnsiBuffer + ALine[I]
               else
               if (ALine[I] = ';') then
               Begin
                    AnsiParams[AnsiCnt] := StrToIntDef(AnsiBuffer, 0);
                    AnsiBuffer := '';
                    Inc(AnsiCnt);
                    if (AnsiCnt > High(AnsiParams)) then
                       AnsiCnt := High(AnsiParams);
               End else
               Begin
                    Write(Buf);
                    Buf := '';
                    
                    AnsiParams[AnsiCnt] := StrToIntDef(AnsiBuffer, 0);
                    AnsiCommand(ALine[I]);
                    AnsiBracket := False;
               End;
          End else
              Buf := Buf + ALine[I];
     End;
     Write(Buf);
End;



Procedure ANSIDisplay(F:string); Overload;
Begin
  ANSIDisplay(F,0);
End;


Function xAnsi_Color (B : Byte; Attr: Byte) : String;
  Var
    S : String;
  Begin
    S          := '';
    Result := '';

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

    If B in [00..07] Then B := (Attr SHR 4) and 7 + 16;

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

    Result := S;
  End; 

Procedure SaveScreenANSI(Filename: String; Image: TScreenBuf);
  Var
    OutFile   : Text;
    FG,BG     : Byte;
    OldAT     : Byte;
    Outname   : String;
    Count1    : Integer;
    Count2    : Integer; 
    Prep      : Byte;
    LastLine  : Byte;
    LineLen   : Byte;
  Begin
    Outname := Filename; //GetSaveFileName(' Save Screen ','blockart.ans');
    if Outname <> '' then Begin
      Assign     (OutFile, Outname);
      //SetTextBuf (OutFile, Buffer);
      ReWrite    (OutFile);
      OldAt:=0;
      LastLine := 21;
      For Count1 := 2 to LastLine Do Begin
        //LineLen := GetLineLength(Image,Count1);
        For Count2 := 1 to 79 Do Begin
          If OldAt <> Image.data[Count1][Count2].Attributes then Begin
            FG := Image.data[Count1][Count2].Attributes mod 16;
            BG := 16 + (Image.data[Count1][Count2].Attributes div 16);
            system.Write(Outfile,xAnsi_Color(FG,Screen.TextAttr));
            system.Write(Outfile,xAnsi_Color(BG,Screen.TextAttr));
          End;
          system.Write(Outfile,Image.data[Count1][Count2].UnicodeChar);
          OldAt := Image.data[Count1][Count2].Attributes;
        End;
        If Count1 <> Lastline Then system.Write(Outfile,EOL);
      End;
      close(Outfile);
    End;
  
  End;
  
Function stripc (Str: String) : String;
Var
  Count : Byte;
  r:string = '';
Begin
  Count := 1;

  While Count <= Length(Str) Do Begin
   If Not (Str[Count] in [#32..#125]) Then
     //r:=r+' '
     r:=r
   Else r:=r+str[count];
  Inc(Count);
  end;
  

  stripc := r;
End;  
  
Function ReadSauceInfo (FN: String; Var Sauce: RecSauceInfo) : Boolean;
Var
  DF  : TFilestream;
  Str : String;
  Res : LongInt;
Begin
  Result := False;
  if not fileexist(fn) then exit;
  fillbyte(sauce,sizeof(sauce),0);
  df := TFilestream.Create(FN, fmOpenRead);
  try
    df.seek(-128,soFromEnd);
    res:=df.Read (Sauce, sizeof(sauce));
  finally
    df.free;
  End;
   
  //Writeln(stripc(sauce.title));
  Result := copy(sauce.id,1,5) = 'SAUCE';
End;

Function isSauce(S:RecSauceInfo):Boolean;
Begin
  Result := copy(S.id,1,5) = 'SAUCE';
End;

{
Function ReadSauceInfo (FN: String; Var Sauce: RecSauceInfo) : Boolean;
Var
  DF  : File;
  Str : String;
  Res : LongInt;
Begin
  Result := False;

  Assign (DF, FN);

  Reset (DF, 1);

  If IoResult <> 0 Then Exit;

  Seek (DF, FileSize(DF) - 130);

  If IoResult <> 0 Then Begin
    Close (DF);
    Exit;
  End;
  BlockRead (DF, Str[1], 130);
  Str[0] := #130;
  Close (DF);
  Res := Pos('SAUCE', Copy(Str, 1, 7));
  If Res > 0 Then Begin
    Result := True;

    Sauce.Title  := Replace(Copy(Str,  7 + Res, 35), #0, #32);
    Sauce.Author := Replace(Copy(Str, 42 + Res, 20), #0, #32);
    Sauce.Group  := Replace(Copy(Str, 62 + Res, 20), #0, #32);
  End;
End;
}

Procedure ANSIDisplay(S:String; BaudEmu:Integer); Overload;
    Const
      ColorTable : Array[30..47] of Byte = (0, 4, 2, 6, 1, 5, 3, 7, 0, 0, 0, 64, 32, 96, 16, 80, 48, 112);  

    Var
      Buffer   : Array[1..4096] of Char;
      dFile    : File;
      Ext      : String[4];
      Code     : String[2];
      dRead    : LongInt;
      Old      : Boolean;
      Options  : String;
      Str      : String;
       State   : Byte;
        SavedX  : Byte;
        SavedY  : Byte;
      A        : Word;
      Ch       : Char;
      Done     : Boolean;
      LastCh  : Char;
      WasValid : boolean ;
      
    Procedure ResetState;
    Begin
    State   := 0;
      Options := '';
    End;  

    Function ParseNumber : Integer;
    Var
      Res : LongInt;
      Str : String;
      r:integer;
    Begin
      Val (Options, r, Res);

      If Res = 0 Then
        Options := ''
      Else Begin
        Str := Copy(Options, 1, Pred(Res));

        Delete (Options, 1, Res);
        Val    (Str, r, Res);
      End;
      ParseNumber:=r;
    End;

    Procedure CursorMove;
    Var
      X : Byte;
      Y : Byte;
    Begin
      Y := ParseNumber;
      If Y = 0 Then Y := 1;
      X := ParseNumber;
      If X = 0 Then X := 1;
      Gotoxy (X, Y);
      ResetState;
    End;

    Procedure CursorUp;
    Var
      Y      : Integer;
      NewY   : Integer;
      Offset : Integer;
    Begin
      Offset := ParseNumber;
      If Offset = 0 Then Offset := 1;
      Y := wherey;
      If (Y - Offset) < 1 Then
        NewY := 1
      Else
        NewY := Y - Offset;
      gotoxy (wherex, NewY);
      ResetState;
    End;

    Procedure CursorDown;
    Var
      NewY : Byte;
    Begin
      NewY := ParseNumber;
      If NewY = 0 Then NewY := 1;
      NewY := NewY + wherey;
      gotoxy (wherex, NewY);
      ResetState;
    End;
    
    Procedure LineDown;
    Var
      NewY : Byte;
    Begin
      NewY := ParseNumber;
      If NewY = 0 Then NewY := 1;
      NewY := NewY + wherey;
      gotoxy (1, NewY);
      ResetState;
    End;

    Procedure CursorRight;
    Var
      X      : Integer;
      Offset : Integer;
    Begin
      Offset := ParseNumber;
      If Offset = 0 Then Offset := 1;
      X := wherex;
      If (X + Offset) > 80 Then Begin
         gotoxy (80, wherey);
        //Screen.WriteChar(#10);  // force lf incase we have to scroll
        //Screen.CursorXY(X + Offset - 80, Screen.CursorY);
      End Else
        gotoxy (x + offset, wherey);
      ResetState;
    End;

    Procedure CursorLeft;
    Var
      X      : Integer;
      NewX   : Integer;
      Offset : Integer;
    Begin
      Offset := ParseNumber;
      If Offset = 0 Then offset := 1;
      X := wherex;
      If (X - Offset) < 1 Then
        NewX := 1
      Else
        NewX := X - Offset;

      gotoXY (NewX, wherey);
      ResetState;
    End;

    Procedure ClearEOL;
    Begin
      Write(StrRep(' ',80-Wherex));
    End;
      
    Procedure CheckCode (Ch : Char);
    Var
      Temp : Byte;
    Begin
      Case Ch of
        'h'           : ResetState;
        '0'..'9',
        '?', ';'      : Options := Options + Ch;
        'H', 'f'      : CursorMove;
        'A'           : CursorUp;
        'B'           : CursorDown;
        'C'           : CursorRight;
        'D'           : CursorLeft;
        'E'           : LineDown;
        'G'           : Begin
                          GotoXY (1, WhereY);
                          ResetState;
                        End;
        'J'           : Begin
                          ClrScr;
                          ResetState;
                        End;
        'K'           : Begin
                          ClearEOL;
                          ResetState;
                        End;
        'm'           : Begin
                          If Length(Options) = 0 Then Begin
                            Screen.TextAttr := 7;

                            ResetState;
                          End Else
                          While Length(Options) > 0 Do Begin
                            Temp := ParseNumber;

                            Case Temp of
                              0 : Screen.TextAttr := 7;
                              1 : Screen.TextAttr := Screen.TextAttr OR $08;
                              5 : Screen.TextAttr := Screen.TextAttr OR $80;
                              7 : Begin
                                    Screen.TextAttr := Screen.TextAttr AND $F7;
                                    Screen.TextAttr := (((Screen.TextAttr AND $70) SHR 4) + ((Screen.TextAttr AND $7) SHL 4) + Screen.TextAttr AND $80);
                                  End;
                              30..
                              37: Screen.TextAttr := (Screen.TextAttr AND $F8 + ColorTable[Temp]);
                              40..
                              47: Screen.TextAttr := (Screen.TextAttr AND $F + ColorTable[Temp]);
                            End;
                          End;

                          ResetState;
                        End;
        'n'           : Begin
                          write(#27 + '[' + int2str(wherey) + ';' + int2str(wherex) + 'R');

                          ResetState;
                        End;
        's'           : Begin
                          SavedX := WhereX;
                          SavedY := WhereY;

                          ResetState;
                        End;
        'u'           : Begin
                          GotoXY (SavedX, SavedY);
                          ResetState;
                        End;
      Else
        ResetState;
      End;
    End;  
      
    Procedure ProcessBuf (Var Buf; BufLen : Word);
    Var
      Count : Word;
      Data  : Array[1..16384] of Char Absolute Buf;
    Begin
      For Count := 1 to BufLen Do Begin
        WasValid := False;

        Case State of
          0 : Begin
                Case Data[Count] of
                  #0  : ;
                  #27 : State := 1;
                  #9  : gotoxy (wherex + 8, wherey);
                  #12 : clrscr;
                  {$IFDEF UNIX}
                  #14,
                  #15 : write('X');
                  {$ENDIF}
                Else
                  write(Data[Count]);
                  WasValid := True;
                  State    := 0;
                End;
              End;
          1 : If Data[Count] = '[' Then Begin
                 State   := 2;
                 Options := '';
               End Else
                 State := 0;
           2 : CheckCode(Data[Count]);
         Else
            State   := 0;
            Options := '';
         End;
      End;
    End;

    Procedure Process (Ch : Char);
    Begin
      WasValid := False;

      Case State of
        0 : Begin
              Case Ch of
                #0  : ;
                #27 : State := 1;
                #9  : gotoXY (whereX + 8, whereY);
                #10 : Begin
                        If LastCh <> #13 Then
                          write(#13);Write(#10);
                      End;
                #12 : clrscr;
                {$IFDEF UNIX}
                #14,
                #15 : write('X');
                {$ENDIF}
              Else
                write(Ch);

                State    := 0;
                WasValid := True;
              End;
            End;
        1 : If Ch = '[' Then Begin
               State   := 2;
               Options := '';
             End Else
               State := 0;
         2 : CheckCode(Ch);
       Else
         ResetState;
       End;

       LastCh := Ch;
    End;

      Function GetChar : Char;
      Begin
        If A = dRead Then Begin
          BlockRead (dFile, Buffer, SizeOf(Buffer), dRead);
          A := 0;
          If dRead = 0 Then Begin
            Done      := True;
            Buffer[1] := #26;
          End;
        End;

        Inc (A);
        GetChar := Buffer[A];
      End;

      Function Ansi_Color (B : Byte) : String;
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

        If B in [00..07] Then B := (Screen.TextAttr SHR 4) and 7 + 16;

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

    Procedure OutStr (S: String);
    Begin
      ProcessBuf(S[1], Length(S));
    End;

Var
  
  c: char;
Begin
  Assign (dFile, S);
  Reset  (dFile, 1);

  If IoResult <> 0 Then Begin
    WriteLn('File ' + S + ' not found.');
    Exit;
  End; 

  //BaudEmu := str2int(ParamStr(2));
  Done    := False;
  A       := 0;
  dRead   := 0;
  Ch      := #0;

  While Not Done Do Begin
    Ch := GetChar;
    if keypressed then begin
      c:=readkey;
      Case C of
        '+' : BaudEmu := BaudEmu + 3;
        '-' : BaudEmu := BaudEmu - 3;
        '*' : BaudEmu := 20;
        '/' : BaudEmu := str2int(ParamStr(2));
        #27 : Done:=true;
      End;
    
    end;
    If BaudEmu > 0 Then Begin
      

      If A MOD BaudEmu = 0 Then delay(6);
    End;

    If Ch = #26 Then
      Break
    Else
    If Ch = #10 Then Begin
      Process(#10);
    End Else
    If Ch = '|' Then Begin
      Code := GetChar;
      Code := Code + GetChar;

      If Code = '00' Then OutStr(Ansi_Color(0)) Else
      If Code = '01' Then OutStr(Ansi_Color(1)) Else
      If Code = '02' Then OutStr(Ansi_Color(2)) Else
      If Code = '03' Then OutStr(Ansi_Color(3)) Else
      If Code = '04' Then OutStr(Ansi_Color(4)) Else
      If Code = '05' Then OutStr(Ansi_Color(5)) Else
      If Code = '06' Then OutStr(Ansi_Color(6)) Else
      If Code = '07' Then OutStr(Ansi_Color(7)) Else
      If Code = '08' Then OutStr(Ansi_Color(8)) Else
      If Code = '09' Then OutStr(Ansi_Color(9)) Else
      If Code = '10' Then OutStr(Ansi_Color(10)) Else
      If Code = '11' Then OutStr(Ansi_Color(11)) Else
      If Code = '12' Then OutStr(Ansi_Color(12)) Else
      If Code = '13' Then OutStr(Ansi_Color(13)) Else
      If Code = '14' Then OutStr(Ansi_Color(14)) Else
      If Code = '15' Then OutStr(Ansi_Color(15)) Else
      If Code = '16' Then OutStr(Ansi_Color(16)) Else
      If Code = '17' Then OutStr(Ansi_Color(17)) Else
      If Code = '18' Then OutStr(Ansi_Color(18)) Else
      If Code = '19' Then OutStr(Ansi_Color(19)) Else
      If Code = '20' Then OutStr(Ansi_Color(20)) Else
      If Code = '21' Then OutStr(Ansi_Color(21)) Else
      If Code = '22' Then OutStr(Ansi_Color(22)) Else
      If Code = '23' Then OutStr(Ansi_Color(23)) Else
      Begin
        Process('|');
        Dec (A, 2);
        Continue;
      End;
    End Else
      Process(Ch);
  End;

  Close (dFile);

End;

Function Pipe2Ansi (Color: Byte) : String;
Var
  CurFG  : Byte;
  CurBG  : Byte;
  Prefix : String[2];
Begin
  Result := '';

  CurBG  := (Screen.TextAttr SHR 4) AND 7;
  CurFG  := Screen.TextAttr AND $F;
  Prefix := '';

  If Color < 16 Then Begin
    If Color = CurFG Then Exit;

//    Console.TextAttr := Color + CurBG * 16;

    If (Color < 8) and (CurFG > 7) Then Prefix := '0;';
    If (Color > 7) and (CurFG < 8) Then Prefix := '1;';

    If Color > 7 Then Dec(Color, 8);

    Case Color of
      00: Result := #27 + '[' + Prefix + '30';
      01: Result := #27 + '[' + Prefix + '34';
      02: Result := #27 + '[' + Prefix + '32';
      03: Result := #27 + '[' + Prefix + '36';
      04: Result := #27 + '[' + Prefix + '31';
      05: Result := #27 + '[' + Prefix + '35';
      06: Result := #27 + '[' + Prefix + '33';
      07: Result := #27 + '[' + Prefix + '37';
    End;

    If Prefix <> '0;' Then
      Result := Result + 'm'
    Else
      Case CurBG of
        00: Result := Result + ';40m';
        01: Result := Result + ';44m';
        02: Result := Result + ';42m';
        03: Result := Result + ';46m';
        04: Result := Result + ';41m';
        05: Result := Result + ';45m';
        06: Result := Result + ';43m';
        07: Result := Result + ';47m';
      End;
  End Else Begin
    If (Color - 16) = CurBG Then Exit;

//    Console.TextAttr := CurFG + (Color - 16) * 16;

    Case Color of
      16: Result := #27 + '[40m';
      17: Result := #27 + '[44m';
      18: Result := #27 + '[42m';
      19: Result := #27 + '[46m';
      20: Result := #27 + '[41m';
      21: Result := #27 + '[45m';
      22: Result := #27 + '[43m';
      23: Result := #27 + '[47m';
    End;
  End;
End;

Procedure GetTemplateSimple(TC,Rep:Char);
Var
  x,y,w,a: Byte;
  tb : Boolean = False;
  c : Char;
Begin
  SetLength(TemplatePos,0);
  For y:= 1 to 25 Do
    For x := 1 to 80 Do Begin
    C := GetCharAt(x,y);
      If C = TC Then Begin
        If TB Then Begin
          TemplatePos[High(TemplatePos)].W := TemplatePos[High(TemplatePos)].W + 1;
        End Else Begin
          TB:=True;
          SetLength(TemplatePos,Length(TemplatePos)+1);
          TemplatePos[High(TemplatePos)].X := X;
          TemplatePos[High(TemplatePos)].Y := Y;
          TemplatePos[High(TemplatePos)].A := GetAttrAt(x,y);
          TemplatePos[High(TemplatePos)].W := 1;
        End;
      WriteXY(x,y,TemplatePos[High(TemplatePos)].A,Rep);
      End Else If (C <> TC) And (TB=True) Then TB:=False;
    End;
End;

Procedure GetTemplate(TC,TE,Rep:Char);
Var
  x,y,w,a,p: Byte;
  c : Char;
  TB : boolean = false;
Begin
  SetLength(TemplatePos,0);
  SetLength(TemplatePos,26);
  y:=1;
  x:=1;
  CC := Rep;
  while y < 26 Do Begin
    While x < 81 Do Begin
      C := GetCharAt(x,y);
      If C = TC Then Begin
        p:=Ord(LoCase(GetCharAt(x+1,y)))-97;
        TemplatePos[p].X := X;
        TemplatePos[p].Y := Y;
        TemplatePos[p].A := GetAttrAt(x,y);
        TemplatePos[p].W := 1;
        WriteXY(x,y,TemplatePos[p].A,Rep);
        x:=x+1;
        WriteXY(x,y,TemplatePos[p].A,Rep);
        tb:=true
      End Else If (C = TE) and (tb=true) Then Begin
        tb:=false;
        TemplatePos[p].W := x-TemplatePos[p].X+1;
      End;
      x:=x+1;
    End;
    y:=y+1;x:=1;
  End;
End;

Procedure FreeTemplate;
Begin
  SetLength(TemplatePos,0);
End;

Procedure WriteTemplate(P:Byte; S:String);
Begin
  With TemplatePos[p] Do Begin
    If w=1 Then WriteXY(x,y,a,S)
      Else WriteXY(x,y,a,StrpadR(S,w,CC));
    
  End;
End;

Initialization
//Var
// d:byte;
Begin
     AnsiBracket := False;
     AnsiBuffer := '';
     AnsiCnt := 1;
     AnsiEscape := False;
     AnsiXY := $0101;
End;

Finalization
Begin
  FreeTemplate;
End;

End.
