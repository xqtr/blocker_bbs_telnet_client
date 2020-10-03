{
   ====================================================================
   xLib - xFileRec                                                 xqtr
   ====================================================================

   This file is part of xlib for FreePascal
    
   To use this Unit you need the source code of MysticBBS from here:
   https://github.com/fidosoft/mysticbbs, which is shared under GPL
    
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

{$IFDEF FPC}
  {$mode objfpc}
  {$PACKRECORDS 1}
  {$H-}
  {$V-}
{$EndIF}

Unit xFileRec;

Interface

Type 
  
  TFileRec = Class
  Private
    F : File;
    RecSize : Integer;
  Public
    FileName : String;
    
    Constructor Create(FName:String; RS:Integer; DoReWrite:Boolean);
    destructor  Destroy; override;
    Function    FileSizeRec:Integer;
    Function    FileSize:Integer;
    Procedure   SeekRecord(RN:Integer);
    Procedure   Seek(RN:Integer);
    Procedure   ReadRecord(Var R; I:Integer);
    Procedure   WriteRecord(Var R; I:Integer);
    Procedure   AppendRecord(Var R);
    Procedure   InsertRecord(Var R; I:Integer);
  End;

Implementation

Uses 
  {$IFDEF WINDOWS}
    Windows,
  {$ENDIF}
   DOS;

{$IFDEF WINDOWS}
Function FileErase (Str: String) : Boolean;
Begin
  Str    := Str + #0;
  Result := Windows.DeleteFile(PChar(@Str[1]));
End;
{$ELSE}
Function FileErase (Str: String) : Boolean;
Var
  F : File;
Begin
  {$I-}

  Assign (F, Str);
  Erase  (F);

  Result := IoResult = 0;
End;
{$ENDIF}

Function FileCopy (Source, Target: String) : Boolean;
Var
  SF      : File;
  TF      : File;
  BRead   : LongInt;
  BWrite  : LongInt;
  FileBuf : Array[1..4096] of Char;
Begin
  Result   := False;
  FileMode := 66;

  Assign (SF, Source);
  {$I-} Reset(SF, 1); {$I+}

  If IOResult <> 0 Then Exit;

  Assign (TF, Target);
  {$I-} ReWrite(TF, 1); {$I+}

  If IOResult <> 0 then Exit;

  Repeat
    BlockRead  (SF,  FileBuf, SizeOf(FileBuf), BRead);
    BlockWrite (TF, FileBuf, BRead, BWrite);
  Until (BRead = 0) or (BRead <> BWrite);

  Close(SF);
  Close(TF);

  Result := BRead = BWrite;
End;

Function FileExist (Str: String) : Boolean;
Var
  DF   : File;
  Attr : Word;
Begin
  Assign   (DF, Str);
  GetFattr (DF, Attr);

  Result := (DosError = 0) and (Attr And Directory = 0);
End;

Constructor TFileRec.Create(FName:String; RS:Integer; DoReWrite:Boolean);
Begin
  FileName:=FName;
  Assign(F,FileName);
  If Not DoReWrite Then
    Reset(F,1)
  Else 
    Rewrite(F,1);
  
  RecSize := RS;
End;

Destructor TFileRec.Destroy;
Begin
  Close(F);
  inherited Destroy;
End;

Function TFileRec.FileSizeRec:Integer;
Begin
  Result := System.FileSize(F) Div RecSize;
End;

Procedure TFileRec.ReadRecord(Var R; I:Integer);
Begin
  System.Seek(F,I*RecSize);
  BlockRead(F,R,RecSize);
End;

Procedure TFileRec.WriteRecord(Var R; I:Integer);
Begin
  System.Seek(F,I*RecSize);
  BlockWrite(F,R,RecSize);
End;

Procedure TFileRec.AppendRecord(Var R);
Begin
  System.Seek(F,System.FileSize(F));
  BlockWrite(F,R,RecSize);
End;

Procedure TFileRec.InsertRecord(Var R; I:Integer);
Var
  T : File;
  Rec : Array Of Byte;
  D : Integer;
Begin
  Assign(T,'tmp.$$$');
  ReWrite(T,1);
  System.Seek(F,0);
  SetLength(Rec,RecSize);
  
  For D := 0 To I Do Begin
    BlockRead(F,Rec,RecSize);
    BlockWrite(T,Rec,RecSize);
  End;
  
  BlockWrite(T,R,RecSize);
  
  While Not Eof(F) Do Begin
    BlockRead(F,Rec,RecSize);
    BlockWrite(T,Rec,RecSize);
  End;
  
  Close(T);
  Close(F);
  Reset(F,1);
  FileErase(FileName);
  FileCopy('tmp.$$$',FileName);
  FileErase('tmp.$$$');
End;

Function TFileRec.FileSize:Integer;
Begin
  Result := System.Filesize(F);
End;

Procedure TFileRec.SeekRecord(RN:Integer);
Begin
  If RN*RecSize<=System.FileSize(F) Then System.Seek(F,RN*RecSize);
End;

Procedure TFileRec.Seek(RN:Integer);
Begin
  If RN<=System.FileSize(F) Then System.Seek(F,RN);
End;

End.
