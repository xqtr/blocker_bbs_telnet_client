# blocker_bbs_telnet_client
Telnet Client for use with ANSI BBSes

This Application is based on Nodespy Code ver1.10, written for Mystic BBS, By James Coyle. The original code released under GPL3, so the same applies here.

Demo:
https://www.youtube.com/watch?v=PBEzEV-5oRA

Blocker Features:
- Full ANSI Support for BBSes
- Macros
- Insert any ASCII character with a dialog box
- Quotes/Tags with a press of a button
- Preview ANSI Files, locally
- Convert ANSI Files to Mystic BBS, Pipe Format
- Capture Current Screen, in ANSI
- Capture ANSI Graphics while connected
- ScrollBack
- Capture ScrollBack Buffer
- Up to 600 BBS Recods per Each PhoneBook File
- Open Infinite PhoneBook Files
- Immidiate Address Dial
- Import SyncTerm PhoneBook
- AutoText
- Music/Sounds
- Script to download fresh BBS list from BBSIndex.
- Use it as a DOOR program for linux BBSes
- ZMODEM Download / Upload
- Beep Sound in ALSA 
- Built in Emoticons
- Find Regular Expressions and launch external applications
- Built in script to find information about a BBS (Nodefinder)
- Modem and Keystroke FXs
- Copy/Paste, ASCII or ANSI with keyboard
- OnConnect and OnDisconnect events to play music or launch any application

Music/Sounds
---------
Play track music while viewing a BBS, see the Help section inside the app.
It can also play a modem handshake sound to emulate the good old dialup times
and also emulates mechanical keyboard sounds ;) Full old shit expirience!!!

Autotext
---------
Autotext is a simple feature, for writing text to BBSes with too much lag. If there is too much lag in the connection, its very difficult to write text (correct mistakes, go back etc.) So with autotext, you write the text you want locally in a Form and then its sended, automatically to the BBS.

Regular Expressions
-------------------
Detects RegEx values on screen and you can either copy the founded text or launch an application for it. For example you can use it to browse URLs.

DOOR
---------
To use it as a DOOR, in the command line specify the path and filename to the DOOR32.SYS file like:
./blocker /home/my/path/door32.sys

Make sure to configure properly all ACS levels in the configuration file (blocker.ini)

Bugs / ToDo
-----
- For the time being, IPv6 is not supported. If you have an IPv6 Address, convert it (if possible) to IPv4 and then enter it to connect.

