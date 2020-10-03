unit xtextview;

{$mode objfpc}
{$h+}

Interface

Uses
  classes,
  xCrt,
  xstrings,
  m_types,
  sysutils,
  xmenubox;

Type

   ttextviewer=Class
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
    sl         : tstringlist;
    iy         : integer;
    ix         : integer;
    fbar       : boolean;

    fbarfg,fbarbg:byte;
    fx,fy,fw,fh:byte;
    tfx,tfy,tfw,tfh:byte;
    ffile:string;
    fullscreen:boolean;

    procedure openfile(filename:string);
    procedure clear;
    procedure updatebar;
    Constructor Create;
    Destructor  Destroy; Override;
    Procedure   Open;
    Procedure   Close;
    Procedure   Hide;
    Procedure   Show;

    Property    Filename:string read ffile write openfile;
    Property    Shadow:boolean read fshadow write fshadow;
    Property    fg:byte read ffg write ffg;
    Property    bg:byte read fbg write fbg;
    property    barfg:byte read fbarfg write fbarfg;
    property    barbg:byte read fbarbg write fbarbg;
    property    x:byte read fx write fx;
    property    y:byte read fy write fy;
    property    width:byte read fw write fw;
    property    height:byte read fh write fh;
    property    showbar:boolean read fbar write fbar;
    property    lines:tstringlist read sl write sl;

  end;

Implementation

Uses
  xDialogs;

Constructor TTextViewer.Create;
Begin
  Inherited Create;
  Shadow     := True;
  ShadowAttr := 8;
  HideImage  := NIL;
  WasOpened  := False;
  sl:=tstringlist.create;
  fbar:=true;
  fbarfg:=yellow;
  fbarbg:=red;
  iy:=0;
  ix:=0;
  fw:=80;
  fy:=25;
  fullscreen:=false;
  FillChar(Image, SizeOf(TConsoleImageRec), 0);
  BufFlush;
End;

Destructor TTextViewer.Destroy;
Begin
  sl.free;
  Inherited Destroy;
End;

procedure TTextViewer.clear;
var
  i:byte;
begin
  for i:=fy to fy+fh do writexy(fx,fy,0,strrep(' ',fw));
end;

procedure TTextViewer.updatebar;
var
  ind,h,d:byte;
begin
  h:=trunc(((fh*fh)/sl.count));
  if h<=0 then h:=1;
  if h>=fh then h:=fh;
  ind:=trunc((iy / sl.count)*fh);
  if ind<0 then ind:=0;
  if ind>fh then ind:=fh-1;

  for d:=0 to fh-1 do writexy(fx+fw-1,fy+d,fbarfg+fbarbg*16,' ');
  for d:=0 to h do writexy(fx+fw-1,fy+ind+d,fbarbg+fbarfg*16,' ');
end;

procedure TTextViewer.openfile(filename:string);
begin
  sl.clear;
  if fileexists(filename) then 
    sl.loadfromfile(filename) else sl.add(' ');
  iy:=0;
  ix:=0;
end;

Procedure TTextViewer.Open;
var
  ch:char;
  i,d:integer;
  tw:integer;
  bb:TMenuBox;
  findw:shortstring;
  findpos:integer;
  highlight:boolean;
  filenm:shortstring;
  ss: TConsoleImageRec;

procedure highlighttext;
var m:integer;
begin
    for m:=0 to length(findw)-1 do begin
      writexy(fx+findpos-ix+m-1,fy,GetAttrAt(fx+m+findpos-ix,fy)-(fbg*16)+(red*16),GetCharAt(fx+m-ix+findpos-1,fy));
      //readattrxy(fx+m+findpos-ix,fy)-(fbg*16)+(red*16)
    end;
end;

begin
  findw:='';
  highlight:=false;
  clear;
  if sl.count=0 then exit;
  repeat
  if iy+fh>sl.count-1 then iy:=sl.count-1-fh;
  if sl.count<fh then iy:=0;
  i:=0;
  while (i<=sl.count-1) and (i<=fh) do begin
    writexypipe(fx,fy+i,ffg+fbg*16,strpadr(copy(sl[iy+i],ix+1,fw-1),fw,' '));
    i:=i+1;
  end;
  if fbar then updatebar;
  if highlight then highlighttext;
  ch:=readkey;
  case ch of
   #43: begin
                ffg:=ffg+1;
                if ffg>15 then ffg:=15;
                end;
   #45: begin
                ffg:=ffg-1;
                if (ffg>200) and (ffg<255) then ffg:=1;
                end;
    #47: begin
         fbg:=fbg+1;
         if fbg>15 then fbg:=15;
    end;
    #42:begin
        fbg:=fbg-1;
        if fbg<9 then fbg:=9;
    end;
    ^S : begin
			filenm:=ffile;
      filenm:=GetSaveFileName(' Save... ',filenm,filenm);
			if filenm<>'' then
					sl.savetofile(filenm);
		end;
    ^R: begin
               ffg:=white;
               fbg:=blue;
               ix:=0;
               iy:=0;
           end;
    ^F: begin
        if inputbox(fx+(fw div 2) - 13, fy+2, 26,5,' Find... ','Enter word to find:',findw) then begin
          for i:=iy to sl.count-1 do begin
            findpos:=pos(uppercase(findw),uppercase(sl[i]));
            if findpos>0 then begin
              iy:=i;
              highlight:=true;
              if findpos>fw then begin
                ix:=findpos-1;
              end;
              break;
            end else highlight:=false;
          end;
        end else highlight:=false;
    end;
    ^G: begin
        if findw<>'' then begin
          for i:=iy+1 to sl.count-1 do begin
            findpos:=pos(uppercase(findw),uppercase(sl[i]));
            if findpos>0 then begin
              iy:=i;
              highlight:=true;
              if findpos>fw then begin
                ix:=findpos-1;
              end;
              break;
            end else highlight:=false;
          end;
        end;
    end;
    #00: begin
         ch:=readkey;
         case ch of
           
           home: ix:=0;
           endkey:begin
                  for i:=0 to sl.count-1 do
                    if length(sl[i])>tw then tw:=length(sl[i]);
                  ix:=tw-fw-1;
                  end;
           pgup: begin
                 iy:=iy-fh;
                 if iy<0 then iy:=0;
           end;
           pgdn: begin
                 iy:=iy+fh;
                 if iy+fh>sl.count-1 then iy:=sl.count-1-fh;
           end;
           cursorright: begin //left
                ix:=ix+1;

           end;
           cursorleft: begin  //right
                ix:=ix-1;
                if ix<0 then ix:=0;
           end;
           cursorup: begin //up
                iy:=iy-1;
                if iy<0 then iy:=0;
           end;
           cursordown: begin //down
                iy:=iy+1;
                if iy+fh>sl.count-1 then iy:=sl.count-1-fh;
           end;
           F1: begin

                  //winboxborder(10,6,70,18,0);
                  winboxborder(fx+5,fy+2,fx+fw-10,fy+14,0);
                  writexy(fx+7,fy+3,15+16,'Help');
                  
                  writexy(fx+9,fy+5,  7*16,'+-       : Change Font Color');
                  writexy(fx+9,fy+6 ,7*16,'/*       : Change Background Color');
                  writexy(fx+9,fy+7 ,7*16,'CTRL + R : Resets Viewer');
                  writexy(fx+9,fy+8 ,7*16,'CTRL + F : Search');
                  writexy(fx+9,fy+9,7*16,'CTRL + G : Repeat Search');
                  writexy(fx+9,fy+10,7*16,'CTRL + S : Save file to disk');
                  writexy(fx+9,fy+12,7*16,'Press any key...');
                  
                  readkey;

                end;
           f10: begin
                fullscreen:=not fullscreen;
                if fullscreen then begin
                  hide;
                  tfx:=fx;
                  tfy:=fy;
                  tfw:=fw;
                  tfh:=fh;
                  fx:=1;
                  fy:=1;
                  fw:=screenwidth;
                  fh:=screenheight;
                  show;
                end else begin
                  hide;
                  fx:=tfx;
                  fy:=tfy;
                  fw:=tfw;
                  fh:=tfh;
                  show;
                end;
           end;
         end;
         end;
    enter,tab,esc: break;
  end;
  until false;
end;

Procedure TTextViewer.Close;
Begin
  If WasOpened Then RestoreScreen(Image);
End;

Procedure TTextViewer.Hide;
Begin
  If Assigned(HideImage) Then FreeMem(HideImage, SizeOf(TConsoleImageRec));

  GetMem (HideImage, SizeOf(TConsoleImageRec));

  SaveScreen (HideImage^);
  RestoreScreen (Image);
End;

Procedure TTextViewer.Show;
Begin
  If Assigned (HideImage) Then Begin
    RestoreScreen(HideImage^);
    FreeMem (HideImage, SizeOf(TConsoleImageRec));
    HideImage := NIL;
  End;
End;

end.
