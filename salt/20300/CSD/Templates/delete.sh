#!/bin/bash
sudo bin/cqlsh $1 -u $2 -p $3 -e "ALTER ROLE cassandra WITH SUPERUSER = false AND LOGIN = false;"
