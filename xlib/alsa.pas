{  Free Pascal port by Nikolay Nikolov <nickysn@users.sourceforge.net>
   This version of the header has been created by Andreas Stoeckel and has been
   adapted to the needs of the Audorra audio library. For a complete version of the
   header for pascal have a look for the fpAlsa project on sourceforge.
   http://sourceforge.net/projects/fpalsa/
   This adaption has been done for the following reasons:
     - Easier to update to new versions of ALSA, as not the whole header has to be updated
     - Easier to distribute with Audorra (only a short, single file)
}

{**
 * \file include/asoundlib.h
 * \brief Application interface library for the ALSA driver
 * \author Jaroslav Kysela <perex@perex.cz>
 * \author Abramo Bagnara <abramo@alsa-project.org>
 * \author Takashi Iwai <tiwai@suse.de>
 * \date 1998-2001
 *
 * Application interface library for the ALSA driver
 *}
{*
 *   This library is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Lesser General Public License as
 *   published by the Free Software Foundation; either version 2.1 of
 *   the License, or (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Lesser General Public License for more details.
 *
 *   You should have received a copy of the GNU Lesser General Public
 *   License along with this library; if not, write to the Free Software
 *   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
 *
 *}
unit alsa;

{$MODE objfpc}
{$PACKRECORDS c}
{$LINKLIB c}

interface

uses
  ctypes;

const
  libasound = 'asound';

type
  { PCM generic info container }
  PPsnd_pcm_info_t = ^Psnd_pcm_info_t;
  Psnd_pcm_info_t = Pointer;

  { PCM hardware configuration space container }
  PPsnd_pcm_hw_params_t = ^Psnd_pcm_hw_params_t;
  Psnd_pcm_hw_params_t = Pointer;

  { PCM software configuration container }
  PPsnd_pcm_sw_params_t = ^Psnd_pcm_sw_params_t;
  Psnd_pcm_sw_params_t = Pointer;

  { PCM status container }
  PPsnd_pcm_status_t = ^Psnd_pcm_status_t;
  Psnd_pcm_status_t = Pointer;

  { PCM access types mask }
  PPsnd_pcm_access_mask_t = ^Psnd_pcm_access_mask_t;
  Psnd_pcm_access_mask_t = Pointer;

  { PCM formats mask }
  PPsnd_pcm_format_mask_t = ^Psnd_pcm_format_mask_t;
  Psnd_pcm_format_mask_t = Pointer;

  { PCM subformats mask }
  PPsnd_pcm_subformat_mask_t = ^Psnd_pcm_subformat_mask_t;
  Psnd_pcm_subformat_mask_t = Pointer;

  { PCM handle }
  PPsnd_pcm_t = ^Psnd_pcm_t;
  Psnd_pcm_t = Pointer;

  { CTL Handle}
  PPsnd_ctl_t = ^Psnd_ctl_t;
  Psnd_ctl_t = Pointer;

  { CTL type }
  PPsnd_ctl_type_t = ^Psnd_ctl_type_t;
  Psnd_ctl_type_t = ^snd_ctl_type_t;
  snd_ctl_type_t = cint;

  { PCM sample format }
  Psnd_pcm_format_t = ^snd_pcm_format_t;
  snd_pcm_format_t = cint;

  { PCM stream (direction) }
  Psnd_pcm_stream_t = ^snd_pcm_stream_t;
  snd_pcm_stream_t = cint;

  { PCM access type }
  Psnd_pcm_access_t = ^snd_pcm_access_t;
  snd_pcm_access_t = cint;

  { Unsigned frames quantity }
  Psnd_pcm_uframes_t = ^snd_pcm_uframes_t;
  snd_pcm_uframes_t = cuint;

  { Signed frames quantity }
  Psnd_pcm_sframes_t = ^snd_pcm_sframes_t;
  snd_pcm_sframes_t = cint;

const
	{ Unknown }
	SND_PCM_FORMAT_UNKNOWN: snd_pcm_format_t = -1;
	{ Signed 8 bit }
	SND_PCM_FORMAT_S8: snd_pcm_format_t = 0;
	{ Unsigned 8 bit }
	SND_PCM_FORMAT_U8: snd_pcm_format_t = 1;
	{ Signed 16 bit Little Endian }
	SND_PCM_FORMAT_S16_LE: snd_pcm_format_t = 2;
	{ Signed 16 bit Big Endian }
	SND_PCM_FORMAT_S16_BE: snd_pcm_format_t = 3;
	{ Unsigned 16 bit Little Endian }
	SND_PCM_FORMAT_U16_LE: snd_pcm_format_t = 4;
	{ Unsigned 16 bit Big Endian }
	SND_PCM_FORMAT_U16_BE: snd_pcm_format_t = 5;
	{ Signed 24 bit Little Endian using low three bytes in 32-bit word }
	SND_PCM_FORMAT_S24_LE: snd_pcm_format_t = 6;
	{ Signed 24 bit Big Endian using low three bytes in 32-bit word }
	SND_PCM_FORMAT_S24_BE: snd_pcm_format_t = 7;
	{ Unsigned 24 bit Little Endian using low three bytes in 32-bit word }
	SND_PCM_FORMAT_U24_LE: snd_pcm_format_t = 8;
	{ Unsigned 24 bit Big Endian using low three bytes in 32-bit word }
	SND_PCM_FORMAT_U24_BE: snd_pcm_format_t = 9;
	{ Signed 32 bit Little Endian }
	SND_PCM_FORMAT_S32_LE: snd_pcm_format_t = 10;
	{ Signed 32 bit Big Endian }
	SND_PCM_FORMAT_S32_BE: snd_pcm_format_t = 11;
	{ Unsigned 32 bit Little Endian }
	SND_PCM_FORMAT_U32_LE: snd_pcm_format_t = 12;
	{ Unsigned 32 bit Big Endian }
	SND_PCM_FORMAT_U32_BE: snd_pcm_format_t = 13;
	{ Float 32 bit Little Endian, Range -1.0 to 1.0 }
	SND_PCM_FORMAT_FLOAT_LE: snd_pcm_format_t = 14;
	{ Float 32 bit Big Endian, Range -1.0 to 1.0 }
	SND_PCM_FORMAT_FLOAT_BE: snd_pcm_format_t = 15;
	{ Float 64 bit Little Endian, Range -1.0 to 1.0 }
	SND_PCM_FORMAT_FLOAT64_LE: snd_pcm_format_t = 16;
	{ Float 64 bit Big Endian, Range -1.0 to 1.0 }
	SND_PCM_FORMAT_FLOAT64_BE: snd_pcm_format_t = 17;
	{ IEC-958 Little Endian }
	SND_PCM_FORMAT_IEC958_SUBFRAME_LE: snd_pcm_format_t = 18;
	{ IEC-958 Big Endian }
	SND_PCM_FORMAT_IEC958_SUBFRAME_BE: snd_pcm_format_t = 19;
	{ Mu-Law }
	SND_PCM_FORMAT_MU_LAW: snd_pcm_format_t = 20;
	{ A-Law }
	SND_PCM_FORMAT_A_LAW: snd_pcm_format_t = 21;
	{ Ima-ADPCM }
	SND_PCM_FORMAT_IMA_ADPCM: snd_pcm_format_t = 22;
	{ MPEG }
	SND_PCM_FORMAT_MPEG: snd_pcm_format_t = 23;
	{ GSM }
	SND_PCM_FORMAT_GSM: snd_pcm_format_t = 24;
	{ Special }
	SND_PCM_FORMAT_SPECIAL: snd_pcm_format_t = 31;
	{ Signed 24bit Little Endian in 3bytes format }
	SND_PCM_FORMAT_S24_3LE: snd_pcm_format_t = 32;
	{ Signed 24bit Big Endian in 3bytes format }
	SND_PCM_FORMAT_S24_3BE: snd_pcm_format_t = 33;
	{ Unsigned 24bit Little Endian in 3bytes format }
	SND_PCM_FORMAT_U24_3LE: snd_pcm_format_t = 34;
	{ Unsigned 24bit Big Endian in 3bytes format }
	SND_PCM_FORMAT_U24_3BE: snd_pcm_format_t = 35;
	{ Signed 20bit Little Endian in 3bytes format }
	SND_PCM_FORMAT_S20_3LE: snd_pcm_format_t = 36;
	{ Signed 20bit Big Endian in 3bytes format }
	SND_PCM_FORMAT_S20_3BE: snd_pcm_format_t = 37;
	{ Unsigned 20bit Little Endian in 3bytes format }
	SND_PCM_FORMAT_U20_3LE: snd_pcm_format_t = 38;
	{ Unsigned 20bit Big Endian in 3bytes format }
	SND_PCM_FORMAT_U20_3BE: snd_pcm_format_t = 39;
	{ Signed 18bit Little Endian in 3bytes format }
	SND_PCM_FORMAT_S18_3LE: snd_pcm_format_t = 40;
	{ Signed 18bit Big Endian in 3bytes format }
	SND_PCM_FORMAT_S18_3BE: snd_pcm_format_t = 41;
	{ Unsigned 18bit Little Endian in 3bytes format }
	SND_PCM_FORMAT_U18_3LE: snd_pcm_format_t = 42;
	{ Unsigned 18bit Big Endian in 3bytes format }
	SND_PCM_FORMAT_U18_3BE: snd_pcm_format_t = 43;
	SND_PCM_FORMAT_LAST: snd_pcm_format_t = 43;

	{ Playback stream }
	SND_PCM_STREAM_PLAYBACK: snd_pcm_stream_t = 0;
	{ Capture stream }
	SND_PCM_STREAM_CAPTURE: snd_pcm_stream_t = 1;
	SND_PCM_STREAM_LAST: snd_pcm_stream_t = 1;

	{ mmap access with simple interleaved channels }
	SND_PCM_ACCESS_MMAP_INTERLEAVED: snd_pcm_access_t = 0;
	{ mmap access with simple non interleaved channels }
	SND_PCM_ACCESS_MMAP_NONINTERLEAVED: snd_pcm_access_t = 1;
	{ mmap access with complex placement }
	SND_PCM_ACCESS_MMAP_COMPLEX: snd_pcm_access_t = 2;
	{ snd_pcm_readi/snd_pcm_writei access }
	SND_PCM_ACCESS_RW_INTERLEAVED: snd_pcm_access_t = 3;
	{ snd_pcm_readn/snd_pcm_writen access }
	SND_PCM_ACCESS_RW_NONINTERLEAVED: snd_pcm_access_t = 4;
	SND_PCM_ACCESS_LAST: snd_pcm_access_t = 4;

	{ Kernel level CTL }
	SND_CTL_TYPE_HW: snd_ctl_type_t = 0;
	{ Shared memory client CTL }
	SND_CTL_TYPE_SHM: snd_ctl_type_t = 1;
	{ INET client CTL (not yet implemented) }
	SND_CTL_TYPE_INET: snd_ctl_type_t = 2;
	{ external control plugin }
	SND_CTL_TYPE_EXT: snd_ctl_type_t = 3;

  { Lower boundary of sound error codes. }
  SND_ERROR_BEGIN                = 500000;
  { Kernel/library protocols are not compatible. }
  SND_ERROR_INCOMPATIBLE_VERSION = SND_ERROR_BEGIN + 0;
  { Lisp encountered an error during acall. }
  SND_ERROR_ALISP_NIL            = SND_ERROR_BEGIN + 1;

{Functions neccessary to perform audio output}
function snd_pcm_open(pcm: PPsnd_pcm_t; name: PChar;
	stream: snd_pcm_stream_t; mode: cint): cint; cdecl; external libasound;
function snd_pcm_close(pcm: Psnd_pcm_t): cint; cdecl; external libasound;
function snd_pcm_writei(pcm: Psnd_pcm_t; buffer: Pointer;
  size: snd_pcm_uframes_t): snd_pcm_sframes_t; cdecl; external libasound;
function snd_pcm_recover(pcm: Psnd_pcm_t; err, silent: cint): cint; cdecl; external libasound;         // added in from fpAlsa
function snd_pcm_prepare(pcm: Psnd_pcm_t): cint; cdecl; external libasound;
function snd_pcm_resume(pcm: Psnd_pcm_t): cint; cdecl; external libasound;
function snd_pcm_start(pcm: Psnd_pcm_t): cint; cdecl; external libasound;
function snd_pcm_pause(pcm: Psnd_pcm_t; enable: cint): cint; cdecl; external libasound;
function snd_pcm_drop(pcm: Psnd_pcm_t): cint; cdecl; external libasound;
function snd_pcm_wait(pcm: Psnd_pcm_t; timeout: cint): cint; cdecl; external libasound;
function snd_pcm_set_params(pcm: Psnd_pcm_t; format: snd_pcm_format_t;
  access: snd_pcm_access_t; channels, rate: cuint; soft_resample: cint;
  latency: cuint): cint; cdecl; external libasound;
function snd_pcm_avail(pcm: Psnd_pcm_t): snd_pcm_sframes_t; cdecl; external libasound;
function snd_pcm_avail_update(pcm: Psnd_pcm_t): snd_pcm_sframes_t; cdecl; external libasound;
function snd_pcm_avail_delay(pcm: Psnd_pcm_t; availp: Psnd_pcm_sframes_t;
  delayp: Psnd_pcm_sframes_t): cint; cdecl; external libasound;

{ALSA snd_pcm_info functions}
function snd_pcm_info_malloc(ptr: PPsnd_pcm_info_t): cint; cdecl; external libasound;
procedure snd_pcm_info_free(obj: Psnd_pcm_info_t); cdecl; external libasound;
procedure snd_pcm_info_copy(dst: Psnd_pcm_info_t; src: Psnd_pcm_info_t); cdecl; external libasound;
function snd_pcm_info_get_device(obj: Psnd_pcm_info_t): cuint; cdecl; external libasound;
function snd_pcm_info_get_subdevice(obj: Psnd_pcm_info_t): cuint; cdecl; external libasound;
function snd_pcm_info_get_stream(obj: Psnd_pcm_info_t): snd_pcm_stream_t; cdecl; external libasound;
function snd_pcm_info_get_card(obj: Psnd_pcm_info_t): cint; cdecl; external libasound;
function snd_pcm_info_get_id(obj: Psnd_pcm_info_t): PChar; cdecl; external libasound;
function snd_pcm_info_get_name(obj: Psnd_pcm_info_t): PChar; cdecl; external libasound;
function snd_pcm_info_get_subdevice_name(obj: Psnd_pcm_info_t): PChar; cdecl; external libasound;
//function snd_pcm_info_get_class(obj: Psnd_pcm_info_t): snd_pcm_class_t; cdecl; external libasound;
//function snd_pcm_info_get_subclass(obj: Psnd_pcm_info_t): snd_pcm_subclass_t; cdecl; external libasound;
function snd_pcm_info_get_subdevices_count(obj: Psnd_pcm_info_t): cuint; cdecl; external libasound;
function snd_pcm_info_get_subdevices_avail(obj: Psnd_pcm_info_t): cuint; cdecl; external libasound;
//function snd_pcm_info_get_sync(obj: Psnd_pcm_info_t): snd_pcm_sync_id_t; cdecl; external libasound;
procedure snd_pcm_info_set_device(obj: Psnd_pcm_info_t; val: cuint); cdecl; external libasound;
procedure snd_pcm_info_set_subdevice(obj: Psnd_pcm_info_t; val: cuint); cdecl; external libasound;
procedure snd_pcm_info_set_stream(obj: Psnd_pcm_info_t; val: snd_pcm_stream_t); cdecl; external libasound;

{Control functions}
function snd_card_next(card: Pcint): cint; cdecl; external libasound;
function snd_card_get_index(name: PChar): cint; cdecl; external libasound;
function snd_card_get_name(card: cint; name: PPChar): cint; cdecl; external libasound;
function snd_card_get_longname(card: cint; name: PPChar): cint; cdecl; external libasound;

function snd_ctl_open(ctl: PPsnd_ctl_t; name: PChar; mode: cint): cint; cdecl; external libasound;
function snd_ctl_close(ctl: Psnd_ctl_t): cint; cdecl; external libasound;
function snd_ctl_pcm_next_device(ctl: Psnd_ctl_t; device: Pcint): cint; cdecl; external libasound;
function snd_ctl_pcm_info(ctl: Psnd_ctl_t; info: Psnd_pcm_info_t): cint; cdecl; external libasound;

{Error handling}
function snd_strerror(errnum: cint): PChar; cdecl; external libasound;


implementation

end.
