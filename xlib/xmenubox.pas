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

Unit xMenuBox;
{$MODE objfpc}
Interface

Uses
  xStrings,xCrt;

Const
  BoxFrameType : Array[1..8] of String[8] =
        ('ÚÄ¿³³ÀÄÙ',
         'ÉÍ»ººÈÍ¼',
         'ÖÄ·ººÓÄ½',
         'ÕÍ¸³³ÔÍ¾',
         'ÛßÛÛÛÛÜÛ',
         'ÛßÜÛÛßÜÛ',
         '        ',
         '.-.||`-''');
         
Var
  
  {$IFNDEF NORMAL}
  Scr : TOutput;
  {$ENDIF}
  Inp : TInput;         

Type
  TMenuBox = Class
    Image      : TScreenBuf;
    HideImage  : TScreenBuf;
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
    Header     : String;
    WasOpened  : Boolean;
    Emboss     : Boolean;

    Constructor Create;
    Destructor  Destroy; Override;
    Procedure   Open (X1, Y1, X2, Y2: Byte);
    Procedure   Close;
    Procedure   Hide;
    Procedure   Show;
  End;

  TMenuListStatusProc = Procedure (Num: Word; Str: String);
  TMenuListSearchProc = Procedure (Var Owner: Pointer; Str: String);

  TMenuListBoxRec = Record
    Name   : String;
    Tagged : Byte;                     { 0 = false, 1 = true, 2 = never }
  End;

  TMenuList = Class
    List       : Array[1..10000] of ^TMenuListBoxRec;
    Box        : TMenuBox;
    HiAttr     : Byte;
    LoAttr     : Byte;
    PosBar     : Boolean;
    Format     : Byte;
    LoChars    : String;
    HiChars    : String;
    ExitCode   : Char;
    Picked     : Integer;
    TopPage    : Integer;
    NoWindow   : Boolean;
    ListMax    : Integer;
    AllowTag   : Boolean;
    TagChar    : Char;
    TagKey     : Char;
    TagPos     : Byte;
    TagAttr    : Byte;
    Marked     : Word;
    StatusProc : TMenuListStatusProc;
    Width      : Integer;
    WinSize    : Integer;
    X1         : Byte;
    Y1         : Byte;
    NoInput    : Boolean;
    LastBarPos : Byte;
    SearchProc : TMenuListSearchProc;
    SearchX    : Byte;
    SearchY    : Byte;
    SearchA    : Byte;

    Constructor Create;
    Destructor  Destroy; Override;
    Procedure   Open (BX1, BY1, BX2, BY2: Byte);
    Procedure   Close;
    Procedure   Add (Str: String; B: Byte);
    Procedure   Get (Num: Word; Var Str: String; Var B: Boolean);
    Procedure   SetStatusProc (P: TMenuListStatusProc);
    Procedure   SetSearchProc (P: TMenuListSearchProc);
    Procedure   Clear;
    Procedure   Delete (RecPos : Word);
    Procedure   UpdatePercent;
    Procedure   UpdateBar (X, Y: Byte; RecPos: Word; IsHi: Boolean);
    Procedure   Update;
  End;
  

  
Procedure Box3d(x1,y1,x2,y2:Byte;Shadow:Boolean);
Procedure Box3dBorder(x1,y1,x2,y2:Byte;Shadow:Boolean);
Procedure WinBox(x1,y1,x2,y2,bg:Byte);
Procedure WinBoxBorder(x1,y1,x2,y2,bg:Byte);
Procedure ShadowBox(x1,y1,x2,y2,at:byte);
Procedure SmallBox(x,y:Byte);
Procedure WideBox(x,y:Byte);
Procedure MenuBox(x,y:Byte);
Procedure Selection(X: Byte; Text: String);

Implementation

Procedure DefListBoxSearch (Var Owner: Pointer; Str: String);
Begin
  If Str = '' Then
    Str := strRep(BoxFrameType[TMenuList(Owner).Box.FrameType][7], 17)
  Else Begin
    If Length(Str) > 15 Then
      Str := Copy(Str, Length(Str) - 15 + 1, 255);

    Str := '[' + Lower(Str) + ']';

    While Length(Str) < 17 Do
      Str := Str + BoxFrameType[TMenuList(Owner).Box.FrameType][7];
  End;

  WriteXY (
           TMenuList(Owner).SearchX,
           TMenuList(Owner).SearchY,
           TMenuList(Owner).SearchA,
           Str);
End;

Constructor TMenuBox.Create;
Begin
  Inherited Create;

  Shadow     := theme.shadow;
  ShadowAttr := theme.ShadowAttr;
  Header     := '';
  FrameType  := theme.FrameType;
  Box3D      := theme.Box3d;
  BoxAttr    := theme.BoxAttr;
  BoxAttr2   := theme.BoxAttr2;
  BoxAttr3   := theme.BoxAttr3;
  BoxAttr4   := theme.BoxAttr4;
  HeadAttr   := theme.HeadAttr;
  HeadType   := 0;
  WasOpened  := False;
  Emboss     := Theme.Emboss;

  FillChar(Image, SizeOf(TScreenBuf), 0);
End;

Destructor TMenuBox.Destroy;
Begin
  Inherited Destroy;
End;

Procedure TMenuBox.Open (X1, Y1, X2, Y2: Byte);
Var
  A  : Integer;
  B  : Integer;
  Ch : Char;
Begin
  If Not WasOpened Then
    If Shadow Then
      SaveScreen(Image)
    Else
      SaveScreen(Image);

  WasOpened := True;

  B := X2 - X1 - 1;

  If Not Box3D Then Begin
    BoxAttr2 := BoxAttr;
    BoxAttr3 := BoxAttr;
    BoxAttr4 := BoxAttr;
  End;
  If Not Emboss Then Begin
    WriteXY (X1, Y1, BoxAttr, BoxFrameType[FrameType][1] + strRep(BoxFrameType[FrameType][2], B));
    WriteXY (X2, Y1, BoxAttr4, BoxFrameType[FrameType][3]);

    For A := Y1 + 1 To Y2 - 1 Do Begin
      WriteXY (X1, A, BoxAttr, BoxFrameType[FrameType][4] + strRep(' ', B));
      WriteXY (X2, A, BoxAttr2, BoxFrameType[FrameType][5]);
    End;

    WriteXY (X1,   Y2, BoxAttr3, BoxFrameType[FrameType][6]);
    WriteXY (X1+1, Y2, BoxAttr2, strRep(BoxFrameType[FrameType][7], B) + BoxFrameType[FrameType][8]);
  End Else Begin
    WriteXY (X1, Y1, BoxAttr4, BoxFrameType[FrameType][1] + strRep(BoxFrameType[FrameType][2], B));
    WriteXY (X2, Y1, BoxAttr, BoxFrameType[FrameType][3]);

    For A := Y1 + 1 To Y2 - 1 Do Begin
      WriteXY (X1, A, BoxAttr2, BoxFrameType[FrameType][4] + strRep(' ', B));
      WriteXY (X2, A, BoxAttr, BoxFrameType[FrameType][5]);
    End;

    WriteXY (X1,   Y2, BoxAttr2, BoxFrameType[FrameType][6]);
    WriteXY (X1+1, Y2, BoxAttr3, strRep(BoxFrameType[FrameType][7], B) + BoxFrameType[FrameType][8]);
  End;

  If Header <> '' Then
    Case HeadType of
      0 : WriteXY (X1 + 1 + (B - Length(Header)) DIV 2, Y1, HeadAttr, Header);
      1 : WriteXY (X1 + 1, Y1, HeadAttr, Header);
      2 : WriteXY (X2 - Length(Header), Y1, HeadAttr, Header);
      3 : WriteXY (X1 , Y1, HeadAttr, StrPadC(Header,X2-X1+1,' '));
      4 : WriteXY (X1 , Y1, HeadAttr, StrPadR(Header,X2-X1+1,' '));
      5 : WriteXY (X1 , Y1, HeadAttr, StrPadL(Header,X2-X1+1,' '));
    End;

  If Shadow Then Begin
    For A := Y1 + 1 to Y2 + 1 Do
      For B := X2 + 1 to X2 + 2 Do Begin
        Ch := GetCharAt(B, A);
        WriteXY (B, A, ShadowAttr, Ch);
      End;

    A := Y2 + 1;
    For B := (X1 + 2) To (X2 + 2) Do Begin
      Ch := GetCharAt(B, A);
      WriteXY (B, A, ShadowAttr, Ch);
    End;
  End;
End;

Procedure TMenuBox.Close;
Begin
  If WasOpened Then RestoreScreen(Image);
End;

Procedure TMenuBox.Hide;
Begin
  SaveScreen(HideImage);
  RestoreScreen(Image);
End;

Procedure TMenuBox.Show;
Begin
  RestoreScreen(HideImage);
End;

Constructor TMenuList.Create;
Begin
  Inherited Create;

  Box        := TMenuBox.Create;
  ListMax    := 0;
  HiAttr     := 15 + 1 * 16;
  LoAttr     := 1  + 7 * 16;
  PosBar     := True;
  Format     := 0;
  LoChars    := #13#27;
  HiChars    := '';
  NoWindow   := False;
  AllowTag   := False;
  TagChar    := '*';
  TagKey     := #09;
  TagPos     := 0;
  TagAttr    := 15 + 7 * 16;
  Marked     := 0;
  Picked     := 1;
  NoInput    := False;
  LastBarPos := 0;
  StatusProc := NIL;
  SearchProc := NIL;
  SearchProc := @DefListBoxSearch;
  SearchX    := 0;
  SearchY    := 0;
  SearchA    := 0;
  TopPage    := 1;
End;

Procedure TMenuList.Clear;
Var
  Count : Word;
Begin
  For Count := 1 to ListMax Do
    Dispose(List[Count]);

  ListMax := 0;
  Marked  := 0;
End;

Procedure TMenuList.Delete (RecPos : Word);
Var
  Count : Word;
Begin
  If List[RecPos] <> NIL Then Begin
    Dispose (List[RecPos]);

    For Count := RecPos To ListMax - 1 Do
      List[Count] := List[Count + 1];

    Dec (ListMax);
  End;
End;

Destructor TMenuList.Destroy;
Begin
  Box.Free;
  Clear;
  Inherited Destroy;
End;

Procedure TMenuList.UpdateBar (X, Y: Byte; RecPos: Word; IsHi: Boolean);
Var
  Str  : String;
  Attr : Byte;
Begin
  If IsHi Then
    Attr := HiAttr
  Else
    Attr := LoAttr;

  If RecPos <= ListMax Then Begin
    Str := ' ' + List[RecPos]^.Name + ' ';

    Case Format of
      0 : Str := strPadR(Str, Width, ' ');
      1 : Str := strPadL(Str, Width, ' ');
      2 : Str := strPadC(Str, Width, ' ');
    End;
  End Else
    Str := strRep(' ', Width);

  WriteXY (X, Y, Attr, Str);

  If AllowTag Then
    If (RecPos <= ListMax) and (List[RecPos]^.Tagged = 1) Then
      WriteXY (TagPos, Y, TagAttr, TagChar)
    Else
      WriteXY (TagPos, Y, TagAttr, ' ');
End;

Procedure TMenuList.UpdatePercent;
Var
  NewPos : LongInt;
Begin
  If Not PosBar Then Exit;

  If (ListMax > 0) and (WinSize > 0) Then Begin
    NewPos := (Picked * WinSize) DIV ListMax;

    If Picked >= ListMax Then NewPos := Pred(WinSize);

    If (NewPos < 0) or (Picked = 1) Then NewPos := 0;

    NewPos := Y1 + 1 + NewPos;

    If LastBarPos <> NewPos Then Begin
      If LastBarPos > 0 Then
        WriteXY (X1 + Width + 1, LastBarPos, Box.BoxAttr2, #176);

      LastBarPos := NewPos;

      WriteXY (X1 + Width + 1, NewPos, Box.BoxAttr2, #178);
    End;
  End;
End;

Procedure TMenuList.Update;
Var
  Loop   : LongInt;
  CurRec : Integer;
Begin
  For Loop := 0 to WinSize - 1 Do Begin
    CurRec := TopPage + Loop;

    UpdateBar (X1 + 1, Y1 + 1 + Loop, CurRec, CurRec = Picked);
  End;

  UpdatePercent;
End;

Procedure TMenuList.Open (BX1, BY1, BX2, BY2 : Byte);

  Procedure DownArrow;
  Begin
    If Picked < ListMax Then Begin
      If Picked >= TopPage + WinSize - 1 Then Begin
        Inc (TopPage);
        Inc (Picked);

        Update;
      End Else Begin
        UpdateBar (X1 + 1, Y1 + Picked - TopPage + 1, Picked, False);

        Inc (Picked);

        UpdateBar (X1 + 1, Y1 + Picked - TopPage + 1, Picked, True);

        UpdatePercent;
      End;
    End;
  End;

Var
  Ch          : Char;
  Count       : Word;
  StartPos    : Word;
  EndPos      : Word;
  First       : Boolean;
  SavedRec    : Word;
  SavedTop    : Word;
  SearchStr   : String;
  LastWasChar : Boolean;
Begin
  If Not NoWindow Then
    Box.Open (BX1, BY1, BX2, BY2);

  If SearchX = 0 Then SearchX := BX1 + 2;
  If SearchY = 0 Then SearchY := BY2;
  If SearchA = 0 Then SearchA := Box.BoxAttr4;

  X1 := BX1;
  Y1 := BY1;

  If (Picked < TopPage) or (Picked < 1) or (Picked > ListMax) or (TopPage < 1) or (TopPage > ListMax) Then Begin
    Picked  := 1;
    TopPage := 1;
  End;

  Width   := BX2 - X1 - 1;
  WinSize := BY2 - Y1 - 1;
  TagPos  := X1 + 1;

  While Picked > TopPage + WinSize - 1 Do
    Inc (TopPage);

  If PosBar Then
    For Count := 1 to WinSize Do
      WriteXY (X1 + Width + 1, Y1 + Count, Box.BoxAttr2, #176);

  If NoInput Then Exit;

  Update;

  LastWasChar := False;
  SearchStr   := '';

  Repeat
    If Not LastWasChar Then Begin
      If Assigned(SearchProc) And (SearchStr <> '') Then
        SearchProc (Self, '');

      SearchStr := ''
    End Else
      LastWasChar := False;

    If Assigned(StatusProc) Then
      If ListMax > 0 Then
        StatusProc(Picked, List[Picked]^.Name)
      Else
        StatusProc(Picked, '');

    Ch := ReadKey;

    Case Ch of
      #00 : Begin
              Ch := ReadKey;

              If Pos(Ch, HiChars) > 0 Then Begin
                If SearchStr <> '' Then Begin
                  SearchStr := '';
                  If Assigned(SearchProc) Then
                    SearchProc(Self, SearchStr);
                End;

                ExitCode := Ch;

                Exit;
              End;

              Case Ch of
                #71 : If Picked > 1 Then Begin { home }
                        Picked  := 1;
                        TopPage := 1;
                        Update;
                      End;
                #72 : If (Picked > 1) Then Begin
                        If Picked <= TopPage Then Begin
                          Dec (Picked);
                          Dec (TopPage);

                          Update;
                        End Else Begin
                          UpdateBar (X1 + 1, Y1 + Picked - TopPage + 1, Picked, False);

                          Dec (Picked);

                          UpdateBar (X1 + 1, Y1 + Picked - TopPage + 1, Picked, True);

                          UpdatePercent;
                        End;
                      End;
                #73,
                #75 : If (TopPage > 1) or (Picked > 1) Then Begin
                        If Picked - WinSize > 1 Then Dec (Picked, WinSize) Else Picked := 1;
                        If TopPage - WinSize < 1 Then TopPage := 1 Else Dec(TopPage, WinSize);
                        Update;
                      End;
                #79 : If Picked < ListMax Then Begin
                        If ListMax > WinSize Then TopPage := ListMax - WinSize + 1;
                        Picked := ListMax;
                        Update;
                      End;
                #80 : DownArrow;
                #77,
                #81 : If (Picked <> ListMax) Then Begin
                        If ListMax > WinSize Then Begin
                          If Picked + WinSize > ListMax Then
                            Picked := ListMax
                          Else
                            Inc (Picked, WinSize);

                          Inc (TopPage, WinSize);

                          If TopPage + WinSize > ListMax Then TopPage := ListMax - WinSize + 1;
                        End Else Begin
                          Picked := ListMax;
                        End;

                        Update;
                      End;
              End;
            End;
    Else
      If AllowTag and (Ch = TagKey) and (List[Picked]^.Tagged <> 2) Then Begin
        If (List[Picked]^.Tagged = 1) Then Begin
          Dec (List[Picked]^.Tagged);
          Dec (Marked);
        End Else Begin
          List[Picked]^.Tagged := 1;
          Inc (Marked);
        End;

        DownArrow;
      End Else
      If Pos(Ch, LoChars) > 0 Then Begin
        If SearchStr <> '' Then Begin
          SearchStr := '';
          If Assigned(SearchProc) Then
            SearchProc(Self, SearchStr);
        End;

        ExitCode := Ch;
        Exit;
      End Else Begin
        If Ch <> #01 Then Begin
          If Ch = #25 Then Begin
            LastWasChar := False;
            Continue;
          End;

          If Ch = #8 Then Begin
            If Length(SearchStr) > 0 Then
              Dec(SearchStr[0])
            Else
              Continue;
          End Else
            If Ord(Ch) < 32 Then
              Continue
            Else
              SearchStr := SearchStr + UpCase(Ch);
        End;

        SavedTop    := TopPage;
        SavedRec    := Picked;
        LastWasChar := True;
        First       := True;
        StartPos    := Picked + 1;
        EndPos      := ListMax;

        If Assigned(SearchProc) Then
          SearchProc(Self, SearchStr);

        If StartPos > ListMax Then StartPos := 1;

        Count := StartPos;

        While (Count <= EndPos) Do Begin
          If Pos(Upper(SearchStr), Upper(List[Count]^.Name)) > 0 Then Begin

            While Count <> Picked Do Begin
              If Picked < Count Then Begin
                If Picked < ListMax Then Inc (Picked);
                If Picked > TopPage + WinSize - 1 Then Inc (TopPage);
              End Else
              If Picked > Count Then Begin
                If Picked > 1 Then Dec (Picked);
                If Picked < TopPage Then Dec (TopPage);
              End;
            End;
            Break;
          End;

          If (Count = ListMax) and First Then Begin
            Count    := 0;
            StartPos := 1;
            EndPos   := Picked - 1;
            First    := False;
          End;

          Inc (Count);
        End;

        If TopPage <> SavedTop Then
          Update
        Else
        If Picked <> SavedRec Then Begin
          UpdateBar (X1 + 1, Y1 + SavedRec - SavedTop + 1, SavedRec, False);
          UpdateBar (X1 + 1, Y1 + Picked - TopPage + 1, Picked, True);
          UpdatePercent;
        End;
      End;
    End;
  Until False;
End;

Procedure TMenuList.Close;
Begin
  If Not NoWindow Then Box.Close;
End;

Procedure TMenuList.Add (Str : String; B : Byte);
Begin
  Inc (ListMax);
  New (List[ListMax]);

  List[ListMax]^.Name   := Str;
  List[ListMax]^.Tagged := B;

  If B = 1 Then Inc(Marked);
End;

Procedure TMenuList.Get (Num : Word; Var Str : String; Var B : Boolean);
Begin
  Str := '';
  B   := False;

  If Num <= ListMax Then Begin
    Str := List[Num]^.Name;
    B   := List[Num]^.Tagged = 1;
  End;
End;

Procedure TMenuList.SetSearchProc (P: TMenuListSearchProc);
Begin
  SearchProc := P;
End;

Procedure TMenuList.SetStatusProc (P: TMenuListStatusProc);
Begin
  StatusProc := P;
End;


Procedure WinBox(x1,y1,x2,y2,bg:Byte);
Var
  i:Byte;
Begin
  SetTextAttr(15+bg*16);
  GotoXY(x1,y1);
  Write(StrRep('Ü',x2-x1+1));
  
  SetTextAttr(15+7*16);
  For i:=y1+1 to y2-1 Do Begin
    GotoXY(x1,i);
    Write('Ý');
  End;
  
  SetTextAttr(8+bg*16);
  GotoXY(x1,y2);
  Write(StrRep('ß',x2-x1+1));
  
  SetTextAttr(8+7*16);
  For i:=y1+1 to y2-1 Do Begin
    GotoXY(x2,i);
    Write('Þ');
  End;
  
  SetTextAttr(7*16);
  For i:=y1+1 to y2-1 Do Begin
    GotoXY(x1+1,i);
    Write(strrep(' ',x2-x1-1));
  End;
  
  SetTextAttr(15+16);
  GotoXY(x1,y1+1);
  Write('Ý');
  
  SetTextAttr(8+16);
  GotoXY(x2,y1+1);
  Write('Þ');
  GotoXY(x1+1,y1+1);
  Write(StrRep(' ',x2-x1-1));
  SetTextAttr(7);
  
End;

Procedure WinBoxBorder(x1,y1,x2,y2,bg:Byte);
Var
  B2 : TMenuBox;
Begin
  WinBox(x1,y1,x2,y2,bg);
  B2 := TMenuBox.Create;
  B2.Shadow:=False;
  B2.FrameType:=1;
  B2.Emboss:=True;
  B2.Open(x1+1,y1+2,x2-1,y2-1);
  B2.Destroy;
End;

Procedure Box3d(x1,y1,x2,y2:Byte;Shadow:Boolean);
Var
  i:Byte;
Begin
  SetTextAttr(15+7*16);
  GotoXY(x1,y1);
  Write(StrRep('ß',x2-x1));
  
  For i:=y1 to y2-1 Do Begin
    GotoXY(x1,i);
    Write('Û');
  End;
  
  SetTextAttr(8+7*16);
  GotoXY(x1,y2);
  Write(StrRep('Ü',x2-x1+1));
  SetTextAttr(8+7*16);
  For i:=y1+1 to y2 Do Begin
    GotoXY(x2,i);
    Write('Û');
  End;
  
  SetTextAttr(7*16);
  For i:=y1+1 to y2-1 Do Begin
    GotoXY(x1+1,i);
    Write(strrep(' ',x2-x1-1));
  End;
  
  WriteXY(x2,y1,8+7*16,'Ü');
  WriteXY(x1,y2,15+7*16,'ß');
End;

Procedure Box3dBorder(x1,y1,x2,y2:Byte;Shadow:Boolean);
Var
  B1 : TMenuBox;
  B2 : TMenuBox;
Begin
  B1 := TMenuBox.Create;
  B2 := TMenuBox.Create;
  B1.FrameType:=5;
  B1.Shadow:=Shadow;
  B2.Shadow:=False;
  B2.FrameType:=1;
  B2.Emboss:=True;
  B1.Open(x1,y1,x2,y2);
  B2.Open(x1+2,y1+2,x2-2,y2-1);
  B1.Destroy;
  B2.Destroy;
End;

Procedure ShadowBox(x1,y1,x2,y2,at:byte);
Var
  i  : Byte;
  l  : Char;
Begin

    For i := y1+3 to y2 Do Begin
      l := GetCharAt(x2+1,i);
      WriteXY(x2+1,i,at,l);
      l := GetCharAt(x2+2,i);
      WriteXY(x2+2,i,at,l);
    End;
      For i := x1+5 to x2 Do Begin
      l := GetCharAt(i,y2+3);
      WriteXY(i,y2+3,at,l);
    End;
End;

Procedure SmallBox(x,y:Byte);
Var
  d     : Byte = 0;
Begin

  SetTextAttr(0);
  GotoXY(x,y);           WritePipe('|23|07Ü|00ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ');
  d:=d+1; GotoXY(x,y+d); WritePipe('|16 |15ÜÛßß|07ß|15ß|07ß²ßß|08 ßßß±±ßßßßßÛÜ ');
  d:=d+1; GotoXY(x,y+d); WritePipe('|16 |07²|00 |23ß                 ß|16 |08Û ');
  d:=d+1; GotoXY(x,y+d); WritePipe(' |07Û|00 |23 °                 |16 |08Û|16 ');
  d:=d+1; GotoXY(x,y+d); WritePipe(' |15|23ß|00|16 |23                   |16 |08Û|16 ');
  d:=d+1; GotoXY(x,y+d); WritePipe(' |23Ü|00Ü                   |16 |08Û|16 ');
  d:=d+1; GotoXY(x,y+d); WritePipe(' |23°|00|16 |23                   |16 |08Û|16 ');
  d:=d+1; GotoXY(x,y+d); WritePipe(' |23Ü|00|16 |23                   |16 |08Û|16 ');
  d:=d+1; GotoXY(x,y+d); WritePipe(' ²|00 |23                   |16 |07²|16 ');
  d:=d+1; GotoXY(x,y+d); WritePipe(' |08ß|00 |23                   |16 |07Û|16 ');
  d:=d+1; GotoXY(x,y+d); WritePipe(' |08Û|00 |23                 ° |16 |15|23ß|16 ');
  d:=d+1; GotoXY(x,y+d); WritePipe(' |08|16Û|00 |23Ü                 Ü|16 |15Û|16 ');
  d:=d+1; GotoXY(x,y+d); WritePipe(' |08ßÛÜÜÜÜ Ü²²ÜÜ|00|23°°|07|16ÜÜ|15ÜÜ|07Ü|15ÜÜ|00|23°|15|16ß ');
  d:=d+1; GotoXY(x,y+d); WritePipe('|23|07Ü|16ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ');

End;

Procedure WideBox(x,y:Byte);
Var
  d     : Byte = 0;
Begin

    GotoXY(x,y);
    Write('[1;37mÜÛßß[0;37;40mß[1mß[0;37;40mß²ßßßß[1;30mß[0;37;40mß[1;30mßßßßßßßßßßßßßßßßßßßßßßß[0;37;40mß[1;30mßßßß ßßß±±ßßßßßÛÜ[0m');
    d:=d+1; GotoXY(x,y+d); Write('²[1CÜÛÛÛÛÛÛÛÛÛÛÛÛÛ[30;47m                [37;40mÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÜ[1C[1;30mÛ[0m');
    d:=d+1; GotoXY(x,y+d); Write('[1;30mÛ[1C[0;30;47m                                                  [37;40mÛ[1C[1;47mß[0m');
    d:=d+1; GotoXY(x,y+d); Write('[1;30mÛ[1C[0;37;40mßÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛß[1C[1mÛ[0m');
    d:=d+1; GotoXY(x,y+d); Write('[1;30mßÛÜÜÜÜ Ü²²ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ[0;37;40mÜ[1;30mÜÜ[0;37;40mÜ[1;30mÜ[0;37;40mÜ[30;47m°°[37;40mÜÜ[1mÜÜ[0;37;40mÜ[1mÜÜ[0;30;47m°[1;37;40mß[0m');

End;

Procedure MenuBox(x,y:Byte);
Begin
WriteXY(x,y,7,'[1;37;47m [0;37;40mÛßßßßßßßßßßßßßßßßßßßßßÛ[1;47m [0;30;40m [0m');
WriteXY(x,y+1,7,'[1;30;47m±[0;30;40m [37mÜ[30;47m                   [37;40mÜ[1C[1;30;47m±[0;30;40m   [0m');
WriteXY(x,y+2,7,'[1;30m²[1C[0;30;47m                     [1C[1;40m²[0m');
WriteXY(x,y+3,7,'[1;30m²[1C[0;30;47m                     [1C[1;40m²[0m');
WriteXY(x,y+4,7,'[1;30m±[1C[0;30;47m                     [1C[1;40m±[0m');
WriteXY(x,y+5,7,'[1;30m±[1C[0;30;47m                     [1C[1;40m±[0m');
WriteXY(x,y+6,7,'[1;30m²[1C[0;30;47m                     [1C[1;40m±[0m');
WriteXY(x,y+7,7,'[1;30mÛ[1C[0;37;40mß[30;47m                   [37;40mß[1C[1;30m²[0m');
WriteXY(x,y+8,7,'[1;30mÛÛÜ ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ ÜÜÛÛ[0m');
End;

Procedure Selection(X: Byte; Text: String);
Var
  S : String;
Begin
  S := Text;
  While Length(S)<12 Do Begin
    S := ' '+S+' ';
  End;
//WriteXY(1,2,8+7*16,'    File       Tools      Other    1           2          3          Help ');
  WriteXY(1,2,8+7*16,'    File       Tools      Other                                      Help ');
  WriteXY(X,1,7,'[37mÜ[1;47m°ÜÛÛÜÜÛÜ[0;37;40m²[1mÜ[47mÜÜ[0;37;40mÛÜ');
  WriteXY(X,2,7,'²[1;47m             [0;37;40m±');
  WriteXY(X,3,7,'ßÛ[1;30;47mßß[0;37;40m²[1;30;47mßßß[40mß[47mßßßß[37m²[40mß[0m');
  WriteXY(X+2,2,15+7*16,Text);
End;

End.
