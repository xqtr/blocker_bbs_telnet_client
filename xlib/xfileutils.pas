Unit xFileUtils;
{$MODE objfpc}
Interface

Uses 
  Math,
  Classes,
  Sysutils,
  xStrings;

procedure ListFiles(dir:string; ext:String; var files:tstringlist);
procedure listdir(dir:string; var dirs:tstringlist);
function LevenshteinCompareText(const s1, s2: string): integer;

Implementation

procedure ListFiles(dir:string; ext:String; var files:tstringlist);
var
  Info : TSearchRec;
begin
  If FindFirst (AddSlash(dir)+'*',faAnyFile and faDirectory,Info)=0 then
    begin
    Repeat
      With Info do
        begin
          if (Attr and faDirectory) = 0 then
            if Pos(Upper(ext),Upper(Name))>0 Then Files.Add(Name);
        end;
    Until FindNext(info)<>0;
    end;
  FindClose(Info);
end;

procedure listdir(dir:string; var dirs:tstringlist);
var
  Info : TSearchRec;
begin
  // if we have found a file...
  If FindFirst (AddSlash(dir)+'*',faAnyFile ,Info)=0 Then
  Begin
  Repeat
     
        If (Info.Attr and faDirectory) = faDirectory then begin
         if (Info.name<>'') and (Info.name<>'..') and (Info.name<>'.') then
         dirs.add(Info.name);
         
        end;
    Until FindNext(info)<>0
  end;
   // we are done with file list
  FindClose(Info);
end;

function LevenshteinDistance(const s1 : string; s2 : string) : integer;
var
  length1, length2, i, j ,
  value1, value2, value3 : integer;
  matrix : array of array of integer;
begin
  length1 := Length( s1 );
  length2 := Length( s2 );
  SetLength (matrix, length1 + 1, length2 + 1);
  for i := 0 to length1 do matrix [i, 0] := i;
  for j := 0 to length2 do matrix [0, j] := j;
  for i := 1 to length1 do
    for j := 1 to length2 do
      begin
        if Copy( s1, i, 1) = Copy( s2, j, 1 )
          then matrix[i,j] := matrix[i-1,j-1]
          else  begin
            value1 := matrix [i-1, j] + 1;
            value2 := matrix [i, j-1] + 1;
            value3 := matrix[i-1, j-1] + 1;
            matrix [i, j] := min( value1, min( value2, value3 ));
          end;
      end;
  result := matrix [length1, length2];
end;

function LevenshteinCompareText(const s1, s2: string): integer;
var
  s1lower, s2lower: string;
begin
  s1lower := Lower( s1 );
  s2lower := Lower( s2 );
  result := LevenshteinDistance( s1lower, s2lower );
end;

end.
