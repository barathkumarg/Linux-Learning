adduser barath
# creation of user, we can also use useradd instead of "adduser". whenever we create user, there will be default primary group will be created
grep barath /etc/passwd
grep barath /etc/group
# default values of user creation are stored in /etc/login.defs
useradd -c "creating user" -d /var/barath2 barath2
# creating user with customised shell
usermod -d /home/barath2 -s /sbin/login barath2
# modifying user shell and login
useradd barath3 -u 501 -g 501 -d /home/barath3 -c "creating barath3"
# creating user with customised id
#if group doesnt exist try below cmd
groupadd -g 501 barath3
# change password
passwd barath3
usermod -d /etc/barath3
usermod -l barath333 barath3
# used to change login name 
usermod -L barath333
# used to lock a user
usermod -U barath333
# used to unlock a user

#changing password  params
chage barath 
# in this we can change it using interactive mode 

chage -E 2024-11-10 barath 
#password inctive arguement
chage -l barath
# to view passwd onfo about user
chage -E -1 barath 
# making password expire inactive

userdel -r barath333
# used to delete a user with removing directory


#group
groupadd vegetable
gpasswd vegetable
#adding password to group
groupadd -g 501 fruit
# adding group with specific id

groupmod -g 502  fruit
# changing group id
groupmod -n  fruits fruit
# changing group name
useradd tomato
useradd potato

usermod -G vegetable potato
usermod -G vegetable tomato
# adding user in group

gpasswd -d tomato vegetable
gpasswd -d potato vegetable
# removing user from group

gpasswd -M tomato, potato  vegatable
#adding multiple users in group

