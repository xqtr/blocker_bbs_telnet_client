program bassurl;

uses 
  crt,
  bass,
  BaseUnix;

var
  stream:hstream;
  url:ansistring;
  done:boolean = False;
  oa,na : PSigActionRec;
  
procedure DoSig(aSignal: LongInt); cdecl;
begin
  writeln('Receiving signal: ',aSignal);
  Writeln('Application killed. Closing BASS Lib.');
  bass_stop;
  BASS_Free;
  done:=True;
  Halt(1);
end;

procedure showhelp;
begin
  writeln;
  writeln('BASS Stream Player for Blocker');
  writeln;
  writeln('This utility is intended to play streams for usage inside the Blocker');
  writeln('terminal application. http://github.com/xqtr/');
  writeln;
  writeln('Usage:');
  writeln;
  writeln('  bassurl <stream>');
  writeln('');
  writeln('  <stream> : URL of the file to stream. Should begin with http:// or https://');
  writeln('             or ftp://, or another add-on supported protocol. The URL can be');
  writeln('             followed by custom HTTP request headers to be sent to the server.');
  writeln;
  writeln(' To stop playing you can press any key while the app is in the foreground. If');
  writeln('you have sent the app to the background use this command to kill it properly:');
  writeln('kill -15 <PID>  # Where <PID> is the Process ID reported by the system.');
  writeln;
  halt(0);
end;

begin
  if paramcount<1 then showhelp;
  if (upcase(paramstr(1))='-HELP') or
     (upcase(paramstr(1))='/HELP') or
     (upcase(paramstr(1))='/H') or
     (upcase(paramstr(1))='-H') or
     (upcase(paramstr(1))='/?') or
     (upcase(paramstr(1))='-?')
   then showhelp;
  
  if Hi(BASS_GetVersion) <> BASSVERSION then writeln('An incorrect version of bass.so was loaded');
  
  if not BASS_Init(-1, 44100, 0, nil, nil) then begin
    writeln('Could not initialize music library (BASS). Exiting...');
    halt(-1);
  end;
  
  url:=paramstr(1)+#13#10;
  //bass_start;
  
  stream:=BASS_StreamCreateURL(pchar(url), 0, 0, nil, nil);
  if stream=0 then begin
    writeln('Couln not play stream. Exiting...');
    bass_stop;
    bass_free;
    halt(-2);
  end;
  
  //Install Signal handler
  new(na);
  new(oa);
  na^.sa_Handler:=SigActionHandler(@DoSig);
  fillchar(na^.Sa_Mask,sizeof(na^.sa_mask),#0);
  na^.Sa_Flags:=0;
  {$ifdef Linux}               // Linux specific
   na^.Sa_Restorer:=Nil;
  {$endif}
  if fpSigAction(SigTerm,na,oa)<>0 then begin
    writeln('Error: ',fpgeterrno,'.');
    halt(1);
  end;
  
  BASS_ChannelPlay(stream,false);
  
  readkey;
  
  bass_stop;
  BASS_Free;
end.
