#!/bin/sh
BASEDIR="/opt"
URL="http://www.joewein.net/dl/bl/dom-bl-base.txt"
WEBSERVER_FOLDER="/var/www"
 
# !!! DO NOT CHANGE BELOW THIS LINE !!!
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
 
 
cd $BASEDIR
domainfile=$BASEDIR"/domains.txt"
 
# IP Address validation
# http://www.linuxjournal.com/content/validating-ip-address-bash-script
function valid_ip()
{
    local  ip=$1
    local  stat=1
 
    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
            && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}
 
# Delete old domains file.
if [ -f "$domainfile" ]
then
       rm $domainfile
 
else
 
       echo "$domainfile not found."
 
fi
 
# Get new domains RBL
wget -q $URL -O $domainfile
 
# Read each line of domains file
while read -r line
 
do
 
    name=$line
 
    echo "Domain read from file - $name"
 
    ip=`dig +short a $name`
 
    if valid_ip $ip
 
        then  echo "$ip"; echo "$ip" >> ip.txt;
        else echo "IP invalido: '$ip'"
        ip2=`dig +short a $ip`
 
        if valid_ip $ip; then echo "Novo IP: '$ip2'"; echo "$ip2" >> ip.txt; fi;
 
    fi
 
done < "$domainfile"
 
# Removing duplicate IPs addresses
sort ip.txt | uniq > ip-reduced.txt
 
# Copy file to Web Server
cp ip-reduced.txt $WEBSERVER_FOLDER
