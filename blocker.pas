{
   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.
   
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   
   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
   MA 02110-1301, USA.
   
}


Program Blocker;

{$I M_OPS.PAS}

Uses
  {$IFDEF DEBUG}
    HeapTrc,
    LineInfo,
  {$ENDIF}
  {$IFDEF UNIX}
    BaseUnix,
  {$ENDIF}
  DOS,
  m_FileIO,
  m_DateTime,
  m_Strings,
  m_Pipe,
  m_Input,
  m_Output,
  m_Output_ScrollBack,
  m_Term_Ansi,
  //m_IniReader,
  inifiles,
  Blocker_Common,
  Blocker_Term;
 
Procedure ApplicationShutdown;
Begin
  Keyboard.Free;
  Screen.Free;
End;

Procedure ApplicationInit;
Var
  INI   : TInifile;
Begin

  ExitProc := @ApplicationShutdown;
  Screen   := TConsoleScrollBack.Create(True);
  Keyboard := TInput.Create;

  GetDIR (0, XferPath);

  INI := TInifile.Create(justpath(paramstr(0))+'blocker.ini');
  Try
    XferPath   := INI.ReadString('General', 'transfer_dir', DirSlash(XferPath));
    AutoZmodem := INI.ReadBool('General;', 'auto_zmodem', True);
    blocker_term.zmdn:= ini.readstring('general','zmodem_dn','');
    blocker_term.zmup:= ini.readstring('general','zmodem_up','');
    pref.listlow := Ini.readinteger('List','Low',7);
    pref.listhi := Ini.readinteger('List','Hi',47);
    pref.tag := Ini.readinteger('List','tag',14);
    
    pref.MsgBox_FrameType := Ini.readinteger('MsgBox','Frame', 6);
    pref.MsgBox_HeadAttr  := Ini.readinteger('MsgBox','Header',112);
    pref.MsgBox_BoxAttr    := Ini.readinteger('MsgBox','Attr1',127);
    pref.MsgBox_BoxAttr2   := Ini.readinteger('MsgBox','Attr2',120);
    pref.MsgBox_BoxAttr3   := Ini.readinteger('MsgBox','Attr3',127);
    pref.MsgBox_BoxAttr4   := Ini.readinteger('MsgBox','Attr4',120);
    pref.MsgBox_Box3D := Ini.readbool('MsgBox','3D',True);
    
     pref.form_Lo          := Ini.readinteger('Form','Lo',112);
     pref.form_Hi          := Ini.readinteger('Form','Hi',47);
     pref.form_Data        := Ini.readinteger('Form','Data',120);
     pref.form_LoKey       := Ini.readinteger('Form','Lokey',127);
     pref.form_HiKey       := Ini.readinteger('Form','HiKey',46);
     pref.form_Field1      := Ini.readinteger('Form','Field1',47);
     pref.form_Field2      := Ini.readinteger('Form','Field2',47);
     
     with pref do begin
       PreviewANSIsec := Ini.readinteger('ACS','PreviewANSI',50);
       PreviewCharsSec := Ini.readinteger('ACS','PreviewChars',20);
       ConvertANSISec := Ini.readinteger('ACS','ConvertANSI',50);
       ImmidiateDialSec := Ini.readinteger('ACS','ImmidiateDial',50);
       LoadPhoneBookSec:= Ini.readinteger('ACS','LoadPhoneBook',50);
       SortRecordsSec:= Ini.readinteger('ACS','SortRecords',20);
       ImportSyncTermSec := Ini.readinteger('ACS','ImportSyncterm',50);
       EditMacrosSec:= Ini.readinteger('ACS','EditMacros',50);
       EditBookSec:= Ini.readinteger('ACS','EditBook',50);
       DelBookSec:= Ini.readinteger('ACS','DelBook',50);
       DelRecordSec:= Ini.readinteger('ACS','DelRecord',50);
       SaveScreenSec:= Ini.readinteger('ACS','SaveScreen',50);
       
       statusbar:=ini.readstring('general','statusbar','|15ALT-Z|07 H|08elp Screen');
       quotefile:=ini.readstring('general','quotefile','');
       bookfile:=ini.readstring('general','phonebook','');
       
       play:=ini.readstring('music','play','');
       stop:=ini.readstring('music','stop','');
     end;
     
  Finally
    INI.Free;
  End;
End;

var
 s1,s2:string;

Begin
  
  ApplicationInit;
  if paramstr(1)<>'' then s1:=paramstr(1);
  if paramstr(2)<>'' then s2:=paramstr(2);
  Terminal(paramstr(1),paramstr(2))
End.
