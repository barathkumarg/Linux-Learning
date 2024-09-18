#!/bin/bash

: '
grep command syntax:
  grep [options] <search pattern> [filename]

Note: test.txt,pattern.txt file used (copy them from misc directory)
'

# Displays the matched string in file (no option used)
grep windows test.txt

: '
output: windows
'

# Displays the matched occurrence
grep -c windows test.txt

: '
output: 1
'

# Displays the line number of the matched pattern
grep -n windows test.txt

: '
output: 3:windows
'

# Displays the matched string by ignoring the case sensitive
grep -i linux test.txt

: '
output: LINUX
        LINUX - distributions
'

#Displays the non matching pattern's content
grep -v LINUX test.txt

: '
output: The list of OS
        mac
        windows

'

#Displays the content matched with the expression (text starts with 'win' )
grep -e win* test.txt

: '
output: windows
'

#Displays the content matched with pattern found in another file (file: pattern.txt)
grep -f pattern.txt test.txt

: '
output: windows
        LINUX
        LINUX - distributions
'

# Displays the content matched on extended regular expressions
# NOTE: multiple regular expression can be used further
grep -E '(windows|mac)' test.txt

: '
output: mac
        windows
'

# Displays the content when whole word matched
grep -w windows test.txt

: '
output: windows

Note: if wind was given no output will be generated, where it works on above discussed commands
'

# Displays only the matched content
grep -o LINUX test.txt

: '
output: LINUX
        LINUX

'