{
   ====================================================================
   xLib - xJAM                                                     xqtr
   ====================================================================
   This file is part of xlib for FreePascal
    
   https://github.com/xqtr/xlib
   
   This unit is based on code from MysticBBS 1.10 source code and also
   the MK Source for Msg Access v1.06 - Mark May's.
   
   For contact look at Another Droid BBS [andr01d.zapto.org:9999],
   FSXNet and ArakNet.
   
   --------------------------------------------------------------------
   
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

Unit xJAM;
{$Mode objfpc}
{$warnings off}
{$packrecords default}

Interface

Uses SysUtils,Classes,xstrings;

Const
  JamIdxBufSize = 200;
  JamSubBufSize = 4000;
  JamTxtBufSize = 4000;
  TxtSubBufSize = 2000;
  
  Const
  CRC_32_TAB: Array[0..255] of LongInt = (
    $00000000, $77073096, $ee0e612c, $990951ba, $076dc419, $706af48f, $e963a535, $9e6495a3,
    $0edb8832, $79dcb8a4, $e0d5e91e, $97d2d988, $09b64c2b, $7eb17cbd, $e7b82d07, $90bf1d91,
    $1db71064, $6ab020f2, $f3b97148, $84be41de, $1adad47d, $6ddde4eb, $f4d4b551, $83d385c7,
    $136c9856, $646ba8c0, $fd62f97a, $8a65c9ec, $14015c4f, $63066cd9, $fa0f3d63, $8d080df5,
    $3b6e20c8, $4c69105e, $d56041e4, $a2677172, $3c03e4d1, $4b04d447, $d20d85fd, $a50ab56b,
    $35b5a8fa, $42b2986c, $dbbbc9d6, $acbcf940, $32d86ce3, $45df5c75, $dcd60dcf, $abd13d59,
    $26d930ac, $51de003a, $c8d75180, $bfd06116, $21b4f4b5, $56b3c423, $cfba9599, $b8bda50f,
    $2802b89e, $5f058808, $c60cd9b2, $b10be924, $2f6f7c87, $58684c11, $c1611dab, $b6662d3d,
    $76dc4190, $01db7106, $98d220bc, $efd5102a, $71b18589, $06b6b51f, $9fbfe4a5, $e8b8d433,
    $7807c9a2, $0f00f934, $9609a88e, $e10e9818, $7f6a0dbb, $086d3d2d, $91646c97, $e6635c01,
    $6b6b51f4, $1c6c6162, $856530d8, $f262004e, $6c0695ed, $1b01a57b, $8208f4c1, $f50fc457,
    $65b0d9c6, $12b7e950, $8bbeb8ea, $fcb9887c, $62dd1ddf, $15da2d49, $8cd37cf3, $fbd44c65,
    $4db26158, $3ab551ce, $a3bc0074, $d4bb30e2, $4adfa541, $3dd895d7, $a4d1c46d, $d3d6f4fb,
    $4369e96a, $346ed9fc, $ad678846, $da60b8d0, $44042d73, $33031de5, $aa0a4c5f, $dd0d7cc9,
    $5005713c, $270241aa, $be0b1010, $c90c2086, $5768b525, $206f85b3, $b966d409, $ce61e49f,
    $5edef90e, $29d9c998, $b0d09822, $c7d7a8b4, $59b33d17, $2eb40d81, $b7bd5c3b, $c0ba6cad,
    $edb88320, $9abfb3b6, $03b6e20c, $74b1d29a, $ead54739, $9dd277af, $04db2615, $73dc1683,
    $e3630b12, $94643b84, $0d6d6a3e, $7a6a5aa8, $e40ecf0b, $9309ff9d, $0a00ae27, $7d079eb1,
    $f00f9344, $8708a3d2, $1e01f268, $6906c2fe, $f762575d, $806567cb, $196c3671, $6e6b06e7,
    $fed41b76, $89d32be0, $10da7a5a, $67dd4acc, $f9b9df6f, $8ebeeff9, $17b7be43, $60b08ed5,
    $d6d6a3e8, $a1d1937e, $38d8c2c4, $4fdff252, $d1bb67f1, $a6bc5767, $3fb506dd, $48b2364b,
    $d80d2bda, $af0a1b4c, $36034af6, $41047a60, $df60efc3, $a867df55, $316e8eef, $4669be79,
    $cb61b38c, $bc66831a, $256fd2a0, $5268e236, $cc0c7795, $bb0b4703, $220216b9, $5505262f,
    $c5ba3bbe, $b2bd0b28, $2bb45a92, $5cb36a04, $c2d7ffa7, $b5d0cf31, $2cd99e8b, $5bdeae1d,
    $9b64c2b0, $ec63f226, $756aa39c, $026d930a, $9c0906a9, $eb0e363f, $72076785, $05005713,
    $95bf4a82, $e2b87a14, $7bb12bae, $0cb61b38, $92d28e9b, $e5d5be0d, $7cdcefb7, $0bdbdf21,
    $86d3d2d4, $f1d4e242, $68ddb3f8, $1fda836e, $81be16cd, $f6b9265b, $6fb077e1, $18b74777,
    $88085ae6, $ff0f6a70, $66063bca, $11010b5c, $8f659eff, $f862ae69, $616bffd3, $166ccf45,
    $a00ae278, $d70dd2ee, $4e048354, $3903b3c2, $a7672661, $d06016f7, $4969474d, $3e6e77db,
    $aed16a4a, $d9d65adc, $40df0b66, $37d83bf0, $a9bcae53, $debb9ec5, $47b2cf7f, $30b5ffe9,
    $bdbdf21c, $cabac28a, $53b39330, $24b4a3a6, $bad03605, $cdd70693, $54de5729, $23d967bf,
    $b3667a2e, $c4614ab8, $5d681b02, $2a6f2b94, $b40bbe37, $c30c8ea1, $5a05df1b, $2d02ef8d
  );

  Jam_Local =        $00000001;
  Jam_InTransit =    $00000002;
  Jam_Priv =         $00000004;
  Jam_Rcvd =         $00000008;
  Jam_Sent =         $00000010;
  Jam_KillSent =     $00000020;
  Jam_AchvSent =     $00000040;
  Jam_Hold =         $00000080;
  Jam_Crash =        $00000100;
  Jam_Imm =          $00000200;
  Jam_Direct =       $00000400;
  Jam_Gate =         $00000800;
  Jam_Freq =         $00001000;
  Jam_FAttch =       $00002000;
  Jam_TruncFile =    $00004000;
  Jam_KillFile =     $00008000;
  Jam_RcptReq =      $00010000;
  Jam_ConfmReq =     $00020000;
  Jam_Orphan =       $00040000;
  Jam_Encrypt =      $00080000;
  Jam_Compress =     $00100000;
  Jam_Escaped =      $00200000;
  Jam_FPU =          $00400000;
  Jam_TypeLocal =    $00800000;
  Jam_TypeEcho =     $01000000;
  Jam_TypeNet =      $02000000;
  Jam_NoDisp =       $20000000;
  Jam_Locked =       $40000000;
  Jam_Deleted =      $80000000;
  
Type  
  
  RecFileList = Record
    FileName  : String[70];
    Size      : LongInt;
    DateTime  : LongInt;
    Uploader  : String[30];
    Flags     : Byte;
    Downloads : LongInt;
    Rating    : Byte;
    DescPtr   : LongInt;
    DescLines : Byte;
  End;
  
  RecEchoMailAddr = Record
    Zone,
    Net,
    Node,
    Point : Word;
  End;

  MsgMailType = (mmtNormal, mmtEchoMail, mmtNetMail);

  JamHdrType = Record
    Signature  : Array[1..4] of Char;
    Created    : LongInt;
    ModCounter : LongInt;
    ActiveMsgs : LongInt;
    PwdCRC     : LongInt;
    BaseMsgNum : LongInt;
    Extra      : Array[1..1000] of Char;
  End;

  JamMsgHdrType = Record
    Signature   : Array[1..4] of Char;
    Rev         : Word;
    Resvd       : Word;
    SubFieldLen : LongInt;
    TimesRead   : LongInt;
    MsgIdCrc    : LongInt;
    ReplyCrc    : LongInt;
    ReplyTo     : LongInt;
    ReplyFirst  : LongInt;
    ReplyNext   : LongInt;
    DateWritten : LongInt;
    DateRcvd    : LongInt;
    DateArrived : LongInt;
    MsgNum      : LongInt;
    Attr1       : Cardinal;
    Attr2       : LongInt;
    TextOfs     : LongInt;
    TextLen     : LongInt;
    PwdCrc      : LongInt;
    Cost        : LongInt;
  End;
    
  SubFieldType = Record
    LoID    : Word;
    HiID    : Word;
    DataLen : LongInt;
  End;

  JamIdxType = Record
    MsgToCrc : LongInt;
    HdrLoc   : LongInt;
  End;

  JamLastType = Record
    NameCrc  : LongInt;
    UserNum  : LongInt;
    LastRead : LongInt;
    HighRead : LongInt;
  End;
  
  TJamBase = Class
    Filename    : String;
    HeaderFile  : TFileStream;
    IndexFile   : TFileStream;
    TxtFile     : TFileStream;
    OldMod      : LongInt;
    fSearch     : String;
    fSearchPos  : LongInt;
    
    Header      : JamHdrType;
    MsgHeader   : JamMsgHdrType;
    MsgHdrPos   : LongInt;
    
    MsgCount    : LongInt;
    MsgText     : TStringList;
    MsgNo       : LongInt;
    
    Dest        : RecEchoMailAddr;
    Orig        : RecEchoMailAddr;
    From        : String[65];
    Receipient  : String[65];
    Subject     : String[100];
    MsgDate     : String[8];
    MsgTime     : String[5];
    
    SubMSGID    : String[100];
    SubReplyID  : String[100];
    SubPID      : String[40];
    SubTrace    : String[100];
    EmbinDat    : Boolean;
    SubKludge   : String[255];
    SeenBy      : String;
    Path2d      : String;
    ZUTCINFO    : String;
    SubFlags    : String;
    
    Constructor Create;
    Destructor  Destroy; Override;
    
    Function Init:Boolean;
    
    Function  LoadMsg(N:LongInt):Boolean;
    Function  FirstMsg:Boolean;
    Function  LastMsg:Boolean;
    Function  GetMsgCount:LongInt;
    Function  GetMsgText(N:LongInt):Boolean;
    Function  NextMsg:Boolean;
    Function  PrevMsg:Boolean;
    Function  SaveHeader:Boolean;
    
    Function  CreateMsgBase (Path,Name:String; MaxMsg: Word; MaxDays: Word): SmallInt;
    Procedure SetAttr1 (Mask: Cardinal; St: Boolean);
    Function  GetHighMsgNum: LongInt;
    Function  BaseChanged:Boolean;
    Function  ReReadHeader:Boolean;
    
    Function  SearchFirst(Sub:String; CS:Boolean):LongInt;
    Function  SearchNext(Sub:String; CS:Boolean):LongInt;
    Function  MsgAtTextPos(P:LongInt):LongInt;
    
    Function  GetLastReadUNum(U:LongInt):LongInt;
    Function  GetLastReadUCrc(UCRC:LongInt):LongInt;
    Function  GetLastRead:LongInt;
    Function  DeleteUser(U:LongInt):Boolean;
    Function  FindLastRead(UCRC:LongInt; Var L:JamLastType):Boolean;
    Function  SetLastRead(User,LastRead:LongInt):Boolean;
    
    Function  NewMsg(MFrom,MTo,MSubj:String; FAddr,TAddr:RecEchoMailAddr ;FName:String):SmallInt;
    Function  DeleteMsg(N:LongInt; PurgeText:Boolean):Boolean;
    
    Procedure UpdateModCounter;
    
    Function  IsLocal        : Boolean; 
    Function  IsCrash        : Boolean; 
    Function  IsKillSent     : Boolean; 
    Function  IsSent         : Boolean; 
    Function  IsFAttach      : Boolean; 
    Function  IsFileReq      : Boolean; 
    Function  IsRcvd         : Boolean; 
    Function  IsPriv         : Boolean; 
    Function  IsDeleted      : Boolean; 
    Function  IsEncrypted    : Boolean; 
    Function  IsCompressed   : Boolean; 
    Function  IsEscaped      : Boolean; 
    Function  IsLocked       : Boolean;     
  End;  
  
  Function Addr2Str (Addr : RecEchoMailAddr) : String;
  Function Str2Addr (S: String; Var Addr: RecEchoMailAddr) : Boolean;
  Function EchoMailAddrValid(Addr:RecEchoMailAddr): Boolean;
  Function JamStrCrc (St: String): LongInt;
  Function isJamBase(F:String):Boolean;

Implementation

Uses
  xFileIO,
  xDateTime;
  
Function isJamBase(F:String):Boolean;
Var
  head : JamHdrType;
  fp   : File;
Begin
  Result:=False;
  If Not FileExist(F) Then Exit;
  AssignFile(fp,F);
  Reset(fp,1);
  If IOResult <> 0 Then Exit;
  BlockRead(fp,head,SizeOf(head));
  If (Head.Signature[1] = 'J') And
        (Head.Signature[2] = 'A') And
        (Head.Signature[3] = 'M') And
        (Head.Signature[4] = #0) Then Result:=True;  
  CloseFile(fp);
End;  
  
Function Addr2Str (Addr : RecEchoMailAddr) : String;
Var
  Temp : String[20];
Begin
  Temp := Int2Str(Addr.Zone) + ':' + Int2Str(Addr.Net) + '/' +
          Int2Str(Addr.Node);

  If Addr.Point <> 0 Then Temp := Temp + '.' + Int2Str(Addr.Point);

  Result := Temp;
End;

Function Str2Addr (S: String; Var Addr: RecEchoMailAddr) : Boolean;
Var
  A     : Byte;
  B     : Byte;
  C     : Byte;
  D     : Byte;
  Point : Boolean;
Begin
  Result := False;
  Point  := True;

  D := Pos('@', S);
  A := Pos(':', S);
  B := Pos('/', S);
  C := Pos('.', S);

  If (A = 0) or (B <= A) Then Exit;

  If D > 0 Then
    Delete (S, D, 255);

  If C = 0 Then Begin
    Point      := False;
    C          := Length(S) + 1;
    Addr.Point := 0;
  End;

  Addr.Zone := Str2Int(Copy(S, 1, A - 1));
  Addr.Net  := Str2Int(Copy(S, A + 1, B - 1 - A));
  Addr.Node := Str2Int(Copy(S, B + 1, C - 1 - B));

  If Point Then Addr.Point := Str2Int(Copy(S, C + 1, Length(S)));

  Result := True;
End;

Function EchoMailAddrValid(Addr:RecEchoMailAddr): Boolean;
Begin
If ((Addr.Zone <> 0) or (Addr.Net <> 0) or
        (Addr.Node <> 0) or (Addr.Point <> 0)) Then
        Result:=True Else Result:=False;
End;        

Function Crc32 (Octet: Byte; CRC: LongInt) : LongInt;
Begin
  Crc32 := LongInt(CRC_32_TAB[Byte(CRC xor LongInt(Octet))] xor ((CRC shr 8) and $00FFFFFF));
End;

Function JamStrCrc (St: String): LongInt;
Var
  i: Word;
  crc: LongInt;
Begin
  Crc := -1;

  For i := 1 to Length(St) Do
    Crc := Crc32(Ord(LoCase(St[i])), Crc);

  JamStrCrc := Crc;
End;

Constructor TJamBase.Create;
Begin
  Inherited Create;
  MsgText := TStringList.Create;
End;

Function TJamBase.ReReadHeader:Boolean;
Begin
  Result := False;
  HeaderFile.Seek(0,0);
  HeaderFile.ReadBuffer(Header,SizeOf(Header));
  OldMod := Header.ModCounter;
  Result:=True;
End;

Function TJamBase.Init:Boolean;
Begin
  Result := False;
  If Filename='' Then Exit;
  Try
    HeaderFile := TFileStream.Create(Filename+'.jhr',fmOpenReadWrite or fmShareDenyNone);
    HeaderFile.Seek(0,0);
    IndexFile := TFileStream.Create(Filename+'.jdx',fmOpenReadWrite or fmShareDenyNone);
    IndexFile.Seek(0,0);
    TxtFile := TFileStream.Create(Filename+'.jdt',fmOpenReadWrite or fmShareDenyNone);
    TxtFile.Seek(0,0);
  Except
    System.Writeln;
    System.Writeln('Error on Init');
    Exit;
  End;
  HeaderFile.Read(Header,SizeOf(Header));
  If (Header.Signature[1] = 'J') And
      (Header.Signature[2] = 'A') And
      (Header.Signature[3] = 'M') And
      (Header.Signature[4] = #0) Then Begin
    MsgCount:=GetMsgCount;
    Result:=True;
  End;
  OldMod := Header.ModCounter;
End;

Destructor  TJamBase.Destroy;
Begin
  HeaderFile.Free;
  IndexFile.Free;
  TxtFile.Free;
  MsgText.Free;
  Inherited Destroy;
End;

Function TJamBase.CreateMsgBase (Path,Name:String; MaxMsg: Word; MaxDays: Word): SmallInt;
Var
  tf  : File Of Byte;
  hdr : JamHdrType;
  idx : JamIdxType;
Begin
  Result:=-100;
  If FileExist(AddSlash(path)+Name+'.jhr') Then Result:=-1;
  
  Try
    AssignFile(tf,AddSlash(path)+Name+'.jhr');
    Rewrite(tf,1);
  Except
    Result:=-99;
    Exit;
  End;
  
  FillChar(hdr, SizeOf(hdr), #0);
  hdr.Signature[1] :=  'J';
  hdr.Signature[2] :=  'A';
  hdr.Signature[3] :=  'M';
  hdr.BaseMsgNum   := 1;
  hdr.Created      := DateDos2Unix(CurDateDos);
  hdr.PwdCrc       := -1;
  BlockWrite(tf,hdr,Sizeof(hdr));
  CloseFile(tf);
  
  Try
    AssignFile(tf,AddSlash(path)+Name+'.jdx');
    Rewrite(tf,1);
    Seek(tf,0);
    CloseFile(tf);
  Except
    Result := -98;
    Exit;
  End;
  
  Try
  AssignFile(tf,AddSlash(path)+Name+'.jdt');
  Rewrite(tf,1);
  Seek(tf,0);
  CloseFile(tf);
  Except
    Result := -97;
    Exit;
  End;
  
  Try
  AssignFile(tf,AddSlash(path)+Name+'.jlr');
  Rewrite(tf,1);
  Seek(tf,0);
  CloseFile(tf);
  Except
    Result := -96;
    Exit;
  End;
 
  Result:=0;
End;

Function TJamBase.GetHighMsgNum: LongInt;
Var
  idx : JamIdxType;
Begin
  Result := Header.BaseMsgNum + (IndexFile.Size Div SizeOf(idx)) - 1;
  //FileSize(JM^.IdxFile) - 1;
End;

Function TJamBase.GetMsgCount:LongInt;
Var
  idx : JamIdxType;
Begin
  result:=indexfile.size div sizeof(idx);
End;

Function TJamBase.LoadMsg(N:LongInt):Boolean;
Var
  i   : LongInt;
  idx : JamIdxType;
  SubLength : LongInt;
  SubEnd    : LongInt;
  SubF      : SubFieldType;
  Data      : String = '';
Begin
  Result:=False;
  If N>MsgCount Then Exit;
  Subject:='';
  From:='';
  Receipient:='';
  
  IndexFile.Seek((N-1) * Sizeof(JamIdxType),0);
  IndexFile.Read(idx,Sizeof(JamIdxType));
  
  If Idx.HdrLoc = -1 Then Exit;
  MsgHdrPos := Idx.HdrLoc;
  HeaderFile.Seek(Idx.HdrLoc,0);
  FillChar(MsgHeader,Sizeof(MsgHeader),#0);
  HeaderFile.Read(MsgHeader,SizeOf(MsgHeader));
  
  //SubFields
  SubLength := MsgHeader.SubFieldLen;
  If SubLength<>0 Then Begin
    SubEnd := HeaderFile.Position+SubLength;
    While HeaderFile.Position < SubEnd Do Begin
      SetLength(Data,0);
      //Data:='';
      Fillbyte(SubF,SizeOf(SubF),0);
      HeaderFile.Read(SubF,SizeOf(SubF));
      SetLength(Data,SubF.DataLen);
      HeaderFile.Read(Data[1],SubF.DataLen);
      //Writeln('LoID:'+Int2Str(SubF.LoID));
      //Writeln('Length:'+Int2Str(SubF.DataLen));
      Case SubF.LoID Of
        0:  Begin {Orig}
              FillChar(Orig, SizeOf(Orig), #0);
              Move(Data, Orig, SubF.DataLen);
              //Str2Addr(Data,Orig);
            End;
        1:  Begin {Dest}
              FillChar(Dest, SizeOf(Dest), #0);
              Move(Data, Dest, SubF.DataLen);
              //Str2Addr(Data,Dest);
            End;
        2:  Begin {From}
              SetLength(From,SubF.DataLen);
              Move(Data, From, SubF.DataLen);
              From:=Data;
            End;
        3:  Begin
              Receipient:=Data;
            End;
        6:  Begin
              Subject:=Data;
            End;
        9:  Begin
              If IsFAttach Then Begin
                Subject:=Data;
              End;
            End;
        11: Begin
              If IsFileReq Then Begin
                Subject:=Data;
              End;
            End;
        1000:
            Begin
              EmbinDat:=True;
            End;
        2000:
            Begin
              SubKludge:=Data;
            End;
        2001:
            Begin
              SeenBy:=Data;
            End;
        2002:
            Begin
              Path2d:=Data;
            End;
        2003:
            Begin
              SubFlags:=Data;
            End;
        2004:
          Begin
            ZUTCINFO:=Data;
          End;
      End;
    End;
  End;
  MsgNo := N;
  Result:=True;
End;

Function TJamBase.GetMsgText(N:LongInt):Boolean;
Var
  C   : Char;
  r,i : Integer;
  L   : String;
Begin
  Result:=False;
  If LoadMsg(N)= False Then Exit;
  l:='';
  TxtFile.Seek(MsgHeader.TextOfs,0);
  MsgText.Clear;
  c:=#0;
  While (TxtFile.Position < MsgHeader.TextOfs+MsgHeader.TextLen) Do Begin
    TxtFile.Read(C,1);
    If C<>#13 Then L:=L+C
        Else Begin
          MsgText.Add(L);
          L:='';
        End;
  End;
  MsgNo := N;
  Result:=True;
End;

Function TJamBase.FirstMsg:Boolean;
Begin
  Result:=False;
  If Not LoadMsg(1) Then Exit;
  MsgNo := 0;
  Result:=True;
End;

Function TJamBase.LastMsg:Boolean;
Begin
  Result:=False;
  If Not LoadMsg(Header.ActiveMsgs) Then Exit;
  MsgNo := Header.ActiveMsgs;
  Result:=True;
End;

Function TJamBase.NextMsg:Boolean;
Begin
  Result:=False;
  If MsgNo+1 <= Header.ActiveMsgs Then MsgNo := MsgNo + 1;
  If Not LoadMsg(MsgNo) Then Exit;
  Result:=True;
End;

Function  TJamBase.PrevMsg:Boolean;
Begin
  Result:=False;
  If MsgNo-1 >= 1 Then MsgNo := MsgNo - 1;
  If Not LoadMsg(MsgNo) Then Exit;
  Result:=True;
End;

Procedure TJamBase.SetAttr1 (Mask: Cardinal; St: Boolean);
Begin
If St Then
  MsgHeader.Attr1 := MsgHeader.Attr1 Or Mask
Else
  MsgHeader.Attr1 := MsgHeader.Attr1 And (Not Mask);
End;

Function TJamBase.IsLocal        : Boolean; 
Begin
  Result := (MsgHeader.Attr1 and Jam_Local) <> 0;
End;

Function TJamBase.IsCrash        : Boolean;
Begin
  Result := (MsgHeader.Attr1 and Jam_Crash) <> 0;
End;

Function TJamBase.IsKillSent     : Boolean; 
Begin
  Result := (MsgHeader.Attr1 and Jam_KillSent) <> 0;
End;

Function TJamBase.IsSent         : Boolean; 
Begin
  Result := (MsgHeader.Attr1 and Jam_Sent) <> 0;
End;

Function TJamBase.IsFAttach      : Boolean; 
Begin
  Result := (MsgHeader.Attr1 and Jam_FAttch) <> 0;
End;

Function TJamBase.IsFileReq      : Boolean; 
Begin
  Result := (MsgHeader.Attr1 and Jam_FReq) <> 0;
End;

Function TJamBase.IsRcvd         : Boolean; 
Begin
  Result := (MsgHeader.Attr1 and Jam_Rcvd) <> 0;
End;

Function TJamBase.IsPriv         : Boolean; 
Begin
  Result := (MsgHeader.Attr1 and Jam_Priv) <> 0;
End;

Function TJamBase.IsDeleted      : Boolean; 
Begin
  Result := (MsgHeader.Attr1 and Jam_Deleted) <> 0;
End;

Function TJamBase.IsEncrypted    : Boolean; 
Begin
  Result := (MsgHeader.Attr1 and Jam_Encrypt) <> 0;
End;

Function TJamBase.IsCompressed   : Boolean; 
Begin
  Result := (MsgHeader.Attr1 and Jam_Compress) <> 0;
End;

Function TJamBase.IsEscaped         : Boolean; 
Begin
  Result := (MsgHeader.Attr1 and Jam_Escaped) <> 0;
End;

Function TJamBase.IsLocked         : Boolean; 
Begin
  Result := (MsgHeader.Attr1 and Jam_Locked) <> 0;
End;

Function TJamBase.SaveHeader:Boolean;
Begin
  Result := False;
  UpdateModCounter;
  
  HeaderFile.Seek(0,0);
  Try
    HeaderFile.Write(Header,Sizeof(Header));
  Except
    Exit;
  End;
  
  Result:=True;
End;

Function TJamBase.NewMsg(MFrom,MTo,MSubj:String; FAddr,TAddr:RecEchoMailAddr ;FName:String):SmallInt;
Var
  hdr : JamMsgHdrType;
  idx : JamIdxType;
  f   : file of byte;
  sf0  : SubFieldType;
  sf1  : SubFieldType;
  sf2  : SubFieldType;
  sf3  : SubFieldType;
  sf6  : SubFieldType;
  Buff : Byte;
  s    : String;
Begin
  Result:=-1;
  if Not FileExist(Fname) Then Exit;
  Result:=-2;
  If Mfrom = '' Then Exit;
  If MTo = '' Then Exit;
  If MSubj = '' Then Exit;
  
  If BaseChanged Then Begin
    Result:=-4;
    ReReadHeader;
  End;
  Result:=-3;
  
  FillByte(hdr,Sizeof(hdr),0);
  hdr.Signature[1] := 'J';{Set signature}
  hdr.Signature[2] := 'A';
  hdr.Signature[3] := 'M';
  hdr.Signature[4] := #0;
  hdr.rev :=1;
  hdr.MsgNum := Header.ActiveMsgs+1;
  hdr.DateArrived := DateDos2Unix(CurDateDos); {Get date processed}
  hdr.DateWritten := DateDos2Unix(CurDateDos);
  
  SetAttr1(Jam_TypeLocal, True);
  
  hdr.Attr1 := hdr.Attr1 Or Jam_TypeLocal;
  
  
  AssignFile(f,Fname);
  Try
    Reset(f,1);
  Except
    Result := -97;
    Exit;
  End;
  
  txtfile.seek(0,soend);
  hdr.TextOfs := TxtFile.Size;
  hdr.TextLen := FileSize(f)+1;
  
  //FillByte(sf2,Sizeof(sf2),0);
  sf2.LoId:=2;
  sf2.HiId:=0;
  If Length(MFrom)>100 THen MFrom:=Copy(MFrom,1,100);
  //sf2.Data:=MFrom;
  sf2.DataLen:=Length(MFrom);
  //writeln(int2str(sf2.datalen));
  hdr.SubFieldLen:=hdr.SubFieldLen+8+sf2.DataLen;
  
  //FillByte(sf3,Sizeof(sf3),0);
  sf3.LoId:=3;
  sf3.HiId:=0;
  If Length(MTo)>100 THen MTo:=Copy(MTo,1,100);
  //sf3.Data:=MTo;
  sf3.DataLen:=Length(Mto);
  
  hdr.SubFieldLen:=hdr.SubFieldLen+8+sf3.DataLen;
  
  //FillByte(sf0,Sizeof(sf0),0);
  If EchoMailAddrValid(Faddr) Then Begin
    sf0.LoId:=0;
    sf0.HiId:=0;
    s:=Addr2Str(Faddr);
    //sf0.Data:=s;
    sf0.DataLen:=Length(s);
    hdr.SubFieldLen:=hdr.SubFieldLen+8+sf0.DataLen;
  End;
  
  //FillByte(sf1,Sizeof(sf1),0);
  If EchoMailAddrValid(Taddr) Then Begin
    sf1.LoId:=1;
    sf1.HiId:=0;
    s:=Addr2Str(Taddr);
    //sf1.Data:=s;
    sf1.DataLen:=Length(S);
    hdr.SubFieldLen:=hdr.SubFieldLen+8+sf1.DataLen;
  End;
  
  //FillByte(sf6,Sizeof(sf6),0);
  sf6.LoId:=6;
  sf6.HiId:=0;
  //sf6.Data:=MSubj;
  If Length(MSubj)>100 THen MSubj:=Copy(MSubj,1,100);
  sf6.DataLen:=Length(msubj)+1;
  
  hdr.SubFieldLen:=hdr.SubFieldLen+8+sf6.DataLen;
  
  HeaderFile.Seek(0,soEnd);
  
  idx.MsgToCrc := Crc32(8,JamStrCrc(MTo));
  idx.HdrLoc   := HeaderFile.Size;
  
  IndexFile.Seek(IndexFile.Size,0);
  IndexFile.Write(idx,SizeOf(Idx));
  
  
  HeaderFile.WriteBuffer(hdr,SizeOf(hdr));
  If EchoMailAddrValid(Faddr) Then Begin
    HeaderFile.WriteBuffer(Sf0,sizeof(sf0));
    s:=Addr2Str(Faddr);
    HeaderFile.WriteBuffer(s[1],sf0.DataLen);
  End;
  If EchoMailAddrValid(Taddr) Then Begin
    HeaderFile.WriteBuffer(Sf1,sizeof(sf1));
    s:=Addr2Str(Taddr);
    HeaderFile.WriteBuffer(s[1],sf1.DataLen);
  End;
  {HeaderFile.WriteBuffer(Sf2,8+sf2.DataLen);
  HeaderFile.WriteBuffer(MFrom,sf2.DataLen);
  HeaderFile.WriteBuffer(Sf3,8+sf3.DataLen);
  HeaderFile.WriteBuffer(MTo,sf3.DataLen);
  HeaderFile.WriteBuffer(Sf6,8+sf6.DataLen);
  HeaderFile.WriteBuffer(MSubj,sf6.DataLen);}
  HeaderFile.WriteBuffer(Sf2,sizeof(sf2));
  HeaderFile.WriteBuffer(MFrom[1],sf2.DataLen);
  HeaderFile.WriteBuffer(Sf3,sizeof(sf3));
  HeaderFile.WriteBuffer(MTo[1],sf3.DataLen);
  HeaderFile.WriteBuffer(Sf6,sizeof(sf6));
  HeaderFile.WriteBuffer(MSubj[1],sf6.DataLen);
  
  Try
    TxtFile.Seek(0,SoEnd);
    While Not EOF(F) Do begin
      BlockRead(f,buff,1);
      TxtFile.WriteBuffer(buff,1);
    End;
    buff:=13;
    TxtFile.WriteBuffer(buff,1);
  Except
    Result:=-40;
    CloseFile(f);
    Exit;
  End;
  
  CloseFile(f);
  ReReadHeader;
  Header.ActiveMsgs := Header.ActiveMsgs + 1;
  If not SaveHeader Then Begin
    Result:=-10;
    Exit;
  End;
  ReReadHeader;
  Result:=0;
End;

Function TJamBase.DeleteMsg(N:LongInt; PurgeText:Boolean):Boolean;
Var
  r : LongInt;
  C : Char = 'Q';
Begin
  Result:=False;
  If Not LoadMsg(N) Then Exit;
  
  If BaseChanged Then Begin
    ReReadHeader;
    If Not LoadMsg(N) Then Exit;
  End;
  
  If PurgeText Then Begin
    TxtFile.Seek(MsgHeader.TextOfs,0);
    For r := 1 To MsgHeader.TextLen Do TxtFile.Write(C,1);
  End;
  
  MsgHeader.TextLen:=0;
  SetAttr1(Jam_Deleted, True);
  HeaderFile.Seek(MsgHdrPos,0);
  HeaderFile.WriteBuffer(MsgHeader,SizeOf(MsgHeader));
  
  Header.ActiveMsgs:=Header.ActiveMsgs-1;
  MsgCount:=GetMsgCount;
 
  SaveHeader;
  ReReadHeader;
  
  Result:=True;
End;
  
Procedure TJamBase.UpdateModCounter;
Begin
  Header.ModCounter:=Header.ModCounter+1;
  If Header.ModCounter=$ffffffff then Header.ModCounter:=0;  
End;  

Function TJamBase.BaseChanged:Boolean;
Begin
  Result := Not (OldMod = Header.ModCounter);
End;

Function TJamBase.GetLastReadUNum(U:LongInt):LongInt; 
Var
  r : JamLastType;
  f : TFileStream;
  sz : Int64;
Begin
  Result:=-1;
  Try
    f := TFileStream.Create(Filename+'.jlr',fmOpenRead or fmShareDenyNone);
    f.Seek(0,0);
  Except
    Exit;
  End;
  sz:=F.Size;
  While F.Position < sz Do Begin
    F.Read(r,Sizeof(r));
    If r.UserNum = U Then Begin
      Result:=r.HighRead;
      Break;
    End;
  End;
  f.free;
End;

Function TJamBase.GetLastReadUCrc(UCRC:LongInt):LongInt; 
Var
  r : JamLastType;
  f : TFileStream;
  sz : Int64;
Begin
  Result:=-1;
  Try
    f := TFileStream.Create(Filename+'.jlr',fmOpenRead or fmShareDenyNone);
    f.Seek(0,0);
  Except
    Exit;
  End;
  sz := F.size;
  While F.Position < sz Do Begin
    F.Read(r,Sizeof(r));
    If r.NameCrc = UCRC Then Begin
      Result:=r.HighRead;
      Break;
    End;
  End;
  f.free;
End;

Function TJamBase.GetLastRead:LongInt;
Var
  f   : TFileStream;
  lr  : LongInt;
  sz  : Int64;
  L   : JamLastType;
Begin
  Result := -1;
  Try
    f := TFileStream.Create(Filename+'.jlr',fmOpenRead or fmShareDenyNone);
    f.Seek(0,0);
  Except
    Exit;
  End;
  sz := F.size;
  lr:=-1;
  While F.Position < sz Do Begin
    F.Read(L,Sizeof(L));
    if L.HighRead>lr Then lr:=L.HighRead;
  End;
  f.free;
  Result:=lr;
End;

Function TJamBase.FindLastRead(UCRC:LongInt; Var L:JamLastType):Boolean;
Var
  f : TFileStream;
  sz : Int64;
Begin
  Result:=False;
  Try
    f := TFileStream.Create(Filename+'.jlr',fmOpenRead or fmShareDenyNone);
    f.Seek(0,0);
  Except
    Exit;
  End;
  sz := F.size;
  While F.Position < sz Do Begin
    F.Read(L,Sizeof(L));
    If L.NameCrc = UCRC Then Begin
      Result := True;
      Break;
    End;
  End;
  f.free;
End;

Function TJamBase.DeleteUser(U:LongInt):Boolean;
Var
  r : JamLastType;
  f : TFileStream;
  i : LongInt;
  sz : Int64;
Begin
  Try
    f := TFileStream.Create(Filename+'.jlr',fmOpenReadWrite or fmShareDenyNone);
    f.Seek(0,0);
  Except
    Exit;
  End;
  i:=0;
  sz := F.size;
  While F.Position < sz Do Begin
    F.Read(r,Sizeof(r));
    If r.UserNum = U Then Begin
      f.Seek(i*Sizeof(r),0);
      r.UserNum := -1;
      r.NameCRC := -1;
      f.Write(r,sizeof(r));
      Break;
    End;
    i:=i+1;
  End;
  f.free;
End;

Function TJamBase.SetLastRead(User,LastRead:LongInt):Boolean;
Var
  r : JamLastType;
  f : TFileStream;
  i : LongInt;
  found : Boolean = false;
  sz : Int64;
Begin
  Result:=False;
  Try
    f := TFileStream.Create(Filename+'.jlr',fmOpenReadWrite or fmShareDenyNone);
  Except
    Exit;
  End;
  f.seek(0,0);
  i:=0;
  sz := F.size;
  While F.Position < sz Do Begin
    F.Read(r,Sizeof(r));
    If r.UserNum = User Then Begin
      f.Seek(i*Sizeof(r),0);
      r.LastRead := LastRead;
      r.HighRead := LastRead;
      f.Write(r,sizeof(r));
      found :=true;
      Break;
    End;
    i:=i+1;
  End;
  
  If Not Found Then Begin
    f.Seek(0,soEnd);
    r.NameCrc  := User;
    r.UserNum  := User;
    r.LastRead := LastRead;
    r.HighRead := LastRead;
    f.Write(r,sizeof(r));
  End;
  f.free;
  Result:=True;
End;

Function TJamBase.MsgAtTextPos(P:LongInt):LongInt;
Var
  idx : JamIdxType;
  M   : JamMsgHdrType;
  N   : LongInt = 1;
Begin
  Result:=-1;
  If P>=TxtFile.Size Then Exit;
  
  While N<=MsgCount Do Begin
    IndexFile.Seek((N-1) * Sizeof(JamIdxType),0);
    IndexFile.Read(idx,Sizeof(JamIdxType));
    
    If Idx.HdrLoc >0 Then Begin
      HeaderFile.Seek(Idx.HdrLoc,0);
      FillChar(M,Sizeof(M),#0);
      HeaderFile.Read(M,SizeOf(M));
      
      If (P>=M.TextOfs) And (P<=M.TextOfs+M.TextLen) Then Begin
        Result:=N;
        Break;
      End;
      
    End;
    N:=N+1;
  End;
End;

Function TJamBase.SearchFirst(Sub:String; CS:Boolean):LongInt;
Begin
  fSearchPos:=0;
  Result := SearchNext(Sub,CS);
End;

Function TJamBase.SearchNext(Sub:String; CS:Boolean):LongInt;
Var
  buf:String = '';
  found : Boolean = False;
  c : Byte = 0;
  d : Integer;
  si : LongInt = 0;
Begin
  TxtFile.Seek(fSearchPos,0);
  si:=fSearchPos;
  If Not CS Then Sub := Upper(Sub);
  found:=false;
  While (txtfile.position < txtfile.size) Do Begin
    TxtFile.Read(c,1);
    buf:=buf+chr(c);
    if (c=10) or (c=13) Then Begin
      If CS Then d:=Pos(Sub,buf) Else d:=Pos(Sub,Upper(buf));
      if d>0 Then Begin
        Result:=si+d-1;
        fSearchPos:=TxtFile.Position;
        Found := True;
        Break;
      End Else Begin
        si := TxtFile.Position;
        buf:='';
        c:=0;
      End;
    End;
  End; 

  If Not Found Then Begin
    Result := -1;
    fSearchPos:=txtfile.size;
  End;
  
End;
  
Begin
End.
