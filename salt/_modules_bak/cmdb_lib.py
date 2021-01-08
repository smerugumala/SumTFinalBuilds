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
    cursor.execute("SELECT STUFF((SELECT DISTINCT TOP 10',' + SPM2.CHECK_UUID FROM SECURITY_POLICY_MAP SPM2 INNER JOIN SECURITY_CHECK SC ON SC.CHECK_UUID= SPM2.CHECK_UUID AND SC.EXEMPT='FALSE' WHERE spm2.BENCHMARK_UUID= SP.BENCHMARK_UUID FOR XML PATH ('')),1,1,'') as CHECK_UUIDs FROM SECURITY_POLICY SP WHERE SP.ENABLED='TRUE'AND SP.OS = 'centos' AND SP.OS_VERSION = '7'")
    chk = cursor.fetchone()
    #chk = chk[0].replace(',','","')
    return chk[0]
    conn.close


