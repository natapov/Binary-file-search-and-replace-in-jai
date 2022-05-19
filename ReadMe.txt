This is a program to find and replace certain instructions (patterns of bits) in executables (or any binary files).
The program will find all the files in the given folder (and its subfolders) that are named a certain way.
It will back those files up and then search and replace for what you provided in them.

There is a confirmation dialog to make sure settings.txt was parsed correctly and another one after all the files are found, before they are patched. 

Use those dialogs to make sure the program is in the right directory and won't do something you didn't intend!

Backup files are saved in the same folder as the changed files, just remove "_backup" from the end of their name to restore. 
This program will not touch the backup files and won't backup again if a backup already exists.

********************
Settings.txt format:
********************
Lines starting with "#" are ignored, so are empty lines.

The first line should be a directory.

The second line should be the name of the file you want to patch or, if you want to patch multiple files, some substrings that all their names contain (like ".exe" if you want to patch all .exe files in a folder). You can specify as many substrings as you like.

Don't use quotes and seperate the substrings with one space.

After that put the hex pattern you want to find and in the next line what you want to replace if with. Make sure to use a space every two letters like this:

#from:
aa b2 ce ff
#to:
0a b3 c2 fe

The letters don't need to be uppercase or lowercase. You can put as many find and replace "spots" as you want.

********
Warning:
********
Please use this program carefully, I tried to make it as safe as possible but by its nature it will fuck your pc up if you use it carelessly. It is provided "as is" with no warranty.

A precompiled executable is provided given that the language this is written in is still in closed beta.