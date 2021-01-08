#!/bin/bash
date > /tmp/mydate
sudo bin/cqlsh $1 -e "ALTER KEYSPACE system_auth WITH replication = {'class': 'NetworkTopologyStrategy', 'dc1': 2};" > /dev/null 2>&1
