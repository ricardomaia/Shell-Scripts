#!/bin/sh

# Another option would be to use the command --> ps aux | egrep '(tty|pts)' | awk '{print $2}' | xargs kill
# Kills the terminal process of all connected users
for x in `/bin/ps aux | grep tty | cut -c7-14`; do
   kill -9 "`expr "$x" : '[ ]*\(.*[^ ]\)[ ]*$'`"
done

# Backup of files to be changed
cp /etc/pam.d/login /etc/pam.d/login-BACKUP
cp /etc/securetty /etc/securetty-BACKUP

# Block root login
echo "auth required pam_securetty.so" > /etc/pam.d/login
echo "null" > /etc/securetty

# Blocking other users
echo "auth requisite pam_nologin.so" >> /etc/pam.d/login
touch /etc/nologin
