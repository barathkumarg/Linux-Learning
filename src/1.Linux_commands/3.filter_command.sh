less misc/filter-commands.txt
more misc/filter-commands.txt
head misc/filter-commands.txt
head -2 misc/filter-commands.txt 
# -number gives no of lines as per we need (default 10)
tail misc/filter-commands.txt
tail -f misc/filter-commands.txt
# -f it will be a active log  like follow up the things that we do in that file
sort misc/filter-commands.txt
cut -d, -f2  misc/filter-commands.txt
# -d is delimiter to separate values anf -f(numbers)  represents the column which we need it
sed 's/Hannah Black/Jessy/g' misc/filter-commands.txt
# s/text for searching the word /text/g is for replacing the searched word
find / -name filter-commands.txt
# used to find the file location wrt given directory. -name is an option where we can give our fiel name. locate will show all locations where file has been before and now.
# we can multiple commands in find. main arguements of find are -name, -inum, -type, -user, -group
ls -il
# used to get inum to use this another option in find command
