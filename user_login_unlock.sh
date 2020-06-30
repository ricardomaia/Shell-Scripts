#!/bin/sh
 
# Restores the original files
cp /etc/pam.d/login-BACKUP /etc/pam.d/login
cp /etc/securetty-BACKU /etc/securetty
rm /etc/nologin
