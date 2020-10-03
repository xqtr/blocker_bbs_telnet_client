{ Bens Simple CSV Format v1.0.0
  This is a very basic csv readeer and writer that I needed for a basic program
  //See below for features:

  Return RecordCount
  OpenCsv
  SaveCsv Allows saveing to other filenames.
  Update saves the current csv opened file.
  Read field values
  Write field values
  Add new records
  Delete recoreds
  and more.
}

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

unit csv;

interface

uses
  SysUtils, Classes;

type
  TCsv = class
  private
    lFilename: string;
    db: TStringList;
    dbOpen: boolean;
    fFieldCount: integer;
    fRecords: integer;
    fDelimiter: char;
    function Split(Source: string): TStringList;
  public
    constructor Create(Filename: string);
    procedure OpenCsv();
    property IsOpen: boolean read dbOpen;
    property FieldCount: integer read fFieldCount;
    property RecordCount: integer read fRecords;
    property Delimiter: char read fDelimiter write fDelimiter;
    procedure SaveCsv(Filename: string);
    function GetFieldValue(RecIdx: integer; FieldIdx: integer): string;
    function GetRecord(RecIdx: integer): string;
    function DeleteRecord(RecIdx: integer): boolean;
    procedure SetFieldValue(RecIdx: integer; FieldIdx: integer; Data: string);
    procedure AddRecord(Data: string);
    function UpdateCsv(): boolean;
  end;

implementation

procedure TCsv.AddRecord(Data: string);
begin
  //Add new record.
  DB.Add(Data);
  //Update record count.
  fRecords := DB.Count;
end;

function Tcsv.UpdateCsv(): boolean;
begin
  Result := False;
  //Use this function to update the current opened csv filename.
  if not dbOpen then
    exit;
  //Save csv filename.
  DB.SaveToFile(lFilename);
  //Return good result;
  Result := True;
end;

function Tcsv.DeleteRecord(RecIdx: integer): boolean;
begin
  //Check record index.
  if (RecIdx < 0) or (RecIdx > RecordCount) then
  begin
    Result := False;
  end
  else
  begin
    //Delete Record.
    DB.Delete(RecIdx);
    //Update record count.
    fRecords := DB.Count;
    //Return good result
    Result := True;
  end;
end;

function Tcsv.GetRecord(RecIdx: integer): string;
begin
  //Check record index.
  if (RecIdx < 0) or (RecIdx > RecordCount) then
  begin
    Result := '';
  end
  else
  begin
    //Return record.
    Result := db[RecIdx];
  end;
end;

function TCsv.GetFieldValue(RecIdx: integer; FieldIdx: integer): string;
var
  Fields: TStringList;
begin
  //Check record index.
  if (RecIdx < 0) or (RecIdx > RecordCount) then
  begin
    Result := '';
  end
  //Check field index is in range.
  else if (FieldIdx < 0) or (FieldIdx > FieldCount) then
    Result := ''
  else
  begin
    //Create stringlist object.
    Fields := Split(db[RecIdx]);
    //Return field value.
    Result := Fields[FieldIdx];
    //Clear up.
    Fields.Destroy;
  end;
end;

procedure TCsv.SetFieldValue(RecIdx: integer; FieldIdx: integer; Data: string);
var
  Fields: TStringList;
  sRec: string;
  X: integer;
begin
  //Init
  sRec := '';

  //Check record index.
  if (RecIdx < 0) or (RecIdx > RecordCount) then
  begin
    exit;
  end
  //Check field index is in range.
  else if (FieldIdx < 0) or (FieldIdx > FieldCount) then
    exit
  else
  begin
    //Get record.
    Fields := Split(db[RecIdx]);
    //Edit the field value.
    Fields[FieldIdx] := Data;
    //Go tho the field values.
    for X := 0 to Fields.Count - 1 do
    begin
      //Build new record.
      sRec := sRec + Fields[X] + fDelimiter;
    end;
    //Remove last comma at the of string.
    Delete(sRec, Length(sRec), 1);
    //Replace the record back.
    DB[RecIdx] := sRec;
    //Clear up.
    Fields.Destroy;
  end;
end;

procedure TCsv.OpenCsv();
var
  nSize: integer;
begin

  //Return true or false if file was opened.
  dbOpen := FileExists(lFilename);

  if dbOpen then
  begin
    nSize := 0;
    DB.LoadFromFile(lFilename);
    //Get number of records.
    fRecords := DB.Count;
    //Check if we have any records
    if fRecords > 0 then
    begin
      //Store size of returned string list.
      nSize := Split(db[0]).Count;
    end;
    //Set records size.
    fFieldCount := nSize;
  end;
end;

constructor TCsv.Create(Filename: string);
begin
  //Create db stringlist
  db := TStringList.Create;
  //Set Filename
  lFilename := Filename;
  //Set defaults
  dbOpen := False;
  fFieldCount := 0;
  fDelimiter := ';';
end;

function TCsv.Split(Source: string): TStringList;
var
  lDB: TStringList;
begin
  //Create the object
  lDB := TStringList.Create;
  lDB.Delimiter := fDelimiter;
  lDB.CommaText := '"';
  lDB.DelimitedText := Source;
  //Return result
  Result := lDB;
end;

procedure Tcsv.SaveCsv(Filename: string);
begin
  //Save string list to filename.
  DB.SaveToFile(Filename);
end;

end.
