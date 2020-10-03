{
   ====================================================================
   xLib - xTDF                                                     xqtr
   ====================================================================

   This file is part of xlib for FreePascal
    
   https://github.com/xqtr/xlib
    
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

Unit xTDF;
{$MODE objfpc}
{$EXTENDEDSYNTAX ON}
{$PACKRECORDS 1}
Interface
  uses m_types;

type 

  TFontRecord = Record
    Name:String;
    Pos:Integer;
    Typ:Byte;
  End;

  TTDFont = record
    A           : char;  // fixed : 13h
    typo        : Array[1..18] of char;
    B           : char; // fixed : 1Ah
  End;
  
  TFontHeader = Record
    fs          : array[1..4] of byte;  // fixed: 55 AA 00 FF
    NameLen     : byte;
    FontName    : array[1..12] of char;
    nouse       : array[1..4] of byte;  // 00 00 00 00
    FontType    : byte; // Font Type (byte): 00 = Outline, 01 = Block, 
                        // 02 = Color
    Spacing     : byte; // 00 to 40d or 
    BlockSize   : array[1..2]of byte; // Block Size (Word, Little Endian) 
                // Size of character data after main
                // font definition block, including terminating 0 if followed 
                // by another font (last font in collection is not Null 
                // terminated
    CharAddr    : Array[0..187] of byte;
                // 2 bytes (Word, Little Endian) for each character from ASC(33)
                //(“!”) to ASC(126) (“~”) (94 characters total) with the offset
                //(starting at 0) after the font header definition where the 
                // character data star
    
    //At 233 begins the font data
  end;

Type
  TFontChar = Record
    width  : byte;        // 1 <= W <= 30 (1Eh)
    height : byte;        // 1 <= H <= 12 (0Ch)
  end;
  
var
    FontHeader : TFontHeader;
    Font       : TTDFont;
    FontFile   : String;
    Fonts      : Array of TFontRecord;
    Count      : Byte = 0;
    Selected   : Byte = 1;
    FontChar   : TFontChar;
    CharsAvail : String;

Function  IsTDFont(filename:string):Boolean;
Function  Init(f:string):Boolean;
Function  SelectFont(N:Byte):Boolean;
Function  WriteCharBL(x,y:byte;c:char):byte;
Function  WriteCharCL(x,y:byte;c:char):byte;
procedure WriteStr(x,y:byte; s:string);
procedure WriteStrNW(x,y:byte; s:string);
Procedure ExtractFont(F:String);
Procedure MergeFont(F:String);
Function  GetFontType:String;
Procedure WriteHeader;
Procedure ChangeFontName(S:String);
Procedure ChangeSpacing(N:Byte);
Procedure ChangeType(N:Byte); Overload;
Procedure ChangeType(S:String); Overload;
Function  AvailableChars:String;
Function  NewEmptyFont(filename,name:string; ft:byte=2):Boolean;

//Image Functions
Function ImgWriteCharCL(var img: TConsoleImageRec; x,y:byte;c:char):byte;
Function ImgWriteCharBL(var img: TConsoleImageRec; x,y,attr:byte;c:char):byte;
procedure ImgWriteStr(var img: TConsoleImageRec; x,y:byte; s:string);
procedure ImgWriteStrNW(var img: TConsoleImageRec; x,y:byte; s:string);

function le2int(b1,b2:byte):word;

Implementation

Uses
  xcrt,xstrings,sysutils,strutils,ximgcrt;
  
Const
  HeaderOffset = 233;
  
Procedure WriteHeader;
Var
  fpt:File;
Begin
  Assign(fpt,FontFile);
  {$I-} Reset(fpt, 1); {$I+}
  
  If IoResult <> 0 Then Begin
    WriteLn('Error Opening File!');
    Exit;   
  End;
  
  Seek(fpt,Fonts[Selected-1].Pos);
  BlockWrite(fpt,FontHeader,SizeOf(TFontHeader));
  Close(Fpt);
End;

Procedure ChangeFontName(S:String);
Begin
  S:=Copy(S,1,12);
  FontHeader.FontName:=S;
  WriteHeader;
End;

Procedure ChangeSpacing(N:Byte);
Begin
  FontHeader.Spacing:=N;
  WriteHeader;
End;

Procedure ChangeType(N:Byte); Overload;
Begin
  If N>2 Then Exit;
  FontHeader.FontType:=N;
  WriteHeader;
End;

Procedure ChangeType(S:String); Overload;
Var
  T : String;
Begin
  T:=UpperCase(S);
  If T='OUTLINE' Then ChangeType(0) Else
    If T='BLOCK' Then ChangeType(1) Else
      If T='COLOR' Then ChangeType(2);
End;

Function AvailableChars:String;
Var
  i : Byte;
Begin
  Result := '';
  For i:=0 To 93 Do Begin
    If (FontHeader.CharAddr[i*2]=255) And (FontHeader.CharAddr[i*2+1]=255) Then
      Result:=Result+Chr(249) Else Result:=Result + Chr(i+33);
  End;

End;
  
function ByteToHex(InByte:byte):shortstring;
const Digits:array[0..15] of char='0123456789ABCDEF';
begin
 result:=digits[InByte shr 4]+digits[InByte and $0F];
end;    
    
function le2int(b1,b2:byte):word;
var
 l:string;
Begin
  l:=ByteTohex(b1)+bytetohex(b2);
  result:=hex2dec(l);
ENd;    

Function GetFontType:String;
Begin
  Case FontHeader.FontType Of
    0: Result:='Outline';
    1: Result:='Block';
    2: Result:='Color';
  End;
End;

Function  IsTDFont(filename:string):Boolean;
Type 
  tdfv = Record
    A           : char;  // fixed : 13h
    typo        : Array[1..18] of char;
    B           : char; // fixed : 1Ah
    fs          : array[1..4] of byte;  // fixed: 55 AA 00 FF
  End;
Var
  fptr : file;
  TF   : tdfv;
begin
  Result:=False;
    
  Assign(fptr,fontfile);
  {$I-} Reset (fptr, 1); {$I+}
  
  If IOResult <> 0 Then Begin
    WriteLn('Error Opening File!');
    Exit; 
  End;
  BlockRead(fptr,TF,sizeof(TF));
  Close(fptr);
  If (tf.a=Chr($13)) And (tf.typo='TheDraw FONTS file') And (tf.B=Chr($1A)) And (tf.fs[1]=$55) And (tf.fs[2]=$AA) And (tf.fs[3]=$00) And (tf.fs[4]=$FF) 
    Then Result:=True;
end;

Function SelectFont(N:Byte):Boolean;
Var
  fptr : file;
begin
  Result:=False;
    
  Assign(fptr,fontfile);
  {$I-} Reset (fptr, 1); {$I+}
  
  If IOResult <> 0 Then Begin
    WriteLn('Error Opening File!');
    Exit; 
  End;
  Seek(fptr,Fonts[n-1].pos);
  BlockRead(fptr,FontHeader,sizeof(TFontHeader));
  If (FontHeader.fs[1]=$55) and (FontHeader.fs[3]=0) and (FontHeader.fs[4]=$FF) 
    Then Begin
    Result:=True;
    Selected:=N;
  End;
  Close(fptr);
  //FontHeader.Spacing := 1;
end;

Function Init(f:string):Boolean;
Var
  fptr   : file;
  ffont : TTDFont; 
  fheader: TFontHeader;
  s:string;
  i:byte;
  Fpos:integer = 0;
  Cnt:Byte = 0;
begin
  Result:=False;
  if not fileexists(f) then begin
   Exit;
  end;
  fontfile:=f;
  Assign(fptr,f);
  {$I-} Reset (fptr, 1); {$I+}
   
  If IOResult <> 0 Then Begin
    WriteLn('Error Opening File!');
    Exit; 
  End;
  BlockRead(fptr,ffont,sizeof(ffont));
  s:='';
  for i:=1 to 18 do s:=s+ffont.typo[i]; //14603
  if uppercase(s)='THEDRAW FONTS FILE' Then Begin
    seek(fptr,20);
    fpos:=filepos(fptr);
    Font:=ffont;
    while not eof(fptr) do begin 
      BlockRead(fptr,fheader,sizeof(TFontHeader));
      If (fheader.fs[1]=$55) and (fheader.fs[3]=0) and (fheader.fs[4]=$FF) Then Begin
        Cnt:=Cnt+1;
        SetLength(Fonts,Cnt);
        Fonts[Cnt-1].Name:=Copy(fheader.fontname,1,fheader.NameLen);
        Fonts[Cnt-1].Pos:=Filepos(fptr)-sizeof(TFontHeader);
        Fonts[Cnt-1].Typ:=fheader.FontType;
        Selected:=Cnt;
        Count:=Cnt;
        seek(fptr,filepos(fptr)+le2int(fheader.blocksize[2],fheader.blocksize[1]));
      End;
      
    end;
  End;
  Close(fptr);
  SelectFont(Selected);
  CharsAvail:=AvailableChars;
  Result:=True;
End;

procedure printcharaddr(f:Tfontheader);
var
 l:byte;
Begin
  For l:=0 to 187 do write(bytetohex(f.charaddr[l])+' ');
End;

Function WriteCharCL(x,y:byte;c:char):byte;
Var
  fptr : file;
  FChar : TFontChar;
  tbyte : array[1..2] of byte;
  asc:byte;
begin
  
    //If Not ((FontHeader.fs[1]=$55) and (FontHeader.fs[3]=0) and (FontHeader.fs[4]=$FF)) Then Exit;
    if c=' ' then begin
      result:=1;
      exit;
    end;
    asc:=(ord(c)-33)*2;
    assign(fptr,fontfile);
    Reset(fptr,1);
    If IoResult <> 0 Then Begin
      WriteLn('Error Opening File!');
      Exit;   
    End;
       
    if (FontHeader.charaddr[asc+1]<>255) and (FontHeader.charaddr[asc]<>255) Then
      Seek(fptr,Fonts[Selected-1].Pos+213+le2int(FontHeader.charaddr[asc+1],FontHeader.charaddr[asc]))
    Else Begin
      result:=1;
      exit;
    End;

    BlockRead(fptr,FChar,sizeof(Fchar));
    FontChar:=FChar;
    tbyte[1]:=32;
    tbyte[2]:=32;
    GotoXY(x,y);
    while (tbyte[1]<>0) and (not eof(fptr)) do begin
    BlockRead(fptr,tbyte[1],1);
    if tbyte[1]=0 then break;
    if tbyte[1]=13 then begin
      GotoXY(x,WhereY+1);
      if WhereY>25 then break;
    end
     else begin
      BlockRead(fptr,tbyte[2],1);
      SetTextAttr(tbyte[2] mod 16 + tbyte[2] - (tbyte[2] mod 16));
      if WhereX<=79 then Write(chr(tbyte[1]))
    end;
    end ;
    Close(fptr);

    result:=fchar.width;
  
end;

Function WriteCharBL(x,y:byte;c:char):byte;
Var
  fptr : file;
  FChar : TFontChar;
  tbyte : array[1..2] of byte;
  asc:byte;
  r : LongInt;
begin
  
    If Not ((FontHeader.fs[1]=$55) and (FontHeader.fs[3]=0) and (FontHeader.fs[4]=$FF)) Then Exit;
    if c=' ' then begin
      result:=1;
      exit;
    end;
    asc:=(ord(c)-33)*2;
    Assign(fptr,fontfile);
    Reset(fptr,1);
    
    If IOResult <> 0 Then Begin
      WriteLn('Error Opening File!');
      Exit; 
    End;
   
      if (FontHeader.charaddr[asc+1]<>255) and (FontHeader.charaddr[asc]<>255) Then
      Seek(fptr,Fonts[Selected-1].Pos+213+le2int(FontHeader.charaddr[asc+1],FontHeader.charaddr[asc]))
    Else Begin
      result:=1;
      exit;
    End;
      
      
      BlockRead(fptr,FChar,sizeof(Fchar),r);
      FontChar:=FChar;
      tbyte[1]:=32;
      GotoXY(x,y);
      while (tbyte[1]<>0) and (not eof(fptr)) do begin
      BlockRead(fptr,tbyte[1],1,r);
      if tbyte[1]=13 then begin
        GotoXY(x,WhereY+1);
        if WhereY>25 then break;
      end
       else begin
        if WhereX<=79 then Write(chr(tbyte[1]))
      end;
      end ;
      Close(fptr);
   
    result:=fchar.width;


end;

procedure WriteStr(x,y:byte; s:string);
Var
  i:byte;
  sx:byte;
  sy:byte;
begin
  GotoXY(x,y);
  sx:=x;
  sy:=y;
  case FontHeader.fonttype of
  1: begin  
      for i:=1 to length(s) do begin
      sx:=sx+writecharBL(sx,sy,s[i])+FontHeader.spacing;
      if SX+X>79 Then Begin
        SX:=1;
        SY:=Sy+FontChar.Height+1;
        GotoXY(Sx,Sy);
      End;
      end;
   end;
  2: begin  
      for i:=1 to length(s) do begin
      sx:=sx+writecharCL(sx,sy,s[i])+FontHeader.spacing;
      if SX+X>79 Then Begin
        SX:=1;
        SY:=Sy+FontChar.Height+1;
        GotoXY(Sx,Sy);
      End;
      end;
   end;
   end;
end;

procedure WriteStrNW(x,y:byte; s:string);
Var
  i:byte;
  sx:byte;
  sy:byte;
begin
  GotoXY(x,y);
  sx:=x;
  sy:=y;
  case FontHeader.fonttype of
  1: begin  
      for i:=1 to length(s) do begin
      sx:=sx+writecharBL(sx,sy,s[i])+FontHeader.spacing;
      end;
   end;
  2: begin  
      for i:=1 to length(s) do begin
      sx:=sx+writecharCL(sx,sy,s[i])+FontHeader.spacing;
      end;
   end;
   end;
end;    

Procedure   ExtractFont(F:String);
Var
  fpt:File;
  buf:Byte;
  org:File;
  p  :Integer = 0;
  BS : Integer;
Begin

  Assign(fpt,F);
  {$I-} ReWrite(fpt, 1); {$I+}
  
  If IoResult <> 0 Then Begin
    WriteLn('Error Opening File!');
    Exit;   
  End;
  
  BlockWrite(fpt,Font,Sizeof(TTDFont));
  BlockWrite(fpt,FontHeader,Sizeof(TFontHeader));
  
  Assign(org,FontFile);
  {$I-} Reset(org,1);{$I+}
  
  If IoResult <> 0 Then Begin
    WriteLn('Error Opening File!');
    Close(fpt);
    Exit;   
  End;
  
  Seek(org,Fonts[Selected-1].Pos+213);
  
  BS := le2int(FontHeader.blocksize[2],FontHeader.blocksize[1]);
  While (p < BS) And (Not EOF(org)) Do Begin
    BlockRead(org,buf,1);
    BlockWrite(fpt,buf,1);
    p:=p+1;
  End;

  Close(fpt);
  Close(org);
End;

Procedure MergeFont(F:String);
Var
  fpt:File;
  buf:Byte;
  org:File;
  p  :Integer = 0;
  BS : Integer;
Begin

  Assign(fpt,F);
  {$I-} Reset(fpt, 1); {$I+}
  
  If IoResult <> 0 Then Begin
    WriteLn('Error Opening File!');
    Exit;   
  End;
  
  //BlockWrite(fpt,Font,Sizeof(TTDFont));
  //BlockWrite(fpt,FontHeader,Sizeof(TFontHeader));
  
  Assign(org,FontFile);
  {$I-} Reset(org,1);{$I+}
  
  If IoResult <> 0 Then Begin
    WriteLn('Error Opening File!');
    Close(fpt);
    Exit;   
  End;
  
  Seek(org,FileSize(org));
  Seek(fpt,20);
  
  While Not EOF(fpt) Do Begin
    BlockRead(fpt,buf,1);
    BlockWrite(org,buf,1);
  End;

  Close(fpt);
  Close(org);
End;

//Image Functions
Function ImgWriteCharCL(var img: TConsoleImageRec; x,y:byte;c:char):byte;
Var
  fptr : file;
  FChar : TFontChar;
  tbyte : array[1..2] of byte;
  asc:byte;
  attr:byte;
  ox:byte=1;
begin
 
    If Not ((FontHeader.fs[1]=$55) and (FontHeader.fs[3]=0) and (FontHeader.fs[4]=$FF)) Then Exit;
    if c=' ' then begin
      result:=1;
      exit;
    end;
    asc:=(ord(c)-33)*2;
    assign(fptr,fontfile);
    Reset(fptr,1);
    If IoResult <> 0 Then Begin
      WriteLn('Error Opening File!');
      Exit;   
    End;
       
    if (FontHeader.charaddr[asc+1]<>255) and (FontHeader.charaddr[asc]<>255) Then
      Seek(fptr,Fonts[Selected-1].Pos+213+le2int(FontHeader.charaddr[asc+1],FontHeader.charaddr[asc]))
    Else Begin
      result:=1;
      exit;
    End;
    ox:=x;
    BlockRead(fptr,FChar,sizeof(Fchar));
    FontChar:=FChar;
    tbyte[1]:=32;
    tbyte[2]:=32;
    //GotoXY(x,y);
    while (tbyte[1]<>0) and (not eof(fptr)) do begin
    BlockRead(fptr,tbyte[1],1);
    if tbyte[1]=0 then break;
    if tbyte[1]=13 then begin
      y:=y+1;
      //GotoXY(x,WhereY+1);
      ox:=x;
      if Y>25 then break;
    end
     else begin
      BlockRead(fptr,tbyte[2],1);
      attr:=(tbyte[2] mod 16 + tbyte[2] - (tbyte[2] mod 16));
      if X<=79 then ImgWriteChar(img,ox,y,attr,chr(tbyte[1]));
      ox:=ox+1;
    end;
    end ;
    Close(fptr);

    result:=fchar.width;
 
end;

Function ImgWriteCharBL(var img: TConsoleImageRec; x,y,attr:byte;c:char):byte;
Var
  fptr : file;
  FChar : TFontChar;
  tbyte : array[1..2] of byte;
  asc:byte;
  r : LongInt;
  ox:byte=1;
begin
  
    If Not ((FontHeader.fs[1]=$55) and (FontHeader.fs[3]=0) and (FontHeader.fs[4]=$FF)) Then Exit;
    if c=' ' then begin
      result:=1;
      exit;
    end;
    asc:=(ord(c)-33)*2;
    Assign(fptr,fontfile);
    Reset(fptr,1);
    ox:=x;
    If IOResult <> 0 Then Begin
      WriteLn('Error Opening File!');
      Exit; 
    End;
   
      if (FontHeader.charaddr[asc+1]<>255) and (FontHeader.charaddr[asc]<>255) Then
      Seek(fptr,Fonts[Selected-1].Pos+213+le2int(FontHeader.charaddr[asc+1],FontHeader.charaddr[asc]))
    Else Begin
      result:=1;
      exit;
    End;
      BlockRead(fptr,FChar,sizeof(Fchar),r);
      FontChar:=FChar;
      tbyte[1]:=32;
      //GotoXY(x,y);
      while (tbyte[1]<>0) and (not eof(fptr)) do begin
      BlockRead(fptr,tbyte[1],1,r);
      if tbyte[1]=13 then begin
        y:=y+1;
        //GotoXY(x,WhereY+1);
        ox:=x;
        if Y>25 then break;
      end
       else begin
        if X<=79 then Begin
          ImgWriteChar(img,ox,y,attr,chr(tbyte[1]));
          ox:=ox+1;
        End;
      end;
      end ;
      Close(fptr);
      result:=fchar.width;      
end;

procedure ImgWriteStr(var img: TConsoleImageRec; x,y:byte; s:string);
Var
  i:byte;
  sx:byte;
  sy:byte;
begin
  //GotoXY(x,y);
  sx:=x;
  sy:=y;
  case FontHeader.fonttype of
  1: begin  
      for i:=1 to length(s) do begin
      sx:=sx+ImgwritecharBL(img,sx,sy,GetTextAttr,s[i])+FontHeader.spacing;
      if SX+X>79 Then Begin
        SX:=1;
        SY:=Sy+FontChar.Height+1;
        //GotoXY(Sx,Sy);
      End;
      end;
   end;
  2: begin  
      for i:=1 to length(s) do begin
      sx:=sx+ImgwritecharCL(img,sx,sy,s[i])+FontHeader.spacing;
      
      if SX+X>79 Then Begin
        SX:=1;
        SY:=Sy+FontChar.Height+1;
        //GotoXY(Sx,Sy);
      End;
      end;
   end;
   end;
end;

procedure ImgWriteStrNW(var img: TConsoleImageRec; x,y:byte; s:string);
Var
  i:byte;
  sx:byte;
  sy:byte;
begin
  //GotoXY(x,y);
  sx:=x;
  sy:=y;
  case FontHeader.fonttype of
  1: begin  
      for i:=1 to length(s) do begin
      sx:=sx+ImgwritecharBL(img,sx,sy,GetTextAttr,s[i])+FontHeader.spacing;
      
      end;
   end;
  2: begin  
      for i:=1 to length(s) do begin
      sx:=sx+ImgwritecharCL(img,sx,sy,s[i])+FontHeader.spacing;
      end;
   end;
   end;
end;    

Function NewEmptyFont(filename,name:string; ft:byte=2):Boolean;
Var
  tf : TTDFont;
  th : TFontHeader;
  fptr : File;
  i  : Byte;
Begin
  Result:=False;
  With TF Do Begin
    A    := Chr(19);// // fixed : 13h
    typo := 'TheDraw FONTS file';//       : Array[1..18] of char;
    B    := Chr(26);// char; // fixed : 1Ah  
  End;
  With TH Do Begin
    fs[1]:=$55; fs[2]:=$AA; fs[3]:=$00; fs[4]:=$FF; //           : array[1..4] of byte;  // fixed: 55 AA 00 FF
    NameLen     := 12;
    FontName    := StrPadR(name,12,' ');// array[1..12] of char;
    nouse[1]:=0; nouse[2]:=0; nouse[3]:=0; nouse[4]:=0;  //array[1..4] of byte;  // 00 00 00 00
    FontType    := ft;  // Font Type (byte): 00 = Outline, 01 = Block, 
                            // 02 = Color
    Spacing     := 1;  // byte; // 00 to 40d or 
    BlockSize[1]:=0; BlockSize[2]:=0; //  : array[1..2]of byte; // Block Size (Word, Little Endian) 
                // Size of character data after main
                // font definition block, including terminating 0 if followed 
                // by another font (last font in collection is not Null 
                // terminated
    For i:=0 to 187 Do CharAddr[i]:=$FF;
  End;
  Assign(fptr,filename);
  {$I-} ReWrite (fptr, 1); {$I+}
  If IOResult <> 0 Then Exit;
  BlockWrite(fptr,TF,sizeof(tf));
  BlockWrite(fptr,TH,sizeof(tH));
  Close(fptr);
  
  Result:=True;  
End;

Begin  
  
End.
