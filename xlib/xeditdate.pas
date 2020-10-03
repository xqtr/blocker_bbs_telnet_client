unit xeditdate;

{$Mode objfpc}
interface

Uses
  m_Types;

const
  ShadowAttr = 0;
//{$ifdef windows}

Type

teditdate=Class
    Image      : TConsoleImageRec;
    HideImage  : ^TConsoleImageRec;
  
    Shadow     : Boolean;
    ShadowAttr : Byte;
    WasOpened  : Boolean;
    ffg        : byte;
    fbg        : byte;
    fselfg     : byte;
    fselbg     : byte;
    fmonth     : word;
    fdate      : word;
    fyear      : word;
    fdatestr   : string;

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
    property  datestr  : string read fdatestr;
    property  month : word read fmonth write fmonth;
    property  date  : word read fdate write fdate;
    property  year  : word read fyear write fyear;
End;


Var
  screenheight:byte = 25;
  screenwidth:byte = 80;
//{$endif}
  

implementation

Uses
  xStrings,
  xCrt,
  sysutils;

Constructor Teditdate.Create;
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
  decodedate(date,fyear,fmonth,fdate);
  fdatestr:=datetostr(date);


  FillChar(Image, SizeOf(TConsoleImageRec), 0);
  BufFlush;
End;

function dayofmonth(d:byte; y:word):byte;
begin
case d of
1: dayofmonth:=31;
2: if isleapyear(y) then dayofmonth:=29 else dayofmonth:=28;
3: dayofmonth:=31;
4: dayofmonth:=30;
5: dayofmonth:=31;
6: dayofmonth:=31;
7: dayofmonth:=31;
8: dayofmonth:=31;
9: dayofmonth:=31;
10:dayofmonth:=31;
11:dayofmonth:=31;
12:dayofmonth:=31;
end;
end;

Procedure Teditdate.Open(x,y:byte);
var
  w,a,b,i,x1,y1:byte;
  sel:byte;
  c,ch:char;
  ok:boolean;
  q,s:string;
  yr,d,m:word;
begin
  ok:=false;
  sel:=1;
  If Shadow Then
      SaveScreen(Image)
    Else
      SaveScreen(Image);

  yr:=fyear;
  m:=fmonth;
  d:=fdate;
  repeat

  writexy(x,y,ffg+fbg*16,'/\ | /\ |  /\ ');
  writexy(x,y+1,ffg+fbg*16,strpadl(Int2Str(d),2,'0')+' | '+strpadl(Int2Str(m),2,'0')+' | '+strpadl(Int2Str(yr),4,'0'));
  writexy(x,y+2,ffg+fbg*16,'\/ | \/ |  \/ ');
  case sel of
  1: writexy(x,y+1,fselfg+fselbg*16,strpadl(Int2Str(d),2,'0'));
  2: writexy(x+5,y+1,fselfg+fselbg*16,strpadl(Int2Str(m),2,'0'));
  3: writexy(x+10,y+1,fselfg+fselbg*16,strpadl(Int2Str(yr),4,'0'));
  end;


  If Shadow Then Begin
     For B := X + 1 to x+14 Do
        Begin
        Ch := GetCharAt(b, y+3);
        WriteXY (b, y+3, ShadowAttr, Ch);
      End;
     for a:=y+1 to y+3 do
     Begin
        Ch := GetCharAt(x+14, a);
        WriteXY (x+14, a, ShadowAttr, Ch);
      End;
  end;

  C := ReadKey;
  case c of
    #75: begin sel:=sel-1; if sel<1 then sel:=3; end; //left
    #77: begin sel:=sel+1; if sel>3 then sel:=1; end; //right
    #72: begin //up
           case sel of
           1: begin
              d:=d+1;
              if d>dayofmonth(m,yr) then d:=1;
           end;
           2: begin
              m:=m+1;if m>12 then m:=1;
           end;
           3: begin
              yr:=yr+1;if yr>3000 then yr:=0;
           end;
           end;
    end;
    #80: begin //down
         case sel of
           1: begin
              d:=d-1;
              if d<1 then d:=dayofmonth(m,yr);
           end;
           2: begin
              m:=m-1;if m<1 then m:=12;
           end;
           3: begin
              yr:=yr-1;if yr<0 then yr:=3000;
           end;
           end;
    end;
    #13: begin
    fdate:=d;
        fmonth:=m;
        fyear:=yr;
        fdatestr:=strpadl(Int2Str(fdate),2,'0')+'/'+strpadl(Int2Str(fmonth),2,'0')+'/'+strpadl(Int2Str(fyear),4,'0');
    ok:=true;end;
    #27: begin ok:=true;end;
  end;
  until ok;
end;


Destructor Teditdate.Destroy;
Begin
  Inherited Destroy;
End;

Procedure teditdate.Close;
Begin
  If WasOpened Then RestoreScreen(Image);
End;

Procedure Teditdate.Hide;
Begin
  If Assigned(HideImage) Then FreeMem(HideImage, SizeOf(TConsoleImageRec));

  GetMem (HideImage, SizeOf(TConsoleImageRec));

  SaveScreen (HideImage^);
  RestoreScreen (Image);
End;

Procedure Teditdate.Show;
Begin
  If Assigned (HideImage) Then Begin
    RestoreScreen(HideImage^);
    FreeMem (HideImage, SizeOf(TConsoleImageRec));
    HideImage := NIL;
  End;
End;


End.
