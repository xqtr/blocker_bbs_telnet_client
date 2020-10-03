{
  Mystic Software Development Library
  ===========================================================================
  File    | M_OPS.PAS
  Desc    | Compiler options include file.  This file is included in all
            units within MDL.  This file should create some basic
            definitions relating to the target operating system as well as
            include compiler specific compiler options (if ported to work
            with multiple compilers).  This is also where some program
            specific options will be found (such as the ability to compile
            in DEBUG or RELEASE mode, etc).

  Created | August 22, 2002
  Notes   | Sets up the following compiler directives:

            COMPILERS:
              $FPC : Set if compiler is Free Pascal
              $VPC : Set if compiler is Virtual Pascal

            OPERATING SYSTEMS:
              $UNIX    : Set if target OS is unix style
              $LINUX   : Set if target OS is linux
              $WINDOWS : Set if target OS is windows

            FILE SYSTEMS:
              $FS_SENSITIVE : Set if target file system is case sensitive
              $FS_IGNORE    : Set if target file system is not case sensitive
  -------------------------------------------------------------------------
}

{.$DEFINE DEBUG}
{$DEFINE RELEASE}

{ ------------------------------------------------------------------------- }

{$IFDEF LINUX}
  {$DEFINE UNIX}
  {$DEFINE FS_SENSITIVE}
{$ENDIF}

{$IFDEF WIN32}
  {$DEFINE WINDOWS}
  {$DEFINE FS_IGNORE}
{$ENDIF}

{ ------------------------------------------------------------------------- }

{$IFDEF VIRTUALPASCAL}
  {$DEFINE VPC}
  {$I M_OPS_VPC.PAS}
{$ENDIF}

{$IFDEF FPC}
  {$I M_OPS_FPC.PAS}
  {$IFDEF DEBUG}
    {$DEFINE EXTRA}  // This is for the HeapTrc unit...
  {$ENDIF}
{$ENDIF}

{ ------------------------------------------------------------------------ }

{$IFNDEF DEBUG}
  {$IFNDEF RELEASE}
    You must define either DEBUG or RELEASE mode above in order to compile
    this program.
  {$ENDIF}
{$ENDIF}

{$IFNDEF FS_SENSITIVE}
  {$IFNDEF FS_IGNORE}
    You must define the file system type above in order to compile this
    program.
  {$ENDIF}
{$ENDIF}
