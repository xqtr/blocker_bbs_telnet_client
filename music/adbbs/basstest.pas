program basstest;

uses bass,crt,sysutils;

var track:hmusic;

begin
writeln('Init');
if BASS_Init(-1, 44100, 0, nil, nil) then writeln('OK');
writeln('Load');
track:=BASS_MusicLoad(false,pchar('syndicate.mod'),0,0,BASS_MUSIC_LOOP or BASS_MUSIC_RAMPS or BASS_MUSIC_SURROUND or BASS_MUSIC_POSRESET,0);
writeln(inttostr(track));
writeln('Play');
if BASS_ChannelPlay(track,false) then writeln('OK');
//bass_start;
readkey;
writeln('Exit');
BASS_Free();
end.
