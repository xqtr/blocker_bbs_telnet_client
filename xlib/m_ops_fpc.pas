{
  Mystic Software Development Library
  ===========================================================================
  File    | M_OPS_FPC.PAS
  Desc    | Compiler options include file for Free Pascal specific compiler
            options.

  Created | August 22, 2002
  Author  | James Coyle

  Notes   | None
  -------------------------------------------------------------------------
}

{$MEMORY 64000, 800000}
{$MODE DELPHI}
{$EXTENDEDSYNTAX ON}
{$PACKRECORDS 1}
{$VARSTRINGCHECKS OFF}
{$TYPEINFO OFF}
{$LONGSTRINGS OFF}
{$I-}

{$IFDEF DEBUG}
  {$DEBUGINFO ON}
  {$SMARTLINK OFF}
  {$RANGECHECKS ON}
  {$OVERFLOWCHECKS ON}
  {$IFNDEF LINUX}
    {$S+}
  {$ENDIF}
{$ELSE}
  {$DEBUGINFO OFF}
  {$SMARTLINK ON}
  {$RANGECHECKS OFF}
  {$OVERFLOWCHECKS OFF}
  {$IFNDEF LINUX}
    {$S-}
  {$ENDIF}
{$ENDIF}
