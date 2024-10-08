## Content
1. [Basic Commands](#basic-linux-commands)
2. [VI Editor](#vi-editor)
3. [grep command](#grep-command)
4. [Soft Hard Link](#hardlink-and-softlink)
5. [Filter Command](#filter-command)
6. [File Permissions](#file-permissions)

## Basic Linux Commands

### Help docs - man command
```man <command>```  displays the description or usage of the actual command
### Listing the Files or Directory
```ls``` lists the files or directory in the existing path

``ll`` detailed description about the files 

``ls -lhrt`` short hand which displays the detailed description such as created time, file size etc of file or directory

### Creating the file
```cat > <filename> ``` ctrl+d to exist creates the file, creates single file at a time can give the content in the next line and exit to
give the content at the time of creation

``touch <file1> <file2> ..`` Can create multiple files at a time, cannot give content at creation

``echo "<content>" > <filename>`` Creates the file with content, cannot create multiple files at a time.

### Appending the file
``cat >> <filename> <ENTER> <content>`` Appends the content to the file

``echo <content> >> <filename>`` Appends the content to file using the echo command

Note: In the both above mentioned cases multiple file append is not possible

### Creating the directory
``mkdir <directory_name>`` Creates the directory

``mkdir -m 777 <directory_name>`` Creates the directory with permission (-m flag)

``mkdir -p <directory>/{sub_directory/{..}..}`` Creates the recursive sub directories

### Copy file/directory
``cp <source_file> <destination_dir>`` copies the files

``cp -rvfp <source_dir> <destination_dir>`` copies the directory

```
flags: 
r-recursive, v-verbose (description), f-force (no acknowledgement), p-preserve (keep original meta) 

without p flag the modified date will get updated on copied action time (meta changes)
```

### Move/Rename file/directory
``mv <source_file/dir>  <destination_file/dir>`` Moves/rename/overright the file or folder as per the scenario

### Remove file/directory
``rm <filename>`` deletes the file

``rm -rf <directory>`` deletes the directory

```
flags:
r-recursive, f-force (avoids the prompt scenario)
```

## VI Editor
### Basic Command
``vi <filename>``  To open the file

### Extended Command Mode
Operations performed in command Mode or after pressing ESC

``:q!`` Exit file without saving the changes

``:x`` or ``:wq!`` Saves the content in file and exit

``:set nu`` sets the line number

``Note: here ! means do the action forcefully`` 

### Command Mode (Default Mode, ESC)
``gg`` moves cursor to beginning of the file

``G`` moves cursor to the end of the file

``w`` moves one word forward

``b`` moves one word backward

``nw`` eg: 5W, moves 5 word forward

``nb`` moves n word backward

``u`` undo the changes, (useful while making changes in Insert Mode)

``ctrl+r`` redo the changes

``yy`` copy the line were the cursor, (will not copy to main clipboard, ctrl+v not works)

``nyy`` eg: 5yy, copies 5 line from the cursor

``p`` paste the copied content below the cursor

``P`` paste the copied content above the cursor

``dd`` deletes the entire line, where cursor placed

``ndd`` eg:5dd, deletes the 5 lines from the cursor

``dw`` deletes the word, where cursor placed 

``/<word>`` searches the word, Press ``Enter`` then ``n`` to search the next occurrence of the same word 

### Insert Mode (ESC + i)

It was just like the normal text file editing mode, after doing the changes follow the 
extended command for further actions

## Grep Command

![](../media/Linux_commands/grep_command_1.png)
![](../media/Linux_commands/grep_command_2.png)

## [Hardlink and softlink](https://www.geeksforgeeks.org/soft-hard-links-unixlinux/)
![img.png](../media/Linux_commands/hardlink_soflink1.png)

Type of file identified with `ll` or `ls` command in linux

![img.png](https://i.pinimg.com/564x/d3/e7/4a/d3e74a87f423bbb62e39d9de30e6399d.jpg)

### Difference between Hardlink and Sofetlink
![img.png](../media/Linux_commands/hardlink_softlink_2.png)
``Note: *inode - Index Number (Like address of the file), ls -il command to view inode number``

### Command
To create the softlink

``ln -s <source> <destination link>``

To create the hardlink

``ln <source> <destination link>``

Note: Modifying the content reflects in 2 way between original and link files

## Filter Command
![img.png](../media/Linux_commands/filter_1.png)

[Sort command in detail](https://www.geeksforgeeks.org/sort-command-linuxunix-examples/)

[cut command in detail](https://www.geeksforgeeks.org/cut-command-linux-examples/)

[sed command in detail](https://www.geeksforgeeks.org/sed-command-in-linux-unix-with-examples/)

[find command in detail](https://www.redhat.com/sysadmin/linux-find-command)

[locate command in detail](https://www.geeksforgeeks.org/locate-command-in-linux-with-examples/)

## File permissions
![img.png](../media/Linux_commands/file_permission_1.png)

![](https://miro.medium.com/v2/resize:fit:660/0*5FgkfJtRbgCQIJuk.png)

![img.png](../media/Linux_commands/file_permission_2.png)

![](https://i.redd.it/vkxuqbatopk21.png)

example:

Symbolic link: chmod u=rwx,g=rx,o=w file.txt

Absolute link: chmod 752 file.txt

``` 
Note : Default permission for file in linux is rw r r (644)
       Default permission for directory in linux rwx rx rx (755)
```

### Umask

Decider for assigning the default permission for the file

![img.png](../media/Linux_commands/file_permission_3.png)

