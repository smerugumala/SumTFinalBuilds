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
import re
import subprocess
import platform
#import salt.utils.args
import threading
import time
import copy
import cmdb_orchTracking
import packageInfo 
import pmp_resource
import oriondb_IPAM

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

def getvmId(server):
    serviceClass = vm_maintenance.Maintenance()
    data = serviceClass.get_vmId(server)
    return data

def getAvaliableIP():
    AvaliableIPClass = oriondb_IPAM.oriondb()
    data = AvaliableIPClass.getNextAvaliableIP()
    return data

def SetStatus(ServerIP):
    AvaliableIPClass = oriondb_IPAM.oriondb()
    return AvaliableIPClass.UpdateStatus(ServerIP)

def getMemory(version,role):
    trackingClass = cmdb_orchTracking.SaltJob()
    return trackingClass.getCPU_COUNT(version,role)

def domain(datacenter):
    trackingClass = cmdb_orchTracking.SaltJob()
    data = trackingClass.getDomain(datacenter)
    return data

def gateway(Port_Group):
    trackingClass = cmdb_orchTracking.SaltJob()
    return trackingClass.defaultGateway(Port_Group)

def getPassword(source):
    trackingClass = cmdb_orchTracking.SaltJob()
    return trackingClass.getpassword(source)

def getresource(resource,account):
    pmpClass = pmp_resource.PMP()
    return pmpClass.PMP_resource(resource,account)

def ipSublist(clusterrole,datacenter,environment):
    trackingClass = cmdb_orchTracking.SaltJob()
    data = trackingClass.ipSublist(clusterrole,datacenter,environment)
    return data

def getlb (datacenter,environment):
    loadbalancer = cmdb_orchTracking.SaltJob()
    lb = loadbalancer.getLoadBalancer(datacenter,environment)
    return lb

def dictinfo (clustername,packagename):
    trackingClass = cmdb_orchTracking.SaltJob()
    data = trackingClass.lbDict(clustername,packagename)
    return data

def isLoadBalanced(fqdn,packagename,clusterrole):
    loadbalanced = cmdb_orchTracking.SaltJob()
    islb = loadbalanced.isLoadBalanced(fqdn,packagename,clusterrole)
    return islb

def zoneForVIP(datacenter,environment):
    getZone = cmdb_orchTracking.SaltJob()
    zone = getZone.getDNSZoneForVip (datacenter,environment)
    return zone

def getDNS(datacenter):
    dns = cmdb_orchTracking.SaltJob()
    dns1 = dns.getPrimaryDNS (datacenter)
    return dns1

def getDatastore(datacenter,environment,clusterrole,packagename,esxcluster):
    ds = cmdb_orchTracking.SaltJob()
    datastore = ds.getDatastore (datacenter,environment,clusterrole,packagename,esxcluster)
    return datastore

def AddorUpdateServer(Vmname,clusterrole,packagename,patch,workflowname,Status):
    ds = cmdb_orchTracking.SaltJob()
    updatevm = ds.AddorUpdateServerVersion (Vmname,clusterrole,packagename,patch,workflowname,Status)
    return updatevm

def prometheusvm(datacenter):
    trackingClass = cmdb_orchTracking.SaltJob()
    data = trackingClass.getPrometheusserver(datacenter)
    return data

def addClusterinfo(clusterName,associateClusterName,isDedicated,isValidated,podClusterCode,udaPackage):
    trackingClass = cmdb_orchTracking.SaltJob()
    data = trackingClass.addNewClusterinfo(clusterName,associateClusterName,isDedicated,isValidated,podClusterCode,udaPackage)
    return data

def buildServerlist(ClusterName,numOfServers,datacenter):
    trackingClass = cmdb_orchTracking.SaltJob()
    return trackingClass.getservername(ClusterName,numOfServers,datacenter)

def getIP(networkname,datacenter):
    trackingClass = cmdb_orchTracking.SaltJob()
    return trackingClass.FindIp(networkname,datacenter)

def getNameservers(datacenter):
    trackingClass = cmdb_orchTracking.SaltJob()
    return trackingClass.Nameservers(datacenter)

def ClusterServerExists(ClusterName):
    trackingClass = cmdb_orchTracking.SaltJob()
    return trackingClass.checkServerExists(ClusterName)

def getesxClusterName(datacenter,environment,clusterrole):
    trackingClass = cmdb_orchTracking.SaltJob()
    return trackingClass.esxClusterName(datacenter,environment,clusterrole)

def getDatastore(datacenter,environment,clusterrole,packagename,esxcluster):
    trackingClass = cmdb_orchTracking.SaltJob()
    return trackingClass.Datastore(datacenter,environment,clusterrole,packagename,esxcluster)

def addVMinfo(vmName,vmIP,uuid,os,clusterrole,Environment,ClusterName,fqdn):
    trackingClass = cmdb_orchTracking.SaltJob()
    return trackingClass.UUID(vmName,vmIP,uuid,os,clusterrole,Environment,ClusterName,fqdn)

def addPMPResource(account,passwd,resource,RESOURCETYPE):
    trackingClass = pmp_resource.PMP()
    return trackingClass.add_resource(account,passwd,resource,RESOURCETYPE)

def getClusterServerList(ClusterName):
    trackingClass = cmdb_orchTracking.SaltJob()
    return trackingClass.getServers(ClusterName)

def getDVS_switch(Port_Group):
    trackingClass = cmdb_orchTracking.SaltJob()
    return trackingClass.getDVS_switch(Port_Group)

def getClusterServerIP(ClusterName):
    trackingClass = cmdb_orchTracking.SaltJob()
    return trackingClass.getcmdb_clusterVmIps(ClusterName)

def GetSplunk(datacenter):
    trackingClass = cmdb_orchTracking.SaltJob()
    return trackingClass.Splunk(datacenter)

def DCC_CONFIGKEYS(ClusterName):
    trackingClass = cmdb_orchTracking.SaltJob()
    return trackingClass.DCC_CONFIGKEYS(ClusterName)

def SCC_CONFIGKEYS(ClusterName):
    trackingClass = cmdb_orchTracking.SaltJob()
    return trackingClass.SCC_CONFIGKEYS(ClusterName)

def HAM_CONFIGKEYS(ClusterName):
    trackingClass = cmdb_orchTracking.SaltJob()
    return trackingClass.HAM_CONFIGKEYS(ClusterName)

def UKA_CONFIGKEYS(ClusterName):
    trackingClass = cmdb_orchTracking.SaltJob()
    return trackingClass.UKA_CONFIGKEYS(ClusterName)

def CSD_CONFIGKEYS(ClusterName):
    trackingClass = cmdb_orchTracking.SaltJob()
    return trackingClass.CSD_CONFIGKEYS(ClusterName)

def UEC_CONFIGKEYS(ClusterName):
    trackingClass = cmdb_orchTracking.SaltJob()
    return trackingClass.UEC_CONFIGKEYS(ClusterName)

def UXD_CONFIGKEYS(ClusterName):
    trackingClass = cmdb_orchTracking.SaltJob()
    return trackingClass.UXD_CONFIGKEYS(ClusterName)

def UMD_CONFIGKEYS(ClusterName):
    trackingClass = cmdb_orchTracking.SaltJob()
    return trackingClass.UMD_CONFIGKEYS(ClusterName)

def getBenchmarkID(version,vm_type,role_version):
    trackingClass = cmdb_orchTracking.SaltJob()
    return trackingClass.getBenchmarkID(version,vm_type,role_version)

def getCheckID(version,vm_type,role_version):
    trackingClass = cmdb_orchTracking.SaltJob()
    return trackingClass.getCheckID(version,vm_type,role_version)

def getVariables(version,vm_type,role_version):
    trackingClass = cmdb_orchTracking.SaltJob()
    return trackingClass.getVariables(version,vm_type,role_version)

def get_syslog_server(datacenter):
    trackingClass = cmdb_orchTracking.SaltJob()
    return trackingClass.SYSLOG_SERVER(datacenter)

def get_ntp_server(datacenter):
    trackingClass = cmdb_orchTracking.SaltJob()
    return trackingClass.NTP_SERVER(datacenter)

def get_eset_config(datacenter):
    trackingClass = cmdb_orchTracking.SaltJob()
    return trackingClass.ESET_CONFIG(datacenter)

def getRepoServer(datacenter):
    trackingClass = cmdb_orchTracking.SaltJob()
    return trackingClass.repoServer(datacenter)

def getBaseTemplate(datacenter,clusterrole,packageName):
    trackingClass = cmdb_orchTracking.SaltJob()
    return trackingClass.getBaseTemplate(datacenter,clusterrole,packageName)

def getRoleTemplate(datacenter,clusterrole,packageName):
    trackingClass = cmdb_orchTracking.SaltJob()
    return trackingClass.getRoleTemplate(datacenter,clusterrole,packageName)

def getRoleversion(packageName,clusterrole):
    trackingClass = cmdb_orchTracking.SaltJob()
    return trackingClass.getRoleversion(packageName,clusterrole)

def getSubnet(Port_Group):
    trackingClass = cmdb_orchTracking.SaltJob()
    return trackingClass.getSubnet(Port_Group)

def getassociatedcluster(cluster):
    trackingClass = cmdb_orchTracking.SaltJob()
    return trackingClass.getassociatedcluster(cluster)

def get_install_params(query):
    trackingClass = cmdb_orchTracking.SaltJob()
    return trackingClass.get_install_params(query)

def getVMdata(cluster):
    trackingClass = cmdb_orchTracking.SaltJob()
    return trackingClass.getVMdata(cluster)
