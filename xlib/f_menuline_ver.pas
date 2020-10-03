unit f_menuline_ver;

{$I M_OPS.PAS}
{$M objfpc}
interface

Uses
  sysutils,
  m_Types,
  f_Strings,
  f_Output,
  m_Input;

const
  ShadowAttr = 0;
//{$ifdef windows}
Var
  screenheight:byte = 25;
  screenwidth:byte = 80;
//{$endif}

type
  Tmitems=array[0..4] of string[20];
  tthumb=array of string;
  tthumbs=array of tthumb;
 
   Titem_desc=record
    caption:string[30];
    key:string;
    enabled:boolean;
    keystroke:string;
    hassubmenu:boolean;
    submenu:string[20];
    desc:string;
    result:string;
    end;

  tmenuline_ver=Class
    Console    : TOutput;
    inkey      : Tinput;
    List       : Array[1..30] of ^titem_desc;
    Image      : TConsoleImageRec;
    HideImage  : ^TConsoleImageRec;
  
    Shadow     : Boolean;
    fopened    : boolean;
    ShadowAttr : Byte;
    HeadAttr   : Byte;
    HeadType   : Byte;
    Header     : String;
    WasOpened  : Boolean;
    ffg        : byte;
    fbg        : byte;
    fselfg     : byte;
    fselbg     : byte;
    fresult    : string;
    listmax    : integer;
    fbar       : boolean;

    Constructor Create (Var Screen: TOutput);
    Destructor  Destroy; Override;
    Procedure   Open (X, Y: Byte);
    Procedure   Close;
    Procedure   Hide;
    Procedure   Show;
    //Procedure   Update;
    Procedure   Clear;
    Procedure   Delete (RecPos : Word);
    Procedure   Add (Str,desc,keystroke,submenu,res : String; key:string; enabled,hassubmenu:boolean);//; B : Byte);
    Procedure   Get (Num: Word; Var Str: String; Var B: Boolean);

    Property  fg    : byte read ffg write ffg;
    Property  bg    : byte read fbg write fbg;
    Property  selfg : byte read fselfg write fselfg;
    Property  selbg : byte read fselbg write fselbg;
    property result : string read fresult write fresult;
    property showbar: boolean read fbar write fbar;
    property opened : boolean read fopened write fopened;
  End;

implementation

{

      Foreground colors:
                   0 - Black         6 - Brown           12 - Light Red
                   1 - Blue          7 - Light Grey      13 - Light Magenta
                   2 - Green         8 - Dark Grey       14 - Yellow
                   3 - Cyan          9 - Light Blue      15 - White
                   4 - Red          10 - Light Green
                   5 - Magenta      11 - Light Cyan

                   Background colors:
                   0 - Black         4 - Red
                   1 - Blue          5 - Magenta
                   2 - Green         6 - Brown
                   3 - Cyan          7 - Gray


 -1 escape
 -2 up
 -3 down
 -4 left
 -5 right
}

Constructor Tmenuline_ver.Create (Var Screen: TOutput);
Begin
  Inherited Create;
 inkey      := TInput.Create;
  Console    := Screen;
  Shadow     := True;
  listmax    := 0;
  ShadowAttr := 8;
  Header     := '';
  ffg:=1;
  fbg:=16;
  fselfg:=7;
  fselbg:=17;
  HideImage  := NIL;
  WasOpened  := False;
  fresult    := '-1';
  fbar       := false;
  fopened:=false;

  FillChar(Image, SizeOf(TConsoleImageRec), 0);
  Console.BufFlush;
End;

Destructor Tmenuline_ver.Destroy;
Begin
  inkey.free;
  clear;

  Inherited Destroy;
  
End;


Procedure Tmenuline_ver.Open(x,y:byte);
var
  w,w1,a,b,i,x1,y1:byte;
  sel:integer;
  c,ch:char;
  ok:boolean;
  q,s:string;

  procedure showbar(picked:integer);
  begin
    console.writexypipe(1,screenheight,fg+bg*16,screenwidth,list[picked]^.desc);
  end;

begin
  w:=0;w1:=0;
  ok:=false;
  sel:=1;
  s:='';
  fopened:=true;
  for i:=1 to listmax do
    if length(list[i]^.caption)>w then w:=length(list[i]^.caption);
  for i:=1 to listmax do
    if length(list[i]^.keystroke)>w1 then w1:=length(list[i]^.keystroke);
  w:=w+w1+2;
  if y+listmax>screenheight then y1:=screenheight-listmax else y1:=y;
  if x+w>screenwidth then x1:=screenwidth-w else x1:=x;
  If Shadow Then
      Console.GetScreenImage(X1, Y1, x1+w, y1 + listmax + 1, Image)
    Else
      Console.GetScreenImage(X1, Y1, x1+w, y1 + listmax, Image);
  repeat
  
  for i:=1 to listmax do begin
    if i=sel then begin
          console.textattr:=selfg+selbg*16;
          console.cursorxy(x1,y1+i);
          console.writestr(list[i]^.caption+strrep(' ',w-1-length(list[i]^.caption)-length(list[i]^.keystroke))+list[i]^.keystroke+' ');
        end else begin
          console.textattr:=fg+bg*16;
          console.cursorxy(x1,y1+i);
          if list[i]^.caption='-' then begin
            console.textattr:=darkgray+bg*16;
            console.writestr(strrep('-',w));
            end  else begin
            console.writestr(list[i]^.caption+strrep(' ',w-1-length(list[i]^.caption)-length(list[i]^.keystroke)));
            console.textattr:=darkgray+bg*16;
            console.writestr(list[i]^.keystroke+' ');
            if strstripl(list[i]^.key,' ')<>'' then begin
            a:=pos(list[i]^.caption,list[i]^.key);
            console.writexy(x1+a+1,y1+i,fselbg+fbg*16,list[i]^.key);
          end;
          end;
        end;
  end;
  If Shadow Then Begin
     For B := X1 + 1 to x1+w-1 Do
        Begin
        Ch := Console.ReadCharXY(b, y1+listmax+2);
        Console.WriteXY (b, y1+listmax+1, ShadowAttr, Ch);
      End;
     for a:=y1+2 to y1+listmax+1 do
     Begin
        Ch := Console.ReadCharXY(x1+w, a);
        Console.WriteXY (x1+w, a, ShadowAttr, Ch);
      End;
  end;
  if fbar then showbar(sel);
  C := InKey.ReadKey;
  case c of
    #75: begin fresult:='-4';ok:=true;end; //left
    #77: begin fresult:='-5';ok:=true;end; //right
    #72: begin //up
           sel:=sel-1;
           if (list[sel]^.caption='-') then sel:=sel-1;
           if sel<1 then sel:=listmax;
    end;
    #80: begin //down
           sel:=sel+1;
           if sel>listmax then sel:=1;
           if (list[sel]^.caption='-') then sel:=sel+1;
           if sel>listmax then sel:=1;
    end;
    #13: begin fresult:=list[sel]^.result;ok:=true;end;
    #27: begin fresult:='-1';ok:=true;end;
  end;
  until ok;
end;

Procedure TMenuline_ver.Close;
Begin
  If WasOpened Then Console.PutScreenImage(Image);
  fopened:=false;
End;

Procedure TMenuline_ver.Hide;
Begin
  If Assigned(HideImage) Then FreeMem(HideImage, SizeOf(TConsoleImageRec));

  GetMem (HideImage, SizeOf(TConsoleImageRec));

  Console.GetScreenImage (Image.X1, Image.Y1, Image.X2, Image.Y2, HideImage^);
  Console.PutScreenImage (Image);
  fopened:=false;
End;

Procedure TMenuline_ver.Show;
Begin
  If Assigned (HideImage) Then Begin
    Console.PutScreenImage(HideImage^);
    FreeMem (HideImage, SizeOf(TConsoleImageRec));
    HideImage := NIL;
  End;
  fopened:=true;
End;

Procedure Tmenuline_ver.Clear;
Var
  Count : Word;
Begin
  For Count := 1 to ListMax Do
    Dispose(List[Count]);
   //list[count].text:='';
  ListMax := 1;
End;

Procedure TMenuline_ver.Delete (RecPos : Word);
Var
  Count : Word;
Begin
  If List[RecPos] <> NIL Then Begin
    Dispose (List[RecPos]);

    For Count := RecPos To ListMax - 1 Do
      List[Count] := List[Count + 1];

    //list[listmax].text:='';
    Dec (ListMax);
  End;
End;

Procedure TMenuline_ver.Add (Str,desc,keystroke,submenu,res : String; key:string; enabled,hassubmenu:boolean);//; B : Byte);

Begin
  Inc (ListMax);
  New (List[ListMax]);

  List[ListMax]^.caption := Str;
  list[listmax]^.desc:=desc;
  list[listmax]^.keystroke:=keystroke;
  list[listmax]^.submenu:=submenu;
  list[listmax]^.key:=key;
  list[listmax]^.enabled:=enabled;
  list[listmax]^.hassubmenu:=hassubmenu;
  list[listmax]^.result:=res;
  //List[ListMax]^.Tagged := B;

  //If B = 1 Then Inc(Marked);
End;

Procedure TMenuline_ver.Get (Num : Word; Var Str : String; Var B : Boolean);
Begin
  Str := '';
  B   := False;

  If Num <= ListMax Then Begin
    Str := List[Num]^.caption;
   // B   := List[Num]^.Tagged = 1;
  End;
End;


end.
