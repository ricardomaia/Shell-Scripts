#!/bin/bash

BASEDIR=$(dirname "$0")
SCANNER_DIR="/root/DIGITALIZANDO/"
OCR_DIR="/root/DIGITALIZADOS"
INTERVAL=2

while true; do

if [ "$(ls -A $SCANNER_DIR)" ]; then


    echo "Gerando arquivo de hashes"
    find $SCANNER_DIR*.pdf -type f -print0 | xargs -0 sha512sum > $BASEDIR/checksums.sha512sum
    sleep $INTERVAL

    sha512sum -c $BASEDIR/checksums.sha512sum --quiet --status

    if [ $? = 0 ]; then
        echo "A soma coincide."
        echo "Movendo os arquivos para o diretorio DIGITALIZADOS."
        mv $SCANNER_DIR/*.pdf $OCR_DIR
    else
        echo "A soma NAO coincide. Arquivos sendo modificados..."
    fi
fi

done
