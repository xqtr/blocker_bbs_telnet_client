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
Unit Blocker_Common;

{$I M_OPS.PAS}

Interface

Uses
  Math,
  xDoor,
  m_Input,
  m_Output,
  m_Output_ScrollBack,
  m_Term_Ansi,
  m_strings,
  m_MenuBox,
  m_MenuForm,
  m_MenuInput;

Function ShowMsgBox       (BoxType: Byte; Str: String) : Boolean;
Function GetStr           (Header, Text, Def: String; Len, MaxLen: Byte) : String;
Function GetCommandOption (StartY: Byte; CmdStr: String) : Char;
Function GetChar : Byte;
Function min(a,b:byte):byte;
Function max(a,b:byte):byte;
Function DiffANSI2Str(Oldattr,attr:byte):string;

{$I RECORDS.PAS}

Var
  Screen     : TConsoleScrollback;
  Keyboard   : TInput;
  Term       : TTermAnsi;
  ConfigFile : File of RecConfig;
  Config     : RecConfig;
  XferPath   : String;
  AutoZmodem : Boolean;

Implementation

Uses blocker_term;

Function DiffANSI2Str(Oldattr,attr:byte):string;
var
  oldfg,oldbg:byte;
  fg,bg:byte;
  AnsiTable : String[8] = '04261537';
  res:string = '';
  semi:string[1];
Begin
  DiffANSI2Str:='';
  if oldattr = attr then exit;

  semi:='';
  res:=#27+'[';
  fg := attr mod 16;
  bg := attr shr 4;
  oldfg := oldattr mod 16;
  oldbg := oldattr shr 4;
  
  if oldfg<>fg then begin
    semi:=';';
    if fg>7 then begin
      res:=res+'1;';
      fg:=fg-8;
    end else res:=res+'0;';
    res:=res+'3'+AnsiTable[fg+1];
  end;
  
  if bg>7 then bg:=bg-7;
  
  if oldbg=oldfg then
    res:=res+'m'
  else  
    res:=res+semi+'4'+AnsiTable[bg+1]+'m';
    
  DiffANSI2Str:=res;
end;

Function min(a,b:byte):byte;
begin
  if a<=b then min:=a else min:=b;
end;

Function max(a,b:byte):byte;
begin
  if a>=b then max:=a else max:=b;
end;

Function GetChar : Byte;
Var
  MsgBox: TMenuBox;
  Col,
  Row   : Byte;
  X,Y   : Byte;
 
  Procedure DrawChars;
  Var
    d,b: byte;
    
  Begin
    For d := 0 to 15 Do 
      For b := 0 To 15 Do Screen.WriteXY(32+b,6+d,3,chr(b+16*d));
  End;
  
  Procedure Select(Col,Row:Byte);
  Begin
    Screen.WriteXY(32+Col,6+Row,15+3*16,Chr(Col+16*Row));
    Screen.WriteXY(32,5,3*16,strpadr('Dec: '+ strpadl(Stri2s(Col+16*Row),3,' ')+ ' Hex: '+Byte2Hex(Col+16*Row),16,' '));
  End;
  
Begin
  X := Screen.CursorX;
  Y := Screen.CursorY;
  MsgBox := TMenuBox.Create(TOutput(Screen));
  MsgBox.Header     := ' Chars ';
  MsgBox.FrameType  := pref.MsgBox_FrameType;
  MsgBox.HeadAttr   := pref.MsgBox_HeadAttr ;
  MsgBox.BoxAttr    := pref.MsgBox_BoxAttr  ;
  MsgBox.BoxAttr2   := pref.MsgBox_BoxAttr2 ;
  MsgBox.BoxAttr3   := pref.MsgBox_BoxAttr3 ;
  MsgBox.BoxAttr4   := pref.MsgBox_BoxAttr4 ;
  MsgBox.Box3D      := pref.MsgBox_Box3D ;
  
  MsgBox.Open (30, 4,49,22);
  
  Col := 0;
  Row := 0;
  Repeat
    DrawChars;
    Select(Col,Row);
    Case Keyboard.ReadKey Of
      #13: Begin
            GetChar := Col+16*Row;
            Break;
          End;
      #27: Begin
            GetChar := 0;
            Break;
          End;
      #00: Case Keyboard.ReadKey Of
        KeyUp   : If Row > 0 Then Dec(Row);
        KeyDown : If Row < 15 Then Inc(Row);
        KeyLeft : If Col > 0 Then Dec(Col);
       keyRight : If Col < 15 Then Inc(Col);
      End;
    End;
  Until False;
  MsgBox.Close;
  MsgBox.Free;
  Screen.CursorXY(X,Y);
End;

Function ShowMsgBox (BoxType: Byte; Str: String) : Boolean;
Var
  Len    : Byte;
  Len2   : Byte;
  Pos    : Byte;
  MsgBox : TMenuBox;
  Offset : Byte;
  SavedX : Byte;
  SavedY : Byte;
  SavedA : Byte;
Begin
  ShowMsgBox := True;
  SavedX     := Screen.CursorX;
  SavedY     := Screen.CursorY;
  SavedA     := Screen.TextAttr;

  MsgBox := TMenuBox.Create(TOutput(Screen));
  
  if length(str) > 74 then begin
    str := copy(str,1,50)+'...'+copy(str,length(str)-20,20);
  end;

  Len := (80 - (Length(Str) + 2)) DIV 2;
  Pos := 1;
  MsgBox.Header     := ' Info ';
  MsgBox.FrameType  := pref.MsgBox_FrameType;
  MsgBox.HeadAttr   := pref.MsgBox_HeadAttr ;
  MsgBox.BoxAttr    := pref.MsgBox_BoxAttr  ;
  MsgBox.BoxAttr2   := pref.MsgBox_BoxAttr2 ;
  MsgBox.BoxAttr3   := pref.MsgBox_BoxAttr3 ;
  MsgBox.BoxAttr4   := pref.MsgBox_BoxAttr4 ;
  MsgBox.Box3D      := pref.MsgBox_Box3D ;

  If Screen.ScreenSize = 50 Then Offset := 12 Else Offset := 0;

  If BoxType < 2 Then
    MsgBox.Open (Len, 10 + Offset, Len + Length(Str) + 3, 15 + Offset)
  Else
    MsgBox.Open (Len, 10 + Offset, Len + Length(Str) + 3, 14 + Offset);

  //Screen.WriteXY (Len + 2, 12 + Offset, 15+7*16, Str);
  Screen.WriteXY (Len + 2, 12 + Offset, pref.MsgBox_HeadAttr, Str);
  Case BoxType of
    0 : Begin
          Len2 := (Length(Str) - 4) DIV 2;

          //Screen.WriteXY (Len + Len2 + 2, 14 + Offset, 15+2*16, ' OK ');
          Screen.WriteXY (Len + Len2 + 2, 14 + Offset, pref.listhi, ' OK ');

          Repeat
            Keyboard.ReadKey;
          Until Not Keyboard.KeyPressed;
        End;
    1 : Repeat
          Len2 := (Length(Str) - 9) DIV 2;

          Screen.WriteXY (Len + Len2 + 2, 14 + Offset, pref.listlow, ' YES ');
          Screen.WriteXY (Len + Len2 + 7, 14 + Offset, pref.listlow, ' NO ');

          If Pos = 1 Then
            Screen.WriteXY (Len + Len2 + 2, 14 + Offset, pref.listhi, ' YES ')
          Else
            Screen.WriteXY (Len + Len2 + 7, 14 + Offset, pref.listhi, ' NO ');

          Case UpCase(Keyboard.ReadKey) of
            #00 : Case Keyboard.ReadKey of
                    #75 : Pos := 1;
                    #77 : Pos := 0;
                  End;
            #13 : Begin
                    ShowMsgBox := Boolean(Pos);
                    Break;
                  End;
            #32 : If Pos = 0 Then Inc(Pos) Else Pos := 0;
            'N' : Begin
                    ShowMsgBox := False;
                    Break;
                  End;
            'Y' : Begin
                    ShowMsgBox := True;
                    Break;
                  End;
          End;
        Until False;
  End;

  If BoxType <> 2 Then MsgBox.Close;

  MsgBox.Free;

  Screen.CursorXY (SavedX, SavedY);

  Screen.TextAttr := SavedA;
End;

Function GetStr (Header, Text, Def: String; Len, MaxLen: Byte) : String;
Var
  Box     : TMenuBox;
  Input   : TMenuInput;
  Offset  : Byte;
  Str     : String;
  WinSize : Byte;
Begin
  WinSize := (80 - Max(Len, Length(Text)) + 2) DIV 2;

  Box   := TMenuBox.Create(TOutput(Screen));
  Input := TMenuInput.Create(TOutput(Screen));

  Box.FrameType := pref.MsgBox_FrameType;
  Box.Header    := ' ' + Header + ' ';
  Box.HeadAttr  := pref.MsgBox_HeadAttr;
  Box.HeadAttr   := pref.MsgBox_HeadAttr ;
  Box.BoxAttr    := pref.MsgBox_BoxAttr  ;
  Box.BoxAttr2   := pref.MsgBox_BoxAttr2 ;
  Box.BoxAttr3   := pref.MsgBox_BoxAttr3 ;
  Box.BoxAttr4   := pref.MsgBox_BoxAttr4 ;
  Box.Box3D      := pref.MsgBox_Box3D ;
  
  Input.Attr     := pref.listhi;//15 + 3 * 16;
  Input.FillAttr := pref.listhi;//15 + 2 * 16;
  Input.LoChars  := #13#27;

  If Screen.ScreenSize = 50 Then Offset := 12 Else Offset := 0;

  Box.Open (WinSize, 10 + Offset, WinSize + Max(Len, Length(Text)) + 6, 15 + Offset);

  Screen.WriteXY (WinSize + 2, 12 + Offset, 7, Text);
  Str := Input.GetStr(WinSize + 2, 13 + Offset, Len, MaxLen, 1, Def);

  Box.Close;

  If Input.ExitCode = #27 Then Str := '';

  Input.Free;
  Box.Free;

  Result := Str;
End;

Function GetCommandOption (StartY: Byte; CmdStr: String) : Char;
Var
  Box     : TMenuBox;
  Form    : TMenuForm;
  Count   : Byte;
  Cmds    : Byte;
  CmdData : Array[1..10] of Record
              Key  : Char;
              Desc : String[18];
            End;
Begin
  Cmds := 0;

  While Pos('|', CmdStr) > 0 Do Begin
    Inc (Cmds);

    CmdData[Cmds].Key  := CmdStr[1];
    CmdData[Cmds].Desc := Copy(CmdStr, 3, Pos('|', CmdStr) - 3);

    Delete (CmdStr, 1, Pos('|', Cmdstr));
  End;

  Box  := TMenuBox.Create(TOutput(Screen));
  Form := TMenuForm.Create(TOutput(Screen));

  Form.HelpSize := 0;

  Box.Open (30, StartY, 51, StartY + Cmds + 1);

  For Count := 1 to Cmds Do
    Form.AddNone (CmdData[Count].Key, ' ' + CmdData[Count].Key + ' ' + CmdData[Count].Desc, 31, StartY + Count, 20, '');

  Result := Form.Execute;

  Form.Free;
  Box.Close;
  Box.Free;
End;

End.
