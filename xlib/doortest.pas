program doortest;
{$mode objfpc}
uses xcrt;

var
  sc:toutput;
  inp:tinput;

begin
  sc:=toutput.create(true);
  inp:=tinput.create;
  
  sc.seth:='|';
  xcrt.screen:=sc;
  xcrt.Keyboard:=inp;
  
  writepipe('|SS');
  clrscr;
      textcolor(15);
      
      //writepipe('/|DE|[L-|DE|[L\|DE|[L]|DE|[L/|DE|CR');
      writeln;
      
      writepipe('|OS|CR');
      writeln;
      writepipe('|CR');
      writeln;
      writepipe('|PI');
      writeln;
      
      writepipe('hello');
      writepipe('|TT|CR');
      writepipe('|TD|CR');
      writepipe('|PM');
      writepipe('|RS');
      
      writexypipe(10,10,7,'|12Hello |14there |PM');
      
  sc.destroy;
  inp.destroy;
end.
