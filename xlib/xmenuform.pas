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

Unit xMenuForm;
{$MODE objfpc}
Interface

Uses
  m_Types,
  xMenuInput,
  xCrt;

Const
  FormMaxItems = 50;

Const
  YesNoStr : Array[False..True] of String[03] = ('No', 'Yes');

Type
  FormItemType = (
    ItemNone,
    ItemString,
    ItemBoolean,
    ItemByte,
    ItemWord,
    ItemLong,
    ItemToggle,
    ItemPath,
    ItemChar,
    ItemAttr,
    ItemFlags,
    ItemDate,
    ItemPass,
    ItemPipe,
    ItemCaps,
    ItemBits
  );

  FormItemPTR = ^FormItemRec;
  FormItemRec = Record
    HotKey    : Char;
    Desc      : String[60];
    Help      : String[120];
    DescX     : Byte;
    DescY     : Byte;
    DescSize  : Byte;
    FieldX    : Byte;
    FieldY    : Byte;
    FieldSize : Byte;
    ItemType  : FormItemType;
    MaxSize   : Byte;
    MinNum    : LongInt;
    MaxNum    : LongInt;
    S         : ^String;
    O         : ^Boolean;
    B         : ^Byte;
    W         : ^Word;
    L         : ^LongInt;
    C         : ^Char;
    F         : ^TMenuFormFlagsRec;
    Toggle    :  String[68];
  End;

  TMenuFormHelpProc = Procedure;                // tested
  TMenuFormDrawProc = Procedure (Hi: Boolean);  // not functional
  TMenuFormDataProc = Procedure;                // not functional

  TMenuForm = Class
  Private
    Function  GetColorAttr (C: Byte) : Byte;
    Function  DrawAccessFlags (Var Flags: TMenuFormFlagsRec) : String;
    Procedure EditAccessFlags (Var Flags: TMenuFormFlagsRec);
    Procedure AddBasic (HK: Char; D: String; X, Y, FX, FY, DS, FS, MS: Byte; I: FormItemType; P: Pointer; H: String);
    Procedure BarON;
    Procedure BarOFF (RecPos: Word);
    Procedure FieldWrite (RecPos : Word);
    Procedure EditOption;
  Public
    HelpProc    : TMenuFormHelpProc;
    DrawProc    : TMenuFormDrawProc;
    DataProc    : TMenuFormDataProc;
    ItemData    : Array[1..FormMaxItems] of FormItemPTR;
    Items       : Word;
    ItemPos     : Word;
    Changed     : Boolean;
    ExitOnFirst : Boolean;
    ExitOnLast  : Boolean;
    WasHiExit   : Boolean;
    WasFirstExit: Boolean;
    WasLastExit : Boolean;
    LoExitChars : String[30];
    HiExitChars : String[30];
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

    Constructor Create;
    Destructor  Destroy; Override;

    Procedure   Clear;
    Procedure   AddNone (HK: Char; D: String; X, Y, DS: Byte; H: String);
    Procedure   AddStr  (HK: Char; D: String; X, Y, FX, FY, DS, FS, MX: Byte; P: Pointer; H: String);
    Procedure   AddPipe (HK: Char; D: String; X, Y, FX, FY, DS, FS, MX: Byte; P: Pointer; H: String);
    Procedure   AddPath (HK: Char; D: String; X, Y, FX, FY, DS, FS, MX: Byte; P: Pointer; H: String);
    Procedure   AddPass (HK: Char; D: String; X, Y, FX, FY, DS, FS, MX: Byte; P: Pointer; H: String);
    Procedure   AddBol  (HK: Char; D: String; X, Y, FX, FY, DS, FS: Byte; P: Pointer; H: String);
    Procedure   AddByte (HK: Char; D: String; X, Y, FX, FY, DS, FS: Byte; MN, MX: Byte; P: Pointer; H: String);
    Procedure   AddWord (HK: Char; D: String; X, Y, FX, FY, DS, FS: Byte; MN, MX: Word; P: Pointer; H: String);
    Procedure   AddLong (HK: Char; D: String; X, Y, FX, FY, DS, FS: Byte; MN, MX: LongInt; P: Pointer; H: String);
    Procedure   AddTog  (HK: Char; D: String; X, Y, FX, FY, DS, FS, MN, MX: Byte; TG: String; P: Pointer; H: String);
    Procedure   AddChar (HK: Char; D: String; X, Y, FX, FY, DS, MN, MX: Byte; P: Pointer; H: String);
    Procedure   AddAttr (HK: Char; D: String; X, Y, FX, FY, DS: Byte; P: Pointer; H: String);
    Procedure   AddFlag (HK: Char; D: String; X, Y, FX, FY, DS: Byte; P: Pointer; H: String);
    Procedure   AddDate (HK: Char; D: String; X, Y, FX, FY, DS: Byte; P: Pointer; H: String);
    Procedure   AddCaps (HK: Char; D: String; X, Y, FX, FY, DS, FS, MX: Byte; P: Pointer; H: String);
    Procedure   AddBits (HK: Char; D: String; X, Y, FX, FY, DS: Byte; Flag: LongInt; P: Pointer; H: String);
    Function    Execute : Char;
  End;
  
Var
  FieldCh : Char = #32;

Implementation

Uses
  xFileIO,
  xStrings,
  xMenuBox;

Constructor TMenuForm.Create;
Begin
  Inherited Create;

  HelpProc     := NIL;
  DrawProc     := NIL;
  DataProc     := NIL;
  cLo          := theme.cLo;
  cHi          := theme.cHi;
  cData        := theme.cData;
  cLoKey       := theme.cLoKey;
  cHiKey       := theme.cHiKey;
  cField1      := theme.cField1;
  cField2      := theme.cField2;
  HelpX        := theme.HelpX;
  HelpY        := theme.HelpY;
  HelpColor    := theme.HelpColor;
  HelpSize     := theme.HelpSize;
  WasHiExit    := False;
  WasFirstExit := False;
  ExitOnFirst  := False;
  WasLastExit  := False;
  ExitOnLast   := False;

  Clear;
End;

Destructor TMenuForm.Destroy;
Begin
  Clear;

  Inherited Destroy;
End;

Procedure TMenuForm.Clear;
Var
  Count : Word;
Begin
  For Count := 1 to Items Do
    Dispose(ItemData[Count]);

  Items   := 0;
  ItemPos := 1;
  Changed := False;
End;

Function TMenuForm.DrawAccessFlags (Var Flags: TMenuFormFlagsRec) : String;
Var
  S  : String;
  Ch : Char;
Begin
  S := '';

  For Ch := 'A' to 'Z' Do
    If Ord(Ch) - 64 in Flags Then S := S + Ch Else S := S + '-';

  DrawAccessFlags := S;
End;

Procedure TMenuForm.EditAccessFlags (Var Flags: TMenuFormFlagsRec);
Var
  Box : TMenuBox;
  Ch  : Char;
Begin
  Box := TMenuBox.Create;

  Box.Open (25, 11, 56, 14);

  WriteXY (28, 13, 113, 'A-Z to toggle, ESC to Quit');

  Repeat
    WriteXY (28, 12, 112, DrawAccessFlags(Flags));

    Ch := UpCase(ReadKey);

    Case Ch of
      #00 : ReadKey;
      #27 : Break;
      'A'..
      'Z' : Begin
              If Ord(Ch) - 64 in Flags Then
                Flags := Flags - [Ord(Ch) - 64]
              Else
                Flags := Flags + [Ord(Ch) - 64];

              Changed := True;
            End;
    End;
  Until False;

  Box.Close;
  Box.Free;
End;

Function TMenuForm.GetColorAttr (C: Byte) : Byte;
Var
  FG  : Byte;
  BG  : Byte;
  Box : TMenuBox;
  A   : Byte;
  B   : Byte;
Begin
  FG := C AND $F;
  BG := (C SHR 4) AND 7;

  Box := TMenuBox.Create;

  Box.Header  := ' Select color ';

  Box.Open (30, 7, 51, 18);

  Repeat
    For A := 0 to 9 Do
      WriteXY (31, 8 + A, Box.BoxAttr, '                    ');

    For A := 0 to 7 Do
      For B := 0 to 15 Do
        WriteXY (33 + B, 9 + A, B + A * 16, 'þ');

    WriteXY (37, 18, FG + BG * 16, ' Sample ');

    WriteXYPipe (31 + FG,  8 + BG, 15,  'Û|23ßßß|08Ü');
    WriteXYPipe (31 + FG,  9 + BG, 15,  'Û|23   |08Û');
    WriteXYPipe (31 + FG, 10 + BG, 15,  '|23ß|08ÜÜÜ|08Û');
    WriteXY (33 + FG,  9 + BG, FG + BG * 16, 'þ');

    Case ReadKey of
      #00 : Case ReadKey of
              #72 : If BG > 0 Then Dec(BG);
              #75 : If FG > 0 Then Dec(FG);
              #77 : If FG < 15 Then Inc(FG);
              #80 : If BG < 7 Then Inc(BG);
            End;
      #13 : Begin
              GetColorAttr := FG + BG * 16;
              Break;
            End;
      #27 : Begin
              GetColorAttr := C;
              Break;
            End;
    End;
  Until False;

  Box.Close;
  Box.Free;
End;

Procedure TMenuForm.AddBasic (HK: Char; D: String; X, Y, FX, FY, DS, FS, MS: Byte; I: FormItemType; P: Pointer; H: String);
Begin
  Inc (Items);

  New (ItemData[Items]);

  With ItemData[Items]^ Do Begin
    HotKey    := HK;
    Desc      := D;
    DescX     := X;
    DescY     := Y;
    DescSize  := DS;
    Help      := H;
    ItemType  := I;
    FieldSize := FS;
    MaxSize   := MS;
    FieldX    := FX;
    FieldY    := FY;

    Case ItemType of
      ItemCaps,
      ItemPipe,
      ItemPass,
      ItemDate,
      ItemPath,
      ItemString  : S := P;
      ItemBoolean : O := P;
      ItemAttr,
      ItemToggle,
      ItemByte    : B := P;
      ItemWord    : W := P;
      ItemBits,
      ItemLong    : L := P;
      ItemChar    : C := P;
      ItemFlags   : F := P;
    End;
  End;
End;

Procedure TMenuForm.AddNone (HK: Char; D: String; X, Y, DS: Byte; H: String);
Begin
  If Items = FormMaxItems Then Exit;

  AddBasic (HK, D, X, Y, 0, 0, DS, 0, 0, ItemNone, NIL, H);
End;

Procedure TMenuForm.AddChar (HK: Char; D: String; X, Y, FX, FY, DS, MN, MX: Byte; P: Pointer; H: String);
Begin
  If Items = FormMaxItems Then Exit;

  AddBasic (HK, D, X, Y, FX, FY, DS, 1, 1, ItemChar, P, H);

  ItemData[Items]^.MinNum := MN;
  ItemData[Items]^.MaxNum := MX;
End;

Procedure TMenuForm.AddStr (HK: Char; D: String; X, Y, FX, FY, DS, FS, MX: Byte; P: Pointer; H: String);
Begin
  If Items = FormMaxItems Then Exit;

  AddBasic (HK, D, X, Y, FX, FY, DS, FS, MX, ItemString, P, H);
End;

Procedure TMenuForm.AddPipe (HK: Char; D: String; X, Y, FX, FY, DS, FS, MX: Byte; P: Pointer; H: String);
Begin
  If Items = FormMaxItems Then Exit;

  AddBasic (HK, D, X, Y, FX, FY, DS, FS, MX, ItemPipe, P, H);
End;

Procedure TMenuForm.AddCaps (HK: Char; D: String; X, Y, FX, FY, DS, FS, MX: Byte; P: Pointer; H: String);
Begin
  If Items = FormMaxItems Then Exit;

  AddBasic (HK, D, X, Y, FX, FY, DS, FS, MX, ItemCaps, P, H);
End;

Procedure TMenuForm.AddPass (HK: Char; D: String; X, Y, FX, FY, DS, FS, MX: Byte; P: Pointer; H: String);
Begin
  If Items = FormMaxItems Then Exit;

  AddBasic (HK, D, X, Y, FX, FY, DS, FS, MX, ItemPass, P, H);
End;

Procedure TMenuForm.AddPath (HK: Char; D: String; X, Y, FX, FY, DS, FS, MX: Byte; P: Pointer; H: String);
Begin
  If Items = FormMaxItems Then Exit;

  AddBasic (HK, D, X, Y, FX, FY, DS, FS, MX, ItemPath, P, H);
End;

Procedure TMenuForm.AddBol  (HK: Char; D: String; X, Y, FX, FY, DS, FS: Byte; P: Pointer; H: String);
Begin
  If Items = FormMaxItems Then Exit;

  AddBasic (HK, D, X, Y, FX, FY, DS, FS, 3, ItemBoolean, P, H);
End;

Procedure TMenuForm.AddBits (HK: Char; D: String; X, Y, FX, FY, DS: Byte; Flag: LongInt; P: Pointer; H: String);
Begin
  If Items = FormMaxItems Then Exit;

  AddBasic (HK, D, X, Y, FX, FY, DS, 3, 3, ItemBits, P, H);

  ItemData[Items]^.MaxNum := Flag;
End;

Procedure TMenuForm.AddByte (HK: Char; D: String; X, Y, FX, FY, DS, FS: Byte; MN, MX: Byte; P: Pointer; H: String);
Begin
  If Items = FormMaxItems Then Exit;

  AddBasic (HK, D, X, Y, FX, FY, DS, FS, Length(Int2Str(MX)), ItemByte, P, H);

  ItemData[Items]^.MinNum := MN;
  ItemData[Items]^.MaxNum := MX;
End;

Procedure TMenuForm.AddWord (HK: Char; D: String; X, Y, FX, FY, DS, FS: Byte; MN, MX: Word; P: Pointer; H: String);
Begin
  If Items = FormMaxItems Then Exit;

  AddBasic (HK, D, X, Y, FX, FY, DS, FS, Length(Int2Str(MX)), ItemWord, P, H);

  ItemData[Items]^.MinNum := MN;
  ItemData[Items]^.MaxNum := MX;
End;

Procedure TMenuForm.AddLong (HK: Char; D: String; X, Y, FX, FY, DS, FS: Byte; MN, MX: LongInt; P: Pointer; H: String);
Begin
  If Items = FormMaxItems Then Exit;

  AddBasic (HK, D, X, Y, FX, FY, DS, FS, Length(Int2Str(MX)), ItemLong, P, H);

  ItemData[Items]^.MinNum := MN;
  ItemData[Items]^.MaxNum := MX;
End;

Procedure TMenuForm.AddTog (HK: Char; D: String; X, Y, FX, FY, DS, FS, MN, MX: Byte; TG: String; P: Pointer; H: String);
Begin
  If Items = FormMaxItems Then Exit;

  AddBasic (HK, D, X, Y, FX, FY, DS, FS, MX, ItemToggle, P, H);

  ItemData[Items]^.Toggle := TG;
  ItemData[Items]^.MinNum := MN;
End;

Procedure TMenuForm.AddAttr (HK: Char; D: String; X, Y, FX, FY, DS: Byte; P: Pointer; H: String);
Begin
  If Items = FormMaxItems Then Exit;

  AddBasic (HK, D, X, Y, FX, FY, DS, 8, 8, ItemAttr, P, H);
End;

Procedure TMenuForm.AddFlag (HK: Char; D: String; X, Y, FX, FY, DS: Byte; P: Pointer; H: String);
Begin
  If Items = FormMaxItems Then Exit;

  AddBasic (HK, D, X, Y, FX, FY, DS, 26, 26, ItemFlags, P, H);
End;

Procedure TMenuForm.AddDate (HK: Char; D: String; X, Y, FX, FY, DS: Byte; P: Pointer; H: String);
Begin
  If Items = FormMaxItems Then Exit;

  AddBasic (HK, D, X, Y, FX, FY, DS, 8, 8, ItemDate, P, H);
End;

Procedure TMenuForm.BarON;
Var
  A : Byte;
Begin
  If ItemPos = 0 Then Exit;

  With ItemData[ItemPos]^ Do Begin
    WriteXY (DescX, DescY, cHi, strPadR(Desc, DescSize, ' '));

    A := Pos(HotKey, Upper(Desc));
    If A > 0 Then
      WriteXY (DescX + A - 1, DescY, cHiKey, Desc[A]);

    If HelpSize > 0 Then
      If Assigned(HelpProc) Then
        HelpProc
      Else
        WriteXYPipe (HelpX, HelpY, HelpColor, StrPadR(Help,HelpSize,' '));
  End;
End;

Procedure TMenuForm.BarOFF (RecPos: Word);
Var
  A : Byte;
Begin
  If RecPos = 0 Then Exit;

  With ItemData[RecPos]^ Do Begin
    WriteXY (DescX, DescY, cLo, strPadR(Desc, DescSize, ' '));

    A := Pos(HotKey, Upper(Desc));
    If A > 0 Then
      WriteXY (DescX + A - 1, DescY, cLoKey, Desc[A]);
  End;
End;

Procedure TMenuForm.FieldWrite (RecPos : Word);
Begin
  With ItemData[RecPos]^ Do Begin
    Case ItemType of
      ItemPass    : WriteXY (FieldX, FieldY, cData, strPadR(strRep('*', Length(S^)), FieldSize, FieldCh));
      ItemCaps,
      ItemDate,
      ItemPath,
      ItemString  : WriteXY (FieldX, FieldY, cData, strPadR(S^, FieldSize, FieldCh));
      ItemBoolean : WriteXY (FieldX, FieldY, cData, strPadR(YesNoStr[O^], FieldSize, FieldCh));
      ItemByte    : WriteXY (FieldX, FieldY, cData, strPadR(Int2Str(B^), FieldSize, FieldCh));
      ItemWord    : WriteXY (FieldX, FieldY, cData, strPadR(Int2Str(W^), FieldSize, FieldCh));
      ItemLong    : WriteXY (FieldX, FieldY, cData, strPadR(Int2Str(L^), FieldSize, FieldCh));
      ItemToggle  : WriteXY (FieldX, FieldY, cData, StrPadR(strWordGet(B^ + 1 - MinNum, Toggle, FieldCh), FieldSize, FieldCh));
      ItemChar    : WriteXY (FieldX, FieldY, cData, C^);
      ItemAttr    : WriteXY (FieldX, FieldY, B^, ' Sample ');
      ItemFlags   : WriteXY (FieldX, FieldY, cData, DrawAccessFlags(F^));
      ItemPipe    : WriteXYPipe (FieldX, FieldY, 7, S^);
      ItemBits    : WriteXY (FieldX, FieldY, cData, strPadR(YesNoStr[L^ AND MaxNum <> 0], FieldSize, FieldCh));
    End;
  End;
End;

Procedure TMenuForm.EditOption;
Var
  TempStr  : String;
  TempByte : Byte;
  TempLong : LongInt;
Begin
  With ItemData[ItemPos]^ Do
    Case ItemType of
      ItemCaps    : S^ := GetStr(FieldX, FieldY, FieldSize, MaxSize, 2, S^);
      ItemDate    : S^ := GetStr(FieldX, FieldY, FieldSize, MaxSize, 3, S^);
      ItemPass,
      ItemPipe,
      ItemString  : S^ := GetStr(FieldX, FieldY, FieldSize, MaxSize, 1, S^);
      ItemBoolean : Begin
                      O^      := Not O^;
                      Changed := True;
                    End;
      ItemByte    : B^ := Byte(GetNum(FieldX, FieldY, FieldSize, MaxSize, MinNum, MaxNum, B^));
      ItemWord    : W^ := Word(GetNum(FieldX, FieldY, FieldSize, MaxSize, MinNum, MaxNum, W^));
      ItemLong    : L^ := LongInt(GetNum(FieldX, FieldY, FieldSize, MaxSize, MinNum, MaxNum, L^));
      ItemToggle  : Begin
                      If B^ < MaxSize Then Inc(B^) Else B^ := MinNum;
                      Changed := True;
                    End;
      ItemPath    : S^ := DirSlash(GetStr(FieldX, FieldY, FieldSize, MaxSize, 1, S^));
      ItemChar    : Begin
                      TempStr := GetStr(FieldX, FieldY, FieldSize, MaxSize, 1, C^);
                      Changed := TempStr[1] <> C^;
                      C^      := TempStr[1];
                    End;
      ItemAttr    : Begin
                      TempByte := GetColorAttr(B^);
                      Changed  := TempByte <> B^;
                      B^       := TempByte;
                    End;
      ItemFlags   : EditAccessFlags(F^);
      ItemBits    : Begin
                      Changed  := True;
                      TempLong := L^;
                      TempLong := TempLong XOR MaxNum;
                      L^       := TempLong;
                    End;
    End;

  FieldWrite (ItemPos);

  //Changed := Changed or Changed;
  Changed := True;
End;

Function TMenuForm.Execute : Char;
Var
  Count   : Word;
  Ch      : Char;
  NewPos  : Word;
  NewXPos : Word;
Begin
  WasHiExit    := False;
  WasFirstExit := False;
  WasLastExit  := False;

  Attr     := cField1;
  FillAttr := cField2;

  For Count := 1 to Items Do Begin
    BarOFF(Count);
    FieldWrite(Count);
  End;

  BarON;

  Repeat
    Changed := Changed OR Changed;

    Ch := UpCase(ReadKey);

    Case Ch of
      #00 : Begin
              Ch := ReadKey;

              If Pos(Ch, HiExitChars) > 0 Then Begin
                WasHiExit := True;
                Execute   := Ch;
                Break;
              End;

              Case Ch of
                #72 : If ItemPos > 1 Then Begin
                        BarOFF(ItemPos);
                        Dec(ItemPos);
                        BarON;
                      End Else
                      If ExitOnFirst Then Begin
                        WasFirstExit := True;
                        Execute := Ch;
                        Break;
                      End;
                #75 : Begin
                        NewPos  := 0;
                        NewXPos := 0;

                        For Count := 1 to Items Do
                          If (ItemData[Count]^.DescY = ItemData[ItemPos]^.DescY) and
                             (ItemData[Count]^.DescX < ItemData[ItemPos]^.DescX) and
                             (ItemData[Count]^.DescX > NewXPos) Then Begin
                                NewXPos := ItemData[Count]^.DescX;
                                NewPos  := Count;
                              End;

                        If NewPos > 0 Then Begin
                          BarOFF(ItemPos);
                          ItemPos := NewPos;
                          BarON;
                        End;
                      End;
                #77 : Begin
                        NewPos  := 0;
                        NewXPos := 80;

                        For Count := 1 to Items Do
                          If (ItemData[Count]^.DescY = ItemData[ItemPos]^.DescY) and
                             (ItemData[Count]^.DescX > ItemData[ItemPos]^.DescX) and
                             (ItemData[Count]^.DescX < NewXPos) Then Begin
                                NewXPos := ItemData[Count]^.DescX;
                                NewPos  := Count;
                              End;

                        If NewPos > 0 Then Begin
                          BarOFF(ItemPos);
                          ItemPos := NewPos;
                          BarON;
                        End;
                      End;
                #80 : If ItemPos < Items Then Begin
                        BarOFF(ItemPos);
                        Inc(ItemPos);
                        BarON;
                      End Else
                      If ExitOnLast Then Begin
                        WasLastExit := True;
                        Execute     := Ch;
                        Break;
                      End;
              End;
            End;
      #13 : If ItemPos > 0 Then
              If ItemData[ItemPos]^.ItemType = ItemNone Then Begin
                Execute := ItemData[ItemPos]^.HotKey;
                Break;
              End Else
                EditOption;
      #27 : Begin
              Execute := #27;
              Break;
            End;
    Else
      If Pos(Ch, LoExitChars) > 0 Then Begin
        Execute := Ch;
        Break;
      End;

      For Count := 1 to Items Do
        If ItemData[Count]^.HotKey = Ch Then Begin
          BarOFF(ItemPos);
          ItemPos := Count;
          BarON;

          If ItemData[ItemPos]^.ItemType = ItemNone Then Begin
            Execute := ItemData[ItemPos]^.HotKey;
            BarOFF(ItemPos);
            Exit;
          End Else
            EditOption;
        End;
    End;
  Until False;

  BarOFF(ItemPos);
End;

End.
