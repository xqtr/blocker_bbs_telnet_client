// Play some music!!!

    Do you want to add some music/sound fx to your BBS? Now you can, 
    with Blocker! It's not easy, but you can do it and it also opens 
    many possibilities in using your BBSes, like Sound Notifications 
    ;)
    
    How it's done...
    Blocker uses some character codes to recognize when to play a 
    track file. So, when it finds a code, it knows to play a specific 
    file or stop the music. The code is similar to Pipe codes but 
    instead of a Pipe it uses the SOH/x01 (#01 for Pascal) character 
    and also two more characters from 0 to 9 and A to Z.
    
    For displaying the codes in this file, i will use the [SOH] label.
    
    So, a music code can be: [SOH]00 or [SOH]AF or [SOH]WW etc. One 
    exception is the StopMusic code which is 3 time the [SOH] char. 
    like [SOH][SOH][SOH]. Values from 00 to FE are used for 
    recognizing tracks. This way you have the possibility to use 254
    tracks, which i think are enough. The FF code is a special one 
    and is used to play a random music file, from a specific folder. 
    This way, you can use even more tracks than 254. Let's recap...
    
    [SOH][SOH][SOH]    : Stop Music
    [SOH]00 to [SOH]FE : Play Track with HEX value 00 to FE
    [SOH]FF            : Play random track from specified folder.
    
    How Blocker gets the tracks...
    Actually, Blocker can't get any track :( You have to provide 
    them. A BBS that wants to add Music/Sound, should build a package 
    containing all the tracks, in a specified directory structure and 
    also include an INI file. The INI file must have a name, exactly 
    as the name of the BBS used in the PhoneBook. Lets see an 
    example.
    
    Lets say you have a PhoneBook entry for a BBS called "Ansimania 
    BBS". The music package for this BBS, should have the following 
    format:
    
    + ansimania           [DIR]
    +--+ random           [DIR]
    [  [ track1.mod       [File]
    [  [ track2.mod       [File]
    [  [ etc.
    [
    [ trackx.mod          [File]
    [ tracky.mod          [File]
    [ trackz.mod          [File]
    [ etc.
    [ Ansimania_BBS.ini   [File]
    
    If you have enabled to use music for the specific BBS in your 
    PhoneBook, Blocker will search for the Ansimania_BBS.ini file, it 
    will read it and then play the music according to the music codes 
    the BBS will provide.
    
    The INI file have this format:
    
    [music]
    dir=music/local/
    01=modem.xm
    02=evil.xm
    03=programming.xm
    
    dir=
    This is the directory where the music files are stored. It can be 
    anywhere in your disk. You can use the  pipe code to specify 
    that is inside the same folder as Blocker (Blocker Directory).
    
    01=, 02=... FE=,
    This tells which file to play when Blocker sees the [SOX]10 code. 
    Accordingly you can have values up to FE=
    
    The Random Dir...
    As you see there is also a dir. called "random". Inside this 
    directory you can put any track music you want. When Blocker 
    recognizes the [SOH]FF command, it will pick one track, randomly, 
    from this directory and play it. This way you can use the [SOH]FF 
    command to have different music, on the same menus/functions, 
    with just using one code.
    
    Check the included package for Another Droid BBS, to get an 
    example and understand the use better. Also, login to Another 
    Droid BBS to listen to it ;)
    
    
    
    // Mystic BBS Scripts
    
    In the music folder you will find two mystic bbs scripts (MPL). With
    those two scripts you add the necessary music codes to your menus, by 
    just editing them and adding a menu command.
    
    :: music.mps
    
    This script adds the music code to play the specified track. Compile it
    with MPLC and add it to a custom menu command, with the GX command. The 
    script has four parameters and you must use it like this:
    
    music x y attr track
    
    For example:
    
    music 1 25 0 FF
    
    This command will show the music code in position 1,25 in the screen with
    color 0/black and because its the code FF it will get a random track from 
    the random directory.
    
    You can change the color/attribute of the text, as well the position, so 
    it is masked from the users view and they can't see it ;)
    
    
    :: killmusic.mps
    
    Its use is the same as the music.mps script, but instead it shows the music
    code to kill/stop the music player. So in this case you only have to put
    three parameters like:
    
    killmusic x y attr
    
    For example
    
    killmusic 1 25 0
    
     