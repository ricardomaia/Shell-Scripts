#!/bin/bash

#rblDomainURL="http://www.joewein.net/dl/bl/dom-bl-base.txt"

# https://www.vivaolinux.com.br/dica/IPtables-Blacklist-Script
# idn2
# TODO: Use IPSET

# https://www.ipdeny.com/ipblocks/data/countries/all-zones.tar.gz
# https://www.iblocklist.com/lists
# https://www.spamhaus.org/drop/
# https://github.com/matomo-org/referrer-spam-list/blob/master/spammers.txt
# https://check.torproject.org/exit-addresses
# https://check.torproject.org/torbulkexitlist
# https://rules.emergingthreats.net/blockrules/compromised-ips.txt
# https://lists.blocklist.de/lists/all.txt
# https://iplists.firehol.org/
# https://raw.githubusercontent.com/stamparm/ipsum/master/ipsum.txt

rblDomainURL="http://www.joewein.net/dl/bl/dom-bl.txt"
BASEDIR="/home/fwadmin"

cd $BASEDIR
domainfile=$BASEDIR"/dom-bl-base.txt"


if [ -f "$domainfile" ]
then
        echo "$domainfile found. Deleting..."
        rm $domainfile
else
        echo "$domainfile not found."
fi

wget -q $rblDomainURL -O $domainfile

while read -r line
do
    name=$line
    echo "Domain read from file - $name"
    dig +short $name >> ip-bl.txt
done < "$domainfile"


#http://www.linuxjournal.com/content/validating-ip-address-bash-script
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


rblfile="ip-bl.txt"

while IFS='' read -r line || [[ -n "$line" ]]; do
   if valid_ip $line; then
     echo "OK - Valid IP address: $line"
   else
     echo "ERROR - Invalid IP address: $line"
     sed -i '/'$line'/d' $rblfile
   fi
done < "$rblfile"

sort -u $rblfile | uniq > rbl-ip.txt
