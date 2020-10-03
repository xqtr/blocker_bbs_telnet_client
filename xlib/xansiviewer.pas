Unit xansiviewer;
{$MODE objfpc}

Interface

Uses
  xStrings;
  
Const 
  mysMaxMsgLines = 5000;  

Type
  RecMessageLine = Array[1..80] of Record
                     Ch   : Char;
                     Attr : Byte;
                   End;

  AnsiImage = Array[1..mysMaxMsgLines] of RecMessageLine;
  // make this a pointer...

  TMsgBaseAnsi = Class
    GotAnsi  : Boolean;
    GotPipe  : Boolean;
    PipeCode : String[2];
    Owner    : Pointer;
    Data     : AnsiImage;
    Code     : String;
    Lines    : Word;
    CurY     : Word;
    Escape   : Byte;
    SavedX   : Byte;
    SavedY   : Byte;
    CurX     : Byte;
    Attr     : Byte;

    Procedure   SetFore (Color: Byte);
    Procedure   SetBack (Color: Byte);
    Procedure   ResetControlCode;
    Function    ParseNumber (Var Line: String) : Integer;
    Function    AddChar (Ch: Char) : Boolean;
    Procedure   MoveXY (X, Y: Word);
    Procedure   MoveUP;
    Procedure   MoveDOWN;
    Procedure   MoveLEFT;
    Procedure   MoveRIGHT;
    Procedure   MoveCursor;
    Procedure   CheckCode (Ch: Char);
    Procedure   ProcessChar (Ch: Char);
    
    Constructor Create (O: Pointer; Msg: Boolean);
    Destructor  Destroy; Override;
    Function    ProcessBuf (Var Buf; BufLen: Word) : Boolean;
    Procedure   WriteLine (Y,Line: Word; Flush: Boolean);
    Procedure   DrawLine (Y, Line: Word; Flush: Boolean);
    Procedure   DrawPage (pStart, pEnd, pLine: Word);
    Procedure   Clear;
    Function    GetLineText (Line: Word) : String;
    Procedure   SetLineColor (Attri, Line: Word);
    Procedure   RemoveLine (Line: Word);
    Procedure   PrintAll;
  End;
  
  RecPercent = Record
    BarLength : Byte;
    LoChar    : Char;
    LoAttr    : Byte;
    HiChar    : Char;
    HiAttr    : Byte;
    Format    : Byte;
    StartY    : Byte;
    Active    : Boolean;
    StartX    : Byte;
    LastPos   : Byte;
    Reserved  : Array[1..3] of Byte;
  End;


  
  Procedure AnsiViewer (FName: String); OverLoad;
  Procedure AnsiViewer (FName: String;SBAttr:Byte); OverLoad;
  Function AnsiGotoXY (X, Y: Byte) : String;

Implementation

Uses 
  XCrt,
  xfileio,
  xAnsi;
  
Function DrawPercent (Bar: RecPercent; Part, Whole: SmallInt; Var Percent: SmallInt) : String;
Var
  FillSize : Byte;
  Attr     : Byte;
Begin
  Attr := Screen.TextAttr;

  Screen.TextAttr := 0;  // kludge to force it to return full ansi codes

  If Part > Whole Then Part := Whole;

  If (Part = 0) or (Whole = 0) Then Begin
    FillSize := 0;
    Percent  := 0;
  End Else Begin
    FillSize := Round(Part / Whole * Bar.BarLength);
    Percent  := Round(Part / Whole * 100);
  End;

  {Result := AttrToAnsi(Bar.HiAttr) + strRep(Bar.HiChar, FillSize) +
            AttrToAnsi(Bar.LoAttr) + strRep(Bar.LoChar, Bar.BarLength - FillSize) +
            Pipe2Ansi(16) + AttrToAnsi(Attr);}
  Result := strRep(Bar.HiChar, FillSize) + strRep(Bar.LoChar, Bar.BarLength - FillSize);
End;

Procedure AnsiViewer (FName: String);
Begin
  AnsiViewer(FName,15+16);
End;

Procedure AnsiViewer (FName: String; SBAttr:Byte);
Var
  Buf      : Array[1..4096] of Char;
  BufLen   : LongInt;
  TopLine  : LongInt;
  WinSize  : LongInt;
  Ansi     : TMsgBaseAnsi;
  AFile    : File;
  Ch       : Char;
  FN       : String;
  Speed    : Byte;
  Str      : String;
  Sauce    : RecSauceInfo;
  Bar      : RecPercent;
  Done     : Boolean = False;
  Per : SmallInt;

  Procedure Update;
  Begin
      
      //WriteXY(1,25,15+16,(strPadR(Int2Str(Per), 80, ' ')));
      Ansi.DrawPage (1, WinSize, TopLine);
      
      WriteXY(1,25,SBAttr,StrPadL('['+DrawPercent(Bar, TopLine + WinSize - 1, Ansi.Lines, Per)+']        ',79,' '));
      WriteXY(75,25,SBAttr,StrPadL(int2str(per)+'%',4,' '));
      WriteXY(1,25,SBAttr,'File: '+Copy(Fn,Length(Fn)-20,20));      
      //gotoXY(1,25);
      //Write();
  End;

  Procedure ReDraw;
  Begin
    WinSize := 24;
    TopLine := 1;
    Update;
  End;

Begin
  Speed    := 6;
  FN       := FName;

  Screen.TextAttr:=7;
  
  If Not FileExist(FN) Then Exit;
  
  
  With Bar Do Begin
    BarLength := 25;
    LoChar    :=' ';
    LoAttr    :=8;
    HiChar    :=chr(254);
    HiAttr    :=15;
    Format    :=1;
    StartY    :=25;
    Active    :=True;
    StartX    :=1;
    LastPos   :=1;
    //Reserved  :=[1,1,1];
  End;

  ReadSauceInfo(FN, Sauce);

  Ansi := TMsgBaseAnsi.Create(nil, False);
  ansi.clear;

  Assign  (AFile, FN);
  ioReset (AFile, 1, fmReadWrite + fmDenyNone);

  While Not Eof(AFile) Do Begin
    ioBlockRead (AFile, Buf, SizeOf(Buf), BufLen);
    If Ansi.ProcessBuf (Buf, BufLen) Then Break;
  End;
  
  Close (AFile);

  //ansi.printall;
  //exit;
  
  ReDraw;

  Repeat
    Ch := UpCase(ReadKey);

    If Ch=#0 Then Begin
      Ch := Readkey;
      Case Ch of
        #71 : If TopLine > 1 Then Begin
                TopLine := 1;

                Update;
              End;
        #72 : If TopLine > 1 Then Begin
                Dec (TopLine);

                Update;
              End;
        #73,
        #75 : If TopLine > 1 Then Begin
                Dec (TopLine, WinSize);

                If TopLine < 1 Then TopLine := 1;

                Update;
              End;
        #79 : If TopLine + WinSize <= Ansi.Lines Then Begin
                TopLine := Ansi.Lines - WinSize + 1;

                Update;
              End;
        #80 : If TopLine + WinSize <= Ansi.Lines Then Begin
                Inc (TopLine);

                Update;
              End;
        #77,
        #81 : If TopLine < Ansi.Lines - WinSize Then Begin
                Inc (TopLine, WinSize);

                If TopLine + WinSize > Ansi.Lines Then TopLine := Ansi.Lines - WinSize + 1;

                Update;
              End;
      End;
    End Else
      Case Ch of
        #32 : Begin
                Screen.TextAttr:=7;
                ClrScr;
                //OutFile(FN, False, Speed);
                DispFile(Fn,Speed);
                ReadKey;

                ReDraw;
              End;
        'P' : If TopLine < Ansi.Lines - WinSize Then Begin
                Inc (TopLine, WinSize);

                If TopLine + WinSize > Ansi.Lines Then TopLine := Ansi.Lines - WinSize + 1;

                Update;
              End;
        'N',
        #13 : Begin
                If Per=100 Then Done:=True;
                If TopLine < Ansi.Lines - WinSize Then Begin
                  Inc (TopLine, WinSize);
                  If TopLine + WinSize > Ansi.Lines Then TopLine := Ansi.Lines - WinSize + 1;

                  Update;
                End;
              End;

        #27 : Done := True;
      End;
  Until Done;

  Ansi.Free;

  GotoXY (1, 25);
End;

Constructor TMsgBaseAnsi.Create (O: Pointer; Msg: Boolean);
Begin
  Inherited Create;

  Owner := O;
  Clear;
End;

Destructor TMsgBaseAnsi.Destroy;
Begin
  Inherited Destroy;
End;

Procedure TMsgBaseAnsi.Clear;
Begin
  Lines    := 1;
  CurX     := 1;
  CurY     := 1;
  Attr     := 7;
  GotAnsi  := False;
  GotPipe  := False;
  PipeCode := '';

  FillChar (Data, SizeOf(Data), 0);

  ResetControlCode;
End;

Procedure TMsgBaseAnsi.ResetControlCode;
Begin
  Escape := 0;
  Code   := '';
End;

Procedure TMsgBaseAnsi.SetFore (Color: Byte);
Begin
  Attr := Color + ((Attr SHR 4) AND 7) * 16;
End;

Procedure TMsgBaseAnsi.SetBack (Color: Byte);
Begin
  Attr := (Attr AND $F) + Color * 16;
End;

Function TMsgBaseAnsi.AddChar (Ch: Char) : Boolean;
Begin
  AddChar := False;

  Data[CurY][CurX].Ch   := Ch;
  Data[CurY][CurX].Attr := Attr;

  If CurX < 80 Then
    Inc (CurX)
  Else Begin
    If CurY = mysMaxMsgLines Then Begin
      AddChar := True;
      Exit;
    End Else Begin
      CurX := 1;
      Inc (CurY);
    End;
  End;
End;

Procedure TMsgBaseAnsi.PrintAll;
Var
  A,B:integer;
Begin
  a:=1;
  while a<=Lines do Begin
    For b:=1 to 79 do begin
      Screen.TextAttr:=Data[a][b].Attr;
      case Data[a][b].Ch of
      #0,#255: write(' ');
      else
          Write(Data[a][b].Ch);
      End;
   
    end;
  a:=a+1;
  End;
End;

Function TMsgBaseAnsi.ParseNumber (Var Line: String) : Integer;
Var
  A    : Integer;
  B    : LongInt;
  Str1 : String;
  Str2 : String;
Begin
  Str1 := Line;

  Val(Str1, A, B);

  If B = 0 Then
    Str1 := ''
  Else Begin
    Str2 := Copy(Str1, 1, B - 1);

    Delete (Str1, 1, B);
    Val    (Str2, A, B);
  End;

  Line        := Str1;
  ParseNumber := A;
End;

Procedure TMsgBaseAnsi.MoveXY (X, Y: Word);
Begin
  If X > 80             Then X := 80;
  If Y > mysMaxMsgLines Then Y := mysMaxMsgLines;

  CurX := X;
  CurY := Y;
End;

Procedure TMsgBaseAnsi.MoveCursor;
Var
  X : Byte;
  Y : Byte;
Begin
  X := ParseNumber(Code);
  Y := ParseNumber(Code);

  If X = 0 Then X := 1;
  If Y = 0 Then Y := 1;

  MoveXY (X, Y);

  ResetControlCode;
End;

Procedure TMsgBaseAnsi.MoveUP;
Var
  NewPos : Integer;
  Offset : Integer;
Begin
  Offset := ParseNumber (Code);

  If Offset = 0 Then Offset := 1;

  If (CurY - Offset) < 1 Then
    NewPos := 1
  Else
    NewPos := CurY - Offset;

  MoveXY (CurX, NewPos);
  ResetControlCode;
End;

Procedure TMsgBaseAnsi.MoveDOWN;
Var
  NewPos : Byte;
Begin
  NewPos := ParseNumber (Code);

  If NewPos = 0 Then NewPos := 1;

  MoveXY (CurX, CurY + NewPos);

  ResetControlCode;
End;

Procedure TMsgBaseAnsi.MoveLEFT;
Var
  NewPos : Integer;
  Offset : Integer;
Begin
  Offset := ParseNumber (Code);

  If Offset = 0 Then Offset := 1;

  If CurX - Offset < 1 Then
    NewPos := 1
  Else
    NewPos := CurX - Offset;

  MoveXY (NewPos, CurY);

  ResetControlCode;
End;

Procedure TMsgBaseAnsi.MoveRIGHT;
Var
  NewPos : Integer;
  Offset : Integer;
Begin
  Offset := ParseNumber(Code);

  If Offset = 0 Then Offset := 1;

  If CurX + Offset > 80 Then Begin
    NewPos := (CurX + Offset) - 80;
    Inc (CurY);
  End Else
    NewPos := CurX + Offset;

  MoveXY (NewPos, CurY);

  ResetControlCode;
End;

Procedure TMsgBaseAnsi.CheckCode (Ch: Char);
Var
  Temp1 : Byte;
  Temp2 : Byte;
Begin
  Case Ch of
    '0'..'9', ';', '?' : Code := Code + Ch;
    'H', 'f'      : MoveCursor;
    'A'           : MoveUP;
    'B'           : MoveDOWN;
    'C'           : MoveRIGHT;
    'D'           : MoveLEFT;
    'J'           : Begin
                      {ClearScreenData;}
                      ResetControlCode;
                    End;
    'K'           : Begin
                      Temp1 := CurX;
                      For Temp2 := CurX To 80 Do
                        AddChar(' ');
                      MoveXY (Temp1, CurY);
                      ResetControlCode;
                    End;
    'h'           : ResetControlCode;
    'm'           : Begin
                      While Length(Code) > 0 Do Begin
                        Case ParseNumber(Code) of
                          0 : Attr := 7;
                          1 : Attr := Attr OR $08;
                          5 : Attr := Attr OR $80;
                          7 : Begin
                                Attr := Attr AND $F7;
                                Attr := ((Attr AND $70) SHR 4) + ((Attr AND $7) SHL 4) + Attr AND $80;
                              End;
                          30: Attr := (Attr AND $F8) + 0;
                          31: Attr := (Attr AND $F8) + 4;
                          32: Attr := (Attr AND $F8) + 2;
                          33: Attr := (Attr AND $F8) + 6;
                          34: Attr := (Attr AND $F8) + 1;
                          35: Attr := (Attr AND $F8) + 5;
                          36: Attr := (Attr AND $F8) + 3;
                          37: Attr := (Attr AND $F8) + 7;
                          40: SetBack (0);
                          41: SetBack (4);
                          42: SetBack (2);
                          43: SetBack (6);
                          44: SetBack (1);
                          45: SetBack (5);
                          46: SetBack (3);
                          47: SetBack (7);
                        End;
                      End;

                      ResetControlCode;
                    End;
    's'           : Begin
                      SavedX := CurX;
                      SavedY := CurY;
                      ResetControlCode;
                    End;
    'u'           : Begin
                      MoveXY (SavedX, SavedY);
                      ResetControlCode;
                    End;
  Else
    ResetControlCode;
  End;
End;

Procedure TMsgBaseAnsi.ProcessChar (Ch: Char);
Begin
  If GotPipe Then Begin
    PipeCode := PipeCode + Ch;

    If Length(PipeCode) = 2 Then Begin

      Case Str2Int(PipeCode) of
        00..
        15 : SetFore(Str2Int(PipeCode));
        16..
        23 : SetBack(Str2Int(PipeCode) - 16);
      Else
        AddChar('|');
        AddChar(PipeCode[1]);
        AddChar(PipeCode[2]);
      End;

      GotPipe  := False;
      PipeCode := '';
    End;

    Exit;
  End;

  Case Escape of
    0 : Begin
          Case Ch of
            #27 : Escape := 1;
            #9  : MoveXY (CurX + 8, CurY);
            #12 : {Edit.ClearScreenData};
          Else
            If Ch = '|' Then
              GotPipe := True
            Else
              AddChar (Ch);

            ResetControlCode;
          End;
        End;
    1 : If Ch = '[' Then Begin
           Escape  := 2;
           Code    := '';
           GotAnsi := True;
         End Else
           Escape := 0;
    2 : CheckCode(Ch);
  Else
    ResetControlCode;
  End;
End;

Function TMsgBaseAnsi.ProcessBuf (Var Buf; BufLen: Word) : Boolean;
Var
  Count  : Word;
  Buffer : Array[1..4096] of Char Absolute Buf;
Begin
  Result := False;

  For Count := 1 to BufLen Do Begin
    If CurY > Lines Then Lines := CurY;
    Case Buffer[Count] of
      #10 : If CurY = mysMaxMsgLines Then Begin
              Result  := True;
              GotAnsi := False;
              Break;
            End Else Begin
              CurY:=CurY+1;
              CurX := 1;
            End;
              
      #13 : CurX := 1;
      #26 : Begin
              Result := True;
              Break;
            End;
    Else
      ProcessChar(Buffer[Count]);
    End;
  End;
End;

Procedure TMsgBaseAnsi.WriteLine (Y, Line: Word; Flush: Boolean);
Var
  Count : Byte;
Begin
  If Line > Lines Then Exit;
  GotoXY(1, Y);
  For Count := 1 to 79 Do Begin
    Screen.TextAttr:=Data[Line][Count].Attr;
    If Data[Line][Count].Ch in [#0, #255] Then
      Write(' ')
    Else
      Write(Data[Line][Count].Ch);
  End;

  Write(#13);
  

  If Flush Then BufFlush;

  //Inc (PausePos);
End;

Procedure TMsgBaseAnsi.DrawLine (Y, Line: Word; Flush: Boolean);
Var
  Count : Byte;
Begin
  BufAddStr(AnsiGotoXY(1, Y));

  If Line > Lines Then Begin
    BufAddStr(AttrToAnsi(7) + #27 + '[K');
  End Else
    For Count := 1 to 80 Do Begin
      BufAddStr (AttrToAnsi(Data[Line][Count].Attr));
      If Data[Line][Count].Ch in [#0, #255] Then
        BufAddStr(' ')
      Else
        BufAddStr (Data[Line][Count].Ch);
    End;

  If Flush Then BufFlush;
End;

Procedure TMsgBaseAnsi.DrawPage (pStart, pEnd, pLine: Word);
Var
  Count : Word;
Begin
  For Count := pStart to pEnd Do Begin
    //DrawLine (Count, pLine, False);
    GotoXY(1,Count);
    WriteLine (Count, pLine, True);
    Inc      (pLine);
  End;

  BufFlush;
End;

Function TMsgBaseAnsi.GetLineText (Line: Word) : String;
Var
  Count : Word;
Begin
  Result := '';

  If Line > Lines Then Exit;

  For Count := 1 to 80 Do
    Result := Result + Data[Line][Count].Ch;
End;

Procedure TMsgBaseAnsi.SetLineColor (Attri, Line: Word);
Var
  Count : Word;
Begin
  For Count := 1 to 80 Do
    Data[Line][Count].Attr := Attri;
End;

Procedure TMsgBaseAnsi.RemoveLine (Line: Word);
Var
  Count : Word;
Begin
  For Count := Line to Lines - 1 Do
    Data[Count] := Data[Count + 1];

  Dec (Lines);
End;

Function AnsiGotoXY (X, Y: Byte) : String;
Begin

  If X = 0 Then X := WhereX;
  If Y = 0 Then Y := WhereY;

  Result := #27 + '[' + Int2Str(Y) + ';' + Int2Str(X) + 'H';
End;

End.
