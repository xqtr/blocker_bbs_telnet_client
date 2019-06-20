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

Procedure DrawMainAnsi;
const
  IMAGEDATA_WIDTH=80;
  IMAGEDATA_DEPTH=25;
  IMAGEDATA_LENGTH=922;
  IMAGEDATA : array [1..495] of Char = (
     #7,#16,#25, #7,#11,'Ü',#15,'ß', #3,'Ü',' ','²',#15,'ß', #3,'²',' ',
    '°','°','±',' ','±',' ','²','ß','±',#25, #2,'°','°','°','±',' ','°',
    '°',#24,' ','ß',' ','ß','Û',' ','±','²','²',' ',#19,' ',#11,'Ü',' ',
    #16,' ',#19,'Ü',#16,#25, #6,#19,' ',#16,' ',#19,' ','°',#24,#16,' ',
     #3,'Û','Ü',' ','Ü',#25, #2,#11,#19,'Ü',#16,' ', #7,'Ü',' ',#11,#19,
    'Ü',#16,' ',#19,' ', #3,#16,'ß','ß','ß',#11,#19,'ß', #3,#16,'ß','ß',
    'ß',#11,#19,'Ü',#16,' ', #7,'Ý','Þ',#11,#19,'Ü', #3,#16,'ß','ß','ß',
    #11,#19,'ß', #3,#16,'ß','ß','ß',#11,#19,'ß',#16,' ', #0,#19,'ß','Ü',
    'ß','Ý','v','e','r','.',' ','2','.','0','Þ','Ü','ß','Ü',#24,#16,#25,
     #7,#11,#23,'ß',#16,' ',#23,'Ü',#16,' ',#23,'Ü',#16,' ',#23,'ß',#16,
    ' ',#23,'ß',#16,' ',#23,'ß',#16,' ',#23,'Ü','ß','Ü',#16,' ',' ', #7,
    'ß',#11,#23,'ß',#16,' ', #7,'ß',' ',#11,#23,'Ü',#16,' ',#23,'Ü','ß',
    #24,#15,#16,'Ü','±','ß','ß','ß',' ', #3,'°', #7,'²','²',' ','ß',' ',
    'Û',' ','Û',' ','ß',' ','Û',' ','ß','ß','Û',' ','Û',' ','Û',' ','ß',
    'ß','Û',' ','²','°','°','°', #8,'ß','ß',#15,'ß','ß',' ',#26, #3,'ß',
    #11,'ß','ß','²','Ý',#26, #4,'ß',' ',#26,#18,'ß',' ','ß','Þ','Û','Ü',
    #24,#15,'Û','Ý',#25, #5, #8,#26, #3,'ß',' ','ß',' ','ß','ß','ß',' ',
    'ß','ß','ß',' ','ß',' ','ß',' ','ß','ß','ß',' ','ß',#25,#28,#11,'l',
     #3,'a','s', #8,'t',' ',#11,'c', #3,'a','l', #8,'l',' ',#11,'c', #3,
    'a','l','l', #8,'s',' ',#11,'Þ','Û',#24,#15,'Û',#25,'L',#11,'Û',#24,
    #15,'Û',#25,'L', #7,'²',#24,#15,'²',#25,'L', #7,'²',#24,#15,'²',#25,
    'L', #7,'²',#24,#11,'²',#25,'L', #7,'±',#24,#15,'±',#25,'L', #7,'±',
    #24,#11,'±',#25,'L', #7,'°',#24,#11,'°',#25,'L', #7,'ú',#24,#25,'M',
     #8,'°',#24,#11,'þ',#25,'L', #8,'±',#24,#11,'°',#25,'L', #8,'±',#24,
    #11,'±',#25,'L', #8,'²',#24,#11,'±',#25,'L', #8,'þ',#24,#11,'²',#25,
    'L', #8,'±',#24,#11,'²',#25,'L', #8,'²',#24,#11,'Û',#25,'L', #8,'²',
    #24,#11,'Û','Ý',#25,'J', #8,'Þ','Û',#24,#11,'ß','°',#26, #6,'Ü',' ',
    'Ü','Ü','²',#26,#16,'Ü',' ', #7,'Ü',#11,'þ', #7,#26,#15,'Ü',' ',#26,
    #12,'Ü',' ','Ü','Ü', #8,#26, #3,'Ü','±',#26, #5,'Ü', #7,'°', #8,'ß',
    #24,#24);
Begin
  Screen.ClearScreen;
  Screen.LoadScreenImage(ImageData, ImageData_Length, ImageData_Width, 1, 1);
  //Screen.WriteXYPipe(4,7,7,10,'|15S|11yste|07m');
  //Screen.WriteXYPipe(27,7,7,8,'|15A|11ddres|07s');
  //Screen.WriteXYPipe(56,7,7,12,'|15L|11as|07t |15C|11al|07l');
  //Screen.WriteXYPipe(70,7,7,5,'|15C|11all|07s');
  Screen.WriteXYPipe(1,25,7,80,'|15ALT-Z/|11H|07elp    |15ENTER/|11D|07ial    |15ESC/|11M|07enu    |15ALT-E/|11E|07dit  |15DEL/|11D|07elete   |15ALT-X/|11Q|07uit');
  case field1 of
    0: screen.writexypipe(field1x,fieldy,3,10,'Last Call');
    1: screen.writexypipe(field1x,fieldy,3,10,'Edited');
    2: screen.writexypipe(field1x,fieldy,3,10,'Validated');
    3: screen.writexypipe(field1x,fieldy,3,10,'Added');
  end;
  case field2 of
    0: screen.writexypipe(field2x,fieldy,3,5,'Calls');
    1: screen.writexypipe(field2x,fieldy,3,5,'Rate');
  end;
End;


Procedure DrawQueueAnsi;
const
  IMAGEDATA_WIDTH=80;
  IMAGEDATA_DEPTH=25;
  IMAGEDATA_LENGTH=922;
  IMAGEDATA : array [1..495] of Char = (
     #7,#16,#25, #7,#11,'Ü',#15,'ß', #3,'Ü',' ','²',#15,'ß', #3,'²',' ',
    '°','°','±',' ','±',' ','²','ß','±',#25, #2,'°','°','°','±',' ','°',
    '°',#24,' ','ß',' ','ß','Û',' ','±','²','²',' ',#19,' ',#11,'Ü',' ',
    #16,' ',#19,'Ü',#16,#25, #6,#19,' ',#16,' ',#19,' ','°',#24,#16,' ',
     #3,'Û','Ü',' ','Ü',#25, #2,#11,#19,'Ü',#16,' ', #7,'Ü',' ',#11,#19,
    'Ü',#16,' ',#19,' ', #3,#16,'ß','ß','ß',#11,#19,'ß', #3,#16,'ß','ß',
    'ß',#11,#19,'Ü',#16,' ', #7,'Ý','Þ',#11,#19,'Ü', #3,#16,'ß','ß','ß',
    #11,#19,'ß', #3,#16,'ß','ß','ß',#11,#19,'ß',#16,' ', #0,#19,'ß','Ü',
    'ß','Ý','v','e','r','.',' ','2','.','0','Þ','Ü','ß','Ü',#24,#16,#25,
     #7,#11,#23,'ß',#16,' ',#23,'Ü',#16,' ',#23,'Ü',#16,' ',#23,'ß',#16,
    ' ',#23,'ß',#16,' ',#23,'ß',#16,' ',#23,'Ü','ß','Ü',#16,' ',' ', #7,
    'ß',#11,#23,'ß',#16,' ', #7,'ß',' ',#11,#23,'Ü',#16,' ',#23,'Ü','ß',
    #24,#15,#16,'Ü','±','ß','ß','ß',' ', #3,'°', #7,'²','²',' ','ß',' ',
    'Û',' ','Û',' ','ß',' ','Û',' ','ß','ß','Û',' ','Û',' ','Û',' ','ß',
    'ß','Û',' ','²','°','°','°', #8,'ß','ß',#15,'ß','ß',' ',#26, #3,'ß',
    #11,'ß','ß','²','Ý',#26, #4,'ß',' ',#26,#18,'ß',' ','ß','Þ','Û','Ü',
    #24,#15,'Û','Ý',#25, #5, #8,#26, #3,'ß',' ','ß',' ','ß','ß','ß',' ',
    'ß','ß','ß',' ','ß',' ','ß',' ','ß','ß','ß',' ','ß',#25,#28,#11,' ',
     #3,' ',' ', #8,' ',' ',#11,' ', #3,' ',' ', #8,' ',' ',#11,' ', #3,
    ' ',' ',' ', #8,' ',' ',#11,'Þ','Û',#24,#15,'Û',#25,'L',#11,'Û',#24,
    #15,'Û',#25,'L', #7,'²',#24,#15,'²',#25,'L', #7,'²',#24,#15,'²',#25,
    'L', #7,'²',#24,#11,'²',#25,'L', #7,'±',#24,#15,'±',#25,'L', #7,'±',
    #24,#11,'±',#25,'L', #7,'°',#24,#11,'°',#25,'L', #7,'ú',#24,#25,'M',
     #8,'°',#24,#11,'þ',#25,'L', #8,'±',#24,#11,'°',#25,'L', #8,'±',#24,
    #11,'±',#25,'L', #8,'²',#24,#11,'±',#25,'L', #8,'þ',#24,#11,'²',#25,
    'L', #8,'±',#24,#11,'²',#25,'L', #8,'²',#24,#11,'Û',#25,'L', #8,'²',
    #24,#11,'Û','Ý',#25,'J', #8,'Þ','Û',#24,#11,'ß','°',#26, #6,'Ü',' ',
    'Ü','Ü','²',#26,#16,'Ü',' ', #7,'Ü',#11,'þ', #7,#26,#15,'Ü',' ',#26,
    #12,'Ü',' ','Ü','Ü', #8,#26, #3,'Ü','±',#26, #5,'Ü', #7,'°', #8,'ß',
    #24,#24);
Begin
  Screen.LoadScreenImage(ImageData, ImageData_Length, ImageData_Width, 1, 1);    
  Screen.WriteXYPipe(6,8,7,10,'|15F|07il|08e');
  Screen.WriteXYPipe(29,8,7,8,'|15P|07at|08h');
  Screen.WriteXYPipe(68,8,7,4,'|15S|07iz|08e');
  Screen.WriteXYPipe(1,25,7,80,'|15ALT-Z |07H|08elp                                                                     |15ESC |07B|08ack');  
  Screen.WriteXYPipe(53,6,7,19,'|15T|07ota|08l |15F|07ile|08s:');
  //Screen.WriteXYPipe(67,6,15,19,StrPadL(StrI2S(Queue.QSize),3,' '));
End;  

Procedure DrawHelpAnsi;
var 
  zm : tmenubox;
  sl : tstringlist;
  index : integer = 0;
  left : byte=4;
  top  : byte=3;
  height : byte = 20;
  width : byte = 72;
  c : char;
  d:byte;
Begin
  //Screen.LoadScreenImage(ImageData, ImageData_Length, ImageData_Width, 1, 1); 
  //screen.textattr:=7;   
  zm := TMenubox.create(toutput(screen));
        
  zm.Header    := ' Help & Features ';
  zm.HeadAttr  := pref.MsgBox_HeadAttr;//15 + 7 * 16;
  zm.BoxAttr    := pref.MsgBox_BoxAttr  ;
  zm.BoxAttr2   := pref.MsgBox_BoxAttr2 ;
  zm.BoxAttr3   := pref.MsgBox_BoxAttr3 ;
  zm.BoxAttr4   := pref.MsgBox_BoxAttr4 ;
      
  zm.FrameType := pref.MsgBox_FrameType;
  zm.Box3D     := true;
  zm.ShadowAttr :=8;
  

  zm.Open (3, 2, 77, 5);
  waitms(100);
  zm.Open (3, 2, 77, 10);
  waitms(100);
  zm.Open (3, 2, 77, 23);
  
  
  
  sl:=tstringlist.create;
  
sl.add('    ');
sl.add('    ');
sl.add(' |08// |15Index');
sl.add(' ');
sl.add(' Press number/char. on your keyboard to quick navigate');
sl.add(' ');
sl.add(' :: 1. |15Key ShortCuts');
sl.add(' :: 2. |15Codes for use in Macros');
sl.add(' :: 3. |15Pipe Color Values');
sl.add(' :: 4. |15Calculating Color Value for INI file');
sl.add(' :: 5. |15INI Configuration');
sl.add('       a. |03[MsgBox]');
sl.add('       b. |03[Form] ');
sl.add('       c. |03[General]');
sl.add('       d. |03[ACS]');
sl.add('       e. |03[Macro]');
sl.add('       f. |03[Music]');
sl.add(' :: 6. |15Play some music!!!');
sl.add('       g. |03How it''s done...');
sl.add('       h. |03How Blocker gets the tracks...');
sl.add('       i. |03INI file format');
sl.add(' :: 7. |15Autotext');
sl.add('');
sl.add(' |08// |15Features');
sl.add('    ');
sl.add('    In random order... :p');
sl.add('    ');
sl.add('    + Macros...');
sl.add('    + Take ANSI snapshots of the screen...');
sl.add('    + Up to 600 phonebook records, more than enough...');
sl.add('    + Load multiple phonebooks...');
sl.add('    + Sort phonebook in many ways...');
sl.add('    + Scrollback');
sl.add('    + Import SyncTerm phonebook...');
sl.add('    + Comes with a BASH shell to automatically get the latest list from ');
sl.add('      BBSIndex');
sl.add('    + Preview local ANSI files...');
sl.add('    + Convert an ANSI file to a Mystic Pipe Codes file...');
sl.add('    + Use it as a DOOR program in your BBS...');
sl.add('    + Change fields to view in Phonebook list...');
sl.add('    + Use the ASCII char. dialog to enter any ASCII code to a BBS, very ');
sl.add('      usefull when customizing your BBS.');
sl.add('    + Autotext feature!...');
sl.add('    + Custom StatusBar...');
sl.add('    and more...');
sl.add('');
sl.add(' ');
sl.add('  ');
sl.add(' |08// |15Key ShortCuts');
sl.add(' ');
sl.add(' :: |11PhoneBook Editor');
sl.add(' ');
sl.add('    ALT-C // Convert ANSI file to Mystic Pipes File');
sl.add('    ALT-D // Direct/Quick Dial');
sl.add('    ALT-E // Edit Record');
sl.add('    ALT-I // Import SyncTerm Phonebook file');
sl.add('    ALT-M // Edit Macros');
sl.add('    ALT-O // Open/Load Phonebook file');
sl.add('    ALT-P // Preview ANSI file, locally');
sl.add('    ALT-S // Change PhoneBook Sort Order');
sl.add('    ALT-X // Exit Program');
sl.add('    ');
sl.add('    DEL   // Delete Phonebook Entry');
sl.add('    ESC   // Menu');
sl.add('    ENTER // Dial to Select BBS');
sl.add('');
sl.add(' :: |11While Connected');
sl.add('  ');
sl.add('    ALT-A // Insert ASCII Char.');
sl.add('    ALT-B // ScrollBack History');
sl.add('    ALT-E // Edit PhoneBook Entry');
sl.add('    ALT-H // Hang Up');
sl.add('    ALT-L // Send Login Credentials');
sl.add('    ALT-M // Edit/View Macros');
sl.add('    ALT-N // Snapshot to ANSI (no dialog)');
sl.add('    ALT-P // Stop Music');
sl.add('    ALT-Q // Toggle StatusBar');
sl.add('    ALT-S // Snapshot to ANSI (with dialog)');
sl.add('    ALT-T // Transfer File');
sl.add('    ALT-W // Write AutoText');
sl.add('    ');
sl.add('    ');
sl.add('    ');
sl.add(' |08// |15Codes for use in Macros');
sl.add(' ');
sl.add('    Put one of these codes in place of the value you want to put in a ');
sl.add('    field of the BBS.');
sl.add('    ');
sl.add('    BD  : Blocker Directory');
sl.add('    CR  : Carriage Return');
sl.add('    CL  : Clear Screen');
sl.add('    CE  : Escape Char.');
sl.add('    UN  : Username (from the phonebook record)');
sl.add('    PW  : Password (from the phonebook record)');
sl.add('    PA  : Pause for half a second');
sl.add('    QO  : Random Quote from the Quote File');
sl.add('    DA  : Current Date');
sl.add('  * SH  : Execute BASH Shell Script');
sl.add('  ');
sl.add('  * For use only in the main program and not while connected to a BBS');
sl.add('  ');
sl.add(' ');
sl.add(' ');
sl.add(' |08// |15Pipe Color Values');
sl.add(' ');
sl.add('   00 : Sets the current foreground to Black');
sl.add('   01 : Sets the current foreground to Dark Blue');
sl.add('   02 : Sets the current foreground to Dark Green');
sl.add('   03 : Sets the current foreground to Dark Cyan');
sl.add('   04 : Sets the current foreground to Dark Red');
sl.add('   05 : Sets the current foreground to Dark Magenta');
sl.add('   06 : Sets the current foreground to Brown');
sl.add('   07 : Sets the current foreground to Grey');
sl.add('   08 : Sets the current foreground to Dark Grey');
sl.add('   09 : Sets the current foreground to Light Blue');
sl.add('   10 : Sets the current foreground to Light Green');
sl.add('   11 : Sets the current foreground to Light Cyan');
sl.add('   12 : Sets the current foreground to Light Red');
sl.add('   13 : Sets the current foreground to Light Magenta');
sl.add('   14 : Sets the current foreground to Yellow');
sl.add('   15 : Sets the current foreground to White');
sl.add('   ');
sl.add('   ');
sl.add('   ');
sl.add(' |08// |15Calculating Color Value for INI file');
sl.add(' ');
sl.add('   |03Foreground and Background');
sl.add('   00 : Sets the current foreground to Black');
sl.add('   01 : Sets the current foreground to Dark Blue');
sl.add('   02 : Sets the current foreground to Dark Green');
sl.add('   03 : Sets the current foreground to Dark Cyan');
sl.add('   04 : Sets the current foreground to Dark Red');
sl.add('   05 : Sets the current foreground to Dark Magenta');
sl.add('   06 : Sets the current foreground to Brown');
sl.add('   07 : Sets the current foreground to Grey');
sl.add('   ');
sl.add('   |03Only Foreground');
sl.add('   08 : Sets the current foreground to Dark Grey');
sl.add('   09 : Sets the current foreground to Light Blue');
sl.add('   10 : Sets the current foreground to Light Green');
sl.add('   11 : Sets the current foreground to Light Cyan');
sl.add('   12 : Sets the current foreground to Light Red');
sl.add('   13 : Sets the current foreground to Light Magenta');
sl.add('   14 : Sets the current foreground to Yellow');
sl.add('   15 : Sets the current foreground to White');
sl.add('   ');
sl.add('   To get the color value for White Text in Red Background you do ');
sl.add('   this: 15 + 4 * 16 =|07 79. The format is FG + BG * 16.');
sl.add('  ');
sl.add('  ');
sl.add('  ');
sl.add(' |08// |15INI Configuration');
sl.add(' ');
sl.add(' :: |11[List] Stanza');
sl.add('    Contains the color attributes for any list object. The color is ');
sl.add('    in form FG + BG * 16. ');
sl.add('    ');
sl.add('    |09Hi=|0763       // White on Dark Cyan');
sl.add('    |09Low=|073       // Dark Cyan on Black');
sl.add('    |09Tag=|0714      // Yellow on Black');
sl.add('    ');
sl.add(' :: |11[MsgBox] Stanza');
sl.add('    Contains attributes for boxes, like in the message box, phone ');
sl.add('    rec. list etc.');
sl.add('    ');
sl.add('    |09Frame=|079     // 1 to 9, different chars. for box frame');
sl.add('    |09Header=|0715   // Color value as above');
sl.add('    |09Attr1=|0711    // Color value as above');
sl.add('    |09Attr2=|073     // Color value as above');
sl.add('    |09Attr3=|077     // Color value as above');
sl.add('    |09Attr4=|0715    // Color value as above');
sl.add('    |093D=|071        // 1 for true, 0 for false, also adds shadow to the');
sl.add('                // box.');
sl.add('                ');
sl.add(' :: |11[Form] Stanza');
sl.add('    Contains attributes for the edit entry form. All attributes are ');
sl.add('    color values.');
sl.add('    ');
sl.add('    |09Lo=|073');
sl.add('    |09Hi=|0763');
sl.add('    |09Data=|077');
sl.add('    |09Lokey=|0711');
sl.add('    |09HiKey=|0762');
sl.add('    |09Field1=|0711');
sl.add('    |09Field2=|0715');
sl.add('    ');
sl.add(' :: |11[General] Stanza');
sl.add('    Various settings for the program. ');
sl.add('    ');
sl.add('    |09auto_zmodem=|071   // ZModem Download is not implemented yet.');
sl.add('    |09zmodem_dn=|07sexyz -telnet sz  // External App. to use for download');
sl.add('    |09zmodem_up=|07rz --zmodem       // External App. to use for upload');
sl.add('    ');
sl.add('    This is the file to use for Quotes/Tags. If you don''t specify ');
sl.add('    one, nothing happens :)');
sl.add('    |09quotefile=|07greektags.txt');
sl.add('    ');
sl.add('    This value saves the last phonebook file you used. By default is ');
sl.add('    blocker.bbs.');
sl.add('    |09phonebook=|07blocker.bbs');
sl.add('    ');
sl.add('    The statusbar value contains the text format for the status bar ');
sl.add('    in the program. You can use the following codes to customize your ');
sl.add('    status bar and also any Pipe color code to colorize it.');
sl.add('    statusbar=|07|19|15ALT-Z|07 H|08elp Screen   |00|DA|16');
sl.add('    ;|DA =|07 Date');
sl.add('    ;|BN =|07 BBS Name');
sl.add('    ;|CS =|07 Total Calls');
sl.add('    ;|LO =|07 Last Call');
sl.add('    ;|QO =|07 Random Quote');
sl.add('    ;|SL =|07 Security Level');
sl.add('    ;|UY =|07 User IP ?');
sl.add('    ;|UN =|07 Username');
sl.add('    ;|BD =|07 Blocker Dir');
sl.add('    ');
sl.add(' :: |11[ACS] Stanza');
sl.add('    The ACS stanza contains ACS (securitly level) values for various ');
sl.add('    functions of the program, in case you are using it as a DOOR app. ');
sl.add('    This way, you don''t allow users to have access to sensitive data ');
sl.add('    on your BBS system and you can allow/forbid what they can do or ');
sl.add('    not.');
sl.add('    ');
sl.add('    Any function that browses the BBS file system, should not be let ');
sl.add('    free to use, to random users, so by default the ACS level is ');
sl.add('    increased. The program gets current users ACS level from the ');
sl.add('    DOOR32.SYS file and compares it with this one. If the user has ');
sl.add('    higher or equal, sec.level the function is allowed.');
sl.add('    ');
sl.add('    |09PreviewANSI=|0750');
sl.add('    |09PreviewChars=|0720');
sl.add('    |09ConvertANSI=|0750');
sl.add('    |09ImmidiateDial=|0720');
sl.add('    |09LoadPhoneBook=|0750');
sl.add('    |09SortRecords=|0720');
sl.add('    |09ImportSyncTerm=|0750');
sl.add('    |09EditMacros=|0750');
sl.add('    |09EditBook=|0750');
sl.add('    |09DelBook=|0750');
sl.add('    |09DelRecord=|0750');
sl.add('    |09Upload=|0750');
sl.add('    |09Download=|0750');
sl.add('    |09SaveScreen=|0750');
sl.add('    ');
sl.add(' :: |11[Macro] Stanza');
sl.add('    This stanza saves the Macro commands, which you can also edit ');
sl.add('    from within the program.');
sl.add('    |090=|07');
sl.add('    |091=|07|UN|PA|PW');
sl.add('    |092=|07|CE');
sl.add('    |093=|07|CE|PA');
sl.add('    |094=|07|UN');
sl.add('    |095=|07|PW');
sl.add('    |096=|07|QO');
sl.add('    |097=|07');
sl.add('    |098=|07');
sl.add('    |099=|07|SH|BDbbstelnet.sh');
sl.add('    ');
sl.add(' :: |11[Music] Stanza');
sl.add('    Here you can configure which program to use for playing music. ');
sl.add('    See below on how to customize your BBS to support Music/Sounds.');
sl.add('    ');
sl.add('    By default the program uses XMP which is the best player for ');
sl.add('    track music. You can use anything you want, but i do recommend ');
sl.add('    XMP.');
sl.add('    ');
sl.add('    The |15%f|07 represents the file than the music player will play. ');
sl.add('    Blocker needs one command to play music and one to stop/kill the ');
sl.add('    player. XMP doesn''t support a mode to interact through a command ');
sl.add('    or protocol, so it needs to be killed.');
sl.add('    ');
sl.add('    |09play=|07xmp "%f" -q &');
sl.add('    |09stop=|07pkill xmp');
sl.add('    ');
sl.add('    ');
sl.add('    ');
sl.add('|08// |15Play some music!!!');
sl.add('');
sl.add('    Do you want to add some music/sound fx to your BBS? Now you can, ');
sl.add('    with Blocker! It''s not easy, but you can do it and it also opens ');
sl.add('    many possibilities in using your BBSes, like Sound Notifications ');
sl.add('    ;)');
sl.add('    ');
sl.add('    |03How it''s done...');
sl.add('    Blocker uses some character codes to recognize when to play a ');
sl.add('    track file. So, when it finds a code, it knows to play a specific ');
sl.add('    file or stop the music. The code is similar to Pipe codes but ');
sl.add('    instead of a Pipe it uses the SOH/x01 (#01 for Pascal) character ');
sl.add('    and also two more characters from 0 to 9 and A to Z.');
sl.add('    ');
sl.add('    For displaying the codes in this file, i will use the [SOH] label.');
sl.add('    ');
sl.add('    So, a music code can be: [SOH]00 or [SOH]AF or [SOH]WW etc. One ');
sl.add('    exception is the StopMusic code which is 3 time the [SOH] char. ');
sl.add('    like [SOH][SOH][SOH]. Values from 00 to FE are used for ');
sl.add('    recognizing tracks. This way you have the possibility to use 254');
sl.add('    tracks, which i think are enough. The FF code is a special one ');
sl.add('    and is used to play a random music file, from a specific folder. ');
sl.add('    This way, you can use even more tracks than 254. Let''s recap...');
sl.add('    ');
sl.add('    [SOH][SOH][SOH]    : Stop Music');
sl.add('    [SOH]00 to [SOH]FE : Play Track with HEX value 00 to FE');
sl.add('    [SOH]FF            : Play random track from specified folder.');
sl.add('    ');
sl.add('    |03How Blocker gets the tracks...');
sl.add('    Actually, Blocker can''t get any track :( You have to provide ');
sl.add('    them. A BBS that wants to add Music/Sound, should build a package ');
sl.add('    containing all the tracks, in a specified directory structure and ');
sl.add('    also include an INI file. The INI file must have a name, exactly ');
sl.add('    as the name of the BBS used in the PhoneBook. Lets see an ');
sl.add('    example.');
sl.add('    ');
sl.add('    Lets say you have a PhoneBook entry for a BBS called "Ansimania ');
sl.add('    BBS". The music package for this BBS, should have the following ');
sl.add('    format:');
sl.add('    ');
sl.add('    + ansimania           [DIR]');
sl.add('    +--+ random           [DIR]');
sl.add('    [  [ track1.mod       [File]');
sl.add('    [  [ track2.mod       [File]');
sl.add('    [  [ etc.');
sl.add('    [');
sl.add('    [ trackx.mod          [File]');
sl.add('    [ tracky.mod          [File]');
sl.add('    [ trackz.mod          [File]');
sl.add('    [ etc.');
sl.add('    [ Ansimania_BBS.ini   [File]');
sl.add('    ');
sl.add('    If you have enabled to use music for the specific BBS in your ');
sl.add('    PhoneBook, Blocker will search for the Ansimania_BBS.ini file, it ');
sl.add('    will read it and then play the music according to the music codes ');
sl.add('    the BBS will provide.');
sl.add('    ');
sl.add('    The INI file have this format:');
sl.add('    ');
sl.add('    [music]');
sl.add('    |09dir=|07|BDmusic/local/');
sl.add('    |0901=|07modem.xm');
sl.add('    |0902=|07evil.xm');
sl.add('    |0903=|07programming.xm');
sl.add('    ');
sl.add('    |09dir=|07');
sl.add('    This is the directory where the music files are stored. It can be ');
sl.add('    anywhere in your disk. You can use the |BD pipe code to specify ');
sl.add('    that is inside the same folder as Blocker (Blocker Directory).');
sl.add('    ');
sl.add('    |0901=|07, |0902=|07... |09FE=|07,');
sl.add('    This tells which file to play when Blocker sees the [SOX]10 code. ');
sl.add('    Accordingly you can have values up to |09FE=|07');
sl.add('    ');
sl.add('    |03The Random Dir...');
sl.add('    As you see there is also a dir. called "random". Inside this ');
sl.add('    directory you can put any track music you want. When Blocker ');
sl.add('    recognizes the [SOH]FF command, it will pick one track, randomly, ');
sl.add('    from this directory and play it. This way you can use the [SOH]FF ');
sl.add('    command to have different music, on the same menus/functions, ');
sl.add('    with just using one code.');
sl.add('    ');
sl.add('    Check the included package for Another Droid BBS, to get an ');
sl.add('    example and understand the use better. Also, login to Another ');
sl.add('    Droid BBS to listen to it ;)');
sl.add('    ');
sl.add('    ');
sl.add('    ');
sl.add(' |08// |15Autotext');
sl.add('    ');
sl.add('    In some BBSes i noticed that there is a lot of lag. This is ');
sl.add('    normal if you are connecting from a very long distance or the ');
sl.add('    connection is bad. In some cases, typing text to a BBS was ');
sl.add('    impossible, with a lag of 1-3 secs. This way, i figured to have ');
sl.add('    the Autotext feature.');
sl.add('    ');
sl.add('    By pressing ALT-W, a form appears, where you can type text, up to ');
sl.add('    10 lines at a time. This way you can write your message, edit it ');
sl.add('    and when you are ready, you press OK and Blocker sends it as a ');
sl.add('    stream of text to the BBS.');
sl.add('    ');
sl.add('    This way, you don''t have to wait 1-3 secs for each keypress or ');
sl.add('    when you did a typo, stop wait, press backspace, wait etc... I ');
sl.add('    hope that this will be useful and who knows, you may find other ');
sl.add('    ways to use it. ;) ');
sl.add('    ');
sl.add('    ');

  repeat
    for d:=0 to height-1 do screen.writexypipe(left,top+d,7,width,sl[index+d]);
    c:=keyboard.readkey;
    if c=#00 then begin
      c:=keyboard.readkey;
      case c of
        keyhome : index:=0;
        keyend  : index:=sl.count-1 - height;
        keypgup : if index-height>1 then index:=index-height else index:=0;
        keypgdn : if index+height+height-1<sl.count-1 then index:=index+height-1
                    else index:=sl.count-1-height;
        keyup   : if index>1 then index:=index-1;
        keydown : if index+height<sl.count-1 then index:=index+1;
      end;
    end else 
      case locase(c) of
        keyenter : if index+height<sl.count-1 then index:=sl.count-1-height;
        '1' : index:=48;
        '2' : index:=83;
        '3' : index:=103;
        '4' : index:=124;
        '5' : index:=151;
        'a' : index:=161;
        'b' : index:=174;
        'c' : index:=186;
        'd' : index:=215;
        'e' : index:=243;
        'f' : index:=257;
        '6' : index:=275;
        'g' : index:=282;
        'h' : index:=303;
        'i' : index:=332;
        '7' : index:=360;
      end;
  
  until c=#27;
  sl.free;
  zm.Close;
  zm.destroy;
End;  

Procedure DrawTerminalAnsi;
const
  IMAGEDATA_WIDTH=80;
  IMAGEDATA_DEPTH=25;
  IMAGEDATA_LENGTH=922;
  IMAGEDATA : array [1..495] of Char = (
     #7,#16,#25, #7,#11,'Ü',#15,'ß', #3,'Ü',' ','²',#15,'ß', #3,'²',' ',
    '°','°','±',' ','±',' ','²','ß','±',#25, #2,'°','°','°','±',' ','°',
    '°',#24,' ','ß',' ','ß','Û',' ','±','²','²',' ',#19,' ',#11,'Ü',' ',
    #16,' ',#19,'Ü',#16,#25, #6,#19,' ',#16,' ',#19,' ','°',#24,#16,' ',
     #3,'Û','Ü',' ','Ü',#25, #2,#11,#19,'Ü',#16,' ', #7,'Ü',' ',#11,#19,
    'Ü',#16,' ',#19,' ', #3,#16,'ß','ß','ß',#11,#19,'ß', #3,#16,'ß','ß',
    'ß',#11,#19,'Ü',#16,' ', #7,'Ý','Þ',#11,#19,'Ü', #3,#16,'ß','ß','ß',
    #11,#19,'ß', #3,#16,'ß','ß','ß',#11,#19,'ß',#16,' ', #0,#19,'ß','Ü',
    'ß','Ý','v','e','r','.',' ','2','.','0','Þ','Ü','ß','Ü',#24,#16,#25,
     #7,#11,#23,'ß',#16,' ',#23,'Ü',#16,' ',#23,'Ü',#16,' ',#23,'ß',#16,
    ' ',#23,'ß',#16,' ',#23,'ß',#16,' ',#23,'Ü','ß','Ü',#16,' ',' ', #7,
    'ß',#11,#23,'ß',#16,' ', #7,'ß',' ',#11,#23,'Ü',#16,' ',#23,'Ü','ß',
    #24,#15,#16,'Ü','±','ß','ß','ß',' ', #3,'°', #7,'²','²',' ','ß',' ',
    'Û',' ','Û',' ','ß',' ','Û',' ','ß','ß','Û',' ','Û',' ','Û',' ','ß',
    'ß','Û',' ','²','°','°','°', #8,'ß','ß',#15,'ß','ß',' ',#26, #3,'ß',
    #11,'ß','ß','²','Ý',#26, #4,'ß',' ',#26,#18,'ß',' ','ß','Þ','Û','Ü',
    #24,#15,'Û','Ý',#25, #5, #8,#26, #3,'ß',' ','ß',' ','ß','ß','ß',' ',
    'ß','ß','ß',' ','ß',' ','ß',' ','ß','ß','ß',' ','ß',#25,#28,#11,'l',
     #3,'a','s', #8,'t',' ',#11,'c', #3,'a','l', #8,'l',' ',#11,'c', #3,
    'a','l','l', #8,'s',' ',#11,'Þ','Û',#24,#15,'Û',#25,'L',#11,'Û',#24,
    #15,'Û',#25,'L', #7,'²',#24,#15,'²',#25,'L', #7,'²',#24,#15,'²',#25,
    'L', #7,'²',#24,#11,'²',#25,'L', #7,'±',#24,#15,'±',#25,'L', #7,'±',
    #24,#11,'±',#25,'L', #7,'°',#24,#11,'°',#25,'L', #7,'ú',#24,#25,'M',
     #8,'°',#24,#11,'þ',#25,'L', #8,'±',#24,#11,'°',#25,'L', #8,'±',#24,
    #11,'±',#25,'L', #8,'²',#24,#11,'±',#25,'L', #8,'þ',#24,#11,'²',#25,
    'L', #8,'±',#24,#11,'²',#25,'L', #8,'²',#24,#11,'Û',#25,'L', #8,'²',
    #24,#11,'Û','Ý',#25,'J', #8,'Þ','Û',#24,#11,'ß','°',#26, #6,'Ü',' ',
    'Ü','Ü','²',#26,#16,'Ü',' ', #7,'Ü',#11,'þ', #7,#26,#15,'Ü',' ',#26,
    #12,'Ü',' ','Ü','Ü', #8,#26, #3,'Ü','±',#26, #5,'Ü', #7,'°', #8,'ß',
    #24,#24);
Begin
  Screen.LoadScreenImage(ImageData, ImageData_Length, ImageData_Width, 1, 1);
End;

