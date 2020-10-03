unit xsound;
{$mode objfpc}
{$H-}
interface

procedure playtone(n:string; dur:real; oct:byte);
function  ALSAbeep(frequency, duration:integer):boolean;
procedure beep;


implementation

uses 
  math,
  alsa,
  unix;
  
Function Real2Str (R : Real; D:Byte) : String;
  Var S : String;
begin
 Str (R:10:d,S);
 
 Real2Str:=S;
end;

procedure playtone(n:string; dur:real; oct:byte);
const
  temp = 1.0594630943592952646;
  A4   = 440;
var
  note_int:byte;
  A0 : Real;
  C0 : Real;
  HZ : Real;
  i:byte;
begin
  for i:=1 to Length(n) Do
    n[i]:=Upcase(n[i]);
  case n of
    'A'  :  note_int:=10;
    'A#' :  note_int:=11;
    'A-' :  note_int:=9;
    'B'  :  note_int:=12;
    'B#' :  note_int:=13;
    'B-' :  note_int:=11;
    'C'  :  note_int:=0;
    'C#' :  note_int:=1;
    'C-' :  note_int:=13;
    'D'  :  note_int:=2;
    'D#' :  note_int:=3;
    'D-' :  note_int:=1;
    'E'  :  note_int:=4;
    'E#' :  note_int:=5;
    'E-' :  note_int:=3;
    'F'  :  note_int:=6;
    'F#' :  note_int:=7;
    'F-' :  note_int:=5;
    'G'  :  note_int:=8;
    'G#' :  note_int:=9;
    'G-' :  note_int:=7;
  end;
  A0 := A4 / 16;
  C0 := A0 * ( 1 / temp)**9;
  HZ := C0*Power(2,oct+1) * Power(temp,note_int);
  //HZ:=$( bc -l <<< "$C0_HZ * 2^$OCTAVE * $EQL_TEMPERAMENT ^ $NOTE_INT" )
  
  //fpsystem('play -n synth '+Real2Str(dur,8)+' sin '+Real2Str(hz,8)+' 2>/dev/null');
  
  try
    ALSAbeep(round(hz),round(dur)+100);
  except
  end;
  
end;

function ALSAbeep(frequency, duration:integer):boolean;
var buffer:array[0..2400-1] of byte;     // 1/20th of a second worth of samples @48000 bps
    frames:snd_pcm_sframes_t;
       pcm:PPsnd_pcm_t;
      I,LC:integer;
        SA:array[0..359] of byte;
      SS,R:real;
const device='default'+#0;
begin
  result:=false;
  if duration<50 then duration:=50;
  if frequency<20 then frequency:=20;
 
  SS:=(sizeof(SA)/sizeof(buffer))*(frequency/20.0);
  for I:=0 to 359 do SA[I]:=128 + round(sin(pi*I/180.0) * 100.0);    // 100 is effectively the volume
  R:=0.0;
 
  if snd_pcm_open(@pcm, @device[1], SND_PCM_STREAM_PLAYBACK, 0)=0 then
  if snd_pcm_set_params(pcm, SND_PCM_FORMAT_U8,
                             SND_PCM_ACCESS_RW_INTERLEAVED,
                             1,
                             48000,            // bitrate (bps)
                             1,
                             20000)=0 then     // latency (us)
  for LC:=1 to duration div 50 do
  begin
    for I:=0 to sizeof(buffer)-1 do
    begin
      buffer[I]:=SA[trunc(R)];
      R:=R+SS;
      if R>=360.0 then R:=R-360.0
    end;
    frames:=snd_pcm_writei(pcm, @buffer, sizeof(buffer));
    if frames<0 then frames:=snd_pcm_recover(pcm, frames, 0);
    if frames<0 then break  // writeln(snd_strerror(frames))
  end;
  snd_pcm_close(pcm);
  result:=true
end;

procedure beep;
begin
  if not alsabeep(440,100) then playtone('A',100,1);
end;

end.
