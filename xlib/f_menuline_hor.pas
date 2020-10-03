unit f_menuline_hor;

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
    key:char;
    enabled:boolean;
    keystroke:string;
    hassubmenu:boolean;
    submenu:string[20];
    desc:string;
    result:string;
  end;

  tmenuline_hor=Class
    Console    : TOutput;
    inkey      : Tinput;
    List       : Array[1..30] of ^titem_desc;
    Image      : TConsoleImageRec;
    HideImage  : ^TConsoleImageRec;
  
    fShadow     : Boolean;
    ShadowAttr : Byte;
    HeadAttr   : Byte;
    HeadType   : Byte;
    Header     : String;
    WasOpened  : Boolean;
    ffg        : byte;
    fbg        : byte;
    fselfg     : byte;
    fselbg     : byte;
    fresult    : integer;
    listmax    : integer;
    fbar       : boolean;
    sel:integer;

    Constructor Create (Var Screen: TOutput);
    Destructor  Destroy; Override;
    Procedure   Open (X, Y: Byte);
    Procedure   Close;
    Procedure   Hide;
    Procedure   Show;
    //Procedure   Update;
    Procedure   Clear;
    Procedure   Delete (RecPos : Word);
    Procedure   Add (Str,desc,keystroke,submenu : String; key:char; enabled,hassubmenu:boolean);//; B : Byte);
    Procedure   Get (Num: Word; Var Str: String; Var B: Boolean);

    Property  fg    : byte read ffg write ffg;
    Property  bg    : byte read fbg write fbg;
    Property  selfg : byte read fselfg write fselfg;
    Property  selbg : byte read fselbg write fselbg;
    property result : integer read fresult;
    property showbar : boolean read fbar write fbar;
    property shadow  : boolean read fshadow write fshadow;
    property visible :boolean read wasopened write wasopened;
    property selected:integer read sel;
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

Constructor Tmenuline_hor.Create (Var Screen: TOutput);
Begin
  Inherited Create;
 inkey      := TInput.Create;
  Console    := Screen;
  fShadow     := True;
  listmax    := 0;
  ShadowAttr := 8;
  Header     := '';
  ffg:=1;
  fbg:=16;
  fselfg:=7;
  fselbg:=17;
  HideImage  := NIL;
  WasOpened  := False;
  fresult    := -1;
  fbar	     :=false;

  FillChar(Image, SizeOf(TConsoleImageRec), 0);
  Console.BufFlush;
End;

Destructor Tmenuline_hor.Destroy;
Begin
  inkey.free;
  clear;

  Inherited Destroy;
  
End;


Procedure Tmenuline_hor.Open(x,y:byte);
var
  a,b,i:byte;
  c,ch:char;
  ok:boolean;
  q,s:string;

procedure showbar(picked:integer);
  begin
    console.writexypipe(1,screenheight,fg+bg*16,screenwidth,list[picked]^.desc);
  end;


begin
  ok:=false;
  sel:=1;
  s:='';
  for i:=1 to listmax do begin
    //s:=s+'Helloasd'+' ';
    s:=s+List[i]^.caption+' ';
  end;
  If fShadow Then
      Console.GetScreenImage(X, Y, x+length(s), y + 1, Image)
    Else
      Console.GetScreenImage(X, Y, x+length(s), y, Image);
  repeat
  if x+length(s)>screenwidth then a:=screenwidth-length(s) else a:=x;
  if y>screenheight then b:=screenheight else b:=y;
  console.cursorxy(a,b);//clreol;
  for  i:=1 to listmax do begin
        if i=sel then begin
          console.textattr:=fselfg+fselbg*16;
        end else begin
          console.textattr:=ffg+fbg*16;
        end;
        //console.writestr('Helloasd');
        console.writestr(list[i]^.caption+' ');
        end;
  If fShadow Then Begin
     For B := X + 1 to x+length(s) Do Begin
        Ch := Console.ReadCharXY(B, y+1);
        Console.WriteXY (B, y+1, ShadowAttr, Ch);
      End;
  end;
  if fbar then showbar(sel);
  C := InKey.ReadKey;
  case c of
    #72: begin fresult:=-2;ok:=true;end;  //up
    #80: begin fresult:=-3;ok:=true;end; //down
    #75: begin //left
           sel:=sel-1;
           if sel<1 then sel:=listmax;
    end;
    #77: begin //right
           sel:=sel+1;
           if sel>listmax then sel:=1;
    end;
    #13: begin fresult:=sel;ok:=true;end;
    #27: begin fresult:=-1;ok:=true;end;
  end;
  until ok;
end;

Procedure TMenuline_hor.Close;
Begin
  If WasOpened Then Console.PutScreenImage(Image);
End;

Procedure TMenuline_hor.Hide;
Begin
  If Assigned(HideImage) Then FreeMem(HideImage, SizeOf(TConsoleImageRec));

  GetMem (HideImage, SizeOf(TConsoleImageRec));

  Console.GetScreenImage (Image.X1, Image.Y1, Image.X2, Image.Y2, HideImage^);
  Console.PutScreenImage (Image);
End;

Procedure TMenuline_hor.Show;
Begin
  If Assigned (HideImage) Then Begin
    Console.PutScreenImage(HideImage^);
    FreeMem (HideImage, SizeOf(TConsoleImageRec));
    HideImage := NIL;
  End;
End;

Procedure Tmenuline_hor.Clear;
Var
  Count : Word;
Begin
  For Count := 1 to ListMax Do
    Dispose(List[Count]);
   //list[count].text:='';
  ListMax := 1;
End;

Procedure TMenuline_hor.Delete (RecPos : Word);
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

Procedure TMenuline_hor.Add (Str,desc,keystroke,submenu : String; key:char; enabled,hassubmenu:boolean);//; B : Byte);
Begin
  Inc (ListMax);
  New (List[ListMax]);

  List[ListMax]^.caption := Str;
  list[listmax]^.desc := desc;
  //List[ListMax]^.Tagged := B;

  //If B = 1 Then Inc(Marked);
End;

Procedure TMenuline_hor.Get (Num : Word; Var Str : String; Var B : Boolean);
Begin
  Str := '';
  B   := False;

  If Num <= ListMax Then Begin
    Str := List[Num]^.caption;
   // B   := List[Num]^.Tagged = 1;
  End;
End;


end.