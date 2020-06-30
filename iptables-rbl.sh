#!/bin/bash

iptables -N LISTAIPS
iptables -I INPUT -i eth1 -j LISTAIPS
for list in `cat /home/fwadmin/rbl-ip.txt`;do
  iptables -A LISTAIPS -s $list -j REJECT
done
