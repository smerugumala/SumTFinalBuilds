# -*- coding: utf-8 -*-
'''
Module to provide MS SQL Server compatibility to salt.

:depends:   - FreeTDS
            - pymssql Python module

:configuration: In order to connect to MS SQL Server, certain configuration is
    required in minion configs/pillars on the relevant minions. Some sample
    pillars might look like::

        mssql.server: 'localhost'
        mssql.port:   1433
        mssql.user:   'sysdba'
        mssql.password:   'Some preferable complex password'
        mssql.database: ''

    The default for the port is '1433' and for the database is '' (empty string);
    in most cases they can be left at the default setting.
    Options that are directly passed into functions will overwrite options from
    configs or pillars.
'''

# Import python libs
from __future__ import absolute_import, print_function, unicode_literals
from json import JSONEncoder, loads

import salt.ext.six as six
import sys
import logging
import paramiko
import socket
import requests
import json
from requests.packages.urllib3.exceptions import InsecureRequestWarning
requests.packages.urllib3.disable_warnings(InsecureRequestWarning)

try:
    import pymssql
    HAS_ALL_IMPORTS = True
except ImportError:
    HAS_ALL_IMPORTS = False
    print('Import Failed')

log = logging.getLogger(__name__)

__virtualname__ = 'cmdb_lib'

def __virtual__():
    '''
    Only load if import successful
    '''
    if HAS_ALL_IMPORTS:
        return __virtualname__
    else:
        return False, 'The CMDB_LIB module cannot be loaded: pymssql package unavailable.'

def getBenchmarkID():
    conn = pymssql.connect('DEV_CMDB_AG','cmdb','v13w26!','CMDB')
    cursor = conn.cursor()
    cursor.execute("SELECT BENCHMARK_UUID FROM SECURITY_POLICY WHERE OS = 'centos'")
    row = cursor.fetchone()
    #row = row[0].replace(",","")
    return row[0]
    conn.close

def getCheckID():
    conn = pymssql.connect('DEV_CMDB_AG','cmdb','v13w26!','CMDB')
    cursor = conn.cursor()
    cursor.execute("SELECT DISTINCT SPM.CHECK_UUID FROM SECURITY_POLICY_MAP SPM INNER JOIN SECURITY_POLICY SP ON SP.BENCHMARK_UUID=SPM.BENCHMARK_UUID AND SP.ENABLED='TRUE' INNER JOIN SECURITY_CHECK SC ON SC.CHECK_UUID= SPM.CHECK_UUID AND SC.EXEMPT='FALSE' WHERE SP.OS = 'centos' AND SP.OS_VERSION = '7'")
    chk = cursor.fetchall()
    checks = []
    for row in chk:
        checks.append(row[0])
    return checks
    conn.close

