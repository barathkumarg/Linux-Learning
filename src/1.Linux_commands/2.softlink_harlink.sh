#!/bin/bash
: 'Note: Input and output found in `misc` directory

To create the softlink
'
ln -s misc/test.txt misc/testlink.txt

: '
output:
[ls command]
15614120 -rw-rw-r-- 2 barath barath 60 Sep 18 21:59 test.txt
15597946 lrwxrwxrwx 1 barath barath 13 Sep 18 22:14 testlink.txt -> misc/test.txt

'

: '
To create a hardlink
'
ln misc/test.txt misc/testhardlink.txt

: '
output:
[ls command]
15614120 -rw-rw-r-- 2 barath barath 60 Sep 18 21:59 test.txt
15614120 -rw-rw-r-- 2 barath barath 60 Sep 18 21:59 testhardlink.txt

'