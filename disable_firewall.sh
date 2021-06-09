#!/bin/sh

#IP do servidor
SERVER_IP="xxx.xxx.xxx.xxx"

# Limpar todas as regras
iptables -F
iptables -X

# Politica default
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT
