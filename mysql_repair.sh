#!/bin/bash

MYSQL_LOGIN='-u root --password=your_password'

for db in $(echo "SHOW DATABASES;" | mysql $MYSQL_LOGIN | grep -v -e "Database" -e "information_schema")
do
        TABLES=$(echo "USE $db; SHOW TABLES;" | mysql $MYSQL_LOGIN |  grep -v Tables_in_)
        echo "Selecionando a base de dados $db"
        for table in $TABLES
        do
                echo -n " * Reparando tabela $table ... "
                echo "USE $db; REPAIR TABLE $table" | mysql $MYSQL_LOGIN  >/dev/null
                echo "done."
        done
done
