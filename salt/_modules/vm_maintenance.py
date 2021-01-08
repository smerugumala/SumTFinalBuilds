from __future__ import absolute_import, print_function, unicode_literals
from json import JSONEncoder, loads
from datetime import datetime
#import salt.ext.six as six
import sys
import logging
import uuid
#import salt.utils.args
import threading
import time
import copy
import pmp_resource
#import paramiko

try:
    import pymssql
    HAS_ALL_IMPORTS = True
except ImportError:
    HAS_ALL_IMPORTS = False
    print('Import Failed')

log = logging.getLogger(__name__)

__virtualname__ = 'vm_maintenance'

def __virtual__():
    '''
    Only load if import successful
    '''
    if HAS_ALL_IMPORTS:
        return __virtualname__
    else:
        return False, 'The cmdb_lib module cannot be loaded: dependent package(s) unavailable.'

data = pmp_resource.PMP()
details = data.get_PMP_details('cmdb')
resource = details['resource']
account = details['account']
passwd = data.get_PMP_pass('cmdb')
hostpass = data.get_PMP_pass('svc_saltstack')


class Maintenance:
    def __init__(self):
        self.conn = pymssql.connect(resource,account,passwd,'CMDB')
        self.cursor = self.conn.cursor()

    def connectCMDB():
        self.conn = pymssql.connect(resource,account,passwd,'CMDB')
        return conn    

    def getvmDetails(self,clustername):
        self.cursor.execute("select IP,VM.NAME as VM_NAME from APP_CLUSTER AC inner join APP_CLUSTER_VM ACV on AC.ID=ACV.APP_CLUSTER_ID inner join VM on ACV.VM_ID=VM.ID where AC.NAME='" + clustername + "'")
        records = self.cursor.fetchall()
        ip = [row[0] for row in records]
        server = [row[1] for row in records]
        Ips = map(str, ip)
        servers = map(str, server)
        self.conn.close
        return Ips,servers
    
    def getSG(self,clustername,datacenter,env):
        self.cursor.execute("SELECT LB.NAME AS RESULT FROM LOAD_BALANCE LB INNER JOIN DATACENTER D ON D.ID = LB.DATACENTER_ID INNER JOIN VM_TIER VMTI ON VMTI.ID = LB.VM_TIER_ID WHERE D.CODE = '" + datacenter + "' AND VMTI.CODE = '" + env + "' AND VMTI.IS_UDA='TRUE'")
        row = self.cursor.fetchone()
        HOST = row[0]
        self.conn.close
        self.cursor.execute("select top 1 VM.NAME as VM_NAME from APP_CLUSTER AC inner join APP_CLUSTER_VM ACV on AC.ID=ACV.APP_CLUSTER_ID inner join VM on ACV.VM_ID=VM.ID where AC.NAME='" + clustername + "'")
        record = self.cursor.fetchone()
        server = record[0]
        self.conn.close
        client=paramiko.SSHClient()
        client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        client.connect(HOST,username='svc_saltstack',password=hostpass)
        stdin, stdout, stderr = client.exec_command('sh run | grep -i "bind serviceGroup.*'+ server +'"')
        register = stdout.read().split()
        for row in register:
          if 'sg_' in row:
            return row
          if register is None:
            return False
        client.close()

    def get_vmId(self,server):
        self.cursor.execute("SELECT ID FROM VM WHERE NAME = '" + server + "'")
        record = self.cursor.fetchone()
        id = record[0]
        self.conn.close
        return id

    def get_vmIP(self,server):
        self.cursor.execute("SELECT IP FROM VM WHERE NAME = '" + server + "'")
        record = self.cursor.fetchone()
        id = record[0]
        self.conn.close
        return id    
