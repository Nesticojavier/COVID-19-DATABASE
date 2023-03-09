#!/bin/bash
# Copyright (c) 2012-2022, EnterpriseDB Corporation.  All rights reserved

# PostgreSQL psql runner script for OS X

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
