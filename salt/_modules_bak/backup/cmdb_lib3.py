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

#import salt.ext.six as six
import sys
import logging
import uuid
#import salt.utils.args
import threading
import time
import copy
import cmdb_orchTracking
import packageInfo
import vm_maintenance
import oriondb_IPAM
import pmp_resource
import roleTemplate

try:
    import pymssql
    HAS_ALL_IMPORTS = True
except ImportError:
    HAS_ALL_IMPORTS = False
    print('Import Failed')

log = logging.getLogger(__name__)

__virtualname__ = 'cmdb_lib3'

def __virtual__():
    '''
    Only load if import successful
    '''
    if HAS_ALL_IMPORTS:
        return __virtualname__
    else:
        return False, 'The cmdb_lib3 module cannot be loaded: dependent package(s) unavailable.'

def tracking(CC,status,server):
    trackingClass = cmdb_orchTracking.SaltJob()
    data = trackingClass.tracking(CC,status,server)
    return data

def groupInsert(SaltJobId,groupName,sequence):
    trackingClass = cmdb_orchTracking.SaltJob()
    data = trackingClass.groupInsert(SaltJobId,groupName,sequence)
    return data

def VMtoGroupInsert(SaltJobId,vmGroupId,vmId):
    trackingClass = cmdb_orchTracking.SaltJob()
    data = trackingClass.VMtoGroupInsert(SaltJobId,vmGroupId,vmId)
    return data

def insertVMStatus(SaltJobId,vmId,netscalerStatus,prometheusStatus):
    trackingClass = cmdb_orchTracking.SaltJob()
    data = trackingClass.insertVMStatus(SaltJobId,vmId,netscalerStatus, prometheusStatus)
    return data

def updateVMnetscalerStatus(netscalerStatus,vmId,SaltJobId):
    trackingClass = cmdb_orchTracking.SaltJob()
    data = trackingClass.updateVMnetscalerStatus(netscalerStatus,vmId,SaltJobId)
    return data

def callOrchPath(version, role, action):
    p= packageInfo.packageInfo()
    data = p.getOrchPath(version, role, action)
    return data

def callSaltConfigKeys(config_key, vm_tier):
    p= packageInfo.packageInfo()
    data = p.getSaltConfigKeys(config_key, vm_tier)
    return data

def serverDetails(clustername):
    serverClass = vm_maintenance.Maintenance()
    data = serverClass.getvmDetails(clustername)
    return data

def ServiceGroup(clustername,datacenter,env):
    serviceClass = vm_maintenance.Maintenance()
    data = serviceClass.getSG(clustername,datacenter,env)
    return data

def resource(resource,account):
    serviceClass = pmp_resource.PMP()
    data = serviceClass.PMP_resource(resource,account)
    return data

def addResource(account,passwd,resource):
    serviceClass = pmp_resource.PMP()
    data = serviceClass.add_resource(account,passwd,resource,"Windows","SaltChange")
    return data

def getvmId(server):
    serviceClass = vm_maintenance.Maintenance()
    data = serviceClass.get_vmId(server)
    return data

def getIP(server):
    serviceClass = vm_maintenance.Maintenance()
    data = serviceClass.get_vmIP(server)
    return data

def getAvaliableIP():
    AvaliableIPClass = oriondb_IPAM.oriondb()
    data = AvaliableIPClass.getNextAvaliableIP()
    return data

def SetStatus(ServerIP):
    AvaliableIPClass = oriondb_IPAM.oriondb()
    data = AvaliableIPClass.UpdateStatus(ServerIP)
    return data

def getMemory(version,role):
    TemplateClass = roleTemplate.Template()
    data = TemplateClass.getCPU_COUNT(version,role)
    return data

def getDomain(datacenter):
    TemplateClass = roleTemplate.Template()
    data = TemplateClass.getDNS(datacenter)
    return data

def gateway(networkname):
    TemplateClass = roleTemplate.Template()
    data = TemplateClass.defaultGateway(networkname)
    return data

def getPassword(source):
    TemplateClass = roleTemplate.Template()
    data = TemplateClass.getpassword(source)
    return data

def getTireID(Environment):
    TemplateClass = roleTemplate.Template()
    data = TemplateClass.VM_TIER(Environment)
    return data

def getTypeID(Role):
    TemplateClass = roleTemplate.Template()
    data = TemplateClass.TYPE_ID(Role)
    return data

def getUUID(vmName,vmIP,uuid,os,Role,Environment,ClusterName):
    TemplateClass = roleTemplate.Template()
    data = TemplateClass.UUID(vmName,vmIP,uuid,os,Role,Environment,ClusterName)
    return data

def GetSplunk(datacenter):
    TemplateClass = roleTemplate.Template()
    data = TemplateClass.Splunk(datacenter)
    return data
