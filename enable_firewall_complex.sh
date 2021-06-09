#!/bin/sh

#IP do servidor
SERVER_IP="xxx.xxx.xxx.xxx/32"

# LIMPA TODAS AS REGRAS
iptables -F
iptables -X

# POLITICA DEFAULT
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

# LOOPBACK
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

########### Início da chain de Saída ###############

# Permissões de conexões de saída do servidor

# Permite DNS
iptables -A OUTPUT -p udp -o eth0 --dport 53 -d 0.0.0.0/0 -j ACCEPT

# Permite RSyslog com destino ao Papartrail e Splunk Storm
iptables -I OUTPUT -p udp -o eth0 --dport 27099 -d 67.214.212.0/20 -j ACCEPT
iptables -I OUTPUT -p tcp -o eth0 --dport 1:65535 -d 54.227.219.168/32 -j ACCEPT
iptables -I OUTPUT -p udp -o eth0 --dport 1:65535 -d 54.227.219.168/32 -j ACCEPT

iptables -I OUTPUT -p tcp -o eth0 --dport 27099 -d 45.56.114.176/32 -j ACCEPT
iptables -I OUTPUT -p udp -o eth0 --dport 27099 -d 45.56.114.176/32 -j ACCEPT

# Permite DHCP
iptables -I OUTPUT -p udp --dport 67:68 --sport 67:68 -j ACCEPT

# Permite HTTP, HTTPS e SSH
iptables -A OUTPUT -p tcp -o eth0 -d 0.0.0.0/0 -m multiport --dports 80,443,22 -m state --state NEW -j ACCEPT
iptables -A OUTPUT -p tcp -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT

# Permite SMPT (25)
iptables -A OUTPUT -p tcp -d 0.0.0.0/0 --dport 25 -j ACCEPT

# Permite echo request e echo reply
iptables -A OUTPUT -p icmp --icmp-type echo-request -j ACCEPT
iptables -A INPUT -p icmp --icmp-type echo-reply -j ACCEPT

# Aceitando as conexões estabelecidas de saída
iptables -t filter -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

########## FIM da chain de saída ####################

########## Início da chain de entrada ###############

# Permissões de conexões de entrada para o servidor

# Permite DHCP
iptables -I INPUT -i eth0 -p udp --dport 67:68 --sport 67:68 -j ACCEPT

# PERMITE PORTA 22 80 e 443 (ssh,http e https)
iptables -A INPUT -p tcp -m multiport --dports 22,80,443 -m state --state NEW -s 0.0.0.0/0 -j ACCEPT

# Proteção para ataque de dicionário SSH
iptables -I INPUT -p tcp -m tcp --dport 22 -m state --state NEW -m recent --set --name SSH --rsource
iptables -I INPUT -p tcp -m tcp --dport 22 -m state --state NEW -m recent --update --seconds 180 --hitcount 4 --name SSH --rsource -j DROP

# PERMITE PORTA 53 (dns)
iptables -A INPUT -p udp --sport 53 -s 0.0.0.0/0 -j ACCEPT

# Aceitando as conexões estabelecidas de entrada
iptables -t filter -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

############ Fim da chain de entrada #################3

########### Início das regras de proteção ###########

# Proteção contra DOS
iptables -A INPUT -m state --state INVALID -j DROP
iptables -A OUTPUT -p tcp ! --tcp-flags SYN,RST,ACK SYN -m state --state NEW -j DROP
iptables -A INPUT -p tcp -m limit --limit 25/minute --limit-burst 100 -j ACCEPT

# Proteção contra DOS HTTP
iptables -A INPUT -p tcp --dport 80 -i eth0 -m state --state NEW -m recent --set
iptables -A INPUT -p tcp --dport 80 -i eth0 -m state --state NEW -m recent --update --seconds 1 --hitcount 10 -j DROP
iptables -A INPUT -p tcp --dport 443 -i eth0 -m state --state NEW -m recent --set
iptables -A INPUT -p tcp --dport 443 -i eth0 -m state --state NEW -m recent --update --seconds 1 --hitcount 10 -j DROP

# Proteção contra requisições ICMP Timestamp
iptables -A INPUT -p icmp --icmp-type timestamp-request -j DROP
iptables -A OUTPUT -p icmp --icmp-type timestamp-reply -j DROP

# Proteção SYN Flood
iptables -N syn-flood
iptables -A INPUT -p tcp --syn -j syn-flood
iptables -A syn-flood -m limit --limit 1/s --limit-burst 4 -j RETURN
iptables -A syn-flood -j DROP

# Proteção contra portscan
iptables -A INPUT -p tcp --tcp-flags ALL FIN,URG,PSH -m limit --limit 1/s -j DROP
iptables -A INPUT -p tcp --tcp-flags ALL NONE -m limit --limit 1/s -j DROP
iptables -A INPUT -p tcp --tcp-flags ALL ALL -m limit --limit 1/s -j DROP
iptables -A INPUT -p tcp --tcp-flags ALL FIN,SYN -m limit --limit 1/s -j DROP
iptables -A INPUT -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -m limit --limit 1/s -j DROP
iptables -A INPUT -p tcp --tcp-flags SYN,RST SYN,RST -m limit --limit 1/s -j DROP
iptables -A INPUT -p tcp --tcp-flags SYN,FIN SYN,FIN -m limit --limit 1/s -j DROP

# Proteção contra ataques de fragmentação de pacotes
iptables -N VALID_CHECK
iptables -A VALID_CHECK -p tcp --tcp-flags ALL FIN,URG,PSH -j DROP
iptables -A VALID_CHECK -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -j DROP
iptables -A VALID_CHECK -p tcp --tcp-flags ALL ALL -j DROP
iptables -A VALID_CHECK -p tcp --tcp-flags ALL FIN -j DROP
iptables -A VALID_CHECK -p tcp --tcp-flags SYN,RST SYN,RST -j DROP
iptables -A VALID_CHECK -p tcp --tcp-flags SYN,FIN SYN,FIN -j DROP
iptables -A VALID_CHECK -p tcp --tcp-flags ALL NONE -j DROP

# FAZ O LOG DOS PACOTES DESCARTADOS
iptables -N LOGGING
iptables -A INPUT -j LOGGING
iptables -A LOGGING -m limit --limit 2/min -j LOG --log-prefix "IPTables Packet Dropped: " --log-level 7
iptables -A LOGGING -j DROP

############## Fim das regras de proteção ######################
