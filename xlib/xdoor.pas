Unit xDoor;
{$MODE objfpc}
Interface

Uses
  xStrings,
  xFileIO;

Type
  TEmulationType = (etANSI, etASCII);

  {
    When a dropfile is read there is some useless information so it is not
    necessary to store the whole thing in memory.  Instead only certain
    parts are saved to this record

    Supported Dropfiles
    A = Found In DOOR32.SYS
    B = Found In DORINFO*.DEF
    C = Found In DOOR.SYS
    D = Found In INFO.*
    E = Supported By WINServer
  }
  TDropInfo = Record
    Access    : LongInt;        {ABC--} {User's Access Level}
    Alias     : String;         {ABCDE} {User's Alias/Handle}
    Baud      : LongInt;        {ABCDE} {Connection Baud Rate}
    ComNum    : LongInt;        {ABCD-} {Comm/Socket Number}
    ComType   : Byte;           {A----} {Comm Type (0=Local, 1=Serial, 2=Socket, 3=WC5}
    Emulation : TEmulationType; {ABCDE} {User's Emulation (eANSI or eASCII)}
    MaxTime   : LongInt;        {ABCDE} {User's Time Left At Start (In Seconds)}
    Node      : LongInt;        {A-C-E} {Node Number}
    RealName  : String;         {ABCDE} {User's Real Name}
    RecPos    : LongInt;        {A-CD-} {User's Userfile Record Position (Always 0 Based)}
  end;
  
Var
   DropInfo : TDropInfo;
   Local    : Boolean = False;
   ACS      : Byte = 255;

procedure ReadDoor32(AFile: String);
procedure ReadDoorSys(AFile: String);
procedure ReadDoor(Afile: String);
Function IsACS:Boolean;
Function IsACS(A:Byte):Boolean; Overload;


Implementation

Uses
  DOS;
//  m_fileio;

Function StrToIntDef(S:String; D:LongInt):LongInt;
Begin
  Try
    Result := Str2Int(S);
  Except
    Result := D;
  End;
End;

{
  Read the DOOR32.SYS file AFILE
}
procedure ReadDoor32(AFile: String);
var
   F: Text;
   S: String;
begin
     if (FileExist(AFile)) then
     begin
          Assign(F, AFile);
          {$I-}Reset(F);{$I+}
          if (IOResult = 0) then
          begin          
               ReadLn(F, S); {1 - Comm Type (0=Local, 1=Serial, 2=Telnet)}
               DropInfo.ComType := StrToIntDef(S, 0);

               ReadLn(F, S); {2 - Comm Or Socket Handle}
               DropInfo.ComNum := StrToIntDef(S, -1);

               ReadLn(F, S); {3 - Baud Rate}
               DropInfo.Baud := StrToIntDef(S, 38400);

               ReadLn(F, S); {4 - BBSID (Software Name & Version}

               ReadLn(F, S); {5 - User's Record Position (1 Based)}
               DropInfo.RecPos := StrToIntDef(S, 1) - 1;

               ReadLn(F, S); {6 - User's Real Name}
               DropInfo.RealName := S;

               ReadLn(F, S); {7 - User's Handle/Alias}
               DropInfo.Alias := S;

               ReadLn(F, S); {8 - User's Access Level}
               DropInfo.Access := StrToIntDef(S, 0);

               ReadLn(F, S); {9 - User's Time Left (In Minutes)}
               DropInfo.MaxTime := StrToIntDef(S, 0) * 60;

               ReadLn(F, S); {10 - Emulation (0=Ascii, 1=Ansi, 2=Avatar, 3=RIP, 4=MaxGfx)}
               if (StrToIntDef(S, 1) = 0) then
                  DropInfo.Emulation := etASCII
               else
                   DropInfo.Emulation := etANSI;

               ReadLn(F, S); {11 - Current Node Number}
               DropInfo.Node := StrToIntDef(S, 0);

               Close(F);
          end;
     end;
end;

{
  Read the DOOR.SYS file AFILE
}
procedure ReadDoorSys(AFile: String);
var
   F: Text;
   S: String;
begin
     if (FileExist(AFile)) then
     begin
          Assign(F, AFile);
          {$I-}Reset(F);{$I+}
          if (IOResult = 0) then
          begin
               ReadLn(F, S); {1 - Comm Or Socket Handle}
               DropInfo.ComNum := StrToIntDef(Copy(S, 4, Length(S) - 4), 0);
               if (DropInfo.ComNum > 0) then
                  DropInfo.ComType := 1;

               ReadLn(F, S); {2 - Line Speed}

               ReadLn(F, S); {3 - Data Bits}

               ReadLn(F, S); {4 - Current Node Number}
               DropInfo.Node := StrToIntDef(S, 0);

               ReadLn(F, S); {5 - Modem Speed}
               DropInfo.Baud := StrToIntDef(S, 38400);

               ReadLn(F, S); {6 - Screen Display}

               ReadLn(F, S); {7 - Syslog Printer}

               ReadLn(F, S); {8 - Page Bell}

               ReadLn(F, S); {9 - Caller Alarm}

               ReadLn(F, S); {10 - User's Real Name}
               DropInfo.RealName := S;

               ReadLn(F, S); {11 - City, State}

               ReadLn(F, S); {12 - Phone Number}

               ReadLn(F, S); {13 - Data Phone Number}

               ReadLn(F, S); {14 - Password}

               ReadLn(F, S); {15 - User's Access Level}
               DropInfo.Access := StrToIntDef(S, 0);

               ReadLn(F, S); {16 - Number Of Logons}

               ReadLn(F, S); {17 - Date Last Logged On}

               ReadLn(F, S); {18 - User's Time Left (In Seconds)}
               DropInfo.MaxTime := StrToIntDef(S, 0);

               ReadLn(F, S); {19 - User's Time Left (In Minutes)}

               ReadLn(F, S); {20 - Emulation (GR=Ansi, NG=Ascii, 7E=7-Bit)}
               if (Upper(S) = 'GR') then
                  DropInfo.Emulation := etANSI
               else
                   DropInfo.Emulation := etASCII;

               ReadLn(F, S); {21 - Lines On Screen}

               ReadLn(F, S); {22 - Menu Status}

               ReadLn(F, S); {23 - Conferences}

               ReadLn(F, S); {24 - Current Conference}

               ReadLn(F, S); {25 - Expiration Date}

               ReadLn(F, S); {26 - User's Record Position (1 Based)}
               DropInfo.RecPos := StrToIntDef(S, 1) - 1;

               ReadLn(F, S); {27 - Default Protocol}

               ReadLn(F, S); {28 - kB Uploaded}

               ReadLn(F, S); {29 - kB Downloaded}

               ReadLn(F, S); {30 - Downloaded Today}

               ReadLn(F, S); {31 - Maximum Downloaded Today}

               ReadLn(F, S); {32 - User's Birthday}

               ReadLn(F, S); {33 - BBS Data Directory}

               ReadLn(F, S); {34 - BBS Text Files Directory}

               ReadLn(F, S); {35 - SysOp Name}

               ReadLn(F, S); {36 - User's Handle/Alias}
               DropInfo.Alias := S;

               ReadLn(F, S); {37 - Event Time}

               ReadLn(F, S); {38 - Dont Know}

               ReadLn(F, S); {39 - Ansi Ok But Disable Graphics}

               ReadLn(F, S); {40 - Record Locking}

               ReadLn(F, S); {41 - Base Text Colour}

               ReadLn(F, S); {42 - Time In Time Bank}

               ReadLn(F, S); {43 - Last New Message Scan Date}

               ReadLn(F, S); {44 - Dont Know}

               ReadLn(F, S); {45 - Time Last Call}

               ReadLn(F, S); {46 - Max Files Downloaded Per Day}

               ReadLn(F, S); {47 - Number Of Files Downloaded Today}

               ReadLn(F, S); {48 - kB Uploaded}

               ReadLn(F, S); {49 - kB Downloaded}

               ReadLn(F, S); {50 - User Note}

               ReadLn(F, S); {51 - Number Of Doors Run}

               ReadLn(F, S); {52 - Number Of Messages Posted}

               Close(F);
          end;
     end;
end;

procedure ReadDoor(Afile: String);
Begin
  If FileExist(AFile) Then Begin
    If Pos('door32.sys',Afile)>0 Then ReadDoor32(Afile)
      Else ReadDoorSys(Afile);
  End Else Local := True;
End;

Function IsACS:Boolean;
Begin
  Result:=False;
  If DropInfo.Access>=ACS Then Result := True;
End;

Function IsACS(A:Byte):Boolean; Overload;
Begin
  Result:=False;
  If DropInfo.Access>=A Then Result := True;
End;


Begin
  With DropInfo Do
     Begin
          Access := 0;
          Alias := '';
          ComNum := 0;
          ComType := 0;
          Emulation := etANSI;
          MaxTime := 3600;
          Node := 0;
          RealName := '';
          RecPos := 0;
     End;
End.
