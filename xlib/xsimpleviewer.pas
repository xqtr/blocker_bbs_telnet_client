Unit xSimpleViewer;
{$MODE objfpc}
{$H-}

Interface

Uses 
  Classes;

Type
  TSimpleViewer = Class
    Lines : TStringList;
    X     : Byte;
    Y     : Byte;
    Width : Byte;
    Height : Byte;
    Justify : Boolean;
    TopLine : Integer;
    Attr    : Byte;
    ExitChars:String;
    DoWrap     : Boolean;
    DoBar      : Boolean;
    BarBgC : Char;
    BarFgC : Char;
    BarBgCl: Byte;
    BarFgCl: Byte;
    Constructor Create;
    Destructor Destroy;
    Procedure Add(S:String);
    Procedure LoadFromFile(F:String);
    Procedure Draw;
    Function Keys:Char;
  End;

  
Implementation

Uses 
  xCrt,xStrings,xFileIO;
  
Constructor TSimpleViewer.Create;
Begin
  Inherited Create;
  Width := 79;
  Height :=25;
  Lines := TStringList.Create;
  Justify := False;
  TopLine := 0;
  Attr := 7;
  ExitChars:=#13+#27;
  X:=1;
  Y:=1;
  DoWrap := False;
  DoBar  := False;
  BarBgC := Chr(176);
  BarFgC := Chr(178);
  BarBgCl:=8;
  BarFgCl:=15;
  
End;

Destructor TSimpleViewer.Destroy;
Begin
  Lines.Clear;
  Lines.Free;
  Inherited Destroy;
End;
  
Procedure TSimpleViewer.Add(S:String);
Var
 tmp :String;
Begin
  tmp:=s;
  If Length(S) <=Width Then Lines.Add(S) Else 
    If DoWrap then begin
    While Length(tmp) > width do
      Lines.Add(Wrap(tmp,Width,justify));
    Lines.Add(tmp);
    End Else Lines.add(copy(s,1,width));
End;

Procedure TSimpleViewer.LoadFromFile(F:String);  
Var
  i : Integer;
  S : String;
Begin
  If FileExist(F) Then Lines.LoadFromFile(F);
  If Lines.COunt=0 Then Exit;
  i:=0;
  While i<=Lines.Count-1 Do Begin
    If Length(Lines[i])>Width Then 
      If DoWrap then Begin
        S:=Lines[i];
        Lines[i]:=Wrap(S,Width,Justify);
        While Length(S) <> 0 do Begin
          Lines.Insert(I+1,Wrap(S,Width,Justify));
          i:=i+1;
        End;
      End else Lines[i]:=Copy(lines[i],1,width);
    i:=i+1;
  End;
End;

Procedure TSimpleViewer.Draw;
Var
  i : Byte = 0;
Begin
  Screen.TextAttr:=Attr;
  ClearArea(x,y,x+Width,y+height-1,' ');
  While i<=Height-1 Do Begin
    If TopLine+i <= Lines.Count -1 Then WriteXYPipe(x,y+i,Attr,Lines[TopLine+i])
      Else WriteXY(x,y+i,Attr,StrRep(' ',Width));
    i:=i+1;
  End;
  If DoBar=False THen Exit;
  For i:=0 to height-1 Do WriteXY(x+width,y+i,BarBGCl,BarBgC);
  WriteXY(x+width,y+(TopLine+Height-1) * (Height-1) Div Lines.Count,BarFGCl,BarFgC);  
End;

Function TSimpleViewer.Keys:Char;
Var
  C : Char;
  DOne : Boolean = False;
Begin
  Repeat
    C:=Readkey;
    if Pos(C,ExitChars)>0 Then Begin
      Result:=C;
      Done:=True;
    End;
    If C=#00 Then Begin
      C:=Readkey;
      if Pos(C,ExitChars)>0 Then Begin
        Result:=C;
        Done:=True;
      End;
      Case C Of
        Home        : TopLine:=0;
        EndKey      : If Lines.Count < Height Then TopLine:=0 
                        Else TopLine := Lines.Count -1 - Height;
        CursorUp    : Begin
                        TopLine:=TopLine - 1;
                        If TopLine <0 Then TOpline:=0;
                      End;
        CursorDown  : Begin
                        TopLine:=TopLine + 1;
                        If TopLine > Lines.Count-1 Then TOpline:=Lines.Count-1
                      End;
        PGUP        : Begin
                        TopLine:=TopLine - Height + 1;
                        If TopLine <0 Then TOpline:=0;
                      End;
        PGDN        : Begin
                        TopLine:=TopLine + Height - 1;
                        If TopLine > Lines.Count-1 Then TOpline:=Lines.Count-1
                      End;
      End;
      Draw;
    End;
  Until Done;
End;

End.
