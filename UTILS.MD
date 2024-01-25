
# Shell Script

## Arquivos e Diretórios

### Espaço disponível em disco

```console
df -h
```

### Maiores diretórios

```console
du -h / | grep ^[0-9.]*G  | sort -n -r
```

### Arquivos maiores que 20MB no diretório corrente

```console
find . -size +20000k -exec du -h {} \;
```

### Listar arquivos modificados nas últimas 24 horas

```console
find / -mtime -1
```

  * ''-1'' para as  últimas 24h
  * ''-0,5'' para as últimas 12h
  * ''-0,25'' para as últimas 6h

Você pode restringir os resultados com o comando ''egrep'' fornecendo uma expressão regular. No exemplo abaixo são excluídos dos resultados arquivos terminados com a extensão ''.jpg''.

```console
find / -mtime -1 | egrep -v ".JPG|.jpg$"
```

### Listar arquivos modificados nos últimos 15 minutos

```console
find / -type f -mmin -15 |egrep -v "^/proc|^/home|^/root|^/.|^/tmp|.log$"
```

Novamente o comando ''egrep'' é utilizado para filtrar os resultados.

### Tamanho da pasta

```console
du -hs "diretorio"
```

### Localizar e excluir arquivos com mais de 10 dias

No exemplo abaixo são apenas listados os arquivos de log com mais de 10 dias.

```console
find /var/log/ -name *.log -mtime +10 -exec ls -tl {} \;
```

Exclui os arquivos de log com mais de 10 dias.

```console
find /var/log/ -name *.log -mtime +10 -exec rm -f {} \;
```

### Localizar arquivos com mais de 50MB no diretório corrente

```console
find . -type f -size +50000k -exec ls -lh {} \; | awk '{ print $9 ": " $5 }'
```


### Arquivo Falso / Dummy File

```console
dd if=/dev/zero of=/home/1GBtestfile.img count=1000000 bs=1024
```

Irá criar um arquivo de 1GB com o nome 1GBtestfile.img no diretorio /home

### Verificar arquivos adulterados

```console
find DIRETORIO -type f -print0 | xargs -0 sha512sum > checksums.sha512sum
sha512sum -c checksums.sha512sum
/var/www/file1.php: A soma não coincide
/var/www/file2.php: A soma coincide
/var/www/file3.php: A soma coincide
/var/www/file4.php: A soma coincide
/var/www/file5.php: A soma coincide
sha512sum: AVISO: 1 de 5 checksums computados NÃO conferem
```

Você pode também criar dois arquivos de checksum e então compará-los com diff.

```console
diff -q checksum-original.sha512 checksum-atual.sha512 
Arquivos checksums-original.sha512 e checksums-atual.sha512 diferem
```


### Comparar dois diretórios

```console
diff --brief -r dir1 dir2
```

### Comparar dois arquivos lado a lado

```console
diff --side-by-side file1 file2
```

### Hash de diretório

```console
find DIRETORIO -type f -exec md5sum '{}' \; | md5sum - | awk '{print $1}'
```

## Rede

### Verifica portas abertas

```console
netstat -pnat
```

### Limita o número de conexões por segundo

Esta regra limita a 20 o número de novas conexões por segundo vindas de um mesmo endereço IP.

```console
iptables -F
iptables -X
iptables -A INPUT -p tcp --dport 80 -i eth0 -m state --state NEW -m recent --set
iptables -A INPUT -p tcp --dport 80 -i eth0 -m state --state NEW -m recent --update --seconds 1 --hitcount 20 -j DROP
```

A regra abaixo remove um determinado IP da regra acima.

```console
/sbin/iptables -A INPUT -p tcp --syn --dport 80 -d ! 1.2.3.4 -m connlimit --connlimit-above 20 -j REJECT --reject-with tcp-reset
```

### Teste de conexão

```console
!/bin/bash
ip="10.0.0.1"
port="80"
for i in {1..100}
do
  # nao faz nada, apenas conecta e sai.
  echo "exit" | nc ${ip} ${port};
done
```

### Verificar portas abertas no host remoto

Verificar (rapidamente) todas as portas reservadas em um determinado IP.

```console
nmap -v 10.0.0.1
```

### Conexões estabelecidas com um determinado IP

```console
netstat -pan | grep "ESTABLISHED" | grep "10.0.0.1"
```
### Túnel SSH

  * Para ligar ponto-a-ponto a maquina local a uma porta no servidor remoto.

`ssh -L <porta_local>:<servidor_remoto>:<porta_remota> usuario@servidor_remoto.com`

```console
ssh -L 9000:dev.infusesoftware.com:80 username@remote_machine.com
```

  * Para utilizar o servidor remoto como proxy. Os comandos abaixo criam um proxy ''socks5'' em 127.0.0.1:8080

```console
ssh -fND 8080 username@remote_machine.com
```

```console
ssh -C2qTnN -D 8080 username@remote_machine.com
```

### TCPDump (Sniffer)

Neste comando estamos "sniffando" a eth0 para um determinado host:

```console
tcpdump -i eth0 -qtNnn host 0.0.0.0
```

Neste comando estamos sniffando a eth0 para uma determinada porta:

```console
tcpdump -i eth0 -qtNnn port 110
```

Neste comando estamos sniffando a eth0 para recebimento de ping:

```console
tcpdump -i eth0 -qtNnn icmp
```

Neste comando estamos sniffando a eth0 para um destino especificado:

```console
tcpdump -i eth0 -qtNnn dst 0.0.0.0
```

Neste comando estamos sniffando a eth0 para uma origem especificada:

```console
tcpdump -i eth0 -qtNnn src 0.0.0.0
```

Para monitorar um range de IPs utilize a opção `net`. 
```console
tcpdump -i eth0 -qtNnn net 103.21.244.0/22
```

Se houver necessidade de monitorar, simultaneamente, diversas redes ou IPs, utilize filtros. No exemplo abaixo estão sendo filtrados vários ranges de IPs da CloudFlare:

```console
tcpdump -i eth0 -qtNnn 'net(103.21.244.0/22 or 103.22.200.0/22 or 103.31.4.0/22 or 104.16.0.0/13 or 104.24.0.0/14 or 108.162.192.0/18 or 131.0.72.0/22 or 141.101.64.0/18 or 162.158.0.0/15 or 172.64.0.0/13 or 173.245.48.0/20 or 188.114.96.0/20 or 190.93.240.0/20 or 197.234.240.0/22 or 198.41.128.0/17)'
```

O comando tcpdump possui vários complementos os quais veremos agora.

Neste comando repare que acrescentamos "Xxx", esses parâmetros permitem que você abra o pacote que está sendo transmitido pelo host determinado:

```console
tcpdump -i eth0 -qtNnnXxx host 0.0.0.0
```
Neste comando estamos sniffando um determinado host falando na porta 3389 (Terminal Service):

```console
tcpdump -i eth0 -qtNnn host 0.0.0.0 and port 3389
```

No firewall ele nos permite realizarmos vários tipos de filtros e parâmetros, a seguir veremos um tcpdump com host, porta e exclusão de porta:

```console
tcpdump -i eth0 -qtNnn host 0.0.0.0 and port 25 and not port 3389
```

Bom, também podemos realizar tcpdump em determinadas portas e excluindo alguns hosts. Ex:

```console
tcpdump -i eth0 -qtNnn port 3389 and port 25 and port 110 and not port 443 and not port 3128 and not host 0.0.0.0 and not host 0.0.0.0
```

### Montar diretório remoto com SSH

Requer fuse e sshfs

```console
apt-get install fuse-utils sshfs
```

Para montar informe o comando abaixo:

```console
sshfs remote-user@remote.server:/remote/directory /mnt/remote/
```

## Segurança

### Verificar último acesso de usuários

O comando ''last'' exibe o histórico de logins de um determinado usuário. Se nenhum argumento for passado para comando, uma lista dos logins de todos os usuários será exibida.

```console
last jason
jason   pts/0        dev-db-server   Fri Mar 27 22:57   still logged in
jason   pts/0        dev-db-server   Fri Mar 27 22:09 - 22:54  (00:45)
jason   pts/0        dev-db-server   Wed Mar 25 19:58 - 22:26  (02:28)
jason   pts/1        dev-db-server   Mon Mar 16 20:10 - 21:44  (01:33)
jason   pts/0        192.168.201.11  Fri Mar 13 08:35 - 16:46  (08:11)
jason   pts/1        192.168.201.12  Thu Mar 12 09:03 - 09:19  (00:15)
jason   pts/0        dev-db-server   Wed Mar 11 20:11 - 20:50  (00:39
```

O comando `lastlog` por sua vez, exibe apenas o último login:

```console
lastlog
Nome de Usuário         Porta     De             Último
root             pts/0    10.0.0.1   Ter Out 30 15:48:26 -0200 2012
daemon                                     **Nunca logou**
bin                                        **Nunca logou**
sys                                        **Nunca logou**
sync                                       **Nunca logou**
games                                      **Nunca logou**
man                                        **Nunca logou**
lp                                         **Nunca logou**
mail                                       **Nunca logou**
news                                       **Nunca logou**
uucp                                       **Nunca logou**
proxy                                      **Nunca logou**
www-data                                   **Nunca logou**
backup                                     **Nunca logou**
list                                       **Nunca logou**
irc                                        **Nunca logou**
gnats                                      **Nunca logou**
nobody                                     **Nunca logou**
libuuid                                    **Nunca logou**
Debian-exim                                **Nunca logou**
statd                                      **Nunca logou**
sshd                                       **Nunca logou**
suporte                                    **Nunca logou**
mysql                                      **Nunca logou**
cl-builder                                 **Nunca logou**
messagebus                                 **Nunca logou**
maia             pts/0    10.0.0.5   Qui Out 11 16:33:11 -0300 2012
```

### Proteger arquivo com senha

```console
gpg -c nomedoarquivo.tar.gz 
Enter passphrase: 
```

Este comando poderá ser utilizado para criar arquivos de backup seguros.

Para "desproteger" utilize o gpg sem a opção -c

```console
gpg nomedoarquivo.tar.gz 
gpg: CAST5 encrypted data
Enter passphrase:

gpg: encrypted with 1 passphrase
gpg: WARNING: message was not integrity protected
```

### Verificar arquivos adulterados

Antes de tudo você deve criar um arquivo contendo os resumos criptográficos dos arquivos do diretório desejado.

No exemplo abaixo utilizamos o prefixo httpd e o comando ''date'' para criar o arquivo ''httpd-15-09-2012.sha512sum''.

```console
find /etc/httpd -type f -print0 | xargs -0 sha512sum > httpd-`date +"%d-%m-%Y"`.sha512sum
```

Para verificar por arquivos adulterados, utilize o comando ''sha512sum'' com o parâmetro ''-c'' informando o nome do arquivo que contem os resumos dos arquivos.

Exemplo:

```console
# sha512sum -c httpd-15-09-2012.sha512sum | grep FAILED
# /etc/httpd/conf/httpd.conf: FAILED
# sha512sum: WARNING: 1 of 21 computed checksums did NOT match
```

Neste exemplo foi detectado que o arquivo ''httpd.conf'' sofreu alguma modificação, embora não seja possível saber qual modificação foi esta.

### Converter certificado DER (.crt .cer .der) em PEM

```console
openssl x509 -inform der -in MYCERT.cer -out MYCERT.pem 
```

## Monitoramento e Manutenção

### Removendo kernels antigos

Listar kernels instalados

```console
rpm -qa kernel
```

Verificar o kernel em uso

```console
uname -r
```

Remover um kernel específico

```console
rpm -vv -e kernel-2.6.32-279.2.1.el6.x86_64
```

Você pode ainda remover kernels Devel com o comando

```console
package-cleanup --oldkernels
```

### Monitorando memória e disco

```console
vmstat -SM 1
```

### Listando Processos ativos

```console
ps aux
```

```console
pstree
```

### Histórico de Log

```console
seucomando 2>&1 | /usr/sbin/cronolog --hardlink=/var/log/seucomando.log '/var/log/%Y-%m-%d-seucomando.log' &
```

### Listar segmentos da memória compartilhada

```console
 ipcs -m
```

### Limpar segmentos de memória utilizados por um usuário

```console
 ipcs -m | awk '$3 == "username" {print $2}' | while read i; do ipcrm -m $i; done
```

### Limpar o cache de memória

```console
 sync; echo 3 > /proc/sys/vm/drop_caches
```

### Remover manualmente pacotes quebrados

```console
 sudo gedit /var/lib/dpkg/status
```

Remover todo o bloco referente ao pacote quebrado, como no exemplo abaixo, que se refere ao pacote **libgtkspell0**:

```console
Package: libgtkspell0
Status: install ok installed
Priority: optional
Section: libs
Installed-Size: 624
Maintainer: Ubuntu Developers <ubuntu-devel-discuss@lists.ubuntu.com>
Architecture: i386
Source: gtkspell
Version: 2.0.16-1
Depends: libatk1.0-0 (>= 1.29.3), libc6 (>= 2.3.6-6~), libcairo2 (>= 1.2.4), libenchant1c2a (>= 1.5), libfontconfig1 (>= 2.8.0), libfreetype6 (>= 2.2.1), libglib2.0-0 (>= 2.16.0), libgtk2.0-0 (>= 2.8.0), libpango1.0-0 (>= 1.14.0), zlib1g (>= 1:1.1.4)
Description: a spell-checking addon for GTK's TextView widget
 GtkSpell provides MSWord/MacOSX-style highlighting of misspelled words in a
 GtkTextView widget.  Right-clicking a misspelled word pops up a menu of
 suggested replacements.
Original-Maintainer: Ari Pollak <ari@debian.org>
```

Atualizar o APT

```console
sudo apt-get update
sudo apt-get upgrade
```

### Monitorar um script ou processo

No exemplo abaixo, está sendo verificada a execução do comando rsync.

`while true; clear; ps aux | head -1; do ps aux | grep **rsync** | grep -v grep; sleep 3; done`

```console
while true; clear; ps aux | head -1; do ps aux | grep rsync | grep -v grep; sleep 3; done
```
## Troubleshooting

### Atualizar (upgrade / update) do Dokuwiki

https://www.dokuwiki.org/install:upgrade

Faça o backup da pasta do dokuwiki

```console
cp -a /var/www/wiki /var/www/wiki.bkp
```

Baixar a versão mais atual

```console
wget http://.../dokuwiki-xxxx-xx-xx.tgz
```

Descompacte

```console
tar -xzvf dokuwiki-xxxx-xx-xx.tgz 
```

Copie os novos arquivo para o diretório do wiki

```console
'cp' -rf dokuwiki-xxxx-xx-xx/{*,.??*} /path/to/wiki/
```

Teste e remova o arquivo .tar e o diretório de backup.
