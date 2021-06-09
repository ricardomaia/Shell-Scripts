#!/bin/sh

#IP do servidor
SERVER_IP="xxx.xxx.xxx.xxx"

# Limpar todas as regras
iptables -F
iptables -X

# Politica default
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

# Loopback aceito
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# PERMITE PORTA 80 (http)
iptables -A INPUT -p tcp -s 0/0 -d $SERVER_IP --sport 513:65535 --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp -s $SERVER_IP -d 0/0 --sport 80 --dport 513:65535 -m state --state ESTABLISHED -j ACCEPT

# PERMITE PORTA 443 (https)
iptables -A INPUT -p tcp -s 0/0 -d $SERVER_IP --sport 513:65535 --dport 443 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp -s $SERVER_IP -d 0/0 --sport 443 --dport 513:65535 -m state --state ESTABLISHED -j ACCEPT

# Certifica-se de negar todos os outros pacotes
iptables -A INPUT -j DROP
iptables -A OUTPUT -j DROP
