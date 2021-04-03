Unit Blocker_Term;

{
echo -e "\033[c"   // get terminal information
echo -e "\033[18t" // get terminal size ---> Procedure TOutputLinux.GetOriginalTermSize;

}

{$I M_OPS.PAS}


Interface
Uses m_Protocol_Queue;
Type 
  Tsettings = Record
    ListLow : byte;
    ListHi : byte;
    Tag : Byte;
    MsgBox_FrameType : byte;
    MsgBox_HeadAttr : byte;
    MsgBox_BoxAttr : byte; 
    MsgBox_BoxAttr2 : byte;
    MsgBox_BoxAttr3 : byte;
    MsgBox_BoxAttr4 : byte;
    MsgBox_Box3D : boolean;
    form_Lo    : byte;
    form_Hi    : byte;
    form_Data  : byte;
    form_LoKey : byte;
    form_HiKey : byte;
    form_Field1: byte;
    form_Field2: byte;
    PreviewANSIsec : byte;
    PreviewCharsSec : byte;
    ConvertANSISec : byte;
    ImportSyncTermSec : byte;
    ImmidiateDialSec : byte;
    LoadPhoneBookSec : byte;
    SortRecordsSec : byte;
    EditMacrosSec : byte;
    EditBooksec : byte;
    DelBooksec : byte;
    DelRecordSec:byte;
    SaveScreenSec:byte;
    statusbar:string;
    quotefile:string;
    bookfile:string;
    downloadpath:string;
    uploadpath:string;
    soundfx:boolean;
        
    play:string;
    stop:string;
  end;
  
Const
  version = 'v2.3';  
  
Var
  Pref : Tsettings;
  Queue    : TProtocolQueue;
  BookFile : String;
  Macro    : Array[0..9] of String[255];
  
  zmdn      : string;
  zmup      : string;
  
  Appdir : String;
  
  LastPath : String;
  Captures : Integer = 0;

Procedure Terminal(param1,param2:string);

Implementation

Uses
  DOS,
  m_Types,
  m_DateTime,
  m_Strings,
  m_FileIO,
  inifiles,
  m_QuickSort,
  m_io_Base,
  m_io_Sockets,
  m_Protocol_Zmodem,
  m_Input,
  m_Output,
  m_Term_Ansi,
  m_MenuBox,
  m_MenuForm,
  m_MenuInput,
  xdoor,
  regexpr,
  m_ansi2pipe,
  unix,
  Classes,
  BASS,
  blocker_Common;
  
const
  keyHome          = #71;      
  keyCursorUp      = #72;     
  keyPgUp          = #73;
  keyCursorLeft    = #75;      
  KeyNum5          = #76;     
  keyCursorRight   = #77;
  keyEnd           = #79;
  keyCursorDown    = #80;
  keyPgDn          = #81;
  KeyIns           = #82;
  KeyDel           = #83;
  KeyBackSpace     = #8;
  KeyTab           = #9;
  KeyEnter         = #13;
  KeyEsc           = #27;
  Keyforwardslash  = #47;
  Keyasterisk      = #42;
  Keyminus         = #45;
  Keyplus          = #43;
  KeyF1            = #59;
  KeyF2            = #60;
  KeyF3            = #61;
  KeyF4            = #62;
  KeyF5            = #63;
  KeyF6            = #64;
  KeyF7            = #65;
  KeyF8            = #66;
  KeyF9            = #67;
  field1x = 62;
  field2x = 73;
  fieldy  = 6;
  
  max_keyboard_soundfx = 5;
  
  max_records = 600;
  
  TransArray: array [1..2,1..17] of byte =
     (
      (14,15,17,19,19,25,30,35,40,45,50,55,59,60,61,61,61),
      (14,14,14,14,13,13,13,13,13,13,13,13,13,13,13,13,12)
      );

Type
  PhoneRec = Record
    Position  : LongInt;
    Name      : String[26];
    Address   : String[60];
    User      : String[30];
    Password  : String[20];
    StatusBar : Boolean;
    Music     : Boolean;
    Added     : Longint;
    LastCall  : Longint;
    LastEdit  : Longint;
    Calls     : String[5];
    Rating    : byte;
    Software  : string[30];
    Sysop     : string[20];
    Comment   : string[30];
    Validated : LongInt;
    Flags     : string[5];
    ModemFx   : Boolean;
    KeystrokeFX : Boolean;
    ondial    : string[254];
    onhangup  : string[254];
  End;

  PhoneBookRec = Array[1..max_records] of PhoneRec;
  
  RegExRec = Record
    Name : String[30];
    RX   : String[255];
    cmd  : String[255];
  End;
  
  

Var
  IsBookLoaded : Boolean;
  field1 : byte = 0;
  field2 : byte = 0;
  TotalQuotes : Integer;
  MusicPlaying : Boolean = false;
  MusicFound   : Boolean = false;
  RegExList : Array[1..50] Of RegExRec;
  TransIndex : Byte = 1;
  BASSLoaded : Boolean = False;
  BBSDialed  : PhoneRec;
  
  keystroke_sound : array[0..max_keyboard_soundfx-1] of hstream;
  keystroke_enter : hstream;
  beep_sound : hstream;
  other_sound : hstream;
  trackmod : hmusic;
  
  
{$I blocker_ansiterm.pas}

procedure playmodem;
var  
  ss:ansistring;
begin
  if not pref.soundfx then exit;
  if not BASSLoaded then exit;
  if not BBSDialed.modemfx then exit;
  ss:=appdir+'fx'+pathsep+'modem.wav';
  other_sound:=BASS_StreamCreateFile(False, pchar(ss), 0, 0, 0 {$IFDEF UNICODE} or BASS_UNICODE {$ENDIF});
  BASS_ChannelPlay(other_sound, False);
end;

procedure playbeep;
begin
  if not BASSLoaded then exit;
  BASS_ChannelPlay(beep_sound, False)
end;

procedure playkeystrokefx(c:char);
var
  r:byte;
begin
  if not pref.soundfx then exit;
  if not BBSDialed.keystrokefx then exit;
  if not BASSLoaded then exit;
  if not BASS_IsStarted then bass_start;
  case c of 
  #13: BASS_ChannelPlay(keystroke_enter, False);
  #27: BASS_ChannelPlay(keystroke_sound[0], False);
  else begin
      randomize;
      r:=random(max_keyboard_soundfx);
      BASS_ChannelPlay(keystroke_sound[r], False);
    end;
  end;
end;
        

procedure StopMusic;
  begin
    if dropinfo.isDOOR then exit;
    //fpsystem(pref.stop);
    bass_stop;
  end;
  
Procedure FindRegExs;
type
  match = record
    text: string;
    idx : byte; 
  end;
var
  sl  : tstringlist;
  x,y : byte;
  img : TConsoleImageRec;
  l   : string;
  m   : match;
  re  : tregexpr;
  mm  : tmenulist;
  found : boolean = false;
  b   : boolean;
  d   : word;
  f   : word;
  values : array[1..1000] of string[255];
Begin
{$H+}
  Screen.GetScreenImage(1, 1, 79, Screen.ScreenSize, img);
  mm := TMenuList.Create(TOutput(Screen));
  
  sl:=tstringlist.create;
  sl.text:='';
  for y:=1 to 25 do begin
    l:='';
    for x:=1 to 80 do
      if (ord(img.Data[y][x].UnicodeChar)>31) and (ord(img.Data[y][x].UnicodeChar)<126) then
        l:=l+img.Data[y][x].UnicodeChar;
    sl.add(l);
  end;
  
  re := TRegExpr.Create;
  re.ModifierI := true; //case insensitive
  for f:=0 to 1000 do values[f]:='';
  f:=1;
  //try
    for y := 1 to 50 do begin
      if RegExList[y].rx<>'' then begin
        re.Expression := RegExList[y].rx;
        if re.Exec(sl.text) then begin
          found:=true;
          repeat //alle gefundenen Ausdrücke in String speichern
            if strStripB(re.match[0],' ')<>'' then begin
                mm.add(strpadl(copy(re.Match[0],1,20),21,' ')+' '+chr(179)+' '+copy(RegExlist[y].Name,1,10),0,y,f);
                values[f]:=re.Match[0];
                f:=f+1;
              end;
          until not re.ExecNext;
        
        end;
      end;
    end;
  {except
    found:=false;
    showmsgbox(0,'Error in RegEx!');
  end;}
  
  re.free;
  sl.free;
  {$H-}
  if found then begin
    
        
    mm.AllowTag:=false;
    mm.Box.Header    := ' RegEx Matches ';
    mm.Box.HeadAttr  := pref.MsgBox_HeadAttr;//15 + 7 * 16;
    mm.Box.BoxAttr    := pref.MsgBox_BoxAttr  ;
    mm.Box.BoxAttr2   := pref.MsgBox_BoxAttr2 ;
    mm.Box.BoxAttr3   := pref.MsgBox_BoxAttr3 ;
    mm.Box.BoxAttr4   := pref.MsgBox_BoxAttr4 ;
    mm.LoChars  := #27#13;
    mm.HiChars  := #46;
        
    mm.Box.FrameType := 9;
    mm.Box.Box3D     := true;
    mm.PosBar        := true;
    mm.box.ShadowAttr :=8;
    
    mm.HiAttr := pref.form_hi;//15+2*16;
    mm.LoAttr := pref.form_lo;//0 + 7*16;
    screen.writexypipe(1,25,7,79,'|15ALT-C/|11C|07opy to Clipboard   |15ENTER/|11L|07aunch');
    mm.Open (40, 2, 79, 24);
    
    
    
      Case mm.ExitCode of
        #13: Begin 
                mm.get(mm.picked,l,b,d,f);
                if regexlist[d].cmd='' then begin
                  fpsystem('echo "'+values[f]+'" | xclip -selection c');
                  showmsgbox(0,'Text copied to clipboard.');
                end else begin
                  screen.clearscreen;
                  
                  l:=strReplace(regexlist[d].cmd,'%P',justpath(paramstr(0)));
                  l:=strReplace(l,'%M',values[f]);
                  
                  fpsystem(l);
                  keyboard.readkey;
                end;
                
              End;
        #46 : Begin
                mm.get(mm.picked,l,b,d,f);
                fpsystem('echo "'+values[f]+'" | xclip -selection c');
                //screen.writexy(1,1,14,values[f]+' '+stri2s(f));
                showmsgbox(0,'Text copied to clipboard.');
              End;
        //#27: Break;
    end;
      
    
    mm.Box.Close;
    
  
  end else showmsgbox(0,'No RegExs found...');
  mm.destroy;
  Screen.PutScreenImage(img);
End;  
  
Procedure LoadRegEx;
Var
  Inifile : TIniFile;
  i       : word;
Begin
  fillchar(regexlist,sizeof(regexlist),#0);
  IniFile := TIniFile.Create(appdir+'blocker.ini');
  Try
    for i:=1 to 50 Do Begin
      RegExList[i].Name := IniFile.ReadString('regex_'+StrI2S(i),'Name','');
      RegExList[i].RX   := IniFile.ReadString('regex_'+StrI2S(i),'RegEx','');
      RegExList[i].cmd  := IniFile.ReadString('regex_'+StrI2S(i),'Command','');
    End;
  Finally
    IniFile.Free;
  End;
End;

Procedure SaveRegEx;
Var
  Inifile : TIniFile;
  i       : Word;
Begin
  IniFile := TIniFile.Create(appdir+'blocker.ini');
  Try
   for i:=1 to 50 Do begin
      Inifile.writestring('regex_'+StrI2S(i),'Name',regexlist[i].name);
      IniFile.writestring('regex_'+StrI2S(i),'RegEx',regexlist[i].rx);
      IniFile.writestring('regex_'+StrI2S(i),'Command',regexlist[i].cmd);
    End;
  Finally
    IniFile.Free;
  End;
End;

Procedure regexp_edit;  // Regular Expressions List
Var
  mm : TMenuList;
  j  : Byte;
  picked : word;
  
  Procedure EditRegExEntry (Num: word);
  Var
    Box    : TMenuBox;
    Form   : TMenuForm;
    NewRec : RegExRec;
    Image  : TConsoleImageRec;
    oldx,oldy:byte;
  Begin

    if dropinfo.isdoor then if not isacs(pref.EditBookSec) then begin
      ShowMsgBox(0,'You don''t have the priviliges, for this function!');
      exit;
    end;  
    
    NewRec := RegExList[Num];
    Box    := TMenuBox.Create(TOutput(Screen));
    Form   := TMenuForm.Create(TOutput(Screen));

    Box.Header   := ' RegEx Editor ';
    Box.FrameType  := pref.MsgBox_FrameType;
    Box.HeadAttr   := pref.MsgBox_HeadAttr ;
    Box.BoxAttr    := pref.MsgBox_BoxAttr  ;
    Box.BoxAttr2   := pref.MsgBox_BoxAttr2 ;
    Box.BoxAttr3   := pref.MsgBox_BoxAttr3 ;
    Box.BoxAttr4   := pref.MsgBox_BoxAttr4 ;
    Box.Box3D      := pref.MsgBox_Box3D ;
    
    oldx:=screen.cursorx;
    oldy:=screen.cursory;
    Screen.GetScreenImage(1, 1, 80, Screen.ScreenSize, Image);
    
    Box.Open (17, 8, 63, 15);
    screen.writexy(19,14,8,'%M : Matched String // %P : Blocker path');
    Form.HelpSize := 0;
    
    With Form do Begin
      cLo          := pref.form_lo;
      cHi          := pref.form_hi;
      cData        := pref.form_data;
      cLoKey       := pref.form_lokey;
      cHiKey       := pref.form_hikey;
      cField1      := pref.form_field1;
      cField2      := pref.form_field2;
    end;
    
    Form.AddStr  ('N', ' Name'   , 19, 10, 32, 10, 11, 30, 30, @NewRec.Name, '');
    Form.AddStr  ('R', ' RegEx',   19, 11, 32, 11, 11, 30, 255, @NewRec.rx, '');
    Form.AddStr  ('C', ' Command', 19, 12, 32, 12, 11, 30, 255, @NewRec.cmd, '');
    
    
    Form.Execute;

    If Form.Changed Then
      If ShowMsgBox(1, 'Save changes?') Then Begin
        RegExlist[Num] := NewRec;
        SaveRegEx;
      End;

    Form.Free;

    Box.Close;
    Box.Free;
    Screen.PutScreenImage(Image);
    screen.cursorxy(oldx,oldy);
  End;
  
  procedure reloadlist;
  var
   count:integer;
   s:string;
  begin
    mm.Clear;
    mm.picked:=0;
    For Count := 1 to 50 Do begin
      s:=strPadR(RegExList[Count].Name, 20, ' ') + ' ' +strPadR(RegExList[Count].RX, 30, ' ') + ' ' +strPadR(RegExList[Count].cmd, 30, ' ') + ' ';
      mm.Add(s,0);
    end;
  end;

Begin
  LoadRegEx;
  mm := TMenuList.Create(TOutput(Screen));
      
  mm.AllowTag:=false;
  mm.Box.Header    := ' Regular Expressions ';
  mm.Box.HeadAttr  := pref.MsgBox_HeadAttr;//15 + 7 * 16;
  mm.Box.BoxAttr    := pref.MsgBox_BoxAttr  ;
  mm.Box.BoxAttr2   := pref.MsgBox_BoxAttr2 ;
  mm.Box.BoxAttr3   := pref.MsgBox_BoxAttr3 ;
  mm.Box.BoxAttr4   := pref.MsgBox_BoxAttr4 ;
  mm.LoChars  := #27;
  mm.HiChars  := #18#83#44#46;
  
  mm.NoWindow := True;
  mm.LoAttr   := pref.listlow;
  mm.HiAttr   := pref.listhi;
  mm.SearchA  := 7;
  mm.Searchy  := 24;
  mm.SearchX  := 33;
      
  mm.Box.FrameType := pref.MsgBox_FrameType;
  mm.Box.Box3D     := true;
  mm.PosBar        := true;
  mm.box.ShadowAttr :=8;
  
  mm.HiAttr := pref.form_hi;//15+2*16;
  mm.LoAttr := pref.form_lo;//0 + 7*16;
  Repeat
    mm.Picked := Picked;
    reloadlist;
    
    Picked := mm.Picked;
    drawmainansi;
    
    screen.writexy(38,6,11,' Regular Expressions                    ');
    screen.writexypipe(1,25,7,80,'|15ESC/|11B|07ack   |15ALT-E/|11E|07dit   |15DEL/|11D|07elete   |15ALT-C/|11C|07lear');
    screen.writexypipe(4,7,15,60,strPadR('Name', 22, ' ')+strPadR('RegEx', 31, ' ')+strPadR('Command', 30, ' '));
    mm.Open(3, 7, 79, 24);
    Case mm.ExitCode of
      #18,#13: Begin  //alt-e  add
              EditRegExEntry (mm.picked);
            End;
      #46 : If ShowMsgBox(1,'Clear List?') then mm.Clear;
      #27: Break;
      #83 : If ShowMsgBox(1, 'Delete this record?') Then Begin
              fillchar(regexlist[mm.picked],sizeof(regexrec),' ');
              mm .delete(mm.Picked); 
            End;
    End;
  Until False;
    
  DrawMainAnsi;
  SaveRegEx;
End;

Procedure LoadMacros;
Var
  Inifile : TIniFile;
  i       : Byte;
Begin
  IniFile := TIniFile.Create(appdir+'blocker.ini');
  Try
    For i:=0 to 9 Do Macro[i]:=IniFile.ReadString('macro',StrI2S(i),'');
  Finally
    IniFile.Free;
  End;
End;

Procedure SaveMacros;
Var
  Inifile : TIniFile;
  i       : Byte;
Begin
  IniFile := TIniFile.Create(appdir+'blocker.ini');
  Try
    For i:=0 to 9 Do IniFile.WriteString('macro',StrI2S(i),Macro[i]);
  Finally
    IniFile.Free;
  End;
End;

Procedure SaveSettings;
Var
  Inifile : TIniFile;
  i       : Byte;
Begin
  IniFile := TIniFile.Create(appdir+'blocker.ini');
  Try
    inifile.writestring('general','phonebook',bookfile);
  Finally
    IniFile.Free;
  End;
End;

Procedure ToggleSoundFx;
Var
  Inifile : TIniFile;
  i       : Byte;
Begin
  IniFile := TIniFile.Create(appdir+'blocker.ini');
  pref.soundfx:= not pref.soundfx;
  Try
    inifile.writebool('general','soundfx',pref.soundfx);
  Finally
    IniFile.Free;
  End;
End;
  
Function Ansi_Color (B : Byte) : String;
  Var
    S : String;
  Begin
    S          := '';
    Ansi_Color := '';

    Case B of
      00: S := #27 + '[0;30m';
      01: S := #27 + '[0;34m';
      02: S := #27 + '[0;32m';
      03: S := #27 + '[0;36m';
      04: S := #27 + '[0;31m';
      05: S := #27 + '[0;35m';
      06: S := #27 + '[0;33m';
      07: S := #27 + '[0;37m';
      08: S := #27 + '[1;30m';
      09: S := #27 + '[1;34m';
      10: S := #27 + '[1;32m';
      11: S := #27 + '[1;36m';
      12: S := #27 + '[1;31m';
      13: S := #27 + '[1;35m';
      14: S := #27 + '[1;33m';
      15: S := #27 + '[1;37m';
    End;

    If B in [00..07] Then B := (Screen.TextAttr SHR 4) and 7 + 16;

    Case B of
      16: S := S + #27 + '[40m';
      17: S := S + #27 + '[44m';
      18: S := S + #27 + '[42m';
      19: S := S + #27 + '[46m';
      20: S := S + #27 + '[41m';
      21: S := S + #27 + '[45m';
      22: S := S + #27 + '[43m';
      23: S := S + #27 + '[47m';
    End;

    Ansi_Color := S;
  End;  

Function StripAddressPort (Str : String) : String;
Var
  A : Byte;
Begin
  A := Pos(':', Str);

  If A > 0 Then
    StripAddressPort := Copy(Str, 1, A - 1)
  Else
    StripAddressPort := Str;
End;

Function GetAddressPort (Addr : String) : Word;
Var
  A : Byte;
Begin
  A := Pos(':', Addr);

  If A > 0 Then
    GetAddressPort := strS2I(Copy(Addr, A+1, Length(Addr)))
  Else
    GetAddressPort := 23;
End;

Procedure Center(S:String; L:byte);
Begin
  Screen.WriteXYPipe((40-strMCILen(s) div 2),L,7,strMCILen(s),S);
End;

Function GetTransferType : Byte;
Var
  List : TMenuList;
Begin
  List := TMenuList.Create(TOutput(Screen));

  List.Box.Header    := ' Transfer Type ';
  List.Box.HeadAttr  := pref.MsgBox_HeadAttr;
  List.Box.FrameType := pref.MsgBox_FrameType;
  
  List.Box.BoxAttr    := pref.MsgBox_BoxAttr  ;
  List.Box.BoxAttr2   := pref.MsgBox_BoxAttr2 ;
  List.Box.BoxAttr3   := pref.MsgBox_BoxAttr3 ;
  List.Box.BoxAttr4   := pref.MsgBox_BoxAttr4 ;
  
  List.Box.Box3D     := True;
  List.PosBar        := False;
  
  List.HiAttr := pref.listhi;//15+2*16;
  List.LoAttr := pref.listlow;//0 + 7*16;

  List.Add('Zmodem: Download', 0);
  List.Add('Zmodem: Upload', 0);

  List.Open (30, 11, 49, 14);
  List.Box.Close;

  Case List.ExitCode of
    #27 : GetTransferType := 0;
  Else
    GetTransferType := List.Picked;
  End;

  List.Free;
End;

Function GetNewRecord : PhoneRec;
Begin
  FillChar (Result, SizeOf(PhoneRec), 0);
  
  With Result Do Begin
    Name      := chr(246);
    Address   := '';
    User      := '';
    Password  := '';
    StatusBar := False;
    Music     := False;
    Added     := 0;
    LastCall  := 0;
    LastEdit  := 0;
    Calls     := '';
    Rating    := 0;
    Software  := '';
    Sysop     := '';
    Comment   := '';
    Validated := 0;
    Flags     :='';
    modemfx     := False;
    keystrokefx := False;
    ondial    := '';
    onhangup  := '';
  End;
End;

Procedure InitializeBook (Var Book: PhoneBookRec);
Var
  Count : word;
Begin
  For Count := 1 to max_records Do
    Book[Count] := GetNewRecord;

  //Book[1].Name    := 'Local Login';
  //Book[1].Address := 'localhost:' + strI2S(Config.INetTNPort);
End;

Procedure WriteBook (Var Book: PhoneBookRec; Filename: String);
Var
  OutFile : Text;
  Buffer  : Array[1..4096] of Char;
  Count   : word;
Begin
  //ShowMsgBox (2, 'Saving phonebook');

  Assign     (OutFile, Filename);
  SetTextBuf (OutFile, Buffer);
  ReWrite    (OutFile);

  For Count := 1 to max_records Do Begin
    WriteLn (OutFile, '[' + strI2S(Count) + ']');
    WriteLn (OutFile, #9 + 'name=' + Book[Count].Name);
    WriteLn (OutFile, #9 + 'address=' + Book[Count].Address);
    WriteLn (OutFile, #9 + 'user=' + Book[Count].User);
    WriteLn (OutFile, #9 + 'pass=' + Book[Count].Password);
    WriteLn (OutFile, #9 + 'statusbar=', Ord(Book[Count].StatusBar));
    WriteLn (OutFile, #9 + 'music=', Ord(Book[Count].Music));
    WriteLn (OutFile, #9 + 'last=' + stri2s(Book[Count].LastCall));
    WriteLn (OutFile, #9 + 'added=' + stri2s(Book[Count].added));
    WriteLn (OutFile, #9 + 'lastedit=' + stri2s(Book[Count].LastEdit));
    WriteLn (OutFile, #9 + 'calls=' + Book[Count].Calls);
    WriteLn (OutFile, #9 + 'sysop=' + Book[Count].sysop);
    WriteLn (OutFile, #9 + 'software=' + Book[Count].software);
    WriteLn (OutFile, #9 + 'comment=' + Book[Count].comment);
    WriteLn (OutFile, #9 + 'rating=' + stri2s(Book[Count].rating));
    WriteLn (OutFile, #9 + 'validated=' + stri2s(Book[Count].validated));
    WriteLn (OutFile, #9 + 'flags=' + Book[Count].flags);
    WriteLn (OutFile, #9 + 'keystrokefx=', ord(Book[Count].keystrokefx));
    WriteLn (OutFile, #9 + 'modemfx=', ord(Book[Count].modemfx));
    WriteLn (OutFile, #9 + 'ondial=' + Book[Count].OnDial);
    WriteLn (OutFile, #9 + 'onhangup=' + Book[Count].OnHangup);
    WriteLn (OutFile, '');
  End;

  Close (OutFile);
End;

Procedure LoadBook (Var Book: PhoneBookRec; Filename: String);
Var
  INI   : TInifile;
  Count : word;
Begin
  
  ShowMsgBox (2, 'Loading phonebook');

  INI := TInifile.Create(Filename);

  //INI.Sequential := True;

  For Count := 1 to max_records Do Begin
    Book[Count].Name      := INI.ReadString(strI2S(Count), 'name', '');
    Book[Count].Address   := INI.ReadString(strI2S(Count), 'address', '');
    Book[Count].User      := INI.ReadString(strI2S(Count), 'user', '');
    Book[Count].Password  := INI.ReadString(strI2S(Count), 'pass', '');
    Book[Count].StatusBar := INI.ReadString(strI2S(Count), 'statusbar', '1') = '1';
    Book[Count].Music     := INI.ReadString(strI2S(Count), 'music', '1') = '1';
    Book[Count].LastCall  := INI.ReadInteger(strI2S(Count), 'last', 0);
    Book[Count].added     := INI.ReadInteger(strI2S(Count), 'added', 0);
    Book[Count].Calls     := INI.ReadString(strI2S(Count), 'calls', '');
    Book[Count].Sysop     := INI.ReadString(strI2S(Count), 'sysop', '');
    Book[Count].Software  := INI.ReadString(strI2S(Count), 'software', '');
    Book[Count].Rating    := INI.ReadInteger(strI2S(Count), 'rating', 0);
    Book[Count].Comment   := INI.ReadString(strI2S(Count), 'comment', '');
    Book[Count].Validated   := INI.ReadInteger(strI2S(Count), 'validated', 0);
    Book[Count].Flags       := INI.ReadString(strI2S(Count), 'flags', '');
    Book[Count].modemfx     := INI.ReadBool(strI2S(Count), 'modemfx', False);
    Book[Count].keystrokefx := INI.ReadBool(strI2S(Count), 'keystrokefx', False);
    Book[Count].Name        := INI.ReadString(strI2S(Count), 'name', '');
    Book[Count].OnDial      := INI.ReadString(strI2S(Count), 'ondial', '');
    Book[Count].OnHangup    := INI.ReadString(strI2S(Count), 'onhangup', '');
    Book[Count].Position    := Count;
  End;

  INI.Free;
End;

Function GetSaveFileName(Header,def: String): String;
Const
  ColorBox = 7;
  ColorBar = 15 + 3 * 16;
Var
  DirList  : TMenuList;
  FileList : TMenuList;
  InStr    : TMenuInput;
  Str      : String;
  Path     : String;
  Mask     : String;
  OrigDIR  : String;
  SaveFile : String;

  Procedure UpdateInfo;
  Begin
    Screen.WriteXY (8,  7, 15 + 3 * 16, strPadR(Path, 60, ' '));
    Screen.WriteXY (8, 21, 15 + 3 * 16, strPadR(SaveFile, 60, ' '));
  End;

  Procedure CreateLists;
  Var
    Dir      : SearchRec;
    DirSort  : TQuickSort;
    FileSort : TQuickSort;
    Count    : LongInt;
  Begin
    DirList.Clear;
    FileList.Clear;

    While Path[Length(Path)] = PathSep Do Dec(Path[0]);

    ChDir(Path);

    Path := Path + PathSep;

    If IoResult <> 0 Then Exit;

    DirList.Picked  := 1;
    FileList.Picked := 1;

    UpdateInfo;

    DirSort  := TQuickSort.Create;
    FileSort := TQuickSort.Create;

    FindFirst (Path + '*', AnyFile - VolumeID, Dir);

    While DosError = 0 Do Begin
      If (Dir.Attr And Directory = 0) or ((Dir.Attr And Directory <> 0) And (Dir.Name = '.')) Then Begin
        FindNext(Dir);
        Continue;
      End;

      DirSort.Add (Dir.Name, 0);
      FindNext    (Dir);
    End;

    FindClose(Dir);

    FindFirst (Path + Mask, AnyFile - VolumeID, Dir);

    While DosError = 0 Do Begin
      If Dir.Attr And Directory <> 0 Then Begin
        FindNext(Dir);

        Continue;
      End;

      FileSort.Add(Dir.Name, 0);
      FindNext(Dir);
    End;

    FindClose(Dir);

    DirSort.Sort  (1, DirSort.Total,  qAscending);
    FileSort.Sort (1, FileSort.Total, qAscending);

    For Count := 1 to DirSort.Total Do
      DirList.Add(DirSort.Data[Count]^.Name, 0);

    For Count := 1 to FileSort.Total Do
      FileList.Add(FileSort.Data[Count]^.Name, 0);

    DirSort.Free;
    FileSort.Free;

    Screen.WriteXY (14, 9, 112, strPadR('(' + strComma(FileList.ListMax) + ')', 7, ' '));
    Screen.WriteXY (53, 9, 112, strPadR('(' + strComma(DirList.ListMax) + ')', 7, ' '));
  End;

Var
  Box  : TMenuBox;
  Done : Boolean;
  Mode : Byte;
Begin
  Result   := '';
  Path     := lastpath;//XferPath;
  Mask     := '*.*';
  SaveFile := def;
  Box      := TMenuBox.Create(TOutput(Screen));
  DirList  := TMenuList.Create(TOutput(Screen));
  FileList := TMenuList.Create(TOutput(Screen));

  GetDIR (0, OrigDIR);

  FileList.NoWindow   := True;
  FileList.LoChars    := #9#13#27;
  FileList.HiChars    := #77;
  FileList.HiAttr     := ColorBar;
  FileList.LoAttr     := ColorBox;

  DirList.NoWindow    := True;
  DirList.NoInput     := True;
  DirList.HiAttr      := ColorBox;
  DirList.LoAttr      := ColorBox;

  //Box.Header := ' Save File ';
  Box.Header := Header;
  Box.HeadAttr := 15 + 7 * 16;
  Box.Open (6, 5, 74, 22);

  Screen.WriteXY ( 8,  6, 112, 'Directory');
  Screen.WriteXY ( 8,  9, 112, 'Files');
  Screen.WriteXY (41,  9, 112, 'Directories');
  Screen.WriteXY ( 8, 20, 112, 'File Name');
  Screen.WriteXY ( 8, 21, 15+3*16, strRep(' ', 40));

  CreateLists;

  DirList.Open (40, 9, 72, 19);
  DirList.Update;

  Done := False;

  Repeat
    FileList.Open (7, 9, 39, 19);

    Case FileList.ExitCode of
      #09,
      #77 : Begin
              FileList.HiAttr := ColorBox;
              DirList.NoInput := False;
              DirList.LoChars := #09#13#27;
              DirList.HiChars := #75;
              DirList.HiAttr  := ColorBar;

              FileList.Update;

              Repeat
                DirList.Open(40, 9, 72, 19);

                Case DirList.ExitCode of
                  #09 : Begin
                          DirList.HiAttr := ColorBox;
                          DirList.Update;

                          Mode  := 1;
                          InStr := TMenuInput.Create(TOutput(Screen));
                          InStr.FillAttr := 15+0*16;
                          InStr.Attr := 15+3*16;
                          InStr.LoChars := #09#13#27;

                          Repeat
                            Case Mode of
                              1 : Begin
                                    Str := InStr.GetStr(8, 21, 60, 255, 1, SaveFile);

                                    Case InStr.ExitCode of
                                      #09 : Mode := 2;
                                      #13 : Begin
                                              SaveFile := Str;
                                              if SaveFile <> '' then 
                                                if fileexist(Path + Savefile) then Begin
                                                  if ShowMsgBox(1, 'File Exists. Overwrite?') then Result := Path + Savefile
                                                  End else Result := Path + Savefile;
                                              if result = Path + Savefile then begin
                                                ChDIR(OrigDIR);
                                                FileList.Free;
                                                DirList.Free;
                                                Box.Close;
                                                Box.Free;
                                                exit;
                                              end;
                                              (*CreateLists;
                                              FileList.Update;
                                              DirList.Update;*)
                                            End;
                                      #27 : Begin
                                              Done := True;
                                              Break;
                                            End;
                                    End;
                                  End;
                              2 : Begin
                                    UpdateInfo;

                                    Str := InStr.GetStr(8, 7, 60, 255, 1, Path);

                                    Case InStr.ExitCode of
                                      #09 : Break;
                                      #13 : Begin
                                              ChDir(Str);

                                              If IoResult = 0 Then Begin
                                                Path := Str;
                                                CreateLists;
                                                FileList.Update;
                                                DirList.Update;
                                              End;
                                            End;
                                      #27 : Begin
                                              Done := True;
                                              Break;
                                            End;
                                    End;
                                  End;
                            End;
                          Until False;

                          InStr.Free;

                          UpdateInfo;

                          Break;
                        End;
                  #13 : If DirList.ListMax > 0 Then Begin
                          ChDir  (DirList.List[DirList.Picked]^.Name);
                          GetDir (0, Path);

                          Path := Path + PathSep;
                          LastPath:=Path;
                          CreateLists;
                          FileList.Update;
                        End;
                  #27 : Done := True;
                  #75 : Break;
                End;
              Until Done;

              DirList.NoInput := True;
              DirList.HiAttr  := ColorBox;
              FileList.HiAttr := ColorBar;
              DirList.Update;
            End;
      #13 : If FileList.ListMax > 0 Then Begin
              //Result := Path + FileList.List[FileList.Picked]^.Name;
              if fileexist(Path + FileList.List[FileList.Picked]^.Name) then Begin
                if ShowMsgBox(1, 'File Exists. Overwrite?') then Result := Path + FileList.List[FileList.Picked]^.Name;
              End else Result := Path + FileList.List[FileList.Picked]^.Name;
              if Result = Path + FileList.List[FileList.Picked]^.Name then Break;
            End;
      #27 : Break;
    End;
  Until Done;

  ChDIR(OrigDIR);

  FileList.Free;
  DirList.Free;
  Box.Close;
  Box.Free;
End;

procedure KeyboardCopy2Clipboard;
type 
  timgpoint = record
    x,y,at:byte;
    ch:char;
  end;

const
  copyfooter = 'Cursor: Move | SPACE: Un/Mark | C: ASCII Copy | A: ANSI Copy | ESC: Back';
    
var
  Image   : TConsoleImageRec;
  xpos    : integer = 40;
  ypos    : integer = 12;
  selection : boolean = false;
  done    : boolean = false;
  oldpoint : timgpoint;
  selbegin : timgpoint;
  x1,x2,y1,y2 : byte;
  
  procedure drawselection;
  var x,y : byte;
  begin
    Screen.PutScreenImage(Image);
    screen.writexy(1,25,14+4*16,strpadr(copyfooter,79,' '));
    x1:=min(selbegin.x,xpos);
    x2:=max(selbegin.x,xpos);
    y1:=min(selbegin.y,ypos);
    y2:=max(selbegin.y,ypos);
    for y:=y1 to y2 do 
      for x:=x1 to x2 do begin
        screen.writexy(x,y,screen.readattrxy(x,y) xor $16,screen.ReadCharXY(x,y));
      end;
  end;
  
  procedure asciicopyimagearea2clipboard;
  var
    x,y : byte;
    ss  : ansistring = '';  
  begin
    x1:=min(selbegin.x,xpos);
    x2:=max(selbegin.x,xpos);
    y1:=min(selbegin.y,ypos);
    y2:=max(selbegin.y,ypos);
    for y:=y1 to y2 do begin
      for x:=x1 to x2 do begin
        ss:=ss+screen.ReadCharXY(x,y)
      end;
      ss:=ss+#13#10;
    end;
    fpsystem('echo "'+ss+'" | xclip -selection c');
  end;
  
  procedure ansicopyimagearea2clipboard;
  var
    x,y   : byte;
    ss    : ansistring = '';
    oldat : byte = 0;
    at    : byte = 0;
  begin
    x1:=min(selbegin.x,xpos);
    x2:=max(selbegin.x,xpos);
    y1:=min(selbegin.y,ypos);
    y2:=max(selbegin.y,ypos);
    for y:=y1 to y2 do begin
      for x:=x1 to x2 do begin
        at := image.data[y][x].Attributes;
        ss:=ss+DiffANSI2Str(Oldat,at);
        ss:=ss+image.data[y][x].UnicodeChar;
        oldat:=at;
      end;
      ss:=ss+#13#10;
    end;
    fpsystem('echo "'+ss+'" | xclip -selection c');
  end;
  
begin
  Screen.GetScreenImage(1, 1, 80, Screen.ScreenSize, Image);
  screen.writexy(1,25,14+4*16,strpadr(copyfooter,79,' '));
  oldpoint.x:=1;
  oldpoint.y:=1;
  oldpoint.ch:=screen.ReadCharXY(1,1);
  oldpoint.at:=screen.readattrxy(1,1);
  while not done do begin
    
    Case Keyboard.ReadKey of
      'c','C' : asciicopyimagearea2clipboard;
      'a','A' : ansicopyimagearea2clipboard;
      #00 : Case Keyboard.ReadKey of
        keyLEFT : begin
                    xpos:=xpos-1;
                    if xpos<0 then xpos:=80;
                  end;
        keyRIGHT: begin
                    xpos:=xpos+1;
                    if xpos>80 then xpos:=1;
                  end;
        keyHOME : xpos:=1;
        keyEND  : xpos:=80;
        keyUP   : begin
                    ypos:=ypos-1;
                    if ypos<0 then ypos:=25
                  end;
        keyDOWN : begin
                    ypos:=ypos+1;
                    if ypos>25 then ypos:=1;
                  end;
        keyPGUP : ypos:=1;
        keyPGDN : ypos:=25;
      end;
      #27   : done:=true;
      #32   : begin
                selection := not selection;
                if selection then begin
                  selbegin := oldpoint;
                end else begin
                  Screen.PutScreenImage(Image);
                  screen.writexy(1,25,14+4*16,strpadr(copyfooter,79,' '));
                end;
              end;
    end;
    screen.writexy(oldpoint.x,oldpoint.y,oldpoint.at,oldpoint.ch);
    oldpoint.x:=xpos;
    oldpoint.y:=ypos;
    oldpoint.ch:=screen.ReadCharXY(xpos,ypos);
    oldpoint.at:=screen.readattrxy(xpos,ypos);
    screen.writexy(xpos,ypos,screen.readattrxy(xpos,ypos) xor $16,screen.ReadCharXY(xpos,ypos));
    if selection then drawselection;
    
  end;
  Screen.PutScreenImage(Image);
end;

Procedure ActivateScrollback;
Var
  TopPage : Integer;
  BotPage : Integer;
  WinSize : Byte;
  Image   : TConsoleImageRec;
  
  Procedure SaveScrollBack;
  Var
    Count1,Count2:integer;
    Outfile : Text;
    OutName : String;
    OldAt   : Byte;
    FG      : Byte;
    BG      : Byte;
  Begin
    Outname := GetSaveFileName(' Save Buffer ','buffer.ans');
    if Outname <> '' then Begin
      Assign     (OutFile, Outname);
      //SetTextBuf (OutFile, Buffer);
      ReWrite    (OutFile);
      OldAt:=0;
      For Count1 := 1 to Screen.ScrollPos Do Begin
        For Count2 := 1 to 79 Do Begin
          If OldAt <> Screen.ScrollBuf[Count1][Count2].Attributes then Begin
            FG := Screen.ScrollBuf[Count1][Count2].Attributes mod 16;
            BG := 16 + (Screen.ScrollBuf[Count1][Count2].Attributes div 16);
            Write(Outfile,Ansi_Color(FG));
            Write(Outfile,Ansi_Color(BG));
          End;
          Write(Outfile,Screen.ScrollBuf[Count1][Count2].UnicodeChar);
          OldAt := Screen.ScrollBuf[Count1][Count2].Attributes 
        End;
        Writeln(Outfile,'');
      End;
      close(Outfile);
    End;
  End;
  
  Procedure DrawPage;
  Var
    Count : Integer;
    YPos  : Integer;
  Begin
    YPos := 1;

    For Count := TopPage to BotPage Do Begin
      Screen.WriteLineRec (YPos, Screen.ScrollBuf[Count + 1]);
      Inc (YPos);
    End;
  End;

Var
  Per      : Byte;
  LastPer  : Byte;
  BarPos   : Byte;
  Offset   : Byte;
  StatusOn : Boolean;

  Procedure DrawStatus;
  Begin
    LastPer  := 0;
    StatusOn := True;

    Screen.WriteXY (1, 23 + Offset, 15, strRep('Ü', 80));
    Screen.WriteXY (1, 25 + Offset,  8, strRep('ß', 80));
    Screen.WriteXYPipe (1, 24 + Offset, 0+7*16, 80, ' Scrollback    |15ALT-S |00Save    |15ESC|00 Quit   |15Space |00Toggle                 |00(   /' + strPadR(strI2S(Screen.ScrollPos-1), 4, ' ') + '|00');
  End;

Begin
  If Screen.ScrollPos <= 0 Then Begin
    ShowMsgBox(0, 'No scrollback data');
    Exit;
  End;

  Case Screen.ScreenSize of
    25 : Begin
           Offset  := 0;
           WinSize := 21;
         End;
    50 : Begin
           Offset  := 25;
           WinSize := 46;
         End;
  End;

  Screen.GetScreenImage(1, 1, 80, Screen.ScreenSize, Image);
  Screen.ClearScreen;

  TopPage := Screen.ScrollPos - WinSize - 1;
  BotPage := Screen.ScrollPos - 1;

  If TopPage < 0 Then TopPage := 0;

  DrawStatus;
  DrawPage;

  Repeat
    If StatusOn Then Begin
      Screen.WriteXY (70, 24 + Offset, 0+7*16, strPadL(strI2S(BotPage), 4, ' '));

      Per := Round(BotPage / Screen.ScrollPos * 100 / 10);

      If Per = 0 Then Per := 1;

      If LastPer <> Per Then Begin
        BarPos := 0;

        Screen.WriteXY (58, 24 + Offset, 3, '°°°°°°°°°°');

        Repeat
          Inc (BarPos);

          Case BarPos of
            (*
            1 : Screen.WriteXY (58, 24 + Offset,  3, '°');
            2 : Screen.WriteXY (59, 24 + Offset,  3, '±');
            3 : Screen.WriteXY (60, 24 + Offset,  3, '²');
            4 : Screen.WriteXY (61, 24 + Offset,  3, 'Û');
            5 : Screen.WriteXY (62, 24 + Offset, 27, '°');
            6 : Screen.WriteXY (63, 24 + Offset, 27, '±');
            7 : Screen.WriteXY (64, 24 + Offset, 27, '²');
            8 : Screen.WriteXY (65, 24 + Offset, 11, 'Û');
            9 : Screen.WriteXY (66, 24 + Offset, 27, '±');
            10: Screen.WriteXY (67, 24 + Offset, 27, '²');
            *)
            1 : Screen.WriteXY (58, 24 + Offset, 11, '²');
            2 : Screen.WriteXY (59, 24 + Offset, 11, '²');
            3 : Screen.WriteXY (60, 24 + Offset, 11, '²');
            4 : Screen.WriteXY (61, 24 + Offset, 11, '²');
            5 : Screen.WriteXY (62, 24 + Offset, 11, '²');
            6 : Screen.WriteXY (63, 24 + Offset, 11, '²');
            7 : Screen.WriteXY (64, 24 + Offset, 11, '²');
            8 : Screen.WriteXY (65, 24 + Offset, 11, '²');
            9 : Screen.WriteXY (66, 24 + Offset, 11, '²');
            10: Screen.WriteXY (67, 24 + Offset, 11, '²');
            
          End;
        Until BarPos = Per;

        LastPer := Per;
      End;
    End;

    Case Keyboard.ReadKey of
      #00 : Case Keyboard.ReadKey of
              keyALTS : SaveScrollBack;
              keyHOME : If TopPage > 0 Then Begin
                          TopPage := 0;
                          BotPage := WinSize;
                          DrawPage;
                        End;
              keyEND  : If BotPage <> Screen.ScrollPos - 1 Then Begin
                          TopPage := Screen.ScrollPos - 1 - WinSize;
                          BotPage := Screen.ScrollPos - 1;
                          DrawPage;
                        End;
              keyUP   : If TopPage > 0 Then Begin
                          Dec (TopPage);
                          Dec (BotPage);
                          DrawPage;
                        End;
              keyDOWN : If BotPage < Screen.ScrollPos - 1 Then Begin
                          Inc (TopPage);
                          Inc (BotPage);
                          DrawPage;
                        End;
              keyPGUP : If TopPage - WinSize > 0 Then Begin
                          Dec (TopPage, WinSize);
                          Dec (BotPage, WinSize);
                          DrawPage;
                        End Else Begin
                          TopPage := 0;
                          BotPage := WinSize;
                          DrawPage;
                        End;
              keyPGDN : If BotPage + WinSize < Screen.ScrollPos - 1 Then Begin
                          Inc (TopPage, WinSize + 1);
                          Inc (BotPage, WinSize + 1);
                          DrawPage;
                        End Else Begin
                          TopPage := Screen.ScrollPos - WinSize - 1;
                          BotPage := Screen.ScrollPos - 1;
                          DrawPage;
                        End;
            End;
      #27 : Break;
      #32 : Begin
              If StatusOn Then Begin
                Case Screen.ScreenSize of
                  25 : WinSize := 24;
                  50 : WinSize := 49;
                End;
                StatusOn := False;

                Inc (BotPage, 3);

                If BotPage > Screen.ScrollPos - 1 Then Begin
                  TopPage := Screen.ScrollPos - WinSize - 1;
                  BotPage := Screen.ScrollPos - 1;
                  If TopPage < 0 Then TopPage := 0;
                End;

                DrawPage;
              End Else Begin
                StatusOn := True;

                Case Screen.ScreenSize of
                  25 : WinSize := 21;
                  50 : WinSize := 46;
                End;

                Dec (BotPage, 3);
                DrawStatus;
                DrawPage;
              End;
            End;
    End;
  Until False;

  Screen.PutScreenImage(Image);
End;

Function ProtocolAbort : Boolean;
Begin
  Result := Keyboard.KeyPressed and (KeyBoard.ReadKey = #27);
End;

Procedure UProtocolStatusUpdate (var Starting, Ending:boolean; Status: RecProtocolStatus);
Var
  KBRate  : LongInt;
Begin
  
  Screen.WriteXY (25,  8, 11, strPadR(Status.FileName, 30, ' '));
  Screen.WriteXY (25,  9, 11, strPadR(strComma(Status.FileSize), 15, ' '));
  Screen.WriteXY (25, 10, 11, strPadR(strComma(Status.Position), 15, ' '));
  Screen.WriteXY (51,  9, 11, strPadR(strI2S(Status.Errors), 3, ' '));
  
  Screen.WriteXY (51, 11, 11, strPadR(strI2S(Status.Count), 3, ' '));
  
  KBRate := 0;

  If (TimerSeconds - Status.StartTime > 0) and (Status.Position > 0) Then
    KBRate := Round((Status.Position / (TimerSeconds - Status.StartTime)) / 1024);

  Screen.WriteXY (51, 10, 11, strPadR(strI2S(KBRate) + ' k/sec', 11, ' '));
  
  screen.writexy(transarray[1,transindex],transarray[2,transindex],8,Screen.ReadCharXY (transarray[1,transindex],transarray[2,transindex]));
  screen.writexy(transarray[1,transindex-1],transarray[2,transindex-1],15,Screen.ReadCharXY (transarray[1,transindex-1],transarray[2,transindex-1]));
  
  transindex := transindex - 1;
  if transindex < 2 then begin
    screen.writexy(transarray[1,transindex],transarray[2,transindex],8,Screen.ReadCharXY (transarray[1,transindex],transarray[2,transindex]));
    transindex := 17;
  end;
  
End;

Procedure DProtocolStatusUpdate (var Starting, Ending:boolean; Status: RecProtocolStatus);
Var
  KBRate  : LongInt;
Begin
  
  Screen.WriteXY (25,  8, 11, strPadR(Status.FileName, 30, ' '));
  Screen.WriteXY (25,  9, 11, strPadR(strComma(Status.FileSize), 15, ' '));
  Screen.WriteXY (25, 10, 11, strPadR(strComma(Status.Position), 15, ' '));
  Screen.WriteXY (51,  9, 11, strPadR(strI2S(Status.Errors), 3, ' '));
  
  Screen.WriteXY (51, 11, 11, strPadR(strI2S(Status.Count), 3, ' '));
  
  KBRate := 0;

  If (TimerSeconds - Status.StartTime > 0) and (Status.Position > 0) Then
    KBRate := Round((Status.Position / (TimerSeconds - Status.StartTime)) / 1024);

  Screen.WriteXY (51, 10, 11, strPadR(strI2S(KBRate) + ' k/sec', 11, ' '));
  
  screen.writexy(transarray[1,transindex+1],transarray[2,transindex+1],15,Screen.ReadCharXY (transarray[1,transindex+1],transarray[2,transindex+1]));
  screen.writexy(transarray[1,transindex],transarray[2,transindex],8,Screen.ReadCharXY (transarray[1,transindex],transarray[2,transindex]));
  transindex := transindex + 1;
  if transindex >= 17 then begin
    screen.writexy(transarray[1,transindex],transarray[2,transindex],8,Screen.ReadCharXY (transarray[1,transindex],transarray[2,transindex]));
    transindex := 1;
  end;
  
End;

Procedure ProtocolStatusDraw;
Var
  Box : TMenuBox;
Begin
  Box := TMenuBox.Create(TOutput(Screen));
  Box.FrameType  := pref.MsgBox_FrameType;
  Box.HeadAttr   := pref.MsgBox_HeadAttr ;
  Box.BoxAttr    := pref.MsgBox_BoxAttr  ;
  Box.BoxAttr2   := pref.MsgBox_BoxAttr2 ;
  Box.BoxAttr3   := pref.MsgBox_BoxAttr3 ;
  Box.BoxAttr4   := pref.MsgBox_BoxAttr4 ;
  Box.Box3D      := pref.MsgBox_Box3D ;
  Box.Header := ' Zmodem File Transfer ';
  Box.Open (6, 6, 76, 16);
  
screen.writexypipe(8,8,7,66,'|15|23Û|17ßßßßßßßß|16Û|07                                             |15|23Û|18ßßßßßßßß|16Û');
screen.writexypipe(8,9,7,66,'|15Û|17 /bbs   |16Û|07                                             |15Û|18 /local |16Û');
screen.writexypipe(8,10,7,66,'|15Û|17        |16Û|07                                             |15Û|18        |16Û');
screen.writexypipe(8,11,7,66,'|15ß|23ßßßßßß|10þ|15ß|16ß|07                                             |15ß|23ßßßßßß|10þ|15ß|16ß');
screen.writexypipe(8,12,7,66,'    |08ÜÜ|07                                                |08Ú|07    |08ÜÜ');
screen.writexypipe(8,13,7,66,'  |08ß|07ß|15ßß|07ß|08ß|07   |08ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ|07  |08ß|07ß|15ßß|07ß|08ß');
screen.writexypipe(8,14,7,66,'      |08ÀÄÄÄÄÙ');


  

  Screen.WriteXY (19, 8, 3, 'File:');
  Screen.WriteXY (19, 9, 3, 'Size:');
  Screen.WriteXY (19, 10, 3, 'Pos.:');
  Screen.WriteXY (43, 9, 3,  'Errors:');
  Screen.WriteXY (43, 10, 3, 'Rate  :');
  Screen.WriteXY (43, 11, 3, 'Count :');
  //transindex := 1;
  
  Box.Free;
  
End;

Function GetUploadFileName(Header,mask: String) : String;
Const
  ColorBox = 7;
  ColorBar = 15 + 3 * 16;
Var
  DirList  : TMenuList;
  FileList : TMenuList;
  InStr    : TMenuInput;
  Str      : String;
  Path     : String;
  OrigDIR  : String;

  Procedure UpdateInfo;
  Begin
    Screen.WriteXY (8,  7, ColorBar, strPadR(Path, 60, ' '));
    Screen.WriteXY (8, 21, ColorBar, strPadR(Mask, 60, ' '));
  End;

  Procedure CreateLists;
  Var
    Dir      : SearchRec;
    DirSort  : TQuickSort;
    FileSort : TQuickSort;
    Count    : LongInt;
  Begin
    DirList.Clear;
    FileList.Clear;

    While Path[Length(Path)] = PathSep Do Dec(Path[0]);

    ChDir(Path);

    Path := Path + PathSep;

    If IoResult <> 0 Then Exit;

    DirList.Picked  := 1;
    FileList.Picked := 1;

    UpdateInfo;

    DirSort  := TQuickSort.Create;
    FileSort := TQuickSort.Create;

    FindFirst (Path + '*', AnyFile - VolumeID, Dir);

    While DosError = 0 Do Begin
      If (Dir.Attr And Directory = 0) or ((Dir.Attr And Directory <> 0) And (Dir.Name = '.')) Then Begin
        FindNext(Dir);
        Continue;
      End;

      DirSort.Add (Dir.Name, 0);
      FindNext    (Dir);
    End;

    FindClose(Dir);

    FindFirst (Path + Mask, AnyFile - VolumeID, Dir);

    While DosError = 0 Do Begin
      If Dir.Attr And Directory <> 0 Then Begin
        FindNext(Dir);

        Continue;
      End;

      FileSort.Add(Dir.Name, 0);
      FindNext(Dir);
    End;

    FindClose(Dir);

    DirSort.Sort  (1, DirSort.Total,  qAscending);
    FileSort.Sort (1, FileSort.Total, qAscending);

    For Count := 1 to DirSort.Total Do
      DirList.Add(DirSort.Data[Count]^.Name, 0);

    For Count := 1 to FileSort.Total Do
      FileList.Add(FileSort.Data[Count]^.Name, 0);

    DirSort.Free;
    FileSort.Free;

    Screen.WriteXY (14, 9, 7*16, strPadR('(' + strComma(FileList.ListMax) + ')', 7, ' '));
    Screen.WriteXY (53, 9, 7*16, strPadR('(' + strComma(DirList.ListMax) + ')', 7, ' '));
  End;

Var
  Box  : TMenuBox;
  Done : Boolean;
  Mode : Byte;
Begin
  Result   := '';
  Path     := lastpath;//XferPath;
  //Mask     := '*.bbs';
  Box      := TMenuBox.Create(TOutput(Screen));
  DirList  := TMenuList.Create(TOutput(Screen));
  FileList := TMenuList.Create(TOutput(Screen));

  GetDIR (0, OrigDIR);

  FileList.NoWindow   := True;
  FileList.LoChars    := #9#13#27;
  FileList.HiChars    := #77;
  FileList.HiAttr     := ColorBar;
  FileList.LoAttr     := ColorBox;

  DirList.NoWindow    := True;
  DirList.NoInput     := True;
  DirList.HiAttr      := ColorBox;
  DirList.LoAttr      := ColorBox;

  //Box.Header := ' Upload file ';
  Box.Header := Header;
  Box.HeadAttr := 15+7*16;
  Box.Open (6, 5, 74, 22);

  Screen.WriteXY ( 8,  6, 7*16, 'Directory');
  Screen.WriteXY ( 8,  9, 7*16, 'Files');
  Screen.WriteXY (41,  9, 7*16, 'Directories');
  Screen.WriteXY ( 8, 20, 7*16, 'File Mask');
  Screen.WriteXY ( 8, 21,  15+3*16, strRep(' ', 40));

  CreateLists;

  DirList.Open (40, 9, 72, 19);
  DirList.Update;

  Done := False;

  Repeat
    FileList.Open (7, 9, 39, 19);

    Case FileList.ExitCode of
      #09,
      #77 : Begin
              FileList.HiAttr := ColorBox;
              DirList.NoInput := False;
              DirList.LoChars := #09#13#27;
              DirList.HiChars := #75;
              DirList.HiAttr  := ColorBar;

              FileList.Update;

              Repeat
                DirList.Open(40, 9, 72, 19);

                Case DirList.ExitCode of
                  #09 : Begin
                          DirList.HiAttr := ColorBox;
                          DirList.Update;

                          Mode  := 1;
                          InStr := TMenuInput.Create(TOutput(Screen));
                          InStr.LoChars := #09#13#27;
                          InStr.FillAttr := 15+0*16;
                          InStr.Attr := colorbar;
                          Repeat
                            Case Mode of
                              1 : Begin
                                    InStr.Attr := colorbar;
                                    Str := InStr.GetStr(8, 21, 60, 255, 1, Mask);

                                    Case InStr.ExitCode of
                                      #09 : Mode := 2;
                                      #13 : Begin
                                              Mask := Str;
                                              CreateLists;
                                              FileList.Update;
                                              DirList.Update;
                                            End;
                                      #27 : Begin
                                              Done := True;
                                              Break;
                                            End;
                                    End;
                                  End;
                              2 : Begin
                                    UpdateInfo;
                                    InStr.Attr := colorbar;
                                    Str := InStr.GetStr(8, 7, 60, 255, 1, Path);

                                    Case InStr.ExitCode of
                                      #09 : Break;
                                      #13 : Begin
                                              ChDir(Str);

                                              If IoResult = 0 Then Begin
                                                Path := Str;
                                                CreateLists;
                                                FileList.Update;
                                                DirList.Update;
                                              End;
                                            End;
                                      #27 : Begin
                                              Done := True;
                                              Break;
                                            End;
                                    End;
                                  End;
                            End;
                          Until False;

                          InStr.Free;

                          UpdateInfo;

                          Break;
                        End;
                  #13 : If DirList.ListMax > 0 Then Begin
                          ChDir  (DirList.List[DirList.Picked]^.Name);
                          GetDir (0, Path);

                          Path := Path + PathSep;
                          LastPath:=Path;
                          CreateLists;
                          FileList.Update;
                        End;
                  #27 : Done := True;
                  #75 : Break;
                End;
              Until Done;

              DirList.NoInput := True;
              DirList.HiAttr  := ColorBox;
              FileList.HiAttr := ColorBar;
              DirList.Update;
            End;
      #13 : If FileList.ListMax > 0 Then Begin
              Result := Path + FileList.List[FileList.Picked]^.Name;
              LastPath:=Path;
              Break;
            End;
      #27 : Break;
    End;
  Until Done;

  ChDIR(OrigDIR);

  FileList.Free;
  DirList.Free;
  Box.Close;
  Box.Free;
End;

Procedure DoZmodemDownload (Var Client: TIOSocket);
Var
  Zmodem : TProtocolZmodem;
  Image  : TConsoleImageRec;
  ZQueue  : TProtocolQueue;
  
  zh : ZHdrType;
  st : longint;
Begin
  If Not DirExists(pref.downloadpath) Then Begin
    ShowMsgBox (0, 'Download directory does not exist');

    Exit;
  End;

  ZQueue  := TProtocolQueue.Create;
  Zmodem := TProtocolZmodem.Create(Client, ZQueue);

  Screen.GetScreenImage(1, 1, 80, Screen.ScreenSize, Image);
  transindex := 1;
  ProtocolStatusDraw;

  Zmodem.StatusProc  := @DProtocolStatusUpdate;
  Zmodem.AbortProc   := @ProtocolAbort;
  Zmodem.ReceivePath := pref.downloadpath;
  Zmodem.CurBufSize  := 8 * 1024;

  Zmodem.QueueReceive;    

  Zmodem.Free;
  ZQueue.Free;
  
  center('|11Download Complete!',14);
  center('|03Press any key to continue...',15);
  KeyBoard.ReadKey
  //Screen.PutScreenImage(Image);
End;

Procedure DoZmodemUpload (Var Client: TIOSocket);
Var
  FileName : String;
  Zmodem   : TProtocolZmodem;
  Image    : TConsoleImageRec;
Begin
  
  Zmodem := TProtocolZmodem.Create(Client, Queue);

  Screen.GetScreenImage(1, 1, 80, Screen.ScreenSize, Image);
  transindex := 17;
  ProtocolStatusDraw;

  Zmodem.StatusProc := @UProtocolStatusUpdate;
  Zmodem.AbortProc  := @ProtocolAbort;

  
  If Queue.QSize = 0 Then Begin
    ShowMsgBox(0,'Insert some files in the Queue first!');
    Zmodem.DoAbortSequence;
  end else
    Zmodem.QueueSend;
  Zmodem.Free;
    
  If ShowMsgBox(1, 'Upload finished. Clear File Queue?') then begin
    Queue.Clear;
  end;
  

  Screen.PutScreenImage(Image);
End;

Procedure EditEntry (Var Book: PhoneBookRec; Num: word);
Var
  Box    : TMenuBox;
  Form   : TMenuForm;
  NewRec : PhoneRec;
  Image  : TConsoleImageRec;
  oldx,oldy:byte;
  y : byte = 0;
Begin

  if dropinfo.isdoor then if not isacs(pref.EditBookSec) then begin
    ShowMsgBox(0,'You don''t have the priviliges, for this function!');
    exit;
  end;  
  
  NewRec := Book[Num];
  Box    := TMenuBox.Create(TOutput(Screen));
  Form   := TMenuForm.Create(TOutput(Screen));

  Box.Header   := ' Book Editor ';
  Box.FrameType  := pref.MsgBox_FrameType;
  Box.HeadAttr   := pref.MsgBox_HeadAttr ;
  Box.BoxAttr    := pref.MsgBox_BoxAttr  ;
  Box.BoxAttr2   := pref.MsgBox_BoxAttr2 ;
  Box.BoxAttr3   := pref.MsgBox_BoxAttr3 ;
  Box.BoxAttr4   := pref.MsgBox_BoxAttr4 ;
  Box.Box3D      := pref.MsgBox_Box3D ;
  
  oldx:=screen.cursorx;
  oldy:=screen.cursory;
  Screen.GetScreenImage(1, 1, 80, Screen.ScreenSize, Image);
  
  Box.Open (35, 12, 45, 14);
  box.close;
  waitms(200);
  Box.Open (22, 10, 55, 18);
  box.close;
  waitms(200);
  Box.Open (17, 8, 63, 23);

  Form.HelpSize := 0;
  
  With Form do Begin
    cLo          := pref.form_lo;
    cHi          := pref.form_hi;
    cData        := pref.form_data;
    cLoKey       := pref.form_lokey;
    cHiKey       := pref.form_hikey;
    cField1      := pref.form_field1;
    cField2      := pref.form_field2;
  end;
  
  //newrec.statusbar:=false;
  //newrec.calls:='0';
  //newrec.lastcall:=DateDos2Unix(CurDateDos);
  //newrec.added:=DateDos2Unix(CurDateDos);
  
  //newrec.rating:=0;
  
  y:=9;
  Form.AddStr  ('N', ' Name'   ,   24, y, 32, y,  6, 26, 26, @NewRec.Name, '');y:=y+1;
  Form.AddStr  ('A', ' Address',   21, y, 32, y,  9, 30, 60, @NewRec.Address, '');y:=y+1;
  Form.AddStr  ('U', ' User Name', 19, y, 32, y, 11, 30, 30, @NewRec.User, '');y:=y+1;
  Form.AddPass ('P', ' Password',  20, y, 32, y, 10, 20, 20, @NewRec.Password, '');y:=y+1;
  Form.AddByte ('R', ' Rating', 22, y, 32, y, 8, 30, 1,100, @NewRec.Rating, '');y:=y+1;
  Form.AddStr  ('C', ' Comment', 21, y, 32, y, 9, 30, 30, @NewRec.Comment, '');y:=y+1;
  Form.AddStr  ('Y', ' Sysop', 23, y, 32, y, 7, 30, 30, @NewRec.Sysop, '');y:=y+1;
  Form.AddStr  ('S', ' Software', 20, y, 32, y, 10, 30, 30, @NewRec.Software, '');y:=y+1;
  Form.AddBol  ('B', ' StatusBar', 19, y, 32, y, 11,  3, @NewRec.StatusBar, '');y:=y+1;
  Form.AddBol  ('M', ' Music', 23, y, 32, y, 7,  3, @NewRec.Music, '');y:=y+1;
  
  Form.AddStr  ('D', ' OnDial',   22, y, 32, y,  8, 30, 254, @NewRec.OnDial, '');y:=y+1;
  Form.AddStr  ('H', ' OnHangUp',   20, y, 32, y,  10, 30, 254, @NewRec.OnHangup, '');y:=y+1;
  
  Form.AddBol  ('F', ' ModemFX', 21, y, 32, y, 9,  3, @NewRec.modemfx, '');y:=y+1;
  Form.AddBol  ('K', ' KeysFX', 22, y, 32, y, 8,  3, @NewRec.keystrokefx, '');y:=y+1;
  
  Form.Execute;

  If Form.Changed Then
    If ShowMsgBox(1, 'Save changes?') Then Begin
      newrec.lastedit:=DateDos2Unix(CurDateDos);
      Book[Num] := NewRec;
      WriteBook(Book,BookFile);
    End;

  Form.Free;

  Box.Close;
  Box.Free;
  Screen.PutScreenImage(Image);
  screen.cursorxy(oldx,oldy);
End;

Procedure EditMacros;
Var
  Box    : TMenuBox;
  Form   : TMenuForm;
Begin
  if dropinfo.isdoor then if not isacs(pref.EditMacrosSec) then begin
    ShowMsgBox(0,'You don''t have the priviliges, for this function!');
    exit;
  end;
  
  Box    := TMenuBox.Create(TOutput(Screen));
  Form   := TMenuForm.Create(TOutput(Screen));

  Box.Header   := ' Macros ';
  Box.FrameType  := pref.MsgBox_FrameType;
  Box.HeadAttr   := pref.MsgBox_HeadAttr ;
  Box.BoxAttr    := pref.MsgBox_BoxAttr  ;
  Box.BoxAttr2   := pref.MsgBox_BoxAttr2 ;
  Box.BoxAttr3   := pref.MsgBox_BoxAttr3 ;
  Box.BoxAttr4   := pref.MsgBox_BoxAttr4 ;
  Box.Box3D      := pref.MsgBox_Box3D ;
  
  Box.Open (17, 8, 63, 21);

  Form.HelpSize := 0;
  
  With Form do Begin
    cLo          := pref.form_lo;
    cHi          := pref.form_hi;
    cData        := pref.form_data;
    cLoKey       := pref.form_lokey;
    cHiKey       := pref.form_hikey;
    cField1      := pref.form_field1;
    cField2      := pref.form_field2;
  end;

  Form.AddStr  ('1', '  F1', 19, 10, 25, 10,  5, 37, 255, @Macro[1], '');
  Form.AddStr  ('2', '  F2', 19, 11, 25, 11,  5, 37, 255, @Macro[2], '');
  Form.AddStr  ('3', '  F3', 19, 12, 25, 12,  5, 37, 255, @Macro[3], '');
  Form.AddStr  ('4', '  F4', 19, 13, 25, 13,  5, 37, 255, @Macro[4], '');
  Form.AddStr  ('5', '  F5', 19, 14, 25, 14,  5, 37, 255, @Macro[5], '');
  Form.AddStr  ('6', '  F6', 19, 15, 25, 15,  5, 37, 255, @Macro[6], '');
  Form.AddStr  ('7', '  F7', 19, 16, 25, 16,  5, 37, 255, @Macro[7], '');
  Form.AddStr  ('8', '  F8', 19, 17, 25, 17,  5, 37, 255, @Macro[8], '');
  Form.AddStr  ('9', '  F9', 19, 18, 25, 18,  5, 37, 255, @Macro[9], '');
  Form.AddStr  ('0', ' F10', 19, 19, 25, 19,  5, 37, 255, @Macro[0], '');

  Form.Execute;

  If Form.Changed Then
    If ShowMsgBox(1, 'Save changes?') Then Begin
      SaveMacros;
      LoadMacros;
    End;
      
  Form.Free;

  Box.Close;
  Box.Free;
End;

Procedure SearchEntry (Var Owner: Pointer; Str: String);
Begin
  If Str = '' Then
    Str := strRep(' ', 17)
  Else Begin
    If Length(Str) > 15 Then
      Str := Copy(Str, Length(Str) - 15 + 1, 255);

    Str := strLower(Str);

    While Length(Str) < 17 Do
      Str := Str + ' ';
  End;

  Screen.WriteXY (TMenuList(Owner).SearchX,
                  TMenuList(Owner).SearchY,
                  TMenuList(Owner).SearchA,
                  Str);
End;

Procedure FileQueue;
Var
  Count  : word;
  Count2 : word;
  List   : TMenuList;
  Found  : Boolean;
  Picked : word;
  ch     : Char;
  UploadF: String;
  Image  : TConsoleImageRec;
  Oldx   : Byte;
  Oldy   : Byte;
Begin
  DrawQueueAnsi;

  Picked := 1;

  List := TMenuList.Create(TOutput(Screen));

  List.NoWindow := True;
  List.LoAttr   := pref.listlow;
  List.HiAttr   := pref.listhi;
  List.LoChars  := #27;
  List.HiChars  := #30#83#44#46;
  List.SetSearchProc(SearchEntry);

  Repeat
    List.Clear;

    List.Picked := Picked;

    For Count := 1 to Queue.QSize Do
      List.Add(strPadR(JustFile(Queue.QData[Count].FileName), 23, ' ') + 
               strPadR(JustPath(Queue.QData[Count].FilePath), 37, ' ') + 
               //Queue.QData[Count].Extra + '   ' +
               strPadL(StrI2S(Queue.QData[Count].FileSize), 9, ' '),
               2);
    
    //List Position
    //List.Open(1, 8, 80, 22);
    List.Open(4, 8, 77, 22);
    UploadF := '';
    Picked := List.Picked;

    Case List.ExitCode of
      #30 : Begin
              UploadF:=GetUploadFileName(' Upload File ','*.*');
              if UploadF <> '' then Begin
                If Queue.Add(false,JustPath(UploadF),JustFile(UploadF),'')=false then
                  ShowMsgBox(0,'Error');
                End;
            End;
      #46 : If ShowMsgBox(1,'Clear List?') then Queue.Clear;
      #44 : Begin
                          Oldx:=Screen.Cursorx;
                          Oldy:=Screen.Cursory;
                          Screen.GetScreenImage(1, 1, 80, Screen.ScreenSize, Image);
                          DrawHelpAnsi;
                          //Screen.WriteXYPipe(25,16,7,49,'|15ALT-L |08: |15Se|10nd |02Login|08 Info.');
                          //Screen.WriteXYPipe(25,17,7,49,'|15ALT-E |08: |15Ed|10it |02Phone|08book Entry');
                          //Screen.WriteXYPipe(25,18,7,49,'|15ALT-T |08: |15Tr|10ans|02fer F|08ile');
                          //Screen.WriteXYPipe(25,19,7,49,'|15ALT-A |08: |15Au|10toT|02ext');
                          Center('|15P|10r|02ess a |15K|10e|02y to |15C|10o|02ntinue',21);
                          Keyboard.ReadKey;
                          Screen.PutScreenImage(Image);
                          Screen.CursorXY(Oldx,Oldy);
            end;    
      #27,#13 : Break;
      #83 : If ShowMsgBox(1, 'Delete this record?') Then Begin
              Queue.delete(List.Picked); 
            End;
    End;
    Screen.WriteXYPipe(53,6,7,19,'|15T|07ota|08l |15F|07ile|08s:');
    Screen.WriteXYPipe(67,6,15,19,StrPadL(StrI2S(Queue.QSize),3,' '));
  Until False;

  List.Free;
End;

Function GetQuote(i:integer):string;
var 
  f:text;
  s,q: string;
  d:integer;
Begin
  Result:='';
  if i>TotalQuotes then exit;
  s:=pref.quotefile;
  if not fileexist(s) then begin
    s:=appdir+pref.quotefile;
    if not fileexist(s) then exit;
  end;
  assign(f,s);
  reset(f);
  for d:=1 to i do
    readln(f,q);
  close(f);
  result:=q;
end;

Function MCI2Str(M:String; Dial: PhoneRec):String;
Var
  g:string;
Begin
  g:=m;
  g:=strReplace(g,'|DA',FormatUnixDate(CurDateDos));
  g:=strReplace(g,'|BN',dial.address);
  g:=strReplace(g,'|CS',dial.calls);
  if dropinfo.isdoor=false then g:=strReplace(g,'|UN',dial.user) else g:=strReplace(g,'|UN',dropinfo.Alias);
  g:=strReplace(g,'|LO',FormatUnixDate(dial.lastcall));
  if dropinfo.isdoor=false then g:=strReplace(g,'|SL','loc') else g:=strReplace(g,'|SL',stri2s(dropinfo.Access));
  g:=strReplace(g,'|QO',GetQuote(Random(TotalQuotes)));
  g:=strReplace(g,'|BD',Appdir);
  Result:=g;
End;

Procedure TelnetClient (Var Book: PhoneBookRec; Dial: PhoneRec);
Const
  BufferSize = 1024 * 4;

Var
  Client : TIOSocket;
  Res    : LongInt;
  Buffer : Array[1..BufferSize] of Char;
  Done   : Boolean;
  Ch     : Char;
  Count  : LongInt;  
  Tracks : Array[0..255] of string[40];
  MusicDir : string;
  Oldx   : Byte;
  Oldy   : Byte;
  Image  : TConsoleImageRec;
  ShowSB : Boolean;
  
  
  
  
  
  Procedure DrawStatus (Toggle: Boolean);
  Begin
    If Toggle Then Begin
      Dial.StatusBar:=not Dial.StatusBar;
      if Dial.StatusBar=false then begin
        Screen.SetWindow (1, 1, 80, 25, False);
        Screen.CursorXY(1,25);
      end;
    End;
    If Dial.StatusBar Then Begin
      Screen.SetWindow (1, 1, 80, 24, False);
      Screen.CursorXY(1,25);
      Screen.WriteXYPipe(1,25,7,79,MCI2Str(pref.statusbar,dial));
      //Screen.WriteXYPipe(69,25,7,10,'|15ALT-X|07 Q|08uit');
    End;
  End;
    
  Procedure ExecuteMacro(Mac: Byte);
  Var
    i   : Byte;
    Str : String;
    Pipe: String;
    l : string;
    err:longint;
  Begin
    i := 0;
    Str := Macro[Mac];
    While i <= Length(Str) do Begin
      Inc(i,1);
      If (Str[i] = '|') Then Begin
        pipe:=copy(Str,i,3);
        Case Pipe[2] Of
          'S' : Case Pipe[3] of
                    'H' : Begin
                            l:=copy(str,4,length(str));
                            l:=strreplace(l,'|BD',appdir);
                            If Showmsgbox(1,'Execute: '+l+'?') then begin
                              screen.textattr:=7;
                              screen.clearscreen;
                              err:=fpsystem(l); 
                              //showmsgbox(0,'Script finished with status: '+stri2s(err));
                              drawmainansi;
                            end;
                          End;
                  End;
          'B' : Case Pipe[3] of
                  'D' : Client.WriteStr(Appdir);
                End;
          'C' : Case Pipe[3] Of
                  'R' : Client.WriteStr(#13);
                  'L' : Screen.ClearScreen;
                  'E' : Client.WriteStr(#27);
                 End;
          'U'  : Case Pipe[3] Of
                  'N' : Client.WriteStr (Dial.User + #13);
                 End;
          'P' : Case Pipe[3] Of
                  'W' : Client.WriteStr (Dial.Password + #13);
                  'A' : WaitMS(500);
                End;
          'Q' : Case Pipe[3] of
                  'O' : Client.WriteStr(GetQuote(Random(TotalQuotes)));
                End;
          'D' : Case Pipe[3] of
                  'A' : Client.WriteStr(FormatUnixDate(DateDos2Unix(CurDateDos)));
                End;
        End;
        Inc(i,2);  
      End Else Begin
        Client.WriteStr(Str[i]);
      End;
      
    End;
    DrawStatus(false);
  End;

  Procedure AutoWriteText(Clientt : TIOSocket);
  Var
    Box    : TMenuBox;
    Form   : TMenuForm;
    Line   : Array[1..9] of String[79];
    i,d    : ShortInt;
    OldX,
    OldY   : Byte;
  Begin
    OldX   := Screen.CursorX;
    OldY   := Screen.CursorY;
    Box    := TMenuBox.Create(TOutput(Screen));
    Form   := TMenuForm.Create(TOutput(Screen));

    Box.Header   := ' Edit Text ';
    Box.FrameType  := pref.MsgBox_FrameType;
    Box.HeadAttr   := pref.MsgBox_HeadAttr ;
    Box.BoxAttr    := pref.MsgBox_BoxAttr  ;
    Box.BoxAttr2   := pref.MsgBox_BoxAttr2 ;
    Box.BoxAttr3   := pref.MsgBox_BoxAttr3 ;
    Box.BoxAttr4   := pref.MsgBox_BoxAttr4 ;
    Box.Box3D      := pref.MsgBox_Box3D ;
    Box.Open (1, 8, 80, 20);

    Form.HelpSize := 0;
  
    With Form do Begin
      cLo          := pref.form_lo;
      cHi          := pref.form_hi;
      cData        := pref.form_data;
      cLoKey       := pref.form_lokey;
      cHiKey       := pref.form_hikey;
      cField1      := pref.form_field1;
      cField2      := pref.form_field2;
    end;
    
    For i:=1 to 9 do Line[i]:='';

    Form.AddStr  ('1', ' Line1', 3, 10, 10, 10, 6, 69, 79, @line[1], '');
    Form.AddStr  ('2', ' Line2', 3, 11, 10, 11, 6, 69, 79, @line[2], '');
    Form.AddStr  ('3', ' Line3', 3, 12, 10, 12, 6, 69, 79, @line[3], '');
    Form.AddStr  ('4', ' Line4', 3, 13, 10, 13, 6, 69, 79, @line[4], '');
    Form.AddStr  ('5', ' Line5', 3, 14, 10, 14, 6, 69, 79, @line[5], '');
    Form.AddStr  ('6', ' Line6', 3, 15, 10, 15, 6, 69, 79, @line[6], '');
    Form.AddStr  ('7', ' Line7', 3, 16, 10, 16, 6, 69, 79, @line[7], '');
    Form.AddStr  ('8', ' Line8', 3, 17, 10, 17, 6, 69, 79, @line[8], '');
    Form.AddStr  ('9', ' Line9', 3, 18, 10, 18, 6, 69, 79, @line[9], '');
 
  Form.Execute;

  If Form.Changed Then
    If ShowMsgBox(1, 'Apply Text?') Then Begin
      Screen.CursorXY(OldX,OldY);
      For i:=1 to 9 do 
        If Line[i]<>'' then Begin
            Clientt.WriteStr (Line[i] + #13);
            WaitMS(10);  
        End;
    End;


    Form.Free;
    Box.Close;
    Box.Free;
    DrawStatus(false);
  End;
  
  Procedure SaveScreen;
  Var
    OutFile: Text;
    FG,BG  : Byte;
    OldAT  : Byte;
    Outname: String;
    Image  : TConsoleImageRec;   
    Count1 : Integer;
    Count2 : Integer; 
  Begin
    if dropinfo.isdoor then if not isacs(pref.SaveScreenSec) then begin
    ShowMsgBox(0,'You don''t have the priviliges, for this function!');
    exit;
  end;
    
    Outname := GetSaveFileName(' Save Screen ',strReplace(Dial.Name,' ','_')+Stri2s(captures)+'.ans');
    if Outname <> '' then Begin
      captures:=captures+1;
      Screen.GetScreenImage(1, 1, 79, Screen.ScreenSize, Image);
      Assign     (OutFile, Outname);
      //SetTextBuf (OutFile, Buffer);
      ReWrite    (OutFile);
      OldAt:=0;
      For Count1 := Image.Y1 to Image.Y2 Do Begin
        For Count2 := Image.X1 to Image.X2 Do Begin
          If OldAt <> Image.Data[Count1][Count2].Attributes then Begin
            FG := Image.Data[Count1][Count2].Attributes mod 16;
            BG := 16 + (Image.Data[Count1][Count2].Attributes div 16);
            //Write(Outfile,'|'+StrPadL(StrI2S(FG),2,'0'));
            //Write(Outfile,'|'+StrPadL(StrI2S(BG),2,'0'));
            Write(Outfile,Ansi_Color(FG));
            Write(Outfile,Ansi_Color(BG));
            //Write(Outfile,Ansi_Color(Image.Data[Count1][Count2].Attributes));
          End;
          Write(Outfile,Image.Data[Count1][Count2].UnicodeChar);
          OldAt := Image.Data[Count1][Count2].Attributes 
        End;
        Writeln(Outfile,'');
      End;
      close(Outfile);
    End;
    DrawStatus(false);
  End;
   
  Procedure SaveScreenNoDialog;
  Var
    OutFile: Text;
    FG,BG  : Byte;
    OldAT  : Byte;
    Outname: String;
    Image  : TConsoleImageRec;   
    Count1 : Integer;
    Count2 : Integer; 
    capt   : integer;
  Begin
    if dropinfo.isdoor then if not isacs(pref.SaveScreenSec) then begin
    ShowMsgBox(0,'You don''t have the priviliges, for this function!');
    exit;
  end;
    
    capt:=0;
    repeat
      capt:=capt+1;
      outname := lastpath+strReplace(Dial.Name,' ','_')+Stri2s(capt)+'.ans';
    until fileexist(outname)=false;
    if Outname <> '' then Begin
      captures:=captures+1;
      Screen.GetScreenImage(1, 1, 79, Screen.ScreenSize, Image);
      Assign     (OutFile, Outname);
      //SetTextBuf (OutFile, Buffer);
      ReWrite    (OutFile);
      OldAt:=0;
      For Count1 := Image.Y1 to Image.Y2 Do Begin
        For Count2 := Image.X1 to Image.X2 Do Begin
          If OldAt <> Image.Data[Count1][Count2].Attributes then Begin
            FG := Image.Data[Count1][Count2].Attributes mod 16;
            BG := 16 + (Image.Data[Count1][Count2].Attributes div 16);
            //Write(Outfile,'|'+StrPadL(StrI2S(FG),2,'0'));
            //Write(Outfile,'|'+StrPadL(StrI2S(BG),2,'0'));
            Write(Outfile,Ansi_Color(FG));
            Write(Outfile,Ansi_Color(BG));
            //Write(Outfile,Ansi_Color(Image.Data[Count1][Count2].Attributes));
          End;
          Write(Outfile,Image.Data[Count1][Count2].UnicodeChar);
          OldAt := Image.Data[Count1][Count2].Attributes 
        End;
        Writeln(Outfile,'');
      End;
      close(Outfile);
    End;
    DrawStatus(false);
  End;
  
  Procedure DoTransfers;
  Begin
    Case GetTransferType of
      1 : DoZmodemDownload(Client);
      2 : DoZmodemUpload(Client);
    End;

    DrawStatus(False);
  End;
  
  Procedure DoEditEntry;
  Begin
    EditEntry(Book, Dial.Position);

    If Dial.StatusBar <> Book[Dial.Position].StatusBar Then Begin
      Dial := Book[Dial.Position];

      DrawStatus (True);
    End Else
      Dial := Book[Dial.Position];
  End;
  
  Procedure DoASCIIChar;
  var gc:byte;
  Begin
    gc:=GetChar;
    if gc<>0 then screen.writechar(chr(gc));
  end;
  
  procedure emoticons;
  Var
    ib:tmenulist;
    Oldx,
    Oldy   : Byte;
    Image  : TConsoleImageRec;
    ft     : text;
    l      : string;
    emo    : string;
    emos   : array[1..1000] of string[30];
    i      : word;
  Begin
    if not fileexist(appdir+'emoticons.txt') then begin
      showmsgbox(0,'Emoticons file is not present.');
      exit;
    end;
    Screen.GetScreenImage(1, 1, 80, Screen.ScreenSize, Image);
    ib:=tmenulist.create(TOutput(Screen));
    Oldx:=Screen.Cursorx;
    Oldy:=Screen.Cursory;
    Screen.GetScreenImage(1, 1, 80, Screen.ScreenSize, Image);
    ib.AllowTag:=false;
    ib.Box.Header    := ' Emoticons ';
    ib.Box.HeadAttr  := pref.MsgBox_HeadAttr;//15 + 7 * 16;
    ib.Box.BoxAttr    := pref.MsgBox_BoxAttr  ;
    ib.Box.BoxAttr2   := pref.MsgBox_BoxAttr2 ;
    ib.Box.BoxAttr3   := pref.MsgBox_BoxAttr3 ;
    ib.Box.BoxAttr4   := pref.MsgBox_BoxAttr4 ;
        
    ib.Box.FrameType := 9;
    ib.Box.Box3D     := true;
    ib.PosBar        := True;
    ib.box.ShadowAttr :=8;
    
    ib.HiAttr := pref.form_hi;//15+2*16;
    ib.LoAttr := pref.form_lo;//0 + 7*16;
    
    assign(ft,appdir+'emoticons.txt');
    reset(ft);
    i:=1;
    while not eof(ft) do begin
      readln(ft,l);
      emo := strwordget(1,l,' ');
      emos[i]:=emo;
      ib.add(strpadr(emo,12,' ') + chr(179)+ copy(l,pos(' ',l),length(l)),0,0,i);
      i:=i+1;
    end;    
    close(ft);
  
    ib.Open (50, 3, 78, 23);
    
    
    if ib.exitcode<>#27 then begin
      client.writestr(emos[ib.picked]);
    end;
    
    ib.Box.Close;
    ib.destroy;
    Screen.PutScreenImage(Image);
    DrawStatus(false);
    Screen.CursorXY(Oldx,Oldy);
  
  end;
  
  Procedure InTermBox;
  Var
    ib:tmenulist;
    Oldx,
  Oldy   : Byte;
  Image  : TConsoleImageRec;
  Begin
    ib:=tmenulist.create(TOutput(Screen));
    Oldx:=Screen.Cursorx;
    Oldy:=Screen.Cursory;
    Screen.GetScreenImage(1, 1, 80, Screen.ScreenSize, Image);
    ib.AllowTag:=false;
    ib.Box.Header    := ' Help & Menu ';
    ib.Box.HeadAttr  := pref.MsgBox_HeadAttr;//15 + 7 * 16;
    ib.Box.BoxAttr    := pref.MsgBox_BoxAttr  ;
    ib.Box.BoxAttr2   := pref.MsgBox_BoxAttr2 ;
    ib.Box.BoxAttr3   := pref.MsgBox_BoxAttr3 ;
    ib.Box.BoxAttr4   := pref.MsgBox_BoxAttr4 ;
        
    ib.Box.FrameType := 9;
    ib.Box.Box3D     := true;
    ib.PosBar        := True;
    ib.box.ShadowAttr :=8;
    
    ib.HiAttr := pref.form_hi;//15+2*16;
    ib.LoAttr := pref.form_lo;//0 + 7*16;

    ib.Add('ALT-B // ScrollBack History', 0);
    ib.Add('ALT-H // Hang Up', 0);
    ib.Add('ALT-S // Snapshot to ANSI (with dialog)', 0);
    ib.Add('ALT-N // Snapshot to ANSI (no dialog)', 0);
    ib.Add('ALT-L // Send Login Credentials', 0);
    ib.Add('ALT-E // Edit PhoneBook Entry', 0);
    ib.Add('ALT-T // Transfer File', 0);
    ib.Add('ALT-A // Insert ASCII Char.', 0);
    ib.Add('ALT-W // Write AutoText', 0);//AutoWriteText(Client);
    ib.Add('ALT-P // Stop Music',0);
    ib.Add('ALT-M // Edit/View Macros',0);
    ib.Add('ALT-Q // File Queue ',0);
    ib.Add('CTR-S // StatusBar',0);
    ib.add('ALT-R // Find Links/RegExs',0);
    ib.add('      // Edit RegExs',0);
    ib.add('CTR-E // Emoticons',0);
    ib.add('      // Enable/Disable Sound Fx',0);
    ib.add('ALT-C // Copy Area to Clipboard',0);
    ib.add('',0);
    ib.Add('Exit or Press ESC', 0);

    ib.box.Open (35, 11, 45, 13);
    waitms(100);
    ib.box.close;
    ib.box.Open (27, 9, 55, 16);
    waitms(100);
    ib.box.close;
    ib.Open (20, 6, 60, 19);
    
    
    if ib.exitcode<>#27 then
      Case ib.picked of
      1:Begin
          ActivateScrollBack;
          DrawStatus(False);
        End;
      2:If ShowMsgBox(1,'Close connection?') then Begin
                            If musicplaying then Begin
                              StopMusic;
                              musicplaying:=false;
                            end;
                            Done := True;
                          end;
      3:SaveScreen;
      4:SaveScreenNoDialog;
      5:Begin
          Client.WriteStr (Dial.User + #13);
          Client.WriteStr (Dial.Password + #13);
        End;
      6:DoEditEntry;
      7:DoTransfers;
      8:DoASCIIChar;
      9:AutoWriteText(Client);
      10: stopmusic;
      11:editmacros;
      12:filequeue;
      13: begin
            showsb := not showsb;
            drawstatus(showsb);
          end;
      14: FindRegExs;
      15: regexp_edit;
      16: emoticons;
      17: ToggleSoundFx;
      18: KeyboardCopy2Clipboard;
      end;
    //Until ib.ExitCode = #27;
    ib.Box.Close;
    ib.destroy;
    Screen.PutScreenImage(Image);
    DrawStatus(false);
    Screen.CursorXY(Oldx,Oldy);
  End;
  
  procedure LoadMusic;
  var
    ini:tinifile;
    s:string;
    k:byte;
  begin
    if not dial.music then exit;
    s:=dirslash(appdir+'music')+strReplace(Dial.Name,' ','_')+'.ini';
    if not fileexist(s) then begin
      dial.music:=false;
      musicfound:=false;
      exit;
    end;
    musicfound:=true;
    ini:=tinifile.create(s);
    for k:=1 to 30 do begin
      Tracks[k]:=ini.readstring('music',strpadl(stri2s(k),2,'0'),'');
    end;
      MusicDir :=dirslash(mci2str(ini.readstring('music','dir',''),dial));
    ini.free;
  end;
  
  function getrandommusic:string;
  Var
    DirInfo : SearchRec;
    files:tstringlist;
  Begin
    if dial.music=false then exit;
    if not musicfound then exit;
    FindFirst(dirslash(MusicDir+pathsep+'random') + '*', AnyFile, DirInfo);
    files:=tstringlist.create;

    While DosError = 0 Do Begin
      If DirInfo.Attr And Directory = 0 Then files.add(dirinfo.name);
      FindNext(DirInfo);
    End;
    FindClose (DirInfo);
    result:='';
    if files.count=0 then exit;
    randomize;
    result:=dirslash(MusicDir+pathsep+'random')+files[random(files.count)];
    files.free;
  End;
  
  procedure PlayMusic(t:string);
  var
    ss:ansistring;
    k:byte;
  begin
    if not musicfound then exit;
    if dropinfo.isDOOR then exit;
    if not dial.music then exit;
    if musicplaying then stopmusic;
    if strupper(t)='FF' then begin
      ss:=getrandommusic;
    end else
      ss:=musicdir+tracks[strs2i('$'+t)];

    BASS_MusicFree(trackmod);
    musicplaying:=false;
    trackmod:=BASS_MusicLoad(false,pchar(ss),0,0,BASS_MUSIC_RAMPS or BASS_MUSIC_SURROUND or BASS_MUSIC_POSRESET,0);
    if trackmod=0 then begin
      screen.writexy(1,25,4,'Couldn''t load music track. Error ['+stri2s(BASS_ErrorGetCode)+']');
      screen.writexy(1,1,4,ss);
      musicplaying:=false;
      bass_stop;
      exit;
    end;
    if BASS_IsStarted() then bass_stop;
    bass_start;
    if not BASS_ChannelPlay(trackmod,false) then screen.writeline('Couldn''t playback track music. Error ['+stri2s(BASS_ErrorGetCode)+']');
    musicplaying:=true;
  end;


Begin
  ShowMsgBox (2, 'Connecting to ' + Dial.Address);
  LoadMusic;
  Client := TIOSocket.Create;

  Client.FTelnetClient := True;

  If Not Client.Connect(StripAddressPort(Dial.Address), GetAddressPort(Dial.Address)) Then
    ShowMsgBox (0, 'Unable to connect')
  Else Begin
    Book[Dial.Position].LastCall := DateDos2Unix(CurDateDos);//DateDos2Str(CurDateDos, 1);
    Book[Dial.Position].Calls    := strI2S(strS2I(Dial.Calls) + 1);
    Book[Dial.Position].Validated:= DateDos2Unix(CurDateDos);
    
    WriteBook(Book,BookFile);

    Dial := Book[Dial.Position];
    ShowSB := Book[Dial.Position].StatusBar;
    Screen.TextAttr := 7;
    Screen.ClearScreen;

    Done := False;
    Term := TTermAnsi.Create(TOutput(Screen));

    DrawStatus(False);

    Term.SetReplyClient(TIOBase(Client));

    Repeat
      If Client.DataWaiting Then Begin
        Res := Client.ReadBuf (Buffer, BufferSize);

        If Res < 0 Then Begin
          Done := True;
          Break;
        End;

        Screen.Capture := True;

        If Not AutoZmodem Then
          Term.ProcessBuf(Buffer, Res)
        Else Begin
          For Count := 1 to Res Do
            If (Buffer[Count] = #24) and (Count <= Res - 3) Then Begin
              If (Buffer[Count + 1] <> 'B') or (Buffer[Count + 2] <> '0') Then
                Term.Process(#24)
              Else Begin
                Screen.BufFlush;

                Case Buffer[Count + 3] of
                  '0' : DoZmodemDownload(Client);
                  //'0' : fpsystem('/home/x/programming/Projects/blocker_term_v2/zmod.sh');
                  //'1' : fpsystem(zmdn);
                  '1' : DoZmodemUpload(Client);
                End;
              End;
            End Else If (Buffer[Count] = #01) and (Count <= Res - 2) Then Begin
              If (Buffer[Count+1]=#1) and (Buffer[Count+2]=#1) then StopMusic else begin
                playmusic(Buffer[Count+1]+Buffer[Count+2]);
              end;              
            end else
              Term.Process(Buffer[Count]);

          Screen.BufFlush;
        End;

        Screen.Capture := False;
        
      End Else
      If Keyboard.KeyPressed Then Begin
        
        Ch := Keyboard.ReadKey;
        playkeystrokefx(ch);
        Case Ch of
          #00 : Begin
                Ch := Keyboard.ReadKey;
                Case Ch of
              KeyALTC : KeyboardCopy2Clipboard;
              KeyALTA : DoASCIIChar;
                  #25 : stopmusic;
                  #50 : EditMacros;
                  #59 : ExecuteMacro(1);
                  #60 : ExecuteMacro(2);
                  #61 : ExecuteMacro(3);
                  #62 : ExecuteMacro(4);
                  #63 : ExecuteMacro(5);
                  #64 : ExecuteMacro(6);
                  #65 : ExecuteMacro(7);
                  #66 : ExecuteMacro(8);
                  #67 : ExecuteMacro(9);
                  #68 : ExecuteMacro(0);
                  //#5  : emoticons; 
              KeyAltj : Begin
                          Screen.CaptureFile := not Screen.CaptureFile;
                          If Screen.CaptureFile Then Begin
                              Screen.CaptureFilename := GetSaveFileName(' Save Capture ',strReplace(Dial.Name,' ','_')+'.ans');
                              If Screen.CaptureFilename='' Then Begin
                                Screen.CaptureFile :=  False;
                                ShowMsgBox(0,'Capture is OFF');
                              End Else ShowMsgBox(0,'Capture is ON')
                            end else ShowMsgBox(0,'Capture is OFF');
                        End;
                  #44 : Begin
                          inTermBox;
                        end;    
                  #16 : Begin
                          Oldx:=Screen.CursorX;
                          Oldy:=Screen.Cursory;
                          Screen.GetScreenImage(1, 1, 80, Screen.ScreenSize, Image);
                          FileQueue;
                          Screen.PutScreenImage(Image);
                          Screen.CursorXY(Oldx,Oldy);
                        End;
              KeyAltD : DrawStatus(true);
                  #18 : DoEditEntry;
                  #20 : DoTransfers;
                  #35 : Begin
                          If ShowMsgBox(1,'Close connection?') then Begin
                            If musicplaying then Begin
                              StopMusic;
                              musicplaying:=false;
                            end;
                            Done := True;
                          end;
                        End;
                  #38 : Begin
                          Client.WriteStr (Dial.User + #13);
                          Client.WriteStr (Dial.Password + #13);
                        End;
                  //#45 : Break;
                  #48 : Begin
                          ActivateScrollBack;
                          DrawStatus(False);
                        End;
                  #71 : Client.WriteStr(#27 + '[H');
                  #72 : Client.WriteStr(#27 + '[A');
                  #73 : Client.WriteStr(#27 + '[V');
                  #75 : Client.WriteStr(#27 + '[D');
                  #77 : Client.WriteStr(#27 + '[C');
                  #79 : Client.WriteStr(#27 + '[K'); //END
                  #80 : Client.WriteStr(#27 + '[B');
                  #81 : Client.WriteStr(#27 + '[U');
                  #83 : Client.WriteStr(#127);
              keyALTS : SaveScreen;
              KeyALTR : FindRegExs;
                  #49 : SaveScreenNoDialog; //alt-n
              #17 : AutoWriteText(Client);
                End;
            end;
        #5  : emoticons; 
        #19 : begin
                showsb := not showsb;
                drawstatus(showsb);
              end;
        Else
          Client.WriteBuf(Ch, 1);

          If Client.FTelnetEcho Then Term.Process(Ch);
        End;
      
      End Else
        WaitMS(10);
    Until Done;

    Term.Free;
  End;

  Client.Free;
  //Screen.CaptureFile := False;
  ShowMsgBox (0, 'Connection terminated');

  Screen.TextAttr := 7;
  Screen.SetWindow (1, 1, 80, 25, True);
End;

Procedure ImportSyncTerm;
Var
  SyncTermFile : String;
  SyncFile     : TIniFile;
  OutFile      : String;
  Block        : TIniFile;
  Sections     : TStrings;
  Keys         : TStrings;
  i            : Integer;
  Port         : String;
Begin
  if dropinfo.isdoor then if not isacs(pref.ImportSyncTermSec) then begin
    ShowMsgBox(0,'You don''t have the priviliges, for this function!');
    exit;
  end;
  
  SyncTermFile := GetUploadFileName(' Syncterm PhoneBook ','*.*');
  If SyncTermFile = '' Then Begin
    ShowMsgBox(0,'No File Specified');
    Exit;
  End;
  If not FileExist(SyncTermFile) Then Begin
    ShowMsgBox(0,'File Not Exist.');
    Exit;
  End;
  OutFile := GetSaveFileName(' Enter Filename To Save... ','blocker_sync.bbs');
  If OutFile = '' Then Begin
    ShowMsgBox(0,'No File Specified');
    Exit;
  End;
  Try
    SyncFile := Tinifile.create(SyncTermFile);
    Block := Tinifile.create(OutFile);
    Sections := TStringList.Create;
    Keys     := TStringList.Create;
    SyncFile.ReadSections(Sections);
    For i := 0 to Sections.Count - 1 Do Begin
      Block.WriteString(StrI2S(i+1),'name',Sections[i]);
      Port:=SyncFile.ReadString(Sections[i],'Port','');
      If Port<>'' Then 
        Block.WriteString(StrI2S(i+1),'address',SyncFile.ReadString(Sections[i],'Address','')+':'+Port)
      else
        Block.WriteString(StrI2S(i+1),'address',SyncFile.ReadString(Sections[i],'Address',''));
      Block.WriteString(StrI2S(i+1),'last','');
      Block.WriteString(StrI2S(i+1),'calls',SyncFile.ReadString(Sections[i],'TotalCalls','')); 
      Block.WriteString(StrI2S(i+1),'user',SyncFile.ReadString(Sections[i],'UserName',''));         
      Block.WriteString(StrI2S(i+1),'pass',SyncFile.ReadString(Sections[i],'Password','')); 
      Block.WriteString(StrI2S(i+1),'statusbar','0');
      Block.WriteString(StrI2S(i+1),'music','0');
      Block.WriteString(StrI2S(i+1),'last','');
      Block.WriteString(StrI2S(i+1),'sysop','');
      Block.WriteString(StrI2S(i+1),'software','');
      Block.WriteString(StrI2S(i+1),'comment','');
      Block.WriteString(StrI2S(i+1),'rating','');
      Block.WriteString(StrI2S(i+1),'validated','');
      Block.WriteString(StrI2S(i+1),'flags','');
    End;
  Finally
    Sections.Free;
    Keys.Free;
    SyncFile.Free;
    Block.Free;
  End;

End;

Procedure LoadPhoneBook(Var Book: PhoneBookRec; Var List: TMenuList);
Var
  Count    : Word;
  s:string;
Begin
  if dropinfo.isdoor then if not isacs(pref.LoadPhoneBookSec) then begin
    ShowMsgBox(0,'You don''t have the priviliges, for this function!');
    exit;
  end;
  
  WriteBook(Book,BookFile);
  BookFile := GetUploadFileName(' PhoneBook Filename ','*.bbs');
  If BookFile = '' Then Begin
    ShowMsgBox(2,'No File Assigned');
    Exit;
  End;
  
  List.Clear;
  List.Picked := 0;
  LoadBook(Book,BookFile);
      For Count := 1 to max_records Do begin
      
        Book[Count].Flags:='';
        if Book[Count].Music then Book[Count].Flags:=Book[Count].Flags+'M';
        if Book[Count].StatusBar then Book[Count].Flags:=Book[Count].Flags+'B';
        
        s:=strPadR(Book[Count].Name, 20, ' ') + ' ' +strPadR(Book[Count].Address, 30, ' ') + ' ' +strPadR(Book[Count].Flags, 5, ' ') + ' ';
        {List.Add(strPadR(Book[Count].Name, 20, ' ') + ' ' +
                 strPadR(Book[Count].Address, 30, ' ') + ' ' +
                 strPadR(Book[Count].Flags, 5, ' ') + ' ' +
                 FormatUnixDate(Book[Count].LastCall) + ' ' +
                 strPadL(Book[Count].Calls, 5, ' '),
                 2);}
        case field1 of
          0: s:=s+FormatUnixDate(Book[Count].LastCall) + ' ';
          1: s:=s+FormatUnixDate(Book[Count].LastEdit) + ' ';
          2: s:=s+FormatUnixDate(Book[Count].Validated) + ' ';
          3: s:=s+FormatUnixDate(Book[Count].Added) + ' ';
        end;
        case field2 of
          0: s:=s+strPadL(Book[Count].Calls, 5, ' ');
          1: s:=s+strPadL(stri2s(Book[Count].Rating), 5, ' ');
        end;
        List.Add(s,0);
     
    end;
    
    //List Position
    //List.Open(4, 8, 77, 22);
  IsBookLoaded := True;
  
End;

Function ImmidiateDial(Var Dial: PhoneRec):Boolean;
Var
  InStr   : TMenuInput;
  Box     : TMenuBox;
  Str     : String;
Begin
  if dropinfo.isdoor then if not isacs(pref.ImmidiateDialSec) then begin
    ShowMsgBox(0,'You don''t have the priviliges, for this function!');
    exit;
  end;
  
  Box      := TMenuBox.Create(TOutput(Screen));
  Box.Header := ' Enter Address ';
  Box.HeadAttr  := pref.MsgBox_HeadAttr;
  Box.FrameType := pref.MsgBox_FrameType;
  Box.BoxAttr    := pref.MsgBox_BoxAttr  ;
  Box.BoxAttr2   := pref.MsgBox_BoxAttr2 ;
  Box.BoxAttr3   := pref.MsgBox_BoxAttr3 ;
  Box.BoxAttr4   := pref.MsgBox_BoxAttr4 ;
  Box.Box3D     := True;
  
  
  Box.Open (5, 9, 75, 13);
  Screen.WriteXY(7,10,3,'Press CTRL+SHIFT+V to Paste from ClipBoard');

  InStr := TMenuInput.Create(TOutput(Screen));
  InStr.FillAttr := 15+0*16;
  InStr.Attr := 15+3*16;
  InStr.LoChars := #13#27;

  Str := InStr.GetStr(7, 11, 67, 255, 1, '');
  Case InStr.ExitCode of
    #13: Begin
          With Dial Do Begin
            Position  := max_records;
            Name      := 'Immidiate Dial' ;
            Address   := Str;
            User      := '';
            Password  := '';
            StatusBar := True;
            Music := false;
            LastCall  := 0;
            added     :=0;
            LastEdit  := 0;
            Calls     := '';
            Rating    := 0;
            Software  := '';
            Sysop     := '';
            Comment   := '';
            Validated :=0;
            Flags:='';
          End;
          Result := True;
         End;
    #27: Result := False;
  End;
  InStr.Free;
  Box.Close;
  Box.Free;
End;

Procedure PreviewANSI;
Var
  Buffer   : Array[1..4096] of Char;
  dFile    : File;
  FileName : String;
  Ext      : String[4];
  Code     : String[2];
  dRead    : LongInt;
  Old      : Boolean;
  Str      : String;
  A        : Word;
  Ch       : Char;
  Done     : Boolean;
  Terminal : TTermAnsi;
  ScreenT  : TOutput;
  

  Function GetChar : Char;
  Begin
    If A = dRead Then Begin
      BlockRead (dFile, Buffer, SizeOf(Buffer), dRead);
      A := 0;
      If dRead = 0 Then Begin
        Done      := True;
        Buffer[1] := #26;
      End;
    End;

    Inc (A);
    GetChar := Buffer[A];
  End;

  Procedure OutStr (S: String);
  Begin
    Terminal.ProcessBuf(S[1], Length(S));
  End;
  
Label Replay;  

Var
  BaudEmu : LongInt;
  Image   : TConsoleImageRec;
Begin
  
  if dropinfo.isdoor then if not isacs(pref.PreviewANSISec) then begin
    ShowMsgBox(0,'You don''t have the priviliges, for this function!');
    exit;
  end;
  
  FileName := GetUploadFileName(' ANSI File ','*.ans');
  If Filename = '' Then Begin
    ShowMsgBox(0,'No File. Abort.');
    Exit;
  End;

  Assign (dFile, Filename);
  Reset  (dFile, 1);

  If IoResult <> 0 Then Begin
    ShowMsgBox(0,'Error Opening File.');
    Exit;
  End;
  
  Screen.GetScreenImage(1, 1, 80, Screen.ScreenSize, Image);
  
Replay:   
  Screen.ClearScreen;
  
  Assign (dFile, Filename);
  Reset  (dFile, 1);
  ScreenT   := TOutput.Create(True);
  Terminal := TTermAnsi.Create(ScreenT);
  ScreenT.ClearScreen;
  
  Try
    BaudEmu := strS2I(GetStr('Speed','1 to 1000','20',4,4));
  Except
    BaudEmu := 0;
  End;
  Done    := False;
  A       := 0;
  dRead   := 0;
  Ch      := #0;

  While Not Done Do Begin
    Ch := GetChar;

    If BaudEmu > 0 Then Begin
      Screen.BufFlush;

      If A MOD BaudEmu = 0 Then WaitMS(6);
    End;

    If Ch = #26 Then
      Break
    Else
    If Ch = #10 Then Begin
      Terminal.Process(#10);
    End Else
    If Ch = '|' Then Begin
      Code := GetChar;
      Code := Code + GetChar;

      If Code = '00' Then OutStr(Ansi_Color(0)) Else
      If Code = '01' Then OutStr(Ansi_Color(1)) Else
      If Code = '02' Then OutStr(Ansi_Color(2)) Else
      If Code = '03' Then OutStr(Ansi_Color(3)) Else
      If Code = '04' Then OutStr(Ansi_Color(4)) Else
      If Code = '05' Then OutStr(Ansi_Color(5)) Else
      If Code = '06' Then OutStr(Ansi_Color(6)) Else
      If Code = '07' Then OutStr(Ansi_Color(7)) Else
      If Code = '08' Then OutStr(Ansi_Color(8)) Else
      If Code = '09' Then OutStr(Ansi_Color(9)) Else
      If Code = '10' Then OutStr(Ansi_Color(10)) Else
      If Code = '11' Then OutStr(Ansi_Color(11)) Else
      If Code = '12' Then OutStr(Ansi_Color(12)) Else
      If Code = '13' Then OutStr(Ansi_Color(13)) Else
      If Code = '14' Then OutStr(Ansi_Color(14)) Else
      If Code = '15' Then OutStr(Ansi_Color(15)) Else
      If Code = '16' Then OutStr(Ansi_Color(16)) Else
      If Code = '17' Then OutStr(Ansi_Color(17)) Else
      If Code = '18' Then OutStr(Ansi_Color(18)) Else
      If Code = '19' Then OutStr(Ansi_Color(19)) Else
      If Code = '20' Then OutStr(Ansi_Color(20)) Else
      If Code = '21' Then OutStr(Ansi_Color(21)) Else
      If Code = '22' Then OutStr(Ansi_Color(22)) Else
      If Code = '23' Then OutStr(Ansi_Color(23)) Else
      Begin
        Terminal.Process('|');
        Dec (A, 2);
        Continue;
      End;
    End Else
      Terminal.Process(Ch);
    If Keyboard.keypressed then Break;  
  End;
  Close (dFile);
  Terminal.Free;
  ScreenT.Free;
  If ShowMsgBox(1,'Replay?') Then Goto Replay;
  Screen.PutScreenImage(Image);
End;

Procedure ConvertANSI;
Const
  CRLF = #13#10;
Var
  Ansi    : TAnsiLoader;
  InFile  : File;
  InFileName : String;
  OutFileName: String;
  Buf     : Array[1..4096] of Char;
  BufLen  : LongInt;
  OutFile : Text;
  CountY  : LongInt;
  CountX  : Byte;
  CurAttr : Byte;
  CurFG   : Byte;
  NewFG   : Byte;
  CurBG   : Byte;
  NewBG   : Byte;
Begin
  if dropinfo.isdoor then if not isacs(pref.ConvertANSISec) then begin
    ShowMsgBox(0,'You don''t have the priviliges, for this function!');
    exit;
  end;
  
  InFileName := GetUploadFileName(' Select ANSI File ','*.ans');
  If InFileName = '' Then Begin
    ShowMsgBox(0,'No File. Abort.');
    Exit;
  End;
  
  OutFileName := GetSaveFileName(' Save As Mystic/PIPEs File... ','mystic.asc');
  If OutFileName = '' Then Begin
    ShowMsgBox(0,'No File. Abort.');
    Exit;
  End;

  Ansi := TAnsiLoader.Create;

  Assign (InFile, InFileName);

  If Not ioReset (InFile, 1, fmReadWrite + fmDenyNone) Then Begin
    ShowMsgBox(0,'Unable to open input file.');
    Ansi.Free;
    Exit;
  End;

  ShowMsgBox(2,'Converting ... ');

  While Not Eof(InFile) Do Begin
    ioBlockRead (InFile, Buf, SizeOf(Buf), BufLen);
    If Ansi.ProcessBuf (Buf, BufLen) Then Break;
  End;

  Close (InFile);

  Assign  (OutFile, OutFileName);
  ReWrite (OutFile);

  CurAttr := 7;

  Write (OutFile, '|07|16|CL');

  For CountY := 1 to Ansi.Lines Do Begin
    For CountX := 1 to Ansi.GetLineLength(CountY) Do Begin
      CurBG := (CurAttr SHR 4) AND 7;
      CurFG := CurAttr AND $F;
      NewBG := (Ansi.Data[CountY][CountX].Attr SHR 4) AND 7;
      NewFG := Ansi.Data[CountY][CountX].Attr AND $F;

      If CurFG <> NewFG Then Write (OutFile, '|' + strZero(NewFG));
      If CurBG <> NewBG Then Write (OutFile, '|' + strZero(16 + NewBG));

      If Ansi.Data[CountY][CountX].Ch in [#0, #255] Then
        Ansi.Data[CountY][CountX].Ch := ' ';

      Write (OutFile, Ansi.Data[CountY][CountX].Ch);

      CurAttr := Ansi.Data[CountY][CountX].Attr;
    End;

    Write (OutFile, CRLF);
  End;

  Close (OutFile);

  ShowMsgBox(0, 'Complete!');
End;

Procedure ExecuteMacroS(Mac: Byte);
  Var
    i   : Byte;
    Str : String;
    Pipe: String;
    l : string;
    err:longint;
  Begin
    i := 0;
    Str := Macro[Mac];
    While i <= Length(Str) do Begin
      Inc(i,1);
      If (Str[i] = '|') Then Begin
        pipe:=copy(Str,i,3);
        Case Pipe[2] Of
          'S' : Case Pipe[3] of
                  'H' : Begin
                          l:=copy(str,4,length(str));
                          l:=strreplace(l,'|BD',appdir);
                          If Showmsgbox(1,'Execute: '+l+'?') then begin
                            screen.textattr:=7;
                            screen.clearscreen;
                            err:=fpsystem(l); 
                            showmsgbox(0,'Script finished with status: '+stri2s(err));
                            drawmainansi;
                          end;
                        End;
                End;
        End;
        Inc(i,2);  
      End Else Begin
        
      End;
      
    End;
  End;

Function GetTerminalEntry (Var Book: PhoneBookRec; Var Dial: PhoneRec) : Boolean;
Var
  Count  : word;
  Count2 : word;
  List   : TMenuList;
  Found  : Boolean;
  Picked : word;
  ch     : Char;
  OldX   : Byte;
  OldY   : Byte;
  doExit : Boolean = False;
  s : string;
  
  Procedure GetFieldFormat;
  var 
    mm : tmenulist;
    j  : byte;
  begin
    mm := TMenuList.Create(TOutput(Screen));
        
    mm.AllowTag:=false;
    mm.Box.Header    := ' Select Format ';
    mm.Box.HeadAttr  := pref.MsgBox_HeadAttr;//15 + 7 * 16;
    mm.Box.BoxAttr    := pref.MsgBox_BoxAttr  ;
    mm.Box.BoxAttr2   := pref.MsgBox_BoxAttr2 ;
    mm.Box.BoxAttr3   := pref.MsgBox_BoxAttr3 ;
    mm.Box.BoxAttr4   := pref.MsgBox_BoxAttr4 ;
        
    mm.Box.FrameType := pref.MsgBox_FrameType;
    mm.Box.Box3D     := true;
    mm.PosBar        := False;
    mm.box.ShadowAttr :=8;
    
    mm.HiAttr := pref.form_hi;//15+2*16;
    mm.LoAttr := pref.form_lo;//0 + 7*16;

    mm.Add('Last Call / Calls', 0);
    mm.Add('Last Edited / Calls', 0);
    mm.Add('Last Validated / Calls', 0);
    mm.Add('Date Added / Calls', 0);
    mm.Add('Last Call / Rate', 0);
    mm.Add('Last Edited / Rate', 0);
    mm.Add('Last Validated / Rate', 0);
    mm.Add('Date Added / Rate', 0);

    mm.box.Open (70, 5, 78, 7);
    waitms(100);
    mm.box.close;
    mm.box.Open (60, 5, 78, 11);
    waitms(100);
    mm.box.close;
    mm.Open (50, 5, 78, 16);
    
    
    if mm.exitcode<>#27 then
      Case mm.picked of
      1 : begin field1:=0;field2:=0;end;
      2 : begin field1:=1;field2:=0;end;
      3 : begin field1:=2;field2:=0;end;
      4 : begin field1:=3;field2:=0;end;
      5 : begin field1:=0;field2:=1;end;
      6 : begin field1:=1;field2:=1;end;
      7 : begin field1:=2;field2:=1;end;
      8 : begin field1:=3;field2:=1;end;
      end;
    //Until mm.ExitCode = #27;
    mm.Box.Close;
    mm.destroy;
    DrawMainAnsi;
  end;
  
      Procedure DelRecord;
      var count:word;
      Begin
        if dropinfo.isdoor then if not isacs(pref.DelRecordSec) then begin
          ShowMsgBox(0,'You don''t have the priviliges, for this function!');
          exit;
        end;
        
        If ShowMsgBox(1, 'Delete this record?') Then Begin
                    For Count := List.Picked to max_records - 1 Do
                      Book[Count] := Book[Count + 1];

                    Book[max_records] := GetNewRecord;

                    WriteBook(Book,BookFile);
                  End;
      End;
  
      Procedure SortRecords(Var Book: PhoneBookRec);
      Var
        Lista  : TMenuList;
        Field : Byte;
        Asc   : Byte;
        
        
        Procedure SortByName;
        Var
          i,d   : Integer;
          Sort  : TQuickSort;
          PhoneFile : TIniFile;
          BakFile   : Text;
          Str       : TStringList;
        Begin
          Sort  := TQuickSort.Create;
          
          Case Field Of
            1: For i := 1 to max_records Do Sort.Add(Book[i].Name,i);
            2: For i := 1 to max_records Do Sort.Add(Book[i].Address,i);
            3: For i := 1 to max_records Do Sort.Add(StrPadL(Book[i].Calls,5,'0'),i);
            4: For i := 1 to max_records Do Sort.Add(StrPadL(Stri2s(Book[i].Rating),5,'0'),i);
            5: For i := 1 to max_records Do Sort.Add(Stri2s(Book[i].LastEdit),i);
            6: For i := 1 to max_records Do Sort.Add(Stri2s(Book[i].Validated),i);
          End;
            
          Case Asc Of
            1: Sort.Sort  (1, Sort.Total,  qAscending);
            2: Sort.Sort  (1, Sort.Total,  qDescending);
          End;
          
          Str := TStringList.Create;
          PhoneFile := TIniFile.Create(BookFile);
          Assign(BakFile,appdir+'bak.ini');
          ReWrite(BakFile);
          
          For i := 1 To max_records Do Begin
            PhoneFile.ReadSectionValues(StrI2S(Sort.Data[i]^.Ptr),Str);
            Writeln(BakFile,'['+StrI2S(i)+']');
            For d := 0 To Str.Count - 1 Do Writeln(BakFile,Str[d]);
            Str.Clear;
          End;
          
          Sort.Free;
          Str.Free;
          PhoneFile.Free;
          Close(BakFile);
          
          FileErase(BookFile);
          FileRename(appdir+'bak.ini',BookFile);
          
          InitializeBook(Book);
          LoadBook(Book,BookFile);
          
          Picked := 1;
          List.Picked := Picked;
          
          IsBookLoaded := True;

        End;
        
      Begin
        if dropinfo.isdoor then if not isacs(pref.SortRecordsSec) then begin
          ShowMsgBox(0,'You don''t have the priviliges, for this function!');
          exit;
        end;
  
        Lista := TMenuList.Create(TOutput(Screen));
        
        Lista.AllowTag:=false;
        Lista.TagChar:='#';
        Lista.Tagkey   := #9;
        lista.tagpos:=1;
        Lista.TagAttr    := pref.tag;
        
        Lista.Box.Header    := ' Sort By Field ';
        Lista.Box.HeadAttr  := pref.MsgBox_HeadAttr;//15 + 7 * 16;
        
        Lista.Box.BoxAttr    := pref.MsgBox_BoxAttr  ;
        Lista.Box.BoxAttr2   := pref.MsgBox_BoxAttr2 ;
        Lista.Box.BoxAttr3   := pref.MsgBox_BoxAttr3 ;
        Lista.Box.BoxAttr4   := pref.MsgBox_BoxAttr4 ;
        
        
        Lista.Box.FrameType := pref.MsgBox_Frametype;//6;
        Lista.Box.Box3D     := pref.MsgBox_Box3d;//True;
        Lista.PosBar        := False;
        
        Lista.HiAttr := pref.form_hi;//15+2*16;
        Lista.LoAttr := pref.form_lo;//0 + 7*16;

        Lista.Add('Name', 0);
        Lista.Add('Address', 0);
        Lista.Add('Calls', 0);
        Lista.Add('Rate', 0);
        Lista.Add('Last Edit', 0);
        Lista.Add('Validated', 0);

        Lista.Open (30, 11, 49, 18);
        Lista.Box.Close;

        Case Lista.ExitCode of
          #27 : Field := 255;
        Else
          Field := Lista.Picked
        End;

        If Field <> 255 Then Begin
          Lista.Clear;
          Lista.Add('Ascending', 0);
          Lista.Add('Descending', 0);
          Lista.Open (30, 11, 49, 14);
          Lista.Box.Close;
          Case Lista.ExitCode of
            #27 : Asc := 255;
          Else
            Asc := Lista.Picked;
          End;
        End;
        Lista.Free;
        
        If (Field = 255) Or (Asc = 255) Then Exit;
        SortByName;
      End;
      
  procedure reloadlist;
  var
   count:integer;
  begin
    List.Clear;
    List.Picked := Picked;

    For Count := 1 to max_records Do begin
      
        Book[Count].Flags:='';
        if Book[Count].Music then Book[Count].Flags:=Book[Count].Flags+'M';
        if Book[Count].StatusBar then Book[Count].Flags:=Book[Count].Flags+'B';
        
        s:=strPadR(Book[Count].Name, 20, ' ') + ' ' +strPadR(Book[Count].Address, 30, ' ') + ' ' +strPadR(Book[Count].Flags, 5, ' ') + ' ';
        {List.Add(strPadR(Book[Count].Name, 20, ' ') + ' ' +
                 strPadR(Book[Count].Address, 30, ' ') + ' ' +
                 strPadR(Book[Count].Flags, 5, ' ') + ' ' +
                 FormatUnixDate(Book[Count].LastCall) + ' ' +
                 strPadL(Book[Count].Calls, 5, ' '),
                 2);}
        case field1 of
          0: s:=s+FormatUnixDate(Book[Count].LastCall) + ' ';
          1: s:=s+FormatUnixDate(Book[Count].LastEdit) + ' ';
          2: s:=s+FormatUnixDate(Book[Count].Validated) + ' ';
          3: s:=s+FormatUnixDate(Book[Count].Added) + ' ';
        end;
        case field2 of
          0: s:=s+strPadL(Book[Count].Calls, 5, ' ');
          1: s:=s+strPadL(stri2s(Book[Count].Rating), 5, ' ');
        end;
        List.Add(s,0);
      
    end;
    
    //List Position
    
  
  end;
      
  Procedure MainMenu;
  var 
    mm : tmenulist;
    j  : byte;
    i:integer;
    
    
    Procedure GlobalMenu;
    var 
      gm : tmenulist;
      j  : byte;
      i:integer;
    Begin
    gm := TMenuList.Create(TOutput(Screen));
        
    gm.AllowTag:=false;
    gm.Box.Header    := ' Global Menu ';
    gm.Box.HeadAttr  := pref.MsgBox_HeadAttr;//15 + 7 * 16;
    gm.Box.BoxAttr    := pref.MsgBox_BoxAttr  ;
    gm.Box.BoxAttr2   := pref.MsgBox_BoxAttr2 ;
    gm.Box.BoxAttr3   := pref.MsgBox_BoxAttr3 ;
    gm.Box.BoxAttr4   := pref.MsgBox_BoxAttr4 ;
        
    gm.Box.FrameType := 9;
    gm.Box.Box3D     := true;
    gm.PosBar        := true;
    gm.box.ShadowAttr :=8;
    
    gm.HiAttr := pref.form_hi;//15+2*16;
    gm.LoAttr := pref.form_lo;//0 + 7*16;

    gm.add('Select All',0);
    gm.add('UnSelect All',0);
    gm.add('Invert Selection',0);
    gm.add('Delete',0);
    gm.add('StatusBar Off',0);
    gm.add('Music Off',0);

    gm.Open (24, 8, 45, 17);
    
    
    if gm.exitcode<>#27 then
      Case gm.picked of
        1 : for i:=1 to max_records do list.list[i]^.Tagged:=1;
        2 : for i:=1 to max_records do list.list[i]^.Tagged:=0;
        3 : for i:=1 to max_records do begin
                if list.list[i]^.Tagged=1 then list.list[i]^.Tagged:=0
                  else if list.list[i]^.Tagged=0 then list.list[i]^.Tagged:=1
            end;
        4 : If showmsgbox(1,'Delete selected records?') then
              Begin
                for i:=1 to max_records do 
                  if list.list[i]^.Tagged=1 then Book[i]:=getnewrecord;
                  reloadlist;
                  WriteBook(Book,BookFile);
              End;
        5: Begin
             for i:=1 to max_records do 
               if list.list[i]^.Tagged=1 then Book[i].Statusbar:=false;
             reloadlist;
             WriteBook(Book,BookFile);
           End;
        6: Begin
             for i:=1 to max_records do 
               if list.list[i]^.Tagged=1 then Book[i].Music:=false;
             reloadlist;
             WriteBook(Book,BookFile);
           End;
           
      end;
    gm.Box.Close;
    gm.destroy;
  end;
  
    
  begin
    mm := TMenuList.Create(TOutput(Screen));
        
    mm.AllowTag:=false;
    mm.Box.Header    := ' Menu ';
    mm.Box.HeadAttr  := pref.MsgBox_HeadAttr;//15 + 7 * 16;
    mm.Box.BoxAttr    := pref.MsgBox_BoxAttr  ;
    mm.Box.BoxAttr2   := pref.MsgBox_BoxAttr2 ;
    mm.Box.BoxAttr3   := pref.MsgBox_BoxAttr3 ;
    mm.Box.BoxAttr4   := pref.MsgBox_BoxAttr4 ;
        
    mm.Box.FrameType := 9;
    mm.Box.Box3D     := true;
    mm.PosBar        := true;
    mm.box.ShadowAttr :=8;
    
    mm.HiAttr := pref.form_hi;//15+2*16;
    mm.LoAttr := pref.form_lo;//0 + 7*16;

    mm.Add('Preview ANSI File', 0);
    mm.Add('Convert ANSI to PIPEs', 0);
    mm.Add('Sort PhoneBook', 0);
    mm.Add('Edit Macros', 0);
    mm.Add('Import SyncTerm Book', 0);
    mm.Add('Load PhoneBook', 0);
    mm.add('New PhoneBook',0);
    mm.Add('Quick Dial', 0);
    mm.add('Fields Format',0);
    mm.add('Stop Music',0);
    mm.add('Global Commands...',0);
    mm.add('Reg. Expressions',0);
    //mm.add('find regex',0);
    mm.Add('Exit', 0);

    mm.box.Open (2, 2, 11, 5);
    waitms(100);
    mm.box.close;
    mm.box.Open (2, 2, 20, 10);
    waitms(100);
    mm.box.close;
    mm.Open (2, 2, 27, 16);
    
    
    if mm.exitcode<>#27 then
      Case mm.picked of
      1 : PreviewANSI;
      2 : ConvertANSI;
      3 : begin SortRecords(Book);reloadlist;end;
      4 : begin loadmacros;EditMacros;end;
      5 : begin ImportSyncTerm;reloadlist;end;
      6 : begin LoadPhoneBook(Book, List);reloadlist;end;
      7 : begin
            WriteBook(Book,BookFile);
            BookFile := GetSaveFileName(' PhoneBook Filename ','new-phonebook.bbs');
            If BookFile = '' Then Begin
              ShowMsgBox(2,'No File Assigned');
              Exit;
            End;
            InitializeBook (book);
            WriteBook(Book,BookFile);
            DrawMainAnsi;
          end;
      8 : Begin
              If ImmidiateDial(Dial) Then Begin
                Result:=True;
                DoExit:=true;
              End;
            End;
      9 : begin GetFieldFormat;reloadlist;end;
      10: stopmusic;
      11 : globalmenu;
      12 : regexp_edit;
      //13 : FindRegExs;
      13 : If ShowMsgBox(1, 'Are you sure?') Then DoExit:=True;
      end;
    //Until mm.ExitCode = #27;
    mm.Box.Close;
    mm.destroy;
    DrawMainAnsi;
  end;
  
  
    
Begin
  Result := False;

  If Not FileExist(BookFile) Then Begin
    ShowMsgBox (2, 'Creating phone book');
    WriteBook  (Book,BookFile);

    IsBookLoaded := True;
  End Else
    If Not IsBookLoaded Then Begin
      LoadBook(Book,BookFile);
      IsBookLoaded := True;
    End;

  DrawMainAnsi;
  if DropInfo.isDoor=False then screen.writexy(2,1,8,'local');

  Picked := 1;

  List := TMenuList.Create(TOutput(Screen));

  List.NoWindow := True;
  List.LoAttr   := pref.listlow;
  List.HiAttr   := pref.listhi;
  List.LoChars  := #13#27#9;
  List.HiChars  := #18#82#83#44#16#45#23#24#32#50#31#46#25#59#60#61#62#63#64#65#66#67#68;
  List.SetSearchProc(SearchEntry);
  List.AllowTag:=true;
  List.TagChar:=chr(251);
  List.Tagkey   := #9;
  list.box.boxattr2:=3;
  list.tagpos:=1;
  list.posbar:=true;
  List.TagAttr    := pref.tag;
  List.SearchA  := 8;
  List.Searchy  := 23;
  List.SearchX  := 33;
  
  reloadlist;
  
  Repeat

    List.Open(2, 6, 79, 23);
    Picked := List.Picked;

    Case List.ExitCode of
      #27 : MainMenu;
      #25 : PreviewANSI;
      #46 : ConvertANSI;
      #31 : begin SortRecords(Book);reloadlist;end;
      #50 : EditMacros;
      #59 : ExecuteMacroS(1);
      #60 : ExecuteMacroS(2);
      #61 : ExecuteMacroS(3);
      #62 : ExecuteMacroS(4);
      #63 : ExecuteMacroS(5);
      #64 : ExecuteMacroS(6);
      #65 : ExecuteMacroS(7);
      #66 : ExecuteMacroS(8);
      #67 : ExecuteMacroS(9);
      #68 : ExecuteMacroS(0);
      #32 : Begin
              If ImmidiateDial(Dial) Then Begin
                Result:=True;
                Break;
              End;
            End;
      #24 : LoadPhoneBook(Book, List);
      #23 : ImportSyncTerm;
      #13 : If Book[List.Picked].Address = '' Then Begin
              EditEntry(Book, List.Picked);
              reloadlist;
            end Else Begin
              Dial   := Book[List.Picked];
              Result := True;

              Break;
            End;
      #44 : Begin
              Oldx:=Screen.Cursorx;
              Oldy:=Screen.Cursory;
              DrawHelpAnsi;
              Screen.CursorXY(Oldx,Oldy);
              DrawMainAnsi;
              if DropInfo.isDoor=False then screen.writexy(2,1,8,'local');
            end;    
      #16 : Begin
              Screen.ClearScreen;
              FileQueue;
              DrawMainAnsi;
              if DropInfo.isDoor=False then screen.writexy(2,1,8,'local');
            End;
      #18 : begin EditEntry(Book, List.Picked);reloadlist;end;
      KeyALTX : If ShowMsgBox(1, 'Are you sure?') Then DoExit:=True;
      
      #82 : Begin
              Found := False;

              For Count := List.Picked to max_records Do
                If (Book[Count].Name = '') and (Book[Count].Address = '') and (Book[Count].Calls = '0') Then Begin
                  Found := True;
                  Break;
                End;

              If Not Found Then
                ShowMsgBox (0, 'No blank entries available')
              Else Begin
                For Count2 := Count DownTo List.Picked + 1 Do
                  Book[Count2] := Book[Count2 - 1];

                Book[List.Picked] := GetNewRecord;

                WriteBook(Book,BookFile);
              End;
            End;
      #83 : begin DelRecord;reloadlist;DrawMainAnsi;end;
    End;
  Until DoExit;

  List.Free;
End;

Function GetMaxQuotes:integer;
var 
  f:text;
  s,q: string;
  i:integer;
Begin
  Result:=0;
  i:=0;
  s:=pref.quotefile;
  if not fileexist(s) then begin
    s:=appdir+pref.quotefile;
    if not fileexist(s) then exit;
  end;
  assign(f,s);
  reset(f);
  while not eof(f) do begin
    readln(f,q);
    i:=i+1
  end;
  close(f);
  result:=i;
end;

Procedure Terminal(param1,param2:string);
Var
  Dial : PhoneRec;
  Book : PhoneBookRec;
  x    : Byte;
  tempstr :  AnsiString;
Begin
  if fileexist(param1) then ReadDoor(param1)
    else if fileexist(param2) then ReadDoor(param2);
  LastPath := XferPath;
  Screen.SetWindowTitle('Blocker '+version);
  appdir:=dirslash(justpath(paramstr(0)));
  screen.writeline('[] BASS');
  //Initialize BASS library
  if Hi(BASS_GetVersion) <> BASSVERSION then screen.writeline('An incorrect version of BASS.DLL was loaded');
  
  if not BASS_Init(-1, 44100, 0, 0, nil) then begin
    screen.writeline('BASS Library not initialized. No sound effects!');
    BASSLoaded:=False;
  end else begin
    screen.writeline('BASS Library initialized!');
    BASSLoaded:=True;
  end;
  
  //load keystroke sound fxs
  try
    tempstr:=appdir+'fx'+pathsep+'skey.wav';
    keystroke_sound[0]:=BASS_StreamCreateFile(False, pchar(tempstr), 0, 0, 0 {$IFDEF UNICODE} or BASS_UNICODE {$ENDIF});
    tempstr:=appdir+'fx'+pathsep+'tkey.wav';
    keystroke_sound[1]:=BASS_StreamCreateFile(False, pchar(tempstr), 0, 0, 0 {$IFDEF UNICODE} or BASS_UNICODE {$ENDIF});
    tempstr:=appdir+'fx'+pathsep+'lkey.wav';
    keystroke_sound[2]:=BASS_StreamCreateFile(False, pchar(tempstr), 0, 0, 0 {$IFDEF UNICODE} or BASS_UNICODE {$ENDIF});
    tempstr:=appdir+'fx'+pathsep+'ekey.wav';
    keystroke_sound[3]:=BASS_StreamCreateFile(False, pchar(tempstr), 0, 0, 0 {$IFDEF UNICODE} or BASS_UNICODE {$ENDIF});
    tempstr:=appdir+'fx'+pathsep+'akey.wav';
    keystroke_sound[4]:=BASS_StreamCreateFile(False, pchar(tempstr), 0, 0, 0 {$IFDEF UNICODE} or BASS_UNICODE {$ENDIF});
    tempstr:=appdir+'fx'+pathsep+'enterkey.wav';
    keystroke_enter:=BASS_StreamCreateFile(False, pchar(tempstr), 0, 0, 0 {$IFDEF UNICODE} or BASS_UNICODE {$ENDIF});
    tempstr:=appdir+'fx'+pathsep+'beep.wav';
    beep_sound:=BASS_StreamCreateFile(False, pchar(tempstr), 0, 0, 0 {$IFDEF UNICODE} or BASS_UNICODE {$ENDIF});
  except
    pref.soundfx:=false;
  end;
  
  //bookfile:=appdir+'blocker.bbs';
  bookfile:=pref.bookfile;
  (*If FileExist(JustPath(paramstr(0))+pbook) then
  Begin
    LoadBook(Book);
    IsBookLoaded := True;
  End else Begin*)
    InitializeBook(Book);
    BBSDialed:=GetNewRecord;
    IsBookLoaded := False;
  //End;
  LoadMacros;
  LoadRegEx;
  TotalQuotes:=GetMaxQuotes;
  Queue  := TProtocolQueue.Create;
  x:=pos('/addr=',strlower(param1));
  if x>0 then begin
    If Not FileExist(BookFile) Then Begin
      ShowMsgBox (2, 'Creating phone book');
      WriteBook  (Book,BookFile);

      IsBookLoaded := True;
    End Else
      If Not IsBookLoaded Then Begin
        LoadBook(Book,BookFile);
        IsBookLoaded := True;
      End;

    delete(param1,1,x+5);
    With Dial Do Begin
      Position  := max_records;
      Name      := param1;
      Address   := param1;
      User      := '';
      Password  := '';
      StatusBar := True;
      music := false;
      LastCall  := 0;
      added:=0;
      LastEdit  := 0;
      Calls     := '1';
      Rating    := 0;
      Software  := '';
      Sysop     := '';
      Validated := 0;
      Comment   := 'Used from Cmd.Line';
      ModemFx   := True;
      KeystrokeFX := True;
      ondial    :='';
      onhangup  :='';
    End;
    
    TelnetClient(Book, Dial);
  end else begin
    Repeat
      If Not GetTerminalEntry(Book, Dial) Then Break;
      BBSDialed:=Dial;
      if not fileexist(appdir+'fx'+pathsep+'modem.wav') then bbsdialed.modemfx:=false;
      playmodem;
      if BBSDialed.OnDial<>'' then fpsystem(MCI2Str(BBSDialed.OnDial,BBSDialed));
      TelnetClient(Book, Dial);
      if BBSDialed.OnHangUp<>'' then fpsystem(MCI2Str(BBSDialed.OnHangUp,BBSDialed));
    Until False;
  End;
  WriteBook(Book,BookFile);
  Savesettings;
  Queue.Clear;
  Queue.Free;
  Screen.clearScreen;
  If BASSLoaded then BASS_Free();
End;

End.
