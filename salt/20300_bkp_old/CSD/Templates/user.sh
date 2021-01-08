#!/bin/bash
sudo bin/cqlsh $1 -u cassandra -p cassandra -e "CREATE ROLE $2 WITH SUPERUSER = true AND LOGIN = true AND PASSWORD = '$3';"
