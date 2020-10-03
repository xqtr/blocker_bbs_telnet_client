unit xedittime;

{$Mode objfpc}
interface

Uses
  m_Types;

const
  ShadowAttr = 0;
//{$ifdef windows}

Type

tedittime=Class
   
    Image      : TConsoleImageRec;
    HideImage  : ^TConsoleImageRec;
  
    Shadow     : Boolean;
    ShadowAttr : Byte;
    WasOpened  : Boolean;
    ffg        : byte;
    fbg        : byte;
    fselfg     : byte;
    fselbg     : byte;
    ftimestr   : string;
    fhour      : word;
    fmin       : word;
 
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
    property  timestr  : string read ftimestr;
    property  hour : word read fhour write fhour;
    property  min  : word read fmin write fmin;
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

Constructor Tedittime.Create;
var
 sec,mil:word;
Begin
  Inherited Create;
  Shadow     := True;
  ShadowAttr := 8;
  ffg:=white;
  fbg:=blue;
  fselfg:=yellow;
  fselbg:=red;
  fhour:=00;
  fmin:=0;
  HideImage  := NIL;
  WasOpened  := False;
  decodetime(time,fhour,fmin,sec,mil);
  ftimestr:=timetostr(date);


  FillChar(Image, SizeOf(TConsoleImageRec), 0);
  BufFlush;
End;

Procedure Tedittime.Open(x,y:byte);
var
  w,a,b,i,x1,y1:byte;
  sel,l:byte;
  c,ch:char;
  ok:boolean;
  q,s:string;
  h,m:word;
begin
  ok:=false;
  sel:=1;
  l:= 9;
  If Shadow Then
      SaveScreen(Image)
    Else
      SaveScreen(Image);

  m:=fmin;
  h:=fhour;
  repeat

  writexy(x,y,ffg+fbg*16,' /\ | /\ ');
  writexy(x,y+1,ffg+fbg*16,' '+strpadl(Int2Str(h),2,'0')+' | '+strpadl(Int2Str(m),2,'0'));
  writexy(x,y+2,ffg+fbg*16,' \/ | \/ ');
  case sel of
  1: writexy(x+1,y+1,fselfg+fselbg*16,strpadl(Int2Str(h),2,'0'));
  2: writexy(x+6,y+1,fselfg+fselbg*16,strpadl(Int2Str(m),2,'0'));
  end;


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
    #75: begin sel:=sel-1; if sel<1 then sel:=2; end; //left
    #77: begin sel:=sel+1; if sel>2 then sel:=1; end; //right
    #72: begin //up
           case sel of
           1: begin
              h:=h+1;
              if h>24 then h:=1;
           end;
           2: begin
              m:=m+1;
              if m>59 then begin
                m:=0;
                h:=h+1;
                if h>24 then h:=0;
              end;
           end;
           end;
    end;
    #80: begin //down
         case sel of
           1: begin
              h:=h-1;
              if h<1 then h:=24
           end;
           2: begin
              m:=m-1;
              if m>60 then begin
                m:=59;
                h:=h-1;
                if h<1 then h:=24
              end;
           end;
         end;
    end;
    #13: begin
        fhour:=h;
        fmin:=m;
        ftimestr:=strpadl(Int2Str(fhour),2,'0')+':'+strpadl(Int2Str(fmin),2,'0');
        ok:=true;
        end;
    #27: begin ok:=true;end;
  end;
  until ok;
end;


Destructor Tedittime.Destroy;
Begin
  Inherited Destroy;
End;

Procedure tedittime.Close;
Begin
  If WasOpened Then RestoreScreen(Image);
End;

Procedure Tedittime.Hide;
Begin
  If Assigned(HideImage) Then FreeMem(HideImage, SizeOf(TConsoleImageRec));

  GetMem (HideImage, SizeOf(TConsoleImageRec));

  SaveScreen (HideImage^);
  RestoreScreen (Image);
End;

Procedure Tedittime.Show;
Begin
  If Assigned (HideImage) Then Begin
    RestoreScreen(HideImage^);
    FreeMem (HideImage, SizeOf(TConsoleImageRec));
    HideImage := NIL;
  End;
End;


End.
