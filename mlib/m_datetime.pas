unit m_datetime;
{$MODE objfpc}
{$H-}
Interface

Uses
  DOS;
  
type
   string_2  = string[ 2];
   string_3  = string[ 3];
   string_10 = string[10];

Const
  DayString   : Array[0..6] of String[3]  = ('Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat');
  MonthString : Array[1..12] of String[3] = ('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec');

   days_per_month : array[0..11] of byte =
      ( 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 );

   months : array[0..11] of string_3 =
      ( 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct',
      'Nov', 'Dec' );

   days : array [0..6] of string_3 =
      ( 'Thu', 'Fri', 'Sat', 'Sun', 'Mon', 'Tue', 'Wed' );

   secs_per_min   =       60;
   secs_per_hour  =     3600;     { 60 * 60 }
   secs_per_day   =    86400;     { 60 * 60 * 24 }
   secs_per_year  = 31536000;     { 60 * 60 * 24 * 365 }
   secs_per_lyear = 31622400;     { 60 * 60 * 24 * 366 }

   days_per_year  = 365;
   days_per_lyear = 366;

{- Here are some more constants that illustrate another neat phenomenon I
found, namely that "even" decades have 3 leap years/days, and "odd" decades
have 2 leap years/days.

  "odd"    1972   1992
  decades  1976   1996

  "even"   1980   2000
  decades  1984   2004
           1988   2008
-}

   days_per_odd_dec  = 3652;
   days_per_even_dec = 3653;

   secs_per_odd_dec  = 315532800; { (secs_per_year * 10) + (secs_per_day * 2); }
   secs_per_even_dec = 315619200; { (secs_per_year * 10) + (secs_per_day * 3); }

   secs_to_1980      = 315532800; { secs_per_odd_dec }
   secs_to_1990      = 631152000; { secs_to_1980 + secs_per_even_dec; }
   secs_to_2000      = 946684800; { secs_to_1990 + secs_per_odd_dec; }

   {- Jan 01 2000 00:00:00 = 946,684,800 -}

   secs_to_19960101  = 820454400;
   {- 26 years + 6 leap days,
      26 * 365 = 9490,
      9490 + 6 = 9496,
      9496 * 86400 = 820,454,400
   -}

Function  TimerMinutes      : LongInt;
Function  TimerSeconds      : LongInt;
Function  TimerSet          (Secs: LongInt) : LongInt;
Function  TimerUp           (Secs: LongInt) : Boolean;
Function  CurDateDos        : LongInt;
Function  CurDateJulian     : LongInt;
Function  CurDateDT         : DateTime;
Function  DateDos2Str       (Date: LongInt; Format: Byte) : String;
Function  DateDos2DT        (Date: LongInt) : DateTime;
Function  DateJulian2Str    (Date: LongInt; Format: Byte) : String;
Function  DateStr2Dos       (Str: String) : LongInt;
Function  DateStr2Julian    (Str: String) : LongInt;
Procedure DateG2J           (Year, Month, Day: LongInt; Var Julian: LongInt);
Procedure DateJ2G           (Julian: LongInt; Var Year, Month, Day: SmallInt);
Function  DateValid         (Str: String) : Boolean;
Function  TimeDos2Str (Date: LongInt; Twelve: Boolean) : String;
Function  TimeDos2Str       (Date: LongInt; Mode: Byte) : String; Overload;
Function  DayOfWeek         (Date: LongInt) : Byte;
Function  DaysAgo           (Date: LongInt; dType: Byte) : LongInt;
Function  TimeSecToStr      (Secs: LongInt) : String;
Function  FormatDate        (DT: DateTime; Mask: String) : String;
Procedure WaitMS (MS: Word);
procedure UnpackUnixTime     (t : longint; var dt : DateTime);
procedure PackUnixTime       (dt : DateTime; var t : longint);
function  FormatUnixTime     (t : longint) : string;
function  FormatUnixDate     (t : longint) : string;
Function DateDT2Unix (DT: DateTime): LongInt;
Function DateDos2Unix (DosDate: LongInt): LongInt;

Function SecToDHMS(ASec: LongInt): String;
Function SecToHM(ASec: LongInt): String;
Function SecToHMS(ASec: LongInt): String;
Function SecToMS(ASec: LongInt): String;

function  int2dt             (i : longint) : string_2;
function  uStrI2S            (i : longint; l : integer) : string_10;
function  uStrS2I            (s : string) : longint;

Implementation

Uses
{$IFDEF WINDOWS}
  Windows,
{$ENDIF}
{$IFDEF UNIX}
  BaseUnix,
{$ENDIF}
  m_Strings;

Const
  JulianDay0 = 1461;
  JulianDay1 = 146097;
  JulianDay2 = 1721119;
  DATEC1970 = 2440588;

Function TimeSecToStr (Secs: LongInt) : String;
Var
  Mins,
  Hours : LongInt;
Begin
  Mins  := Secs DIV 60;
  Hours := Mins DIV 60;
  Mins  := Mins MOD 60;

  Result := strZero(Hours) + ':' + strZero(Mins);
End;

Procedure DateG2J (Year, Month, Day: LongInt; Var Julian: LongInt);
Var
  Century : LongInt;
  XYear   : LongInt;
Begin
  If Month <= 2 Then Begin
    Dec (Year);
    Inc (Month, 12);
  End;

  Dec (Month, 3);

  Century := Year DIV 100;
  XYear   := Year MOD 100;
  Century := (Century * JulianDay1) SHR 2;
  XYear   := (XYear * JulianDay0) SHR 2;
  Julian  := ((((Month * 153) + 2) DIV 5) + Day) + JulianDay2 + XYear + Century;
End;

Procedure DateJ2G (Julian: LongInt; Var Year, Month, Day: SmallInt);
Var
  Temp   : LongInt;
  XYear  : LongInt;
  YYear  : LongInt;
  YMonth : LongInt;
  YDay   : LongInt;
Begin
  Temp   := (((Julian - JulianDay2) SHL 2) - 1);
  XYear  := (Temp MOD JulianDay1) OR 3;
  Julian := Temp DIV JulianDay1;
  YYear  := (XYear DIV JulianDay0);
  Temp   := ((((XYear MOD JulianDay0) + 4) SHR 2) * 5) - 3;
  YMonth := Temp DIV 153;

  If YMonth >= 10 Then Begin
    YYear  := YYear + 1;
    YMonth := YMonth - 12;
  End;

  YMonth := YMonth + 3;
  YDay   := Temp MOD 153;
  YDay   := (YDay + 5) DIV 5;
  Year   := YYear + (Julian * 100);
  Month  := YMonth;
  Day    := YDay;
End;

Function CurDateDos : LongInt;
Var
  DT    : DateTime;
  Temp  : Word;
  Temp2 : LongInt;
Begin
  GetDate  (DT.Year, DT.Month, DT.Day, Temp);
  GetTime  (DT.Hour, DT.Min, DT.Sec, Temp);
  PackTime (DT, Temp2);

  Result := Temp2;
End;

Function CurDateJulian : LongInt;
Var
  Date : DateTime;
  Temp : Word;
Begin
  GetDate (Date.Year, Date.Month, Date.Day, Temp);

  Date.Hour := 0;
  Date.Min  := 0;
  Date.Sec  := 0;

  DateG2J(Date.Year, Date.Month, Date.Day, Result);
End;

Function CurDateDT : DateTime;
Var
  Temp : Word;
Begin
  GetDate  (Result.Year, Result.Month, Result.Day, Temp);
  GetTime  (Result.Hour, Result.Min, Result.Sec, Temp);
End;

Function DateDos2DT (Date: LongInt) : DateTime;
Begin
  UnPackTime (Date, Result);
End;

Function TimerSeconds : LongInt;
Var
  Hour,
  Minute,
  Second,
  Sec100  : Word;
Begin
  GetTime (Hour, Minute, Second, Sec100);
  Result := (Hour * 3600) + (Minute * 60) + Second;
End;

Function TimerMinutes : LongInt;
Var
  Hour,
  Min,
  Sec,
  Sec100 : Word;
Begin
  GetTime (Hour, Min, Sec, Sec100);
  Result := (Hour * 60) + Min;
End;

Function DateDos2Str (Date: LongInt; Format: Byte) : String;
{1 = MM/DD/YY  2 = DD/MM/YY  3 = YY/DD/MM}
Var
  DT : DateTime;
  M,
  D,
  Y  : String[2];
Begin
  UnPackTime (Date, DT);

  M := strZero(DT.Month);
  D := strZero(DT.Day);
  Y := Copy(StrI2S(DT.Year), 3, 2);

  Case Format of
    1 : Result := M + '/' + D + '/' + Y;
    2 : Result := D + '/' + M + '/' + Y;
    3 : Result := Y + '/' + M + '/' + D;
  End;
End;

Function DateJulian2Str (Date: LongInt; Format: Byte) : String;
{1 = MM/DD/YY  2 = DD/MM/YY  3 = YY/DD/MM}
Var
  M     : String[2];
  D     : String[2];
  Y     : String[2];
  Temp1 : Real;
  Temp2 : Real;
  Temp3 : Real;
  Temp4 : Real;
  Temp5 : Real;
Begin
  Temp1 := Date + 68569.0;
  Temp2 := Trunc(4 * Temp1 / 146097.0);
  Temp1 := Temp1 - Trunc((146097.0 * Temp2 + 3) / 4);
  Temp3 := Trunc(4000.0 * (Temp1 + 1) / 1461001.0);
  Temp1 := Temp1 - Trunc(1461.0 * Temp3 / 4.0) + 31.0;
  Temp4 := Trunc(80 * Temp1 / 2447.0);
  Temp5 := Temp1 - Trunc(2447.0 * Temp4 / 80.0);
  Temp1 := Trunc(Temp4 / 11);
  Temp4 := Temp4 + 2 - 12 * Temp1;
  Temp3 := 100 * (Temp2 - 49) + Temp3 + Temp1;

  Y := Copy(StrI2S(Trunc(Temp3)), 3, 2);
  M := strZero(Trunc(Temp4));
  D := strZero(Trunc(Temp5));

  Case Format of
    1 : Result := M + '/' + D + '/' + Y;
    2 : Result := D + '/' + M + '/' + Y;
    3 : Result := Y + '/' + M + '/' + D;
  End;
End;

Function DateStr2Julian (Str: String) : LongInt; {MM/DD/YY to Julian Date}
Var
  Month,
  Day,
  Year  : Integer;
  Temp  : Real;
  Temp2 : Real;
Begin
  Month := StrS2I(Copy(Str, 1, 2));
  Day   := StrS2I(Copy(Str, 4, 2));
  Year  := StrS2I(Copy(Str, 7, 2));

  If Year < 20 Then
    Inc(Year, 2000)
  Else
    Inc(Year, 1900);

  Temp2  := (Month - 14) DIV 12;
  Temp   := Day - 32075 + Trunc(1461 * (Year + 4800 + Temp2) / 4);
  Temp   := Temp + Trunc(367 * (Month - 2 - Temp2 * 12) / 12);
  Temp   := Temp - Trunc(3 * Trunc((Year + 4900 + Temp2) / 100) / 4);
//  Temp   := Temp - (3 * (Year + 4900 + Temp2) DIV 100) DIV 4;
  Result := Trunc(Temp);
End;

Function DateStr2Dos (Str: String) : LongInt; {MM/DD/YY to Dos Date}
Var
  DT : DateTime;
Begin
  DT.Year := StrS2I(Copy(Str, 7, 2));

  If Dt.Year < 80 Then
    Inc(DT.Year, 2000)
  Else
    Inc(DT.Year, 1900);

  DT.Month := StrS2I(Copy(Str, 1, 2));
  DT.Day   := StrS2I(Copy(Str, 4, 2));
  DT.Hour  := 0;
  DT.Min   := 0;
  DT.Sec   := 0;

  PackTime (DT, Result);
End;

Function DateValid (Str: String) : Boolean;
Var
  M,
  D : Byte;
Begin
  M := StrS2I(Copy(Str, 1, 2));
  D := StrS2I(Copy(Str, 4, 2));

  Result := (M > 0) and (M < 13) and (D > 0) and (D < 32);
End;

Function TimeDos2Str (Date: LongInt; Twelve: Boolean) : String;
Var
  DT : DateTime;
Begin
  UnPackTime (Date, DT);

  If Twelve Then Begin
    If DT.Hour > 11 Then Begin
      If DT.Hour = 12 Then Inc(DT.Hour, 12);
      Result := strZero(DT.Hour - 12) + ':' + strZero(DT.Min) + 'p'
    End Else Begin
      If DT.Hour = 0 Then Inc(DT.Hour, 12);
      Result := strZero(DT.Hour) + ':' + strZero(DT.Min) + 'a';
    End;
  End Else
    Result := strZero(DT.Hour) + ':' + strZero(DT.Min);
End;

Function DayOfWeek (Date: LongInt) : Byte;
Var
  DT  : DateTime;
  Res : LongInt;
Begin
  UnpackTime (Date, DT);

  If DT.Month < 3 Then
    Res := 365 * DT.Year + DT.Day + 31 * (DT.Month - 1) + Trunc ((DT.Year - 1) / 4) - Trunc(0.75 * Trunc((DT.Year - 1) / 100) + 1)
  Else
    Res := 365 * DT.Year + DT.Day + 31 * (DT.Month - 1) - Trunc (0.4 * DT.Month + 2.3) + Trunc (DT.Year / 4) - Trunc (0.75 * Trunc (DT.Year / 100) + 1);

  Result := Res MOD 7;
End;

Function DaysAgo (Date: LongInt; dType: Byte) : LongInt;
Begin  // 1 = date=julian,  2 = date=dosdate
  Case dType of
    1 : Result := CurDateJulian - Date;
    2 : Result := CurDateJulian - DateStr2Julian(DateDos2Str(Date, 1));
  End;
End;

Function TimerSet (Secs: LongInt) : LongInt;
Var
  DT     : DateTime;
  Sec100 : Word;
Begin
  GetTime (DT.Hour, DT.Min, DT.Sec, Sec100);

  Result := ((DT.Min MOD 60) * 6000 + (DT.Sec MOD 60) * 100 + Sec100) + Secs;
End;

Function TimerUp (Secs: LongInt) : Boolean;
Var
  DT     : DateTime;
  Sec100 : Word;
  Temp   : LongInt;
Begin
  GetTime (DT.Hour, DT.Min, DT.Sec, Sec100);

  Temp := (DT.Min MOD 60) * 6000 + (DT.Sec MOD 60) * 100 + Sec100;

  If Temp < (Secs - 65536) Then
    Temp := Temp + 360000;

  Result := (Temp - Secs) >= 0;
End;

Function FormatDate (DT: DateTime; Mask: String) : String;
Var
  YearStr : String[4];
Begin
  Result  := Mask;
  YearStr := StrI2S(DT.Year);
  Result  := strReplace(Result, 'YYYY', YearStr);
  Result  := strReplace(Result, 'YY', Copy(YearStr, 3, 2));
  Result  := strReplace(Result, 'MM', strZero(DT.Month));
  Result  := strReplace(Result, 'DD', strZero(DT.Day));
  Result  := strReplace(Result, 'HH', strZero(DT.Hour));
  Result  := strReplace(Result, 'II', strZero(DT.Min));
  Result  := strReplace(Result, 'SS', strZero(DT.Sec));
  Result  := strReplace(Result, 'NNN', MonthString[DT.Month]);
End;


{
  Returns a number of seconds formatted as:
  1d 1h 1m 1s
  0 values are not returned, so 3601 becomes
  1h 1s
}
Function SecToDHMS(ASec: LongInt): String;
var
  D, H, M, S: Integer;
Begin
     D := ASec div 86400;
     ASec := ASec mod 86400;
     H := ASec div 3600;
     ASec := ASec mod 3600;
     M := ASec div 60;
     S := ASec mod 60;
     SecToDHMS := StrI2S(D) + 'd ' + StrI2S(H) + 'h ' + StrI2S(M) + 'm ' + StrI2S(S) + 's';
End;

{
  Returns a number of seconds formatted as:
  HH:MM
}
Function SecToHM(ASec: LongInt): String;
var
  H, M: Integer;
Begin
     H := ASec div 3600;
     ASec := ASec mod 3600;
     M := ASec div 60;
     SecToHM := strPadL(StrI2S(H), 2,'0') + ':' + strPadL(StrI2S(M),2, '0');
End;

{
  Returns a number of seconds formatted as:
  HH:MM:SS
}
Function SecToHMS(ASec: LongInt): String;
var
  H, M, S: Integer;
Begin
     H := ASec div 3600;
     ASec := ASec mod 3600;
     M := ASec div 60;
     S := ASec mod 60;
     SecToHMS := strPadL(StrI2S(H),2,'0') + ':' + strPadL(StrI2S(M),2, '0') + ':' + strPadL(StrI2S(S),2, '0');
End;

{
  Returns a number of seconds formatted as:
  MM:SS
}
Function SecToMS(ASec: LongInt): String;
var
  M, S: Integer;
Begin
     M := ASec div 60;
     S := ASec mod 60;
     SecToMS := strPadL(StrI2S(M), 2,'0') + ':' + strPadL(StrI2S(S), 2,'0');
End;

{------------------------------------------------------------------------------}
{- Unpack Unix Time                                                           -}
{-                                                                            -}
{- converts Unix time longint into a DateTime record                          -}
{------------------------------------------------------------------------------}
procedure UnpackUnixTime(t : longint; var dt : DateTime);
begin
   dt.year  := 0;    { 1970 }
   dt.month := 0;    { January }
   dt.day   := 0;    { First }

   dt.hour  := 0;    { midnight }
   dt.min   := 0;
   dt.sec   := 0;

   {- writeln('Seconds since 1/1/70  ', t:12); -}
          { leap year : 9999  t : 999999999999 }
          { years     : 9999 }
          { months    : 9999 }
          { days      : 9999 }
          { hours     : 9999 }
          { minutes   : 9999 }
          { seconds   : 9999 }

   while (t >= secs_per_year) do begin      { while more than one years worth of seconds left }
      if (((dt.year + 2) mod 4) = 0) then begin   { if its a leap year }
         dec(t, secs_per_day);              { subtract an extra days worth of seconds }
         {- writeln('leap year         t : ', t:12); -}
      end;
      inc(dt.year);                         { add another year }
      dec(t, secs_per_year);                { subtract a years worth of seconds }
      {- writeln('years     : ', dt.year:4, '  t : ', t:12); -}
   end;

   if (((dt.year + 2) mod 4) = 0) then begin      { if its a leap year }
      inc(days_per_month[1]);               { add 1 more day to February }
      {- writeln('leap year, February adjusted'); -}
   end;

   while (t >= (days_per_month[dt.month] * secs_per_day)) do begin { while more than one month }
      dec(t, days_per_month[dt.month] * secs_per_day); { subtract a months worth }
      inc(dt.month);                        { add another month }
      {- writeln('months    : ', dt.month:4, '  t : ', t:12); -}
   end;

   while (t >= secs_per_day) do begin       { while more than one day }
      dec(t, secs_per_day);                 { subtract a days worth }
      inc(dt.day);                          { add another day }
      {- writeln('days      : ', dt.day:4, '  t : ', t:12); -}
   end;

   while (t >= secs_per_hour) do begin      { same for hours and minutes }
      dec(t, secs_per_hour);
      inc(dt.hour);
      {- writeln('hours     : ', dt.hour:4, '  t : ', t:12); -}
   end;

   while (t >= secs_per_min) do begin
      dec(t, secs_per_min);
      inc(dt.min);
      {- writeln('minutes   : ', dt.min:4, '  t : ', t:12); -}
   end;

   dt.sec := t;                             { remaining seconds }
   {- writeln('seconds   : ', dt.sec:4, '  t : ', t:12); -}

   if days_per_month[1] = 29 then dec(days_per_month[1]);

   inc(dt.year, 1970);
   inc(dt.month);
   inc(dt.day);
end;

{------------------------------------------------------------------------------}
{- Pack Unix Time                                                             -}
{-                                                                            -}
{- converts a DateTime record into a Unix time longint                        -}
{------------------------------------------------------------------------------}
procedure PackUnixTime(dt : DateTime; var t : longint);
var
   i              : word;
   days_this_year : word;
   num_leap_years : word;
begin
   dec(dt.year, 1970);
   dec(dt.month);
   dec(dt.day);

   t := dt.sec;
   {- writeln('seconds        : ', t:12); -}

   inc(t, dt.min  * secs_per_min);
   {- writeln('minutes        : ', dt.min * secs_per_min:4); -}
   {- writeln('plus minutes   : ', t:12); -}

   inc(t, longint(dt.hour) * secs_per_hour);
   {- writeln('hours          : ', longint(dt.hour) * secs_per_hour:4); -}
   {- writeln('plus hours     : ', t:12); -}

   {- adjust February days if leap year -}
   if (((dt.year + 2) mod 4) = 0) then begin      { if its a leap year }
      inc(days_per_month[1]);                     { add 1 more day to February }
      {- writeln('leap year, February adjusted'); -}
   end;

   {- get total number of days this year -}
   days_this_year := dt.day;                     { days this month }
   i := 0;
   while (i < dt.month) do begin                 { days in previous months }
      inc(days_this_year, days_per_month[i]);
      inc(i);
   end;
   {- writeln('days this year : ', days_this_year:4); -}
   inc(t, days_this_year * secs_per_day);
   {- writeln('in seconds     : ', t:12); -}

   {- reset February days if adjusted -}
   if days_per_month[1] = 29 then dec(days_per_month[1]);

   inc(t, dt.year * secs_per_year);
   {- writeln('years          : ', dt.year * secs_per_year:4); -}
   {- writeln('plus years     : ', t:12); -}

   num_leap_years := (dt.year + 2) div 4;        { get number of leap days }
   if (((dt.year+2) mod 4) = 0) then begin       { if target year is leap year }
      dec(num_leap_years);                       { back out 1 day }
   end;

   {- writeln('num leap years : ', num_leap_years:4); -}

   inc(t, num_leap_years * secs_per_day);
   {- writeln('plus leap days : ', t:12); -}
end;

(*
   1970
   1971
   1972 l
   1973
   1974
   1975
   1976 l
   1977
   1978
   1979
   1980 l
   1981
   1982
   1983
   1984 l
   1985
   1986
   1987
   1988 l
   1989
   1990
   1991
   1992 l
   1993
   1994
   1995
   1996 l
   1997
   1998
   1999
   2000 l

            years evenly divisible by 4 are leap years

   *except* years evenly divisible by 100 are *NOT* leap years

   *except* years evenly divisible by 400 *ARE* leap years

   So the year 2000 is a leap year, and most of us won't have to worry about
   rewriting the routines in 2100 when the simple-minded "div 4" leap year
   routines start failing!

   BTW, the 21st century doesn't start until 2001. The year 2000 is still the
   20th century.

*)

{------------------------------------------------------------------------------}
{- Format Unix Time                                                           -}
{-                                                                            -}
{- formats a Unix time longint into a string like this:                       -}
{-                                                                            -}
{-    Sun Jan 17 20:09:48 1994                                                -}
{------------------------------------------------------------------------------}
function FormatUnixTime(t : longint) : string;
var
   work : string;
   dt   : DateTime;
begin
   UnpackUnixTime(t, dt);
   FormatUnixTime :=
      int2dt (dt.hour)            +':'+
      int2dt (dt.min)             +' '+
      uStrI2S(dt.day, 2)          +'-'+
      uStrI2S(dt.month,2   )      +'-'+
      uStrI2S(dt.year, 4);
end;

function FormatUnixDate(t : longint) : string;
var
   work : string;
   dt   : DateTime;
begin
   UnpackUnixTime(t, dt);
   FormatUnixDate :=
      StrPadL(StrI2s(dt.day),2,'0')          +'/'+
      StrPadL(stri2s(dt.month),2,'0')      +'/'+
      uStrI2S(dt.year, 4);
end;

Function DateDT2Unix (DT: DateTime): LongInt;
Var
  SecsPast, DaysPast: LongInt;
Begin
  DateG2J (DT.Year, DT.Month, DT.Day, DaysPast);

  DaysPast := DaysPast - DATEc1970;
  SecsPast := DaysPast * 86400;
  SecsPast := SecsPast + (LongInt(DT.Hour) * 3600) + (DT.Min * 60) + (DT.Sec);

  Result := SecsPast;
End;

Function DateDos2Unix (DosDate: LongInt): LongInt;
Var
  DT: DateTime;
Begin
  UnpackTime(DosDate, DT);

  Result := DateDT2Unix(DT);
End;

{------------------------------------------------------------------------------}
{- Int2Dt                                                                     -}
{------------------------------------------------------------------------------}
function int2dt(i : longint) : string_2;
var
   s : string_2;
begin
   str(i:2, s);
   if s[1]=' ' then s[1] := '0';
   int2dt := s;
end;

{------------------------------------------------------------------------------}
{- StrI2S                                                                    -}
{------------------------------------------------------------------------------}
function uStrI2S(i : longint; l : integer) : string_10;
var
   s : string_10;
begin
   str(i:l, s);
   uStrI2S := s;
   if s[1]=' ' then s[1]:='0';
end;

{------------------------------------------------------------------------------}
{- StrS2I                                                                    -}
{------------------------------------------------------------------------------}
function uStrS2I(s : string) : longint;
var
   n : longint;
   e : integer;
begin
   val(s, n, e);
   uStrS2I := n;
end;
Function TimeDos2Str (Date: LongInt; Mode: Byte) : String;
Var
  DT : DateTime;
Begin
  UnPackTime (Date, DT);

  Case Mode of
    0 : Result := strZero(DT.Hour) + ':' + strZero(DT.Min);
    1 : If DT.Hour > 11 Then Begin
          If DT.Hour = 12 Then Inc(DT.Hour, 12);

          Result := strZero(DT.Hour - 12) + ':' + strZero(DT.Min) + 'p'
        End Else Begin
          If DT.Hour = 0 Then Inc(DT.Hour, 12);

          Result := strZero(DT.Hour) + ':' + strZero(DT.Min) + 'a';
        End;
    2 : Result := strZero(DT.Hour) + ':' + strZero(DT.Min) + ':' + strZero(DT.Sec);
  End;
End;

Procedure WaitMS (MS: Word);
Begin
  {$IFDEF WIN32}
    Sleep(MS);
  {$ENDIF}

  {$IFDEF UNIX}
    fpSelect(0, Nil, Nil, Nil, MS);
  {$ENDIF}
End;

End.
