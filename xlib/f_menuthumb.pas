unit f_menuthumb;

{$I M_OPS.PAS}

interface

Uses
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
  Tmitems=array of string[20];
  tthumb=array of string;
  tthumbs=array of tthumb;
  Titem_desc=record
    text:string;
    desc:string;
    result:string;
  end;

function menuthumb_hor(screen:toutput; items:tthumbs; selfg,selbg,fg,bg:byte; x,y,width,height:byte):integer;
function menuthumb_ver(screen:toutput; items:tthumbs; selfg,selbg,fg,bg:byte; x,y,width,height:byte):integer;

implementation

function menuthumb_hor(screen:toutput; items:tthumbs; selfg,selbg,fg,bg:byte; x,y,width,height:byte):integer;
var
  a,b,i,w:byte;
  thumbs,idx,sel:integer;
  c:char;
  ok:boolean;
  s:string;
  inkey:tinput;
begin
  inkey      := TInput.Create;
  ok:=false;
  sel:=0;
  idx:=0;
  w:=length(items[0][0]);
  thumbs:=width div w;
  repeat
  if idx>0 then begin
      for a:=0 to length(items[0])-1 do screen.writexy(x,y+a,fg+bg*16,'|');
    end else
    for a:=0 to length(items[0])-1 do screen.writexy(x,y+a,fg+bg*16,' ');

  if idx+thumbs<high(items)+1 then
    begin
      for a:=0 to length(items[0])-1 do screen.writexy(x+width+1,y+a,fg+bg*16,'|');

    end else
      for a:=0 to length(items[0])-1 do screen.writexy(x+width+1,y+a,fg+bg*16,' ');

  for i:=0 to thumbs-1 do begin
    if idx+i=sel then begin
        for a:=low(items[i]) to high(items[i]) do begin
            screen.writexy(1+x+i*w,y+a,selfg+selbg*16,items[idx+i][a]);
            end;
        end else begin
          for a:=low(items[i]) to high(items[i]) do begin
            screen.writexy(1+x+i*w,y+a,fg+bg*16,items[idx+i][a]);
            end;
        end;
   end;
  C := InKey.ReadKey;
  case c of
    #72: begin menuthumb_hor:=-2;ok:=true;end;  //up
    #80: begin menuthumb_hor:=-3;ok:=true;end;//down
    #75: begin //left
           sel:=sel-1;
           if sel<0 then sel:=0;
           idx:=sel;
           if idx<=0 then idx:=0;
           if idx>=high(items)-thumbs+1 then idx:=high(items)-thumbs+1;
    end;
    #77: begin //right
           sel:=sel+1;
           if sel>high(items) then sel:=high(items);
           idx:=sel;
           if idx>=high(items)-thumbs+1 then idx:=high(items)-thumbs+1;
    end;
    #13: begin menuthumb_hor:=sel;ok:=true;end;
    #27: begin menuthumb_hor:=-1;ok:=true;end;
  end;
  until ok;
  inkey.free;
end;


function menuthumb_ver(screen:toutput; items:tthumbs; selfg,selbg,fg,bg:byte; x,y,width,height:byte):integer;
var
  a,b,i,w:byte;
  thumbs,idx,sel:integer;
  c:char;
  ok:boolean;
  s:string;
  inkey:tinput;
begin
  inkey      := TInput.Create;
  ok:=false;
  sel:=0;
  idx:=0;
  w:=high(items[0])+1;//length(items[0][0]);
  thumbs:=height div w;
  repeat
  //textcolor(fg);textbackground(bg);
  screen.textattr:=fg+bg*16;
  screen.cursorxy(x,y);
  if idx>0 then begin
      for a:=0 to length(items[0])+1 do screen.writechar('-');
    end else
      for a:=0 to length(items[0])+1 do screen.writechar(' ');
  screen.cursorxy(x,y+(thumbs*(high(items[0])+1)+1));
  if idx+thumbs<high(items)+1 then
    begin
      for a:=0 to length(items[0])+1 do screen.writechar('-');
    end else
      for a:=0 to length(items[0])+1 do screen.writechar(' ');
  for i:=0 to thumbs-1 do begin
    if idx+i=sel then begin
          //textcolor(selfg);textbackground(selbg);
          for a:=low(items[i]) to high(items[i]) do begin
            screen.writexy(x,y+1+(i*w)+a,selfg+selbg*16,items[idx+i][a]);
            end;
        end else begin
          //textcolor(fg);textbackground(bg);
          for a:=low(items[i]) to high(items[i]) do begin
            screen.writexy(x,y+1+(i*w)+a,fg+bg*16,items[idx+i][a]);
            end;
        end;
   end;
 
  C := InKey.ReadKey;
  case c of
  #75  : begin menuthumb_ver:=-4;ok:=true;end;  //left
  #77  : begin menuthumb_ver:=-5;ok:=true;end;//right
  #72  : begin //up
           sel:=sel-1;
           if sel<0 then sel:=0;
           idx:=sel;
           if idx<=0 then idx:=0;
           if idx>=high(items)-thumbs+1 then idx:=high(items)-thumbs+1;
    end;
  #80  : begin //down
           sel:=sel+1;
           if sel>high(items) then sel:=high(items);
           idx:=sel;
           if idx>=high(items)-thumbs+1 then idx:=high(items)-thumbs+1;
    end;
    #13: begin menuthumb_ver:=sel;ok:=true;end;
    #27: begin menuthumb_ver:=-1;ok:=true;end;
  end;
  until ok;
  inkey.free;
end;

{

function menuline_hor_desc(items:array of titem_desc; selfg,selbg,fg,bg:byte; x,y:byte):integer;
var
  a,b,i:byte;
  sel:integer;
  c:char;
  ok:boolean;
  s:string;
begin
  ok:=false;
  sel:=0;
  repeat
  s:='';
  textbackground(bg);
  console.cursorxy(1,screenheight);clreol;
  for i:=low(items) to high(items) do begin
    s:=s+items[i].text+' ';
  end;
  if x+length(s)>screenwidth then a:=screenwidth-length(s) else a:=x;
  if y>screenheight then b:=screenheight else b:=y;
  console.cursorxy(a,b);//clreol;
  for  i:=low(items) to high(items) do begin
        if i=sel then begin
          textcolor(selfg);textbackground(selbg);
        end else begin
          textcolor(fg);textbackground(bg);
        end;
        console.writestr(items[i].text+' ');
        end;
   textcolor(fg);textbackground(bg);
   console.cursorxy(1,screenheight);console.writestr(items[sel].desc);
  c:=readkey;
  case c of
    #72: begin menuline_hor_desc:=-2;ok:=true;end;  //up
    #80: begin menuline_hor_desc:=-3;ok:=true;end; //down
    #75: begin //left
           sel:=sel-1;
           if sel<0 then sel:=0;
    end;
    #77: begin //right
           sel:=sel+1;
           if sel>high(items) then sel:=high(items);
    end;
    #13: begin menuline_hor_desc:=sel;ok:=true;end;
    #27: begin menuline_hor_desc:=-1;ok:=true;end;
  end;
  until ok;
end;

 }

end.