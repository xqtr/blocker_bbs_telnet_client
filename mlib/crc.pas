unit crc;

{ $Id: crc.pas 7164 2005-11-07 19:47:32Z hjtaenzer $ }

{$I xpdefine.inc }
{$R-}

interface

type
integer8 =   shortint;
    integer16 =  system.smallint;
    integer32 =  longint;
    integer64 =  Int64;
    smallword =  system.word;
    { Unter FPC ist ein Integer standardmaessig 16 Bit gross }
    integer =    longint;
    Word =       System.Word;
    DWord =      Longword;
    Cardinal =   Longword;
    PCharArray = ^TCharArray;
  TCharArray = array[0..MaxInt div 2-1] of Char;
  PByteArray = ^TByteArray;
  TByteArray = array[0..MaxInt div 2] of Byte;

{Iterativ: CRC wird jeweils fuer ein Byte aktualisiert}
function UpdCRC16(cp: byte; crc: smallword): smallword;
function UpdCRC32(octet: byte; crc: DWord) : DWord; 

{Explizit: CRC wird blockweise berechnet}
function CRC16Block(var data; size:smallword): smallword;
{ Das L„ngenbyte wird mit einbezogen }
function CRC16StrXP(s:shortstring): smallword;
{ Hier wird nur der String selbst genutzt }
function CRC16Str(s:string): smallword;

function CRC32Block(var data; size: word): longint;
function CRC32Str(s: string): longint;

(* --------------- CRC64 Routinen ------------------------------- *)
type
  TCRC64 = packed record
             lo32, hi32: longint;
           end;


// Routinen auskommentiert, wegen der Code-Qualität
// erst wieder einschalten, wenn Pointer-Increment raus ist
{$IFDEF DasLassenWirLieber }
procedure CRC64Init(var CRC: TCRC64);                             {-CRC64 initialization}

procedure CRC64Update(var CRC: TCRC64; Msg: pointer; Len: word);  {-update CRC64 with Msg data}

procedure CRC64Final(var CRC: TCRC64);                            {-CRC64: finalize calculation}

procedure CRC64Full(var CRC: TCRC64; Msg: pointer; Len: word);    {-CRC64 of Msg with init/update/final}

{$ENDIF DasLassenWirLieber }

implementation

var
   CRC_Reg: DWord;

(* crctab calculated by Mark G. Mendel, Network Systems Corporation *)
CONST crctab: ARRAY[0..255] OF smallWORD = (
    $0000,  $1021,  $2042,  $3063,  $4084,  $50a5,  $60c6,  $70e7,
    $8108,  $9129,  $a14a,  $b16b,  $c18c,  $d1ad,  $e1ce,  $f1ef,
    $1231,  $0210,  $3273,  $2252,  $52b5,  $4294,  $72f7,  $62d6,
    $9339,  $8318,  $b37b,  $a35a,  $d3bd,  $c39c,  $f3ff,  $e3de,
    $2462,  $3443,  $0420,  $1401,  $64e6,  $74c7,  $44a4,  $5485,
    $a56a,  $b54b,  $8528,  $9509,  $e5ee,  $f5cf,  $c5ac,  $d58d,
    $3653,  $2672,  $1611,  $0630,  $76d7,  $66f6,  $5695,  $46b4,
    $b75b,  $a77a,  $9719,  $8738,  $f7df,  $e7fe,  $d79d,  $c7bc,
    $48c4,  $58e5,  $6886,  $78a7,  $0840,  $1861,  $2802,  $3823,
    $c9cc,  $d9ed,  $e98e,  $f9af,  $8948,  $9969,  $a90a,  $b92b,
    $5af5,  $4ad4,  $7ab7,  $6a96,  $1a71,  $0a50,  $3a33,  $2a12,
    $dbfd,  $cbdc,  $fbbf,  $eb9e,  $9b79,  $8b58,  $bb3b,  $ab1a,
    $6ca6,  $7c87,  $4ce4,  $5cc5,  $2c22,  $3c03,  $0c60,  $1c41,
    $edae,  $fd8f,  $cdec,  $ddcd,  $ad2a,  $bd0b,  $8d68,  $9d49,
    $7e97,  $6eb6,  $5ed5,  $4ef4,  $3e13,  $2e32,  $1e51,  $0e70,
    $ff9f,  $efbe,  $dfdd,  $cffc,  $bf1b,  $af3a,  $9f59,  $8f78,
    $9188,  $81a9,  $b1ca,  $a1eb,  $d10c,  $c12d,  $f14e,  $e16f,
    $1080,  $00a1,  $30c2,  $20e3,  $5004,  $4025,  $7046,  $6067,
    $83b9,  $9398,  $a3fb,  $b3da,  $c33d,  $d31c,  $e37f,  $f35e,
    $02b1,  $1290,  $22f3,  $32d2,  $4235,  $5214,  $6277,  $7256,
    $b5ea,  $a5cb,  $95a8,  $8589,  $f56e,  $e54f,  $d52c,  $c50d,
    $34e2,  $24c3,  $14a0,  $0481,  $7466,  $6447,  $5424,  $4405,
    $a7db,  $b7fa,  $8799,  $97b8,  $e75f,  $f77e,  $c71d,  $d73c,
    $26d3,  $36f2,  $0691,  $16b0,  $6657,  $7676,  $4615,  $5634,
    $d94c,  $c96d,  $f90e,  $e92f,  $99c8,  $89e9,  $b98a,  $a9ab,
    $5844,  $4865,  $7806,  $6827,  $18c0,  $08e1,  $3882,  $28a3,
    $cb7d,  $db5c,  $eb3f,  $fb1e,  $8bf9,  $9bd8,  $abbb,  $bb9a,
    $4a75,  $5a54,  $6a37,  $7a16,  $0af1,  $1ad0,  $2ab3,  $3a92,
    $fd2e,  $ed0f,  $dd6c,  $cd4d,  $bdaa,  $ad8b,  $9de8,  $8dc9,
    $7c26,  $6c07,  $5c64,  $4c45,  $3ca2,  $2c83,  $1ce0,  $0cc1,
    $ef1f,  $ff3e,  $cf5d,  $df7c,  $af9b,  $bfba,  $8fd9,  $9ff8,
    $6e17,  $7e36,  $4e55,  $5e74,  $2e93,  $3eb2,  $0ed1,  $1ef0
);

(*
 * updcrc derived from article Copyright (C) 1986 Stephen Satchell.
 *  NOTE: First argument must be in range 0 to 255.
 *        Second argument is referenced twice.
 *
 * Programmers may incorporate any or all code into their programs,
 * giving proper credit within the source. Publication of the
 * source routines is permitted so long as proper credit is given
 * to Stephen Satchell, Satchell Evaluations and Chuck Forsberg,
 * Omen Technology.
 *)

{ Translated to Turbo Pascal (tm) V4.0 March, 1988 by J.R.Louvau }

FUNCTION UpdCRC16(cp: BYTE; crc: smallWORD): smallWORD;
begin { UpdCRC }
   UpdCRC16 := crctab[((crc SHR 8) AND $FF)] XOR ((crc AND $FF)SHL 8) XOR cp
end;

function _CRC16(var data; size:smallword):smallword;
type ba = array[0..65530] of byte;
var c16,i : smallword;
begin
  c16:=0;
  for i:=0 to size-1 do
    c16 := crctab[((c16 SHR 8) AND $FF)] XOR ((c16 AND $FF)SHL 8) XOR ba(data)[i];

  _CRC16:=c16;
end;

function CRC16Block(var data; size:smallword):smallword;
type ba = array[0..65530] of byte;
var c16,i : smallword;
begin
  c16:=0;
  for i:=0 to size-1 do
    c16 := crctab[((c16 SHR 8) AND $FF)] XOR ((c16 AND $FF)SHL 8) XOR ba(data)[i];

  c16 := crctab[((c16 SHR 8) AND $FF)] XOR ((c16 AND $FF)SHL 8);
  c16 := crctab[((c16 SHR 8) AND $FF)] XOR ((c16 AND $FF)SHL 8);

  CRC16Block:=c16;
end;

function Crc16StrXP(s:shortstring):smallword;
begin
  Crc16StrXP:=_CRC16(s,length(s)+1);
end;

function Crc16Str(s:string):smallword;
begin
  Crc16Str:=_CRC16(s[1],length(s));
end;

{************************* CRC 32 routines *******************************}
{ Use a type LONGINT variable to store the crc value.                     }
{ Initialise the variable to $FFFFFFFF before running the crc routine.    }
{ VERY IMPORTANT!!!! -> This routine was developed for data communications}
{ and returns the crc bytes in LOW to HIGH order, NOT byte reversed!      }
(* Converted to Turbo Pascal (tm) V4.0 March, 1988 by J.R.Louvau       *)
(* Copyright (C) 1986 Gary S. Brown.  You may use this program, or     *)
(* code or tables extracted from it, as desired without restriction.   *)
CONST crc_32_tab: ARRAY[0..255] OF Cardinal = (
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

function UpdCRC32(octet: BYTE; crc: DWord) : Dword;
begin { UpdCRC32 }
   UpdCRC32 := crc_32_tab[(BYTE(crc XOR DWord(octet))AND $FF)] XOR ((crc SHR 8) AND $00FFFFFF)
end;

procedure CCITT_CRC32_calc_Block(var block; size: DWord); { HJT 05.11.2005 ASM ->Pascal }
var
  carry_v : byte;
  carry_n : byte;
  c       : byte;
  i       : DWORD;
  j       : integer;
begin
  if size = 0 then
  begin
    exit;
  end;
  
  carry_v := 0;  carry_n := 0;
  
  for i:=0 to size -1 do
  begin
    c := TByteArray(block)[i];
    for j:=1 to 8 do 
    begin
      carry_n := c and 1;
      c := c shr 1;
      if carry_v <> 0 then
        c := c or $80
      else
        c := c and $7f;
      carry_v := carry_n;
      carry_n := CRC_Reg and 1;
      CRC_Reg := CRC_Reg shr 1;
      if carry_v <> 0 then
        CRC_Reg := CRC_Reg or $80000000
      else
        CRC_Reg := CRC_Reg and $7fffffff;
      if carry_n <> 0 then
        CRC_Reg := CRC_Reg xor $edb88320;
    end;
  end;
end;

function CRC32Str(s: string) : longint;
begin
  CRC_Reg := 0;
  CCITT_CRC32_calc_Block(s[1], length(s));
  CRC32Str := CRC_Reg;
end;

function crc32block(var data; size:word):longint;
begin
  CRC_Reg := 0;
  CCITT_CRC32_calc_block(data, size);
  CRC32block := CRC_Reg;
end;

// Routinen auskommentiert, wegen der Code-Qualität
// erst wieder einschalten, wenn Pointer-Increment raus ist
{$IFDEF DasLassenWirLieber }

(*----------------------------- CRC64 Routinen -----------------------------*)
(*--------------------------------------------------------------------------
 (C) Copyright 2005      Martin Wodrich 

 Modifikation um ohne Assembler-Abschnitte, lange Define-Abschnitte
 und Includes auszukommen (Erleichtert die Itegration in bestehende
 Pascal-Units von FreeXP und OpenXP).

 Der Code an sich ist Copyright 2002-2004 Wolfgang Ehrhardt
----------------------------------------------------------------------------*)

(*-------------------------------------------------------------------------
 (C) Copyright 2002-2004 Wolfgang Ehrhardt

 This software is provided 'as-is', without any express or implied warranty.
 In no event will the authors be held liable for any damages arising from
 the use of this software.

 Permission is granted to anyone to use this software for any purpose,
 including commercial applications, and to alter it and redistribute it
 freely, subject to the following restrictions:

 1. The origin of this software must not be misrepresented; you must not
    claim that you wrote the original software. If you use this software in
    a product, an acknowledgment in the product documentation would be
    appreciated but is not required.

 2. Altered source versions must be plainly marked as such, and must not be
    misrepresented as being the original software.

 3. This notice may not be removed or altered from any source distribution.
----------------------------------------------------------------------------*)

CONST  Mask64 : TCRC64  = (lo32:-1; hi32:-1);

{$ifdef FPC}
{$ifndef VER1_0}
  {$warnings off}
  {$R-} {avoid D9 errors!}
{$endif}
{$endif}

(*************************************************************************
T_CTab64 - CRC64 table calculation     (c) 2002-2004 W.Ehrhardt

Calculate CRC64 tables for polynomial:

x^64 + x^62 + x^57 + x^55 + x^54 + x^53 + x^52 + x^47 + x^46 + x^45 +
x^40 + x^39 + x^38 + x^37 + x^35 + x^33 + x^32 + x^31 + x^29 + x^27 +
x^24 + x^23 + x^22 + x^21 + x^19 + x^17 + x^13 + x^12 + x^10 + x^9  +
x^7  + x^4  + x^1  + 1

const
  PolyLo = $A9EA3693;
  PolyHi = $42F0E1EB;
*************************************************************************)


const Tab64lo : array[0..255] of Cardinal = (
    $00000000,    $A9EA3693,    $53D46D26,    $FA3E5BB5,
    $0E42ECDF,    $A7A8DA4C,    $5D9681F9,    $F47CB76A,
    $1C85D9BE,    $B56FEF2D,    $4F51B498,    $E6BB820B,
    $12C73561,    $BB2D03F2,    $41135847,    $E8F96ED4,
    $90E185EF,    $390BB37C,    $C335E8C9,    $6ADFDE5A,
    $9EA36930,    $37495FA3,    $CD770416,    $649D3285,
    $8C645C51,    $258E6AC2,    $DFB03177,    $765A07E4,
    $8226B08E,    $2BCC861D,    $D1F2DDA8,    $7818EB3B,
    $21C30BDE,    $88293D4D,    $721766F8,    $DBFD506B,
    $2F81E701,    $866BD192,    $7C558A27,    $D5BFBCB4,
    $3D46D260,    $94ACE4F3,    $6E92BF46,    $C77889D5,
    $33043EBF,    $9AEE082C,    $60D05399,    $C93A650A,
    $B1228E31,    $18C8B8A2,    $E2F6E317,    $4B1CD584,
    $BF6062EE,    $168A547D,    $ECB40FC8,    $455E395B,
    $ADA7578F,    $044D611C,    $FE733AA9,    $57990C3A,
    $A3E5BB50,    $0A0F8DC3,    $F031D676,    $59DBE0E5,
    $EA6C212F,    $438617BC,    $B9B84C09,    $10527A9A,
    $E42ECDF0,    $4DC4FB63,    $B7FAA0D6,    $1E109645,
    $F6E9F891,    $5F03CE02,    $A53D95B7,    $0CD7A324,
    $F8AB144E,    $514122DD,    $AB7F7968,    $02954FFB,
    $7A8DA4C0,    $D3679253,    $2959C9E6,    $80B3FF75,
    $74CF481F,    $DD257E8C,    $271B2539,    $8EF113AA,
    $66087D7E,    $CFE24BED,    $35DC1058,    $9C3626CB,
    $684A91A1,    $C1A0A732,    $3B9EFC87,    $9274CA14,
    $CBAF2AF1,    $62451C62,    $987B47D7,    $31917144,
    $C5EDC62E,    $6C07F0BD,    $9639AB08,    $3FD39D9B,
    $D72AF34F,    $7EC0C5DC,    $84FE9E69,    $2D14A8FA,
    $D9681F90,    $70822903,    $8ABC72B6,    $23564425,
    $5B4EAF1E,    $F2A4998D,    $089AC238,    $A170F4AB,
    $550C43C1,    $FCE67552,    $06D82EE7,    $AF321874,
    $47CB76A0,    $EE214033,    $141F1B86,    $BDF52D15,
    $49899A7F,    $E063ACEC,    $1A5DF759,    $B3B7C1CA,
    $7D3274CD,    $D4D8425E,    $2EE619EB,    $870C2F78,
    $73709812,    $DA9AAE81,    $20A4F534,    $894EC3A7,
    $61B7AD73,    $C85D9BE0,    $3263C055,    $9B89F6C6,
    $6FF541AC,    $C61F773F,    $3C212C8A,    $95CB1A19,
    $EDD3F122,    $4439C7B1,    $BE079C04,    $17EDAA97,
    $E3911DFD,    $4A7B2B6E,    $B04570DB,    $19AF4648,
    $F156289C,    $58BC1E0F,    $A28245BA,    $0B687329,
    $FF14C443,    $56FEF2D0,    $ACC0A965,    $052A9FF6,
    $5CF17F13,    $F51B4980,    $0F251235,    $A6CF24A6,
    $52B393CC,    $FB59A55F,    $0167FEEA,    $A88DC879,
    $4074A6AD,    $E99E903E,    $13A0CB8B,    $BA4AFD18,
    $4E364A72,    $E7DC7CE1,    $1DE22754,    $B40811C7,
    $CC10FAFC,    $65FACC6F,    $9FC497DA,    $362EA149,
    $C2521623,    $6BB820B0,    $91867B05,    $386C4D96,
    $D0952342,    $797F15D1,    $83414E64,    $2AAB78F7,
    $DED7CF9D,    $773DF90E,    $8D03A2BB,    $24E99428,
    $975E55E2,    $3EB46371,    $C48A38C4,    $6D600E57,
    $991CB93D,    $30F68FAE,    $CAC8D41B,    $6322E288,
    $8BDB8C5C,    $2231BACF,    $D80FE17A,    $71E5D7E9,
    $85996083,    $2C735610,    $D64D0DA5,    $7FA73B36,
    $07BFD00D,    $AE55E69E,    $546BBD2B,    $FD818BB8,
    $09FD3CD2,    $A0170A41,    $5A2951F4,    $F3C36767,
    $1B3A09B3,    $B2D03F20,    $48EE6495,    $E1045206,
    $1578E56C,    $BC92D3FF,    $46AC884A,    $EF46BED9,
    $B69D5E3C,    $1F7768AF,    $E549331A,    $4CA30589,
    $B8DFB2E3,    $11358470,    $EB0BDFC5,    $42E1E956,
    $AA188782,    $03F2B111,    $F9CCEAA4,    $5026DC37,
    $A45A6B5D,    $0DB05DCE,    $F78E067B,    $5E6430E8,
    $267CDBD3,    $8F96ED40,    $75A8B6F5,    $DC428066,
    $283E370C,    $81D4019F,    $7BEA5A2A,    $D2006CB9,
    $3AF9026D,    $931334FE,    $692D6F4B,    $C0C759D8,
    $34BBEEB2,    $9D51D821,    $676F8394,    $CE85B507);

const Tab64hi : array[0..255] of Cardinal = (
    $00000000,    $42F0E1EB,    $85E1C3D7,    $C711223C,
    $49336645,    $0BC387AE,    $CCD2A592,    $8E224479,
    $9266CC8A,    $D0962D61,    $17870F5D,    $5577EEB6,
    $DB55AACF,    $99A54B24,    $5EB46918,    $1C4488F3,
    $663D78FF,    $24CD9914,    $E3DCBB28,    $A12C5AC3,
    $2F0E1EBA,    $6DFEFF51,    $AAEFDD6D,    $E81F3C86,
    $F45BB475,    $B6AB559E,    $71BA77A2,    $334A9649,
    $BD68D230,    $FF9833DB,    $388911E7,    $7A79F00C,
    $CC7AF1FF,    $8E8A1014,    $499B3228,    $0B6BD3C3,
    $854997BA,    $C7B97651,    $00A8546D,    $4258B586,
    $5E1C3D75,    $1CECDC9E,    $DBFDFEA2,    $990D1F49,
    $172F5B30,    $55DFBADB,    $92CE98E7,    $D03E790C,
    $AA478900,    $E8B768EB,    $2FA64AD7,    $6D56AB3C,
    $E374EF45,    $A1840EAE,    $66952C92,    $2465CD79,
    $3821458A,    $7AD1A461,    $BDC0865D,    $FF3067B6,
    $711223CF,    $33E2C224,    $F4F3E018,    $B60301F3,
    $DA050215,    $98F5E3FE,    $5FE4C1C2,    $1D142029,
    $93366450,    $D1C685BB,    $16D7A787,    $5427466C,
    $4863CE9F,    $0A932F74,    $CD820D48,    $8F72ECA3,
    $0150A8DA,    $43A04931,    $84B16B0D,    $C6418AE6,
    $BC387AEA,    $FEC89B01,    $39D9B93D,    $7B2958D6,
    $F50B1CAF,    $B7FBFD44,    $70EADF78,    $321A3E93,
    $2E5EB660,    $6CAE578B,    $ABBF75B7,    $E94F945C,
    $676DD025,    $259D31CE,    $E28C13F2,    $A07CF219,
    $167FF3EA,    $548F1201,    $939E303D,    $D16ED1D6,
    $5F4C95AF,    $1DBC7444,    $DAAD5678,    $985DB793,
    $84193F60,    $C6E9DE8B,    $01F8FCB7,    $43081D5C,
    $CD2A5925,    $8FDAB8CE,    $48CB9AF2,    $0A3B7B19,
    $70428B15,    $32B26AFE,    $F5A348C2,    $B753A929,
    $3971ED50,    $7B810CBB,    $BC902E87,    $FE60CF6C,
    $E224479F,    $A0D4A674,    $67C58448,    $253565A3,
    $AB1721DA,    $E9E7C031,    $2EF6E20D,    $6C0603E6,
    $F6FAE5C0,    $B40A042B,    $731B2617,    $31EBC7FC,
    $BFC98385,    $FD39626E,    $3A284052,    $78D8A1B9,
    $649C294A,    $266CC8A1,    $E17DEA9D,    $A38D0B76,
    $2DAF4F0F,    $6F5FAEE4,    $A84E8CD8,    $EABE6D33,
    $90C79D3F,    $D2377CD4,    $15265EE8,    $57D6BF03,
    $D9F4FB7A,    $9B041A91,    $5C1538AD,    $1EE5D946,
    $02A151B5,    $4051B05E,    $87409262,    $C5B07389,
    $4B9237F0,    $0962D61B,    $CE73F427,    $8C8315CC,
    $3A80143F,    $7870F5D4,    $BF61D7E8,    $FD913603,
    $73B3727A,    $31439391,    $F652B1AD,    $B4A25046,
    $A8E6D8B5,    $EA16395E,    $2D071B62,    $6FF7FA89,
    $E1D5BEF0,    $A3255F1B,    $64347D27,    $26C49CCC,
    $5CBD6CC0,    $1E4D8D2B,    $D95CAF17,    $9BAC4EFC,
    $158E0A85,    $577EEB6E,    $906FC952,    $D29F28B9,
    $CEDBA04A,    $8C2B41A1,    $4B3A639D,    $09CA8276,
    $87E8C60F,    $C51827E4,    $020905D8,    $40F9E433,
    $2CFFE7D5,    $6E0F063E,    $A91E2402,    $EBEEC5E9,
    $65CC8190,    $273C607B,    $E02D4247,    $A2DDA3AC,
    $BE992B5F,    $FC69CAB4,    $3B78E888,    $79880963,
    $F7AA4D1A,    $B55AACF1,    $724B8ECD,    $30BB6F26,
    $4AC29F2A,    $08327EC1,    $CF235CFD,    $8DD3BD16,
    $03F1F96F,    $41011884,    $86103AB8,    $C4E0DB53,
    $D8A453A0,    $9A54B24B,    $5D459077,    $1FB5719C,
    $919735E5,    $D367D40E,    $1476F632,    $568617D9,
    $E085162A,    $A275F7C1,    $6564D5FD,    $27943416,
    $A9B6706F,    $EB469184,    $2C57B3B8,    $6EA75253,
    $72E3DAA0,    $30133B4B,    $F7021977,    $B5F2F89C,
    $3BD0BCE5,    $79205D0E,    $BE317F32,    $FCC19ED9,
    $86B86ED5,    $C4488F3E,    $0359AD02,    $41A94CE9,
    $CF8B0890,    $8D7BE97B,    $4A6ACB47,    $089A2AAC,
    $14DEA25F,    $562E43B4,    $913F6188,    $D3CF8063,
    $5DEDC41A,    $1F1D25F1,    $D80C07CD,    $9AFCE626);

{$ifdef FPC}
{$ifndef VER1_0}
  {$warnings on}
  {$ifdef RangeChecks_on}
    {$R+}
  {$endif}
{$endif}
{$endif}

{---------------------------------------------------------------------------}
procedure CRC64Update(var CRC: TCRC64; Msg: pointer; Len: word);
  {-update CRC64 with Msg data}
type
  PByte = ^byte;
var
  i,it: word;
  clo,chi: DWord;
type
  BR = packed record
         b0,b1,b2,b3: byte;
       end;
begin
  clo := CRC.lo32;
  chi := CRC.hi32;
  for i:=1 to Len do begin
    {c64 := Tab64[(c64 shr 56) xor Msg^] xor  (c64 shl 8)}
    it := BR(chi).b3 xor PByte(Msg)^;  {index in tables}
    chi := chi shl 8;
    BR(chi).b0 := BR(clo).b3;
    chi := chi xor Tab64Hi[it];
    clo := (clo shl 8) xor Tab64Lo[it];
    inc(PByte(Msg));

  end;
  CRC.lo32 := clo;
  CRC.hi32 := chi;
end;

{---------------------------------------------------------------------------}
procedure CRC64Init(var CRC: TCRC64);
  {-CRC64 initialization}
begin
  CRC := Mask64;
end;

{---------------------------------------------------------------------------}
procedure CRC64Final(var CRC: TCRC64);
  {-CRC64: finalize calculation}
begin
  CRC.lo32 := CRC.lo32 xor Mask64.lo32;
  CRC.hi32 := CRC.hi32 xor Mask64.hi32;
end;

{---------------------------------------------------------------------------}
procedure CRC64Full(var CRC: TCRC64; Msg: pointer; Len: word);
  {-CRC64 of Msg with init/update/final}
begin
  CRC64Init(CRC);
  CRC64Update(CRC, Msg, Len);
  CRC64Final(CRC);
end;

{$ENDIF DasLassenWirLieber }

end.
