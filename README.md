# blocker_bbs_telnet_client
Telnet Client for use with ANSI BBSes

This Application is based on Code written for Mystic BBS, By James Coyle. The original code released under GPL3, so the same applies here.

The file contains all source code needed, in FreePascal. Also contains a bash script to compile the program from its directory/folder.

Blocker Features:
- Full ANSI Support for BBSes
- Macros
- Preview ANSI Files, locally
- Convert ANSI Files to Mystic BBS, Pipe Format
- Capture Current Screen, in ANSI
- Capture ANSI Graphics while connected
- ScrollBack
- Capture ScrollBack Buffer
- Up to 100 BBS Recods per Each PhoneBook File
- Open Infinite PhoneBook Files
- Immidiate Address Dial
- Import SyncTerm PhoneBook
- AutoText

Autotext
---------
Autotext is a simple feature, for writing text to BBSes with too much lag. If there is too much lag in the connection, its very difficult to write text (correct mistakes, go back etc.) So with autotext, you write the text you want locally in a Form and then its sended, automatically to the BBS.

Bugs
-----
- For the time being, IPv6 is not supported. If you have an IPv6 Address, convert it (if possible) to IPv4 and then enter it to connect.
- ZModem Upload/Download is very buggy. Some times you will get a file, but others not. :(  Working on it... 
