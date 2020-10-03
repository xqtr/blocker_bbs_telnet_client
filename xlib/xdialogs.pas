Unit xDialogs;
{$MODE objfpc}

Interface
Var
  CharSet      : Array[1..10,1..10] of Byte = 
  ((218,191,192,217,196,179,195,180,193,194),
  (201,187,200,188,205,186,199,185,202,203),
  (213,184,212,190,205,179,198,189,207,209),
  (197,206,216,215,159,233,155,156,153,239),
  (176,177,178,219,220,223,221,222,254,249),
  (214,183,211,189,196,186,199,182,208,210),
  (174,175,242,243,244,245,246,247,240,251),
  (166,167,168,169,170,171,172,248,252,253),
  (224,225,226,235,238,237,234,228,229,230),
 (232,233,234,155,156,157,159,145,146,247)); 

Function  GetChar : Byte;
Function  ShowMsgBox (BoxType: Byte; Str: String) : Boolean;
Function  GetSaveFileName(Header,def,xferpath: String): String;
Function  GetOpenFileName(Header,xFerPath: String) : String;
Procedure AboutBox(Title:String);
Function  YesNo(Title,Prompt:String):Boolean;
Function  InputBox(x1,y1,x2,y2:Byte; title,prompt:String; var Input:String):Boolean;


Implementation

Uses
  xCrt,
  xStrings,
  xMenuBox,
  //xMenuForm,
  //IniFiles,
  xquicksort,
  xfileio,
  xDateTime,
  DOS,
  Classes,
  xMenuInput;

Type
  TCharSet = Array[1..10] Of String[10];
  
Procedure xCenter(S:String; L:byte);
Begin
  WriteXYPipe((40-strMCILen(s) div 2),L,7,S);
End;  

Function GetSaveFileName(Header,def,xferpath: String): String;
Const
  ColorBox = 7;
  ColorBar = 15 + 3 * 16;
Var
  DirList  : TMenuList;
  FileList : TMenuList;
  Str      : String;
  Path     : String;
  Mask     : String;
  OrigDIR  : String;
  SaveFile : String;

  Procedure UpdateInfo;
  Begin
    WriteXY (8,  7, 15 + 3 * 16, strPadR(Path, 60, ' '));
    WriteXY (8, 21, 15 + 3 * 16, strPadR(SaveFile, 60, ' '));
  End;

  Procedure CreateLists;
  Var
    Dir      : SearchRec;
    DirSort  : TQuickSort;
    FileSort : TQuickSort;
    Count    : LongInt;
  Begin
    DirList.Clear;
    FileList.Clear;

    While Path[Length(Path)] = PathSep Do Dec(Path[0]);

    ChDir(Path);

    Path := Path + PathSep;

    If IoResult <> 0 Then Exit;

    DirList.Picked  := 1;
    FileList.Picked := 1;

    UpdateInfo;

    DirSort  := TQuickSort.Create;
    FileSort := TQuickSort.Create;

    FindFirst (Path + '*', AnyFile - VolumeID, Dir);

    While DosError = 0 Do Begin
      If (Dir.Attr And Directory = 0) or ((Dir.Attr And Directory <> 0) And (Dir.Name = '.')) Then Begin
        FindNext(Dir);
        Continue;
      End;

      DirSort.Add (Dir.Name, 0);
      FindNext    (Dir);
    End;

    FindClose(Dir);

    FindFirst (Path + Mask, AnyFile - VolumeID, Dir);

    While DosError = 0 Do Begin
      If Dir.Attr And Directory <> 0 Then Begin
        FindNext(Dir);

        Continue;
      End;

      FileSort.Add(Dir.Name, 0);
      FindNext(Dir);
    End;

    FindClose(Dir);

    DirSort.Sort  (1, DirSort.Total,  qAscending);
    FileSort.Sort (1, FileSort.Total, qAscending);

    For Count := 1 to DirSort.Total Do
      DirList.Add(DirSort.Data[Count]^.Name, 0);

    For Count := 1 to FileSort.Total Do
      FileList.Add(FileSort.Data[Count]^.Name, 0);

    DirSort.Free;
    FileSort.Free;

    WriteXY (14, 9, 112, strPadR('(' + strComma(FileList.ListMax) + ')', 7, ' '));
    WriteXY (53, 9, 112, strPadR('(' + strComma(DirList.ListMax) + ')', 7, ' '));
  End;

Var
  Box  : TMenuBox;
  Done : Boolean;
  Mode : Byte;
Begin
  Result   := '';
  Path     := XferPath;
  Mask     := '*.*';
  SaveFile := def;
  Box      := TMenuBox.Create;
  DirList  := TMenuList.Create;
  FileList := TMenuList.Create;

  GetDIR (0, OrigDIR);

  FileList.NoWindow   := True;
  FileList.LoChars    := #9#13#27;
  FileList.HiChars    := #77;
  FileList.HiAttr     := ColorBar;
  FileList.LoAttr     := ColorBox;

  DirList.NoWindow    := True;
  DirList.NoInput     := True;
  DirList.HiAttr      := ColorBox;
  DirList.LoAttr      := ColorBox;

  //Box.Header := ' Save File ';
  Box.Header := Header;
  Box.HeadAttr := 15 + 7 * 16;
  Box.Open (6, 5, 74, 22);

  WriteXY ( 8,  6, 112, 'Directory');
  WriteXY ( 8,  9, 112, 'Files');
  WriteXY (41,  9, 112, 'Directories');
  WriteXY ( 8, 20, 112, 'File Name');
  WriteXY ( 8, 21, 15+3*16, strRep(' ', 40));

  CreateLists;

  DirList.Open (40, 9, 72, 19);
  DirList.Update;

  Done := False;

  Repeat
    FileList.Open (7, 9, 39, 19);

    Case FileList.ExitCode of
      #09,
      #77 : Begin
              FileList.HiAttr := ColorBox;
              DirList.NoInput := False;
              DirList.LoChars := #09#13#27;
              DirList.HiChars := #75;
              DirList.HiAttr  := ColorBar;

              FileList.Update;

              Repeat
                DirList.Open(40, 9, 72, 19);

                Case DirList.ExitCode of
                  #09 : Begin
                          DirList.HiAttr := ColorBox;
                          DirList.Update;

                          Mode  := 1;
                          
                          xMenuInput.FillAttr := 15+0*16;
                          xMenuInput.Attr := 15+3*16;
                          xMenuInput.LoChars := #09#13#27;

                          Repeat
                            Case Mode of
                              1 : Begin
                                    Str := GetStr(8, 21, 60, 255, 1, SaveFile);

                                    Case xMenuInput.ExitCode of
                                      #09 : Mode := 2;
                                      #13 : Begin
                                              SaveFile := Str;
                                              if SaveFile <> '' then 
                                                if fileexist(Path + Savefile) then Begin
                                                  if ShowMsgBox(1, 'File Exists. Overwrite?') then Result := Path + Savefile
                                                  End else Result := Path + Savefile;
                                              if result = Path + Savefile then begin
                                                ChDIR(OrigDIR);
                                                FileList.Free;
                                                DirList.Free;
                                                Box.Close;
                                                Box.Free;
                                                exit;
                                              end;
                                              (*CreateLists;
                                              FileList.Update;
                                              DirList.Update;*)
                                            End;
                                      #27 : Begin
                                              Done := True;
                                              Break;
                                            End;
                                    End;
                                  End;
                              2 : Begin
                                    UpdateInfo;

                                    Str := GetStr(8, 7, 60, 255, 1, Path);

                                    Case xMenuInput.ExitCode of
                                      #09 : Break;
                                      #13 : Begin
                                              ChDir(Str);

                                              If IoResult = 0 Then Begin
                                                Path := Str;
                                                CreateLists;
                                                FileList.Update;
                                                DirList.Update;
                                              End;
                                            End;
                                      #27 : Begin
                                              Done := True;
                                              Break;
                                            End;
                                    End;
                                  End;
                            End;
                          Until False;
                          UpdateInfo;
                          Break;
                        End;
                  #13 : If DirList.ListMax > 0 Then Begin
                          ChDir  (DirList.List[DirList.Picked]^.Name);
                          GetDir (0, Path);

                          Path := Path + PathSep;

                          CreateLists;
                          FileList.Update;
                        End;
                  #27 : Done := True;
                  #75 : Break;
                End;
              Until Done;

              DirList.NoInput := True;
              DirList.HiAttr  := ColorBox;
              FileList.HiAttr := ColorBar;
              DirList.Update;
            End;
      #13 : If FileList.ListMax > 0 Then Begin
              //Result := Path + FileList.List[FileList.Picked]^.Name;
              if fileexist(Path + FileList.List[FileList.Picked]^.Name) then Begin
                if ShowMsgBox(1, 'File Exists. Overwrite?') then Result := Path + FileList.List[FileList.Picked]^.Name;
              End else Result := Path + FileList.List[FileList.Picked]^.Name;
              if Result = Path + FileList.List[FileList.Picked]^.Name then Break;
            End;
      #27 : Begin
              Result:='';
              Break;
            End;
    End;
  Until Done;

  ChDIR(OrigDIR);

  FileList.Free;
  DirList.Free;
  Box.Close;
  Box.Free;
End;

Function GetCharSetType() : Byte;
Var
  List  : TMenuList;
  X,Y   : Byte;
Begin
  X := WhereX;
  Y := WhereY;
  List := TMenuList.Create;

  List.Box.Header    := ' Charset ';
  List.Box.HeadAttr  := 15 + 7 * 16;
  List.Box.FrameType := 6;
  List.Box.Box3D     := True;
  List.PosBar        := False;
  
  List.HiAttr := 15+1*16;
  List.LoAttr := 0 + 7*16;
  
  List.Add(Chr(218)+Chr(191)+Chr(192)+Chr(217)+Chr(196)+Chr(179)+Chr(195)+Chr(180)+Chr(193)+Chr(194),0);
  List.Add(Chr(201)+Chr(187)+Chr(200)+Chr(188)+Chr(205)+Chr(186)+Chr(199)+Chr(185)+Chr(202)+Chr(203),0);
  List.Add(Chr(213)+Chr(184)+Chr(212)+Chr(190)+Chr(205)+Chr(179)+Chr(198)+Chr(189)+Chr(207)+Chr(209),0);
  List.Add(Chr(197)+Chr(206)+Chr(216)+Chr(215)+Chr(159)+Chr(233)+Chr(155)+Chr(156)+Chr(153)+Chr(239),0);
  List.Add(Chr(176)+Chr(177)+Chr(178)+Chr(219)+Chr(220)+Chr(223)+Chr(221)+Chr(222)+Chr(254)+Chr(249),0);
  List.Add(Chr(214)+Chr(183)+Chr(211)+Chr(189)+Chr(196)+Chr(186)+Chr(199)+Chr(182)+Chr(208)+Chr(210),0);
  List.Add(Chr(174)+Chr(175)+Chr(242)+Chr(243)+Chr(244)+Chr(245)+Chr(246)+Chr(247)+Chr(240)+Chr(251),0);
  List.Add(Chr(166)+Chr(167)+Chr(168)+Chr(169)+Chr(170)+Chr(171)+Chr(172)+Chr(248)+Chr(252)+Chr(253),0);
  List.Add(Chr(224)+Chr(225)+Chr(226)+Chr(235)+Chr(238)+Chr(237)+Chr(234)+Chr(228)+Chr(229)+Chr(230),0);
  List.Add(Chr(232)+Chr(233)+Chr(234)+Chr(155)+Chr(156)+Chr(157)+Chr(159)+Chr(145)+Chr(146)+Chr(247),0);
  List.Open (30, 8, 43, 19);
  List.Box.Close;

  Case List.ExitCode of
    #27 : GetCharSetType := 4;
  Else
    GetCharSetType := List.Picked;
  End;
  List.Free;
  GotoXY(X,Y);
End;

Function GetColor(Color:Byte) : Byte;
Var
  i     : Byte;
  CS    : TCharSet;
  MsgBox: TMenuBox;
  SelFG : Byte;
  SelBG : Byte;
  FB    : Byte;
  X,Y   : Byte;
  
  Procedure DrawColors;
  Var
    d: byte;
  Begin
    For d := 1 to 7 Do WriteXY(9,6+d,0+7*16,StrRep(' ',65));
    xCenter('|00|23ForeGround Color',6);
    For d := 0 to 15 Do WriteXY(10+d*4,8,d+7*16,Chr(219)+Chr(219));
    xCenter('|00|23BackGround Color',10);
    For d := 0 to 7 Do WriteXY(27+d*4,12,0+d*16,'  ');
  End;
  
  Procedure Select(FG:Byte; CL:Byte);
  Begin
    If FG=1 Then Begin
      WriteXY(9+SelFG*4,8,15+7*16,'[');
      WriteXY(12+SelFG*4,8,15+7*16,']');
    End Else Begin
      WriteXY(9+SelFG*4,8,0+7*16,'[');
      WriteXY(12+SelFG*4,8,0+7*16,']');
    End;
    
    If FG=2 Then Begin
      WriteXY(26+SelBG*4,12,15+7*16,'[');
      WriteXY(29+SelBG*4,12,15+7*16,']');
    End Else Begin
      WriteXY(26+SelBG*4,12,0+7*16,'[');
      WriteXY(29+SelBG*4,12,0+7*16,']');
    End;
  End;
  
Begin
  X := WhereX;
  Y := WhereY;
  MsgBox := TMenuBox.Create;
  MsgBox.Header     := ' Colors ';
  MsgBox.FrameType  := 6;
  MsgBox.HeadAttr   := 112;
  MsgBox.BoxAttr    := 127;
  MsgBox.BoxAttr2   := 120;
  MsgBox.BoxAttr3   := 127;
  MsgBox.BoxAttr4   := 120;
  MsgBox.Box3D      := True;
  
  MsgBox.Open (7, 5,74,14);
  DrawColors;
  FB := 1;
  SelFG:= Color mod 16;
  SelBG:= Color Div 16;
  Repeat
    DrawColors;
    Case FB Of
      1: Select(FB,SelFG);
      2: Select(FB,SelBG);
    End;
    Case ReadKey Of
      #13: Begin
            GetColor := SelFG + SelBG*16;
            Break;
          End;
      #27: Begin
            GetColor := Color;
            Break;
          End;
      #00: Case ReadKey Of
        KeyCursorUp   : If FB>1 Then FB:=1;
        KeyCursorDown : If FB<2 Then FB:=2;
        KeyCursorLeft : Case FB of
                    1: If SelFG>0 Then Dec(SelFG);
                    2: If SelBG>0 Then Dec(SelBG);
                  End;
        KeyCursorRight : Case FB of
                    1: If SelFG<15 Then Inc(SelFG);
                    2: If SelBG<7 Then Inc(SelBG);
                  End;
      End;
    End;
  Until False;
  MsgBox.Close;
  MsgBox.Free;
  GotoXY(X,Y);

End;

Function GetChar() : Byte;
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
      For b := 0 To 15 Do WriteXY(32+b,6+d,0+7*16,chr(b+16*d));
  End;
  
  Procedure Select(Col,Row:Byte);
  Begin
    WriteXY(32+Col,6+Row,15+2*16,Chr(Col+16*Row));
    WriteXY(32,5,0+7*16,'Dec: '+ Int2Str(Col+16*Row)+ ' Hex: '+Byte2Hex(Col+16*Row));
  End;
  
Begin
  X := WhereX;
  Y := WhereY;
  MsgBox := TMenuBox.Create;
  MsgBox.Header     := ' Chars ';
  MsgBox.FrameType  := 6;
  MsgBox.HeadAttr   := 112;
  MsgBox.BoxAttr    := 127;
  MsgBox.BoxAttr2   := 120;
  MsgBox.BoxAttr3   := 127;
  MsgBox.BoxAttr4   := 120;
  MsgBox.Box3D      := True;
  
  MsgBox.Open (30, 4,49,22);
  
  Col := 0;
  Row := 0;
  Repeat
    DrawChars;
    Select(Col,Row);
    Case ReadKey Of
      #13: Begin
            GetChar := Col+16*Row;
            Break;
          End;
      #27: Begin
            GetChar := 0;
            Break;
          End;
      #00: Case ReadKey Of
        KeyCursorUp   : If Row > 0 Then Dec(Row);
        KeyCursorDown : If Row < 15 Then Inc(Row);
        KeyCursorLeft : If Col > 0 Then Dec(Col);
        KeyCursorRight : If Col < 15 Then Inc(Col);
      End;
    End;
  Until False;
  MsgBox.Close;
  MsgBox.Free;
  GotoXY(X,Y);

End;

Function GetOpenFileName(Header,xFerPath: String) : String;
Const
  ColorBox = 7;
  ColorBar = 15 + 3 * 16;
Var
  DirList  : TMenuList;
  FileList : TMenuList;
  
  Str      : String;
  Path     : String;
  Mask     : String;
  OrigDIR  : String;

  Procedure UpdateInfo;
  Begin
    WriteXY (8,  7, 15 + 3 * 16, strPadR(Path, 60, ' '));
    WriteXY (8, 21, 15 + 3 * 16, strPadR(Mask, 60, ' '));
  End;

  Procedure CreateLists;
  Var
    Dir      : SearchRec;
    DirSort  : TQuickSort;
    FileSort : TQuickSort;
    Count    : LongInt;
  Begin
    DirList.Clear;
    FileList.Clear;

    While Path[Length(Path)] = PathSep Do Dec(Path[0]);

    ChDir(Path);

    Path := Path + PathSep;

    If IoResult <> 0 Then Exit;

    DirList.Picked  := 1;
    FileList.Picked := 1;

    UpdateInfo;

    DirSort  := TQuickSort.Create;
    FileSort := TQuickSort.Create;

    FindFirst (Path + '*', AnyFile - VolumeID, Dir);

    While DosError = 0 Do Begin
      If (Dir.Attr And Directory = 0) or ((Dir.Attr And Directory <> 0) And (Dir.Name = '.')) Then Begin
        FindNext(Dir);
        Continue;
      End;

      DirSort.Add (Dir.Name, 0);
      FindNext    (Dir);
    End;

    FindClose(Dir);

    FindFirst (Path + Mask, AnyFile - VolumeID, Dir);

    While DosError = 0 Do Begin
      If Dir.Attr And Directory <> 0 Then Begin
        FindNext(Dir);

        Continue;
      End;

      FileSort.Add(Dir.Name, 0);
      FindNext(Dir);
    End;

    FindClose(Dir);

    DirSort.Sort  (1, DirSort.Total,  qAscending);
    FileSort.Sort (1, FileSort.Total, qAscending);

    For Count := 1 to DirSort.Total Do
      DirList.Add(DirSort.Data[Count]^.Name, 0);

    For Count := 1 to FileSort.Total Do
      FileList.Add(FileSort.Data[Count]^.Name, 0);

    DirSort.Free;
    FileSort.Free;

    WriteXY (14, 9, 7*16, strPadR('(' + strComma(FileList.ListMax) + ')', 7, ' '));
    WriteXY (53, 9, 7*16, strPadR('(' + strComma(DirList.ListMax) + ')', 7, ' '));
  End;

Var
  Box  : TMenuBox;
  Done : Boolean;
  Mode : Byte;
Begin
  Result   := '';
  Path     := XferPath;
  Mask     := '*.*';
  Box      := TMenuBox.Create;
  DirList  := TMenuList.Create;
  FileList := TMenuList.Create;

  GetDIR (0, OrigDIR);

  FileList.NoWindow   := True;
  FileList.LoChars    := #9#13#27;
  FileList.HiChars    := #77;
  FileList.HiAttr     := ColorBar;
  FileList.LoAttr     := ColorBox;

  DirList.NoWindow    := True;
  DirList.NoInput     := True;
  DirList.HiAttr      := ColorBox;
  DirList.LoAttr      := ColorBox;

  //Box.Header := ' Upload file ';
  Box.Header := Header;
  Box.HeadAttr := 15+7*16;
  Box.Open (6, 5, 74, 22);

  WriteXY ( 8,  6, 7*16, 'Directory');
  WriteXY ( 8,  9, 7*16, 'Files');
  WriteXY (41,  9, 7*16, 'Directories');
  WriteXY ( 8, 20, 7*16, 'File Mask');
  WriteXY ( 8, 21,  15+3*16, strRep(' ', 40));

  CreateLists;

  DirList.Open (40, 9, 72, 19);
  DirList.Update;

  Done := False;

  Repeat
    FileList.Open (7, 9, 39, 19);

    Case FileList.ExitCode of
      #09,
      #77 : Begin
              FileList.HiAttr := ColorBox;
              DirList.NoInput := False;
              DirList.LoChars := #09#13#27;
              DirList.HiChars := #75;
              DirList.HiAttr  := ColorBar;

              FileList.Update;

              Repeat
                DirList.Open(40, 9, 72, 19);

                Case DirList.ExitCode of
                  #09 : Begin
                          DirList.HiAttr := ColorBox;
                          DirList.Update;

                          Mode  := 1;
                          
                          xMenuInput.LoChars := #09#13#27;
                          xMenuInput.FillAttr := 15+0*16;
                          xMenuInput.Attr := 15+3*16;
                          Repeat
                            Case Mode of
                              1 : Begin
                                    xMenuInput.Attr := 15+3*16;
                                    Str := GetStr(8, 21, 60, 255, 1, Mask);

                                    Case xMenuInput.ExitCode of
                                      #09 : Mode := 2;
                                      #13 : Begin
                                              Mask := Str;
                                              CreateLists;
                                              FileList.Update;
                                              DirList.Update;
                                            End;
                                      #27 : Begin
                                              Done := True;
                                              Break;
                                            End;
                                    End;
                                  End;
                              2 : Begin
                                    UpdateInfo;
                                    xMenuInput.Attr := 15+3*16;
                                    Str := GetStr(8, 7, 60, 255, 1, Path);

                                    Case xMenuInput.ExitCode of
                                      #09 : Break;
                                      #13 : Begin
                                              ChDir(Str);

                                              If IoResult = 0 Then Begin
                                                Path := Str;
                                                CreateLists;
                                                FileList.Update;
                                                DirList.Update;
                                              End;
                                            End;
                                      #27 : Begin
                                              Done := True;
                                              Break;
                                            End;
                                    End;
                                  End;
                            End;
                          Until False;
                          UpdateInfo;
                          Break;
                        End;
                  #13 : If DirList.ListMax > 0 Then Begin
                          ChDir  (DirList.List[DirList.Picked]^.Name);
                          GetDir (0, Path);

                          Path := Path + PathSep;

                          CreateLists;
                          FileList.Update;
                        End;
                  #27 : Done := True;
                  #75 : Break;
                End;
              Until Done;

              DirList.NoInput := True;
              DirList.HiAttr  := ColorBox;
              FileList.HiAttr := ColorBar;
              DirList.Update;
            End;
      #13 : If FileList.ListMax > 0 Then Begin
              Result := Path + FileList.List[FileList.Picked]^.Name;
              Break;
            End;
      #27 : Break;
    End;
  Until Done;

  ChDIR(OrigDIR);

  FileList.Free;
  DirList.Free;
  Box.Close;
  Box.Free;
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
  
  SavedX     := WhereX;
  SavedY     := WhereY;
  SavedA     := GetTextAttr;

  MsgBox := TMenuBox.Create;

  Len := (80 - (Length(Str) + 2)) DIV 2;
  Pos := 1;
  MsgBox.Header     := ' Info ';
  MsgBox.FrameType  := 6;
  MsgBox.HeadAttr   := 112;
  MsgBox.BoxAttr    := 127;
  MsgBox.BoxAttr2   := 120;
  MsgBox.BoxAttr3   := 127;
  MsgBox.BoxAttr4   := 120;
  MsgBox.Box3D      := True;

  If ScreenHeight = 50 Then Offset := 12 Else Offset := 0;

  If BoxType < 2 Then
    MsgBox.Open (Len, 10 + Offset, Len + Length(Str) + 3, 15 + Offset)
  Else
    MsgBox.Open (Len, 10 + Offset, Len + Length(Str) + 3, 14 + Offset);

  WriteXY (Len + 2, 12 + Offset, 15+7*16, Str);

  Case BoxType of
    0 : Begin
          Len2 := (Length(Str) - 4) DIV 2;

          WriteXY (Len + Len2 + 2, 14 + Offset, 15+3*16, ' OK ');

          Repeat
            ReadKey;
          Until Not KeyPressed;
        End;
    1 : Repeat
          Len2 := (Length(Str) - 9) DIV 2;

          WriteXY (Len + Len2 + 2, 14 + Offset, 8+7*16, ' YES ');
          WriteXY (Len + Len2 + 7, 14 + Offset, 8+7*16, ' NO ');

          If Pos = 1 Then
            WriteXY (Len + Len2 + 2, 14 + Offset, 15+3*16, ' YES ')
          Else
            WriteXY (Len + Len2 + 7, 14 + Offset, 15+4*16, ' NO ');

          Case UpCase(ReadKey) of
            #00 : Case ReadKey of
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
  GotoXY (SavedX, SavedY);
  SetTextAttr (SavedA);
End;

Procedure AboutBox(Title:String);
Var
  Box:TMenuBox;
Begin
  Box := TMenuBox.Create;
  Box.Open (19, 7, 62, 19);

  WriteXY (21,  8,  31, strPadC(Title, 40, ' '));
  WriteXY (21,  9, 112, strRep('-', 40));
  WriteXY (30, 10, 113, 'Copyright (C) 2016');
  WriteXY (22, 11, 113, 'All Rights Reserved for the ANSI Scene');
  WriteXY (21, 13, 113, strPadC('Version 0.8 Beta', 40, ' '));
  WriteXY (34, 16, 113, 'andr01d.zapto.org:9999');
  WriteXY (32, 15, 113, 'xqtr@gmx.com');
  WriteXY (21, 17, 112, strRep('-', 40));
  WriteXY (21, 18,  31, strPadC('(.. Press A Key ..', 40, ' '));

  ReadKey;

  Box.Close;
  Box.Free;
End;

Function YesNo(Title,Prompt:String):Boolean;
Var
  Image : TScreenBuf;
  Res : Boolean = False;
  x     : Byte = 12;
  y     : Byte = 10;
Begin

    SaveScreen (Image);
    ClearArea(x+1,y+1,x+57,y+5,' ');
    WideBox(x,y);
    WriteXY(x+5,y+1,7*16,'                            ');
 
    WriteXY(x+3,y+2,7*16,StrPadC(Prompt,49,' '));
    WriteXY(x+3,y+1,7*16,Title);
    Res := GetYN(x+22,y+3,15+2*16,15+4*16,7*16,False);
    
    RestoreScreen (Image);
  Result:=Res;
End;

Function  InputBox(x1,y1,x2,y2:byte; title,prompt:String; var Input:String):Boolean;
Var
  Pos    : Byte;
  MsgBox : TMenuBox;
  SavedX : Byte;
  SavedY : Byte;
  SavedA : Byte;
  M      : Byte;
  
Begin
  Result := True;
  M := X1+((X2-X1) Div 2);
  SavedX     := WhereX;
  SavedY     := WhereY;
  SavedA     := GetTextAttr;

  MsgBox := TMenuBox.Create;

  Pos := 1;
  MsgBox.Header     := title;
  MsgBox.FrameType  := 6;
  MsgBox.HeadAttr   := 112;
  MsgBox.BoxAttr    := 127;
  MsgBox.BoxAttr2   := 120;
  MsgBox.BoxAttr3   := 127;
  MsgBox.BoxAttr4   := 120;
  MsgBox.Box3D      := True;

  MsgBox.Open (x1,y1,x2,y2);

  WriteXY (x1+2, y1+1, 15+7*16, Prompt);
  WriteXY (M-5, y2-1, 8+7*16, ' YES ');
  WriteXY (M+5, y2-1, 8+7*16, ' NO ');
  Input:=GetStr (X1+2, Y1+2, x2-x1-3, x2-x1-3, 1, Input);
  Repeat
  
  WriteXY (M-5, y2-1, 8+7*16, ' YES ');
  WriteXY (M+5, y2-1, 8+7*16, ' NO ');

    If Pos = 1 Then
      WriteXY (M-5, y2-1, 15+3*16, ' YES ')
    Else
      WriteXY (M+5, y2-1, 15+4*16, ' NO ');
      
    

    Case UpCase(ReadKey) of
      #00 : Case ReadKey of
              #75 : Pos := 1;
              #77 : Pos := 0;
            End;
      #13 : Begin
              Result := Boolean(Pos);
              Break;
            End;
      #32 : If Pos = 0 Then Inc(Pos) Else Pos := 0;
      'N' : Begin
              Result := False;
              Break;
            End;
      'Y' : Begin
              Result := True;
              Break;
            End;
    End;
  Until False;

  MsgBox.Free;
  GotoXY (SavedX, SavedY);
  SetTextAttr (SavedA);
End;

End.
