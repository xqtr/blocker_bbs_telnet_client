unit uucode;
{$M delphi}
{
  UUCode v1.0
  Copyright (c) 1996-1999 Digital Dreams Software.
}

interface

uses
  SysUtils,xFileIO;

procedure UUEncode(FileName: string; Mode: Integer = 664);
procedure UUDecode(FileName: string);
procedure CancelCoding;

type
   TCallBackProc = procedure(Size, Current: Integer) of object;
var
   CallBack: TCallBackProc = nil;

implementation

const
   Offset = 32;
var
   Cancel: Boolean;

procedure CancelCoding;
begin
Cancel := True;
end;

procedure UUEncode(FileName: string; Mode: Integer = 664);
const
   CharsPerLine = 60;
   BytesPerHunk = 3;
   SixBitMask = $3F;
var
   FileIn: file of Byte;
   FileOut: TextFile;
   DestFileName: string;
   Size, Current, LineLength, NumBytes, BytesInLine: Integer;
   Line: array[0..59] of Char;
   Hunk: array[0..2] of Byte;
   Chars: array[0..3] of Byte;

  procedure Initialize;

    procedure OpenFiles;
    begin
    AssignFile(FileIn, FileName);
    Reset(FileIn);
    Size := FileSize(FileIn);
    Current := 0;
    DestFileName := FileName+'.uue';
    AssignFile(FileOut, DestFileName);
    Rewrite(FileOut);
    end;

  begin
  OpenFiles;
  BytesInLine := 0;
  LineLength := 0;
  NumBytes := 0;
  Writeln(FileOut, 'begin ' + IntToStr(Mode) + ' ' + ExtractFileName(FileName));
  end;

  procedure FlushLine;
  var
     I: Integer;

    procedure WriteOut(Ch: Char);
    begin
    if Ch = ' '
    then Write(FileOut, '`')
    else Write(FileOut, Ch);
    end;

  begin
  if Assigned(CallBack)
  then CallBack(Size, Current);
  WriteOut(Char(BytesInLine + Offset));
  for I := 0 to LineLength - 1
  do WriteOut(Line[I]);
  Writeln(FileOut);
  LineLength := 0;
  BytesInLine := 0;
  end;

  procedure FlushHunk;
  var
     I: Integer;
  begin
  if LineLength = CharsPerLine
  then FlushLine;
  Chars[0] := Byte(Hunk[0] shr 2);
  Chars[1] := Byte((Hunk[0] shl 4) + (Hunk[1] shr 4));
  Chars[2] := Byte((Hunk[1] shl 2) + (Hunk[2] shr 6));
  Chars[3] := Byte(Hunk[2] and SixBitMask);
  for I := 0 to 3
  do begin
     Line[LineLength] := Char((Chars[I] and SixBitMask) + Offset);
     Inc(LineLength);
     end;
  Inc(BytesInLine, NumBytes);
  NumBytes := 0
  end;

  procedure Encode;
  begin
  if NumBytes = BytesPerHunk
  then FlushHunk;
  Read(FileIn, Hunk[NumBytes]);
  Inc(Current);
  Inc(Numbytes);
  end;

  procedure Finalize;
  begin
  if NumBytes > 0
  then FlushHunk;
  FlushLine;
  if LineLength > 0
  then FlushLine;
  Writeln(FileOut, 'end');
  CloseFile(FileOut);
  CloseFile(FileIn);
  end;

begin
Cancel := False;
Initialize;
while not Eof(FileIn)
do if Cancel
   then Break
   else Encode;
Finalize;
end;

procedure UUDecode(FileName: string);
var
  FileIn: TextFile;
  //FileIn: Text;
  FileOut: file of Byte;
  Size, Current, LineNum: Integer;
  Line: string;

  procedure Abort(Msg: string);
  begin
  if LineNum > 0
  then Msg := 'Line ' + IntToStr(LineNum) + ': ' + Msg;
  raise EInOutError.Create(Msg);
  end;

  procedure NextLine(var S: string);
  begin
  Inc(LineNum);
  Readln(FileIn, S);
  Inc(Current, Length(S) + 2);
  if Assigned(CallBack)
  then CallBack(Size, Current);
  end;

  procedure Initialize;

    procedure GetFileIn;
    var
       FileInName: string;
    begin
    FileInName := FileName;
    AssignFile(FileIn, FileInName);
    Reset(FileIn);
    //Size := FileSize(FileIn);
    Size:=FileByteSize(FileInName);
    Current := 0;
    end;

    procedure GetFileOut;
    var
       Header, Mode, FileOutName: string;

      procedure ParseHeader;
      var
         Index: Integer;

        procedure NextWord(var Word: string; var Index: Integer);
        begin
        Word := '';
        while Header[Index] = ' '
        do begin
           Inc(Index);
           if Index > Length(Header)
           then Abort('Incomplete header');
           end;
        while Header[Index] <> ' '
        do begin
           Word := Word + Header[Index];
           Inc(Index);
           end;
        end;

      begin
      Header := Header + ' ';
      Index := 7;
      NextWord(Mode, Index);
      NextWord(FileOutName, Index)
      end;

    begin
    if Eof(FileIn)
    then Abort('Nothing to decode.');
    NextLine(Header);
    while not ((Copy(Header, 1, 6) = 'begin ') or Eof(FileIn))
    do NextLine(Header);
    if Eof(FileIn)
    then Abort('Nothing to decode.');
    ParseHeader;
    FileOutName := ExtractFileDir(FileName) + ExtractFileName(FileOutName);
    AssignFile(FileOut, FileOutName);
    Rewrite(FileOut);
    end;

  begin
  LineNum := 0;
  GetFileIn;
  GetFileOut;
  end;

  function CheckLine: Boolean;
  begin
  if Line = ''
  then Abort('Blank line in file');
  Result := not (Line[1] in [' ', '`']) and not (Copy(Line, 1, 3) = 'end');
  end;

  procedure DecodeLine;
  var
     LineIndex, ByteNum, Count, I: Integer;
     Chars: array[0..3] of Byte;
     Hunk: array[0..2] of Byte;

    function NextCh: Char;
    begin
    Inc(LineIndex);
    if LineIndex > Length(Line)
    then Abort('Line too short.');
    if not (Line[LineIndex] in [' '..'`'])
    then Abort('Illegal character in line.');
    if Line[LineIndex] = '`'
    then Result := ' '
    else Result := Line[LineIndex]
    end;

    procedure DecodeByte;

      procedure GetNextHunk;
      var
         I: Integer;
      begin
      for I := 0 to 3
      do Chars[I] := Byte(NextCh) - Offset;
      Hunk[0] := Byte((Chars[0] shl 2) + (Chars[1] shr 4));
      Hunk[1] := Byte((Chars[1] shl 4) + (Chars[2] shr 2));
      Hunk[2] := Byte((Chars[2] shl 6) + Chars[3]);
      ByteNum := 0
      end;

    begin
    if byteNum = 3
    then GetNextHunk;
    Write(FileOut, Hunk[ByteNum]);
    Inc(ByteNum);
    end;

  begin
  LineIndex := 0;
  ByteNum := 3;
  Count := Byte(NextCh) - Offset;
  for I := 1 to Count
  do DecodeByte;
  end;

  procedure Finalize;
  var
     Trailer: string;
  begin
  Trailer := Line;
  if Length(Trailer) < 3
  then Abort('Abnormal end');
  if Copy(Trailer, 1, 3) <> 'end'
  then Abort('Abnormal end');
  CloseFile(FileIn);
  CloseFile(FileOut)
  end;

begin
Cancel := False;
Initialize;
NextLine(Line);
while CheckLine
do if Cancel
   then Break
   else begin
        DecodeLine;
        NextLine(Line);
        end;
Finalize;
end;

end.

