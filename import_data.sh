#!/bin/bash
# Copyright (c) 2023, Nestor Gonzalez, Jesus Bandez
# PostgreSQL psql runner script for OS X, Linux

# Descargar el archivo si no está ya descargado
if [ -e owid-covid-data.csv ];
then
    echo "El archivo owid-covid-data.csv ya se encuentra descargado"
else wget https://covid.ourworldindata.org/data/owid-covid-data.csv
fi

echo -n "Username [postgres]: "
read USERNAME

if [ "$USERNAME" = "" ];
then
    USERNAME="postgres"
fi

echo -n "Database to create: "
read DATABASE

while [ "$DATABASE" = "" ];
do
    echo "Debe indicar el nombre de la DATABASE a crear"
    echo -n "Database: "
    read DATABASE
done

echo -n "Server [localhost]: "
read SERVER

if [ "$SERVER" = "" ];
then
    SERVER="localhost"
fi

echo -n "Port [5432]: "
read PORT

if [ "$PORT" = "" ];
then
    PORT="5432"
fi

createdb  -h $SERVER -p $PORT -U $USERNAME $DATABASE
psql -h $SERVER -p $PORT -U $USERNAME $DATABASE -a -f "import_data.sql"
RET=$?

if [ "$RET" != "0" ];
then
    echo
    echo -n "Press <return> to continue..."
    read dummy
fi

exit $RET
