// ====================================================================
// Mystic BBS Software               Copyright 1997-2013 By James Coyle
// ====================================================================
//
// This file is part of Mystic BBS.
//
// Mystic BBS is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Mystic BBS is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Mystic BBS.  If not, see <http://www.gnu.org/licenses/>.
//
// ====================================================================
{
  Mystic Software Development Library
  ===========================================================================
  File    | M_TYPES.PAS
  Desc    | Common types used throughout the development library.
  Created | August 22, 2002
  ---------------------------------------------------------------------------
}

Unit m_Types;

{$I M_OPS.PAS}

Interface

{$IFDEF WINDOWS}
Uses
  Windows;
{$ENDIF}

{$ifdef linux}
uses crt;
{$endif}

Const
  {$IFDEF UNIX}
    PathSep = '/';
  {$ELSE}
    PathSep = '\';
  {$ENDIF}
  
Type
  TMenuFormFlagsRec = Set of 1..26;

  {$IFNDEF WINDOWS}
  TCharInfo = Record
    Attributes  : Byte;
    UnicodeChar : Char;
  End;
  {$ENDIF}

  TConsoleLineRec   = Array[1..170] of TCharInfo;
  TConsoleScreenRec = Array[1..100] of TConsoleLineRec;

  TConsoleImageRec  = Record
    Data    : TConsoleScreenRec;
    CursorX : Byte;
    CursorY : Byte;
    CursorA : Byte;
    X1      : Byte;
    X2      : Byte;
    Y1      : Byte;
    Y2      : Byte;
  End;

Const
  black		=0;
  blue		=1;
  green		=2;
  cyan         	=3;
  red           =4;
  magenta       =5;
  brown         =6;
  lightgray     =7;
  darkgray      =8;
  lightblue     =9;
  lightgreen    =10;
  lightcyan     =11;
  lightred      =12;
  lightmagenta  =13;
  yellow        =14;
  white         =15;


  Home   = #71;      Up    = #72;     PgUp  = #73;
  Left   = #75;      Num5  = #76;     Right = #77;
  EndKey = #79;      Down  = #80;     PgDn  = #81;
  Ins    = #82;      Del   = #83;
  BackSp  = #8;
  Tab     = #9;      STab    = #143;
  Enter   = #13;
  Esc     = #27;
  //BackTab = #148;
  
  CtrlHome = #247;
 // ctrlend = #117;
      CtrlUp   = #65;    CtrlPgUp  = #132;
  CtrlLeft = #68;    CtrlNum5 = #143;    CtrlRight = #67;
  CtrlEnd  = #245;    CtrlDown = #66;    CtrlPgDn  = #118;
  CtrlIns  = #146;    CtrlDel  = #147;
  forwardslash=#47;
  asterisk=#42;
  minus=#45;
  plus=#43;
  F1 = #59;
  F2 = #60;
  F3 = #61;
  F4 = #62;
  F5 = #63;
  F6 = #64;
  F7 = #65;
  F8 = #66;
  F9 = #67;
  F10 = #68;
  F11 = #69;
  F12 = #70;
  
       sF1  = #212;      CtrlF1  = #222;      AltF1  = #232;
      sF2  = #213;      CtrlF2  = #223;      AltF2  = #233;
      sF3  = #214;      CtrlF3  = #224;      AltF3  = #234;
      sF4  = #215;      CtrlF4  = #225;      AltF4  = #235;
      sF5  = #216;      CtrlF5  = #226;      AltF5  = #236;
      sF6  = #217;      CtrlF6  = #227;      AltF6  = #237;
      sF7  = #218;      CtrlF7  = #228;      AltF7  = #238;
      sF8  = #219;      CtrlF8  = #229;      AltF8  = #239;
      sF9  = #220;      CtrlF9  = #53;      AltF9  = #51;
      sF10 = #221;      CtrlF10 = #231;      AltF10 = #241;
      sF11 = #141;      CtrlF11 = #154;      AltF11 = #156;
      sF12 = #142;      CtrlF12 = #155;      AltF12 = #157;
      
  altminus=#130;
  altplus=#131;    
var
  screenheight:byte;
  screenwidth:byte;

Implementation

begin
{$IFDEF linux}
    screenheight := crt.screenheight;
    screenwidth  := crt.screenwidth;
  {$ELSE}
    screenheight:=25;
    screenwidth:=80;
  {$ENDIF}


End.
