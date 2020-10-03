unit xprogressbar;

{$Mode objfpc}
interface

Uses
  m_Types,
  xStrings,
  xCrt,
  xmenubox;

Type

  tprogressbar=Class
    Image      : TConsoleImageRec;
    HideImage  : ^TConsoleImageRec;
    ftitle     : string;
    fShadow     : Boolean;
    ShadowAttr : Byte;
    WasOpened  : Boolean;
    ffg        : byte;
    fbg        : byte;
    fselfg     : byte;
    fselbg     : byte;
    ftext      : string;
    fmax       : integer;
    fmin       : integer;
    fpos       : integer;
    fbarfg,fbarbg:byte;
    fx,fy,fw,fh:byte;
    procedure changepos(fopos:integer);
    Constructor Create;
    Destructor  Destroy; Override;
    Procedure   Open (X, Y, w,h,boxtype: Byte);
    Procedure   Close;
    Procedure   Hide;
    Procedure   Show;

    Property    Max:integer read fmax write fmax;
    Property    Min:integer read fmin write fmin;
    Property    Position:integer read fpos write changepos;
    Property    Shadow:boolean read fshadow write fshadow;
    Property    fg:byte read ffg write ffg;
    Property    bg:byte read fbg write fbg;
    property    selfg:byte read fselfg write fselfg;
    property    selbg:byte read fselbg write fselbg;
    Property    Title:string read ftitle write ftitle;
    property    Text:string read ftext write ftext;
    Property    BarFg:byte read fbarfg write fbarfg;
    property    barbg:byte read fbarbg write fbarbg;
  end;

implementation

Constructor TProgressBar.Create;
Begin
  Inherited Create;

  Shadow     := True;
  ShadowAttr := 8;
  HideImage  := NIL;
  WasOpened  := False;
  ftitle:='';
  ftext:='';
  fmin:=0;
  fmax:=100;
  fpos:=0;
  fbarfg:=red;
  fbarbg:=blue;

  FillChar(Image, SizeOf(TConsoleImageRec), 0);
  BufFlush;
End;

Destructor TProgressBar.Destroy;
Begin
  Inherited Destroy;
End;

Procedure TProgressBar.changepos(fopos:integer);
var
  i,d:integer;
  at,b:byte;
  s:string;
begin
  if (fopos<fmin) or (fopos>fmax) then begin
    writexy(fx+(fw div 2)-(length('Invalid Position') div 2),fy+fh-2,ffg+fbg*16,'Invalid Position');
    exit;
    end;

  writexy(fx+2,fy+fh-2,fbarfg+fbarbg*16,strrep(' ',fw-3));
  i:=trunc(( (fopos-fmin) / (fmax-fmin)) * 100);
  d:=(i * (fw-3)) div 100;
  writexy(fx+2,fy+fh-2,fbarfg+fbarfg*16,strrep(' ',d));
  s:=Int2Str(i)+'%';
  for b:=1 to length(s) do begin
    at:=GetAttrAt(fx-1+b+(fw div 2)-(length(Int2Str(i)) div 2),fy+fh-2);
    writexy(fx-1+b+(fw div 2)-(length(s) div 2),fy+fh-2,at-fbarfg+fselfg,s[b]);
  end;

end;

Procedure TProgressBar.Open(x,y,w,h,boxtype:byte);
var
  str2:string;
  i,d:integer;
begin
  fx:=x;
  fy:=y;
  fw:=w;
  fh:=h;
  If Not WasOpened Then
    If Shadow Then
      SaveScreen(Image)
    Else
      SaveScreen(Image);
  WasOpened := True;
  box3d(x,y,w,h,true);
  if fshadow then ShadowBox(x,y,w,h,shadowattr);
  if ftitle<>'' then begin
    writexypipe(x+(w div 2)-(strmcilen(ftitle) div 2),y,ffg+fbg*16,ftitle);
  end;

  if (ftext<>'') then begin
     writexypipe(x+1,y+1,ffg+fbg*16,ftext);

  end;
  changepos(fpos);
end;

Procedure TProgressBar.Close;
Begin
  If WasOpened Then RestoreScreen(Image);
End;

Procedure TProgressBar.Hide;
Begin
  If Assigned(HideImage) Then FreeMem(HideImage, SizeOf(TConsoleImageRec));

  GetMem (HideImage, SizeOf(TConsoleImageRec));

  SaveScreen (HideImage^);
  RestoreScreen (Image);
End;

Procedure TProgressBar.Show;
Begin
  If Assigned (HideImage) Then Begin
    RestoreScreen(HideImage^);
    FreeMem (HideImage, SizeOf(TConsoleImageRec));
    HideImage := NIL;
  End;
End;

end.
