unit xeditspin;

{$Mode objfpc}
interface

Uses
  
  m_types;

const
  ShadowAttr = 0;
//{$ifdef windows}

Type

teditspin=Class
    Image      : TConsoleImageRec;
    HideImage  : ^TConsoleImageRec;
  
    Shadow     : Boolean;
    ShadowAttr : Byte;
    WasOpened  : Boolean;
    ffg        : byte;
    fbg        : byte;
    fselfg     : byte;
    fselbg     : byte;
    fvalue     : integer;
    fmin       : integer;
    fmax       : integer;

    Constructor Create;
    Destructor  Destroy; Override;
    Procedure   Open (X, Y: Byte);
    Procedure   Close;
    Procedure   Hide;
    Procedure   Show;
    Property  fg    : byte read ffg write ffg;
    Property  bg    : byte read fbg write fbg;
    Property  selfg : byte read fselfg write fselfg;
    Property  selbg : byte read fselbg write fselbg;
    property  Value  : integer read fvalue write fvalue;
    property  max   : integer read fmax write fmax;
    property  min   : integer read fmin write fmin;
End;

//{$endif}
  

implementation

Uses
  xStrings,
  xcrt;

Constructor Teditspin.Create;
Begin
  Inherited Create;

  Shadow     := True;
  ShadowAttr := 8;
  ffg:=white;
  fbg:=blue;
  fselfg:=yellow;
  fselbg:=red;
  HideImage  := NIL;
  WasOpened  := False;
  fvalue:=0;
  fmin:=0;
  fmax:=0;


  FillChar(Image, SizeOf(TConsoleImageRec), 0);
  BufFlush;
End;


Procedure Teditspin.Open(x,y:byte);
var
  c,ch:char;
  ok:boolean;
  vl:integer;
  l:byte;
  b,a:byte;
begin
  ok:=false;
  if fmax<>0 then l:=length(Int2Str(fmax)) else l:=4;
  vl:=fmin;
  If Shadow Then
      SaveScreen(Image)
    Else
      SaveScreen(Image);

  repeat

  writexy(x,y,ffg+fbg*16,strpadc('/\',l,' '));
  writexy(x,y+1,fselfg+fselbg*16,strpadl(Int2Str(vl),l,' '));
  writexy(x,y+2,ffg+fbg*16,strpadc('\/',l,' '));

  If Shadow Then Begin
     For B := X + 1 to x+l+1 Do
        Begin
        Ch := GetCharAt(b, y+3);
        WriteXY (b, y+3, ShadowAttr, Ch);
      End;
     for a:=y+1 to y+3 do
     Begin
        Ch := GetCharAt(x+l+1, a);
        WriteXY (x+l+1, a, ShadowAttr, Ch);
      End;
  end;

  C := ReadKey;
  case c of
    #75: begin end; //left
    #77: begin end; //right
    #72: begin //up
         vl:=vl+1;
         if (vl>fmax) and (fmax<>0) then vl:=fmin;
    end;
    #80: begin //down
         vl:=vl-1;
         if (vl<fmin) and (fmax<>0) then vl:=fmax;
    end;
    #13: begin
         fvalue:=vl;

    ok:=true;end;
    #27: begin ok:=true;end;
  end;
  until ok;
end;


Destructor Teditspin.Destroy;
Begin
  
  Inherited Destroy;
End;

Procedure teditspin.Close;
Begin
  If WasOpened Then RestoreScreen(Image);
End;

Procedure Teditspin.Hide;
Begin
  If Assigned(HideImage) Then FreeMem(HideImage, SizeOf(TConsoleImageRec));

  GetMem (HideImage, SizeOf(TConsoleImageRec));

  SaveScreen (HideImage^);
  RestoreScreen (Image);
End;

Procedure Teditspin.Show;
Begin
  If Assigned (HideImage) Then Begin
    RestoreScreen(HideImage^);
    FreeMem (HideImage, SizeOf(TConsoleImageRec));
    HideImage := NIL;
  End;
End;


End.
