program fpccrttest;

uses fpc_xcrt,xstrings;

var y:byte;
img:tscreenbuf;

begin
  isutf:=true;
  clrscr;
  writexypipe(40,10,7,'Hello |15man|12 is |04man |07 you');
  gotoxy(5,15);
  write(#254);
  SaveScreen(img);
  readkey;
  clrscr;
  readkey;
  restorescreen(img);
end.
