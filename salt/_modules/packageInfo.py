# -*- coding: utf-8 -*-
'''
:Module to provide connectivity to the CMDB
:depends:   - FreeTDS
            - pymssql Python module
'''

# Import python libs
from __future__ import absolute_import, print_function, unicode_literals
from json import JSONEncoder, loads
from datetime import datetime
# from 192.cmdb_lib import Foo1

#import salt.ext.six as six
import sys
import logging
import uuid
#import salt.utils.args
import threading
import time
import copy

try:
    import pymssql
    HAS_ALL_IMPORTS = True
except ImportError:
    HAS_ALL_IMPORTS = False
    print('Import Failed')

log = logging.getLogger(__name__)

__virtualname__ = 'packageInfo'

def __virtual__():
    '''
    Only load if import successful
    '''
    if HAS_ALL_IMPORTS:
        return __virtualname__
    else:
        return False, 'The cmdb_lib1.0 module cannot be loaded: dependent package(s) unavailable.'

    

class packageInfo:
    #def __init__():
    #    self.conn = pymssql.connect('DEV_CMDB_AG','cmdb','v13w26!','CMDB')
    #    self.cursor = self.conn.cursor() 
       
	
    def getOrchPath(self, version,role,action):
        self.conn = pymssql.connect('DEV_CMDB_AG','cmdb','v13w26!','CMDB')
        self.cursor = self.conn.cursor() 
        self.cursor.execute("SELECT PW.SALT_ORCH_PATH FROM PACKAGE P INNER JOIN PACKAGE_ROLE PR ON PR.PACKAGE_ID=P.ID INNER JOIN VM_TYPE VMTY ON VMTY.ID=PR.VM_TYPE_ID INNER JOIN PACKAGE_WORKFLOW PW ON PW.PACKAGE_ROLE_ID=PR.ID INNER JOIN WORKFLOW W ON W.ID=PW.WORKFLOW_ID WHERE REPLACE(P.NAME,'.','')= %s AND VMTY.CODE= %s AND W.CODE= %s",(version,role,action))
        
        log.info("SELECT PW.SALT_ORCH_PATH FROM PACKAGE P INNER JOIN PACKAGE_ROLE PR ON PR.PACKAGE_ID=P.ID INNER JOIN VM_TYPE VMTY ON VMTY.ID=PR.VM_TYPE_ID INNER JOIN PACKAGE_WORKFLOW PW ON PW.PACKAGE_ROLE_ID=PR.ID INNER JOIN WORKFLOW W ON W.ID=PW.WORKFLOW_ID WHERE REPLACE(P.NAME,'.','')= '%s' AND VMTY.CODE= '%s' AND W.CODE= '%s'",version,role,action)
        row = self.cursor.fetchone()
        if row:
          id = row[0]
        else:
          id = ''	
        self.conn.close
        return id	

    def getSaltConfigKeys(self, config_key, vm_tier):
        self.conn = pymssql.connect('DEV_CMDB_AG','cmdb','v13w26!','CMDB')
        self.cursor = self.conn.cursor() 
        self.cursor.execute("SELECT VALUE FROM CONFIGURATION_KEY_TO_VM_TIER CK_VM_TIER INNER JOIN VM_TIER VMTI ON VMTI.ID=CK_VM_TIER.VM_TIER_ID WHERE CONFIGURATION_KEY_ID=(SELECT ID FROM CONFIGURATION_KEY CK WHERE CK.[KEY]= %s) AND VMTI.CODE= %s",(config_key,vm_tier))
        log.info("SELECT VALUE FROM CONFIGURATION_KEY_TO_VM_TIER CK_VM_TIER INNER JOIN VM_TIER VMTI ON VMTI.ID=CK_VM_TIER.VM_TIER_ID WHERE CONFIGURATION_KEY_ID=(SELECT ID FROM CONFIGURATION_KEY CK WHERE CK.[KEY]= %s) AND VMTI.CODE= %s",config_key,vm_tier)
        row = self.cursor.fetchone()
        if row:
          id = row[0]
        else:
          id = ''
        self.conn.close
        return id
