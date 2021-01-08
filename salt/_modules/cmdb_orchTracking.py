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
import re
import platform
import copy
import random
import string
import pmp_resource
import oriondb_IPAM
import subprocess
import dns.query
import dns.zone
from xml.dom import minidom


try:
    import pymssql
    HAS_ALL_IMPORTS = True
except ImportError:
    HAS_ALL_IMPORTS = False
    print('Import Failed')

log = logging.getLogger(__name__)

__virtualname__ = 'cmdb_orchTracking'

def __virtual__():
    '''
    Only load if import successful
    '''
    if HAS_ALL_IMPORTS:
        return __virtualname__
    else:
        return False, 'The cmdb_lib1.0 module cannot be loaded: dependent package(s) unavailable.'

data = pmp_resource.PMP()
details = data.get_PMP_details('cmdb')
resource = details['resource']
account = details['account']
passwd = data.get_PMP_pass('cmdb')

class SaltJob:
    def __init__(self):     
        self.conn = pymssql.connect(resource,account,passwd,'CMDB')
        self.cursor = self.conn.cursor() 
        
    def connectCMDB():
        self.conn = pymssql.connect(resource,account,passwd,'CMDB')
        return conn
				
    def tracking(self,CC,status,server):
        self.query= "INSERT INTO SALT_JOB(JID,CC,REQUESTED_BY,START_DATE,END_DATE,STATE,ENTITY) VALUES ('" + str(uuid.uuid1()) + "',%s,'installer',getDate(),NULL,%s,%s)"
        self.cursor.execute(self.query,((CC),(status),(server)))
        self.conn.commit()
        self.cursor.execute("SELECT MAX(ID) FROM SALT_JOB")
        row = self.cursor.fetchone()
        id = row[0] 
	#self.conn.close
        return id

    def groupInsert(self,SaltJobId,groupName,sequence):
        self.query= "INSERT INTO SALT_JOB_VM_GROUP(NAME,SALT_JOB_ID,SEQUENCE,START_TIME,END_TIME) VALUES (%s,%s,%s,getDate(),NULL)"
        self.cursor.execute(self.query,((groupName),(SaltJobId),(sequence)))
        self.conn.commit()
        self.cursor.execute("SELECT MAX(ID) FROM SALT_JOB_VM_GROUP")
        row = self.cursor.fetchone()
        id = row[0] 
	#self.conn.close
        return id

    def VMtoGroupInsert(self,SaltJobId,vmGroupId,vmId):
        self.cursor.execute("INSERT INTO SALT_JOB_TO_VM(SALT_JOB_ID,SALT_JOB_VM_GROUP_ID,VM_ID) VALUES (" + str(SaltJobId) + "," + str(vmGroupId) + "," + str(vmId) + ")")
        self.conn.commit()
        self.cursor.execute("SELECT MAX(ID) FROM SALT_JOB_TO_VM")
        row = self.cursor.fetchone()
        id = row[0] 
	#self.conn.close
        return id

    def insertVMStatus(self,SaltJobId,vmId,netscalerStatus,prometheusStatus):
        self.cursor.execute("INSERT INTO SALT_JOB_VM_STATE(SALT_JOB_ID,VM_ID, INITIAL_NETSCALER_STATE, CURRENT_NETSCALER_STATE, INITIAL_PROMETHEUS_STATE, CURRENT_PROMETHEUS_STATE) VALUES (" + str(SaltJobId) + "," + str(vmId) + ",'" + netscalerStatus + "','" + netscalerStatus + "','" + prometheusStatus + "','" + prometheusStatus + "')")
        self.conn.commit()
        self.cursor.execute("SELECT MAX(ID) FROM SALT_JOB_TO_VM")
        row = self.cursor.fetchone()
        id = row[0] 
	#self.conn.close
        return id
    def updateVMnetscalerStatus(self,netscalerStatus,vmId,SaltJobId):
        self.query= ("UPDATE SALT_JOB_VM_STATE SET CURRENT_NETSCALER_STATE=%s WHERE VM_ID=%s AND SALT_JOB_ID=%s")
        self.cursor.execute(self.query,((netscalerStatus),(vmId),(SaltJobId)))
        self.conn.commit()
        self.cursor.execute("SELECT MAX(ID) FROM SALT_JOB_VM_STATE")
        row = self.cursor.fetchone()
        id = row[0]
        #self.conn.close
        return id

#These are my functions
    def ipSublist(self,clusterrole,datacenter,environment):
        #subnetwork = []
        if (clusterrole == "VIP"):
          description = "VIP"
        elif (clusterrole[2] == "D"):
          description = "DB"
        else:
          description = "WEB"
        self.query= ("SELECT IP_S.SUBNET AS SUBNET,IP_S.DIST_PORT_GROUP AS PORTGRP FROM IP_SUBNET IP_S INNER JOIN IP_SUBNET_TO_VM_TIER IP_STVT ON IP_STVT.IP_SUBNET_ID=IP_S.ID INNER JOIN VM_TIER VMTI ON IP_STVT.VM_TIER_ID=VMTI.ID INNER JOIN DATACENTER D ON D.ID = IP_S.DATACENTER_ID WHERE IP_S.DESCRIPTION='" + str(description) + "' AND D.CODE='" + str(datacenter) + "' AND VMTI.CODE='" + str(environment) + "'")
        self.cursor.execute(self.query,((description),(datacenter),(environment)))
        networkname = self.cursor.fetchall()
        network = [i for i in networkname]
        return network


    def getpublicdomain (self,datacenter,environment):
        self.query = ("SELECT DOMAIN AS RESULT FROM CERTIFICATE C INNER JOIN VM_TIER VMTI ON VMTI.ID=C.VM_TIER_ID INNER JOIN DATACENTER D ON D.ID=C.DATACENTER_ID WHERE D.CODE = %s AND VMTI.CODE= %s");
        self.cursor.execute(self.query,(datacenter,environment))
        d = self.cursor.fetchone()
        return d[0]

    def getlbmaintainanceserver (self,datacenter,environment):
        self.query = ("SELECT LB.MAINTENANCE_SERVER AS RESULT FROM LOAD_BALANCE LB INNER JOIN DATACENTER D ON LB.DATACENTER_ID=D.ID INNER JOIN VM_TIER VMT ON VMT.ID= LB.VM_TIER_ID WHERE D.CODE=%s AND VMT.CODE=%s AND VMT.IS_UDA='TRUE'");
        self.cursor.execute(self.query,(datacenter,environment))
        lbmaintainanceserver = self.cursor.fetchone()
        return lbmaintainanceserver[0]

    def gethealthCheckResponse (self,clusterversion,clusterrole):
        self.query = ("SELECT PR.HEALTH_CHECK_RESPONSE AS RESULT FROM PACKAGE_ROLE PR INNER JOIN ROLE_VERSION RV ON PR.ROLE_VERSION_ID=RV.ID INNER JOIN VM_TYPE VMT ON PR.VM_TYPE_ID=VMT.ID AND RV.NAME=%s AND VMT.CODE=%s AND VMT.IS_UDA='TRUE'");
        self.cursor.execute(self.query,(clusterversion,clusterrole))
        healthcheckresponse = self.cursor.fetchone()
        return healthcheckresponse[0]

    def gethealthCheckRequest (self,clusterversion,clusterrole):
        self.query = ("SELECT PR.HEALTH_CHECK_URL AS RESULT FROM PACKAGE_ROLE PR INNER JOIN ROLE_VERSION RV ON PR.ROLE_VERSION_ID=RV.ID INNER JOIN VM_TYPE VMT ON PR.VM_TYPE_ID=VMT.ID AND RV.NAME=%s AND VMT.CODE=%s AND VMT.IS_UDA='TRUE'");
        self.cursor.execute(self.query,(clusterversion,clusterrole))
        healthcheckrequest = self.cursor.fetchone()
        return healthcheckrequest[0]

    def getPersistance (self,clusterversion,clusterrole):
        self.query = ("SELECT PR.PERSISTENCE_METHOD AS RESULT FROM PACKAGE_ROLE PR INNER JOIN ROLE_VERSION RV ON PR.ROLE_VERSION_ID=RV.ID INNER JOIN VM_TYPE VMT ON PR.VM_TYPE_ID=VMT.ID AND RV.NAME=%s AND VMT.CODE=%s AND VMT.IS_UDA='TRUE'");
        self.cursor.execute(self.query,(clusterversion,clusterrole))
        persistance = self.cursor.fetchone()
        return persistance[0]

    def getLbDistMethod (self,clusterversion,clusterrole):
        self.query = ("SELECT PR.LOAD_BALANCE_METHOD AS RESULT FROM PACKAGE_ROLE PR INNER JOIN ROLE_VERSION RV ON PR.ROLE_VERSION_ID=RV.ID INNER JOIN VM_TYPE VMT ON PR.VM_TYPE_ID=VMT.ID AND RV.NAME=%s AND VMT.CODE=%s AND VMT.IS_UDA='TRUE'");
        self.cursor.execute(self.query,(clusterversion,clusterrole))
        lbdistmethod = self.cursor.fetchone()
        return lbdistmethod[0]

    def getCertificate (self,datacenter,environment,domain):
        self.query = ("SELECT C.NAME AS RESULT FROM CERTIFICATE C INNER JOIN DATACENTER D ON C.DATACENTER_ID=D.ID INNER JOIN VM_TIER VMT ON C.VM_TIER_ID=VMT.ID WHERE D.CODE=%s AND VMT.CODE=%s AND VMT.IS_UDA='TRUE' AND C.DOMAIN=%s");
        self.cursor.execute(self.query,(datacenter,environment,domain))
        certificate = self.cursor.fetchone()
        return certificate[0]

    def getHttpsRedirect (self,datacenter,environment):
        self.query = ("SELECT LB.HTTPS_REDIRECT_POLICY AS RESULT FROM LOAD_BALANCE LB INNER JOIN DATACENTER D ON LB.DATACENTER_ID=D.ID INNER JOIN VM_TIER VMT ON VMT.ID= LB.VM_TIER_ID WHERE D.CODE=%s AND VMT.CODE=%s AND VMT.IS_UDA='TRUE'");
        self.cursor.execute(self.query,(datacenter,environment))
        httpsredirect = self.cursor.fetchone()
        return httpsredirect[0]

    def getLoadBalancer (self,datacenter,environment):
        self.query = ("SELECT LB.NAME AS RESULT FROM LOAD_BALANCE LB INNER JOIN DATACENTER D ON D.ID = LB.DATACENTER_ID INNER JOIN VM_TIER VMTI ON VMTI.ID = LB.VM_TIER_ID WHERE D.CODE = %s AND VMTI.CODE =%s AND VMTI.IS_UDA='TRUE'");
        self.cursor.execute(self.query,(datacenter,environment))
        loadbalancer = self.cursor.fetchone()
        return loadbalancer[0]

    def getHealthCheckMonitorType (self,clusterrole,clusterversion,packagename):
        self.query = ("SELECT PR.HEALTH_CHECK_MONITOR_TYPE AS RESULT FROM PACKAGE_ROLE PR INNER JOIN VM_TYPE VMTY ON VMTY.ID = PR.VM_TYPE_ID INNER JOIN ROLE_VERSION RV ON RV.ID = PR.ROLE_VERSION_ID INNER JOIN PACKAGE P On P.ID=PR.PACKAGE_ID WHERE VMTY.CODE = %s AND RV.NAME=%s AND P.NAME=%s and PR.HEALTH_CHECK_MONITOR_TYPE is not null")
        self.cursor.execute(self.query,(clusterrole,clusterversion,packagename))
        monitortype = self.cursor.fetchone()
        return monitortype[0]

    def getLbServerPort (self,packagename,clusterrole):
        self.query = ("SELECT PR.SERVER_PORT AS RESULT FROM PACKAGE_ROLE PR INNER JOIN PACKAGE P ON P.ID = PR.PACKAGE_ID INNER JOIN VM_TYPE VMTY ON VMTY.ID=PR.VM_TYPE_ID WHERE VMTY.IS_UDA='TRUE' AND PR.IS_PRIMARY='TRUE' AND P.NAME =%s AND VMTY.CODE=%s");
        self.cursor.execute(self.query,(packagename,clusterrole))
        lbserverport = self.cursor.fetchone()
        return lbserverport[0]

    def getpublicCSName (self,datacenter,environment):
        self.query = ("SELECT DCTVT.FQDN AS RESULT FROM DATACENTER_TO_VM_TIER DCTVT INNER JOIN VM_TIER VMTI ON VMTI.ID=DCTVT.VM_TIER_ID INNER JOIN DATACENTER D ON D.ID=DCTVT.DATACENTER_ID WHERE D.CODE = %s AND VMTI.CODE = %s");
        self.cursor.execute(self.query,(datacenter,environment))
        publiccsname = self.cursor.fetchone()
        return publiccsname[0]

    def isLoadBalanced (self,fqdn,packagename,clusterrole):
        if fqdn == 'ANY':
            self.query = ("SELECT PR.ID from PACKAGE_ROLE PR INNER JOIN PACKAGE P ON PR.PACKAGE_ID = P.ID INNER JOIN VM_TYPE VMTY ON PR.VM_TYPE_ID = VMTY.ID WHERE PR.IS_LOAD_BALANCED = 1 AND P.NAME = %s AND VMTY.CODE = %s");
            self.cursor.execute(self.query,(packagename,clusterrole))
        else:
            self.query = ("SELECT PR.ID from PACKAGE_ROLE PR INNER JOIN PACKAGE P ON PR.PACKAGE_ID = P.ID INNER JOIN VM_TYPE VMTY ON PR.VM_TYPE_ID = VMTY.ID WHERE PR.IS_LOAD_BALANCED = 1 AND PR.FQDN_TYPE = %s AND P.NAME = %s AND VMTY.CODE = %s");
            self.cursor.execute(self.query,(fqdn,packagename,clusterrole))
        loadbalanced = self.cursor.fetchone()
        if loadbalanced:
            return loadbalanced[0]
        else:
            return None

    def getDNSZoneForVip (self,datacenter,environment):
        self.query = ("SELECT DOMAIN AS RESULT FROM CERTIFICATE C INNER JOIN VM_TIER VMTI ON VMTI.ID=C.VM_TIER_ID INNER JOIN DATACENTER D ON D.ID=C.DATACENTER_ID WHERE D.CODE = %s AND VMTI.CODE=%s");
        self.cursor.execute(self.query,(datacenter,environment))
        zone = self.cursor.fetchone()
        return zone[0]

    def getPrimaryDNS(self,datacenter):
        self.query = ("SELECT INTERNAL_DNS1 AS RESULT FROM DATACENTER D WHERE D.CODE = %s");
        self.cursor.execute(self.query,(datacenter))
        dns1 = self.cursor.fetchone()
        return dns1[0]

    def Datastore(self,datacenter,environment,clusterrole,packagename,esxcluster):
        self.query = ("SELECT DISTINCT DATASTORE FROM GET_DATASTORES(%s,%s,%s,%s,%s)");
        self.cursor.execute(self.query,(datacenter,environment,clusterrole,packagename,esxcluster))
        datastore = self.cursor.fetchone()
        return datastore[0]

    def AddorUpdateServerVersion (self,Vmname,clusterrole,packagename,patch,workflowname,Status):
        self.query = ("Exec AddorUpdateServerVersion_v17_1 %s,%s,%s,%s,%s,%s");
        self.cursor.execute(self.query,(Vmname,clusterrole,packagename,patch,workflowname,Status))
        rowsaffected = self.cursor.fetchone()
        return rowsaffected

    def getDomain (self,datacenter):
        self.query = ("SELECT WINDOWS_DOMAIN AS RESULT FROM DATACENTER WHERE CODE = %s");
        self.cursor.execute(self.query,(datacenter))
        domain = self.cursor.fetchone()
        return domain[0]

    def getPrometheusserver (self,datacenter):
        self.query = ("SELECT PROMETHEUS_SERVER AS RESULT FROM DATACENTER WHERE CODE = %s");
        self.cursor.execute(self.query,(datacenter))
        prometheus = self.cursor.fetchone()
        return prometheus[0]

    def lbDict(self,clustername,packagename):
        clusterName = clustername.upper()
        d = clustername.split("-")
        datacenter = d[0]
        clusterversion = d[1]
        environment = d[2]
        clusterrole = d[3]
        psclustername = clusterName.replace("-","_")
        num = d[4]
        clusternum = num[slice(1,5)]
        patsetname = "ps_" + psclustername + "_fqdns"
        data = dict()
        data['datacenter'] = datacenter
        data['environment'] = environment
        data['clusterName'] = clusterName
        data['clusterVersion'] = clusterversion
        data['clusterRole'] = clusterrole
        data['packageName'] = packagename
        data['domain']= SaltJob.getpublicdomain(self,datacenter,environment)
        data['lbMaintainanceServer'] = SaltJob.getlbmaintainanceserver (self,datacenter,environment)
        data['psClusterName'] = psclustername
        data['patSetName'] = patsetname
        data['clusterNum'] = clusternum
        data['healthCheckResponse'] = SaltJob.gethealthCheckResponse (self,clusterversion,clusterrole)
        data['healthCheckRequest'] = SaltJob.gethealthCheckRequest (self,clusterversion,clusterrole)
        data['serverPort'] = SaltJob.getLbServerPort (self,packagename,clusterrole)
        data['LB'] = SaltJob.getLoadBalancer (self,datacenter,environment)
        data['persistence'] = SaltJob.getPersistance (self,clusterversion,clusterrole)
        data['loadDistMethod'] = SaltJob.getLbDistMethod (self,clusterversion,clusterrole)
        data['certificate'] = SaltJob.getCertificate (self,datacenter,environment,data["domain"])
        data['httpsRedirect'] = SaltJob.getHttpsRedirect (self,datacenter,environment)
        data['publicCsName'] = SaltJob.getpublicCSName (self,datacenter,environment)
        data['monitorType'] = SaltJob.getHealthCheckMonitorType (self,clusterrole,clusterversion,packagename)
        return data


####################################
########SECOPS FUNCTIONS############
    def getRoleversion(self,version,role):
        self.cursor.execute("SELECT RV.NAME AS ROLVEVERSION FROM PACKAGE P INNER JOIN PACKAGE_ROLE PR ON P.id = PR.PACKAGE_ID INNER JOIN VM_TYPE VT ON VT.id = PR.VM_TYPE_ID JOIN ROLE_VERSION RV ON RV.id = PR.ROLE_VERSION_ID WHERE P.NAME ='" + version + "' and VT.CODE ='" + role + "'")
        records = self.cursor.fetchone()
        self.conn.close()
        return records[0]


    def getBenchmarkID(self,version,vm_type,role_version):
        self.cursor.execute("SELECT distinct(sb.BENCHMARK_UUID) FROM SEC_APP_POLICY SAP inner join SEC_APP_POLICY_TO_BENCHMARK_CHECK SAPTBC on saptbc.SEC_APP_POLICY_ID=sap.id inner join SEC_BENCHMARK_TO_SEC_CHECK SBTSC on SBTSC.id=SAPTBC.SEC_BENCHMARK_TO_SEC_CHECK_ID inner join SEC_BENCHMARK sb on sb.id=sbtsc.SEC_BENCHMARK_ID inner join SEC_CHECK sc on sc.id=SBTSC.SEC_CHECK_ID left join SEC_VARIABLE_OVERRIDES svo on saptbc.ID=svo.SEC_APP_POLICY_TO_BENCHMARK_CHECK_ID left join SEC_VARIABLE_DEFS SVD on SC.ID=SVD.SEC_CHECK_ID inner join package p on p.id=sap.PACKAGE_ID inner join vm_type vmty on vmty.id=sap.VM_TYPE_ID inner join ROLE_VERSION rv on rv.id=sap.ROLE_VERSION_ID where p.name='" + version + "' AND VMTY.CODE='" + vm_type + "' AND RV.NAME='" + role_version + "'")
        row = self.cursor.fetchone()
        self.conn.close()
        return row[0]

    def getCheckID(self,version,vm_type,role_version):
        self.cursor.execute("SELECT distinct(sc.CHECK_UUID) FROM SEC_APP_POLICY SAP inner join SEC_APP_POLICY_TO_BENCHMARK_CHECK SAPTBC on saptbc.SEC_APP_POLICY_ID=sap.id inner join SEC_BENCHMARK_TO_SEC_CHECK SBTSC on SBTSC.id=SAPTBC.SEC_BENCHMARK_TO_SEC_CHECK_ID inner join SEC_BENCHMARK sb on sb.id=sbtsc.SEC_BENCHMARK_ID inner join SEC_CHECK sc on sc.id=SBTSC.SEC_CHECK_ID left join SEC_VARIABLE_OVERRIDES svo on saptbc.ID=svo.SEC_APP_POLICY_TO_BENCHMARK_CHECK_ID left join SEC_VARIABLE_DEFS SVD on SC.ID=SVD.SEC_CHECK_ID inner join package p on p.id=sap.PACKAGE_ID inner join vm_type vmty on vmty.id=sap.VM_TYPE_ID inner join ROLE_VERSION rv on rv.id=sap.ROLE_VERSION_ID where p.name='" + version + "' AND VMTY.CODE='" + vm_type + "' AND RV.NAME='" + role_version + "' AND saptbc.ISEXEMPTED=0")
        chk = self.cursor.fetchall()
        checks = []
        for row in chk:
            checks.append(row[0])
        self.conn.close()
        return checks

    def getVariables(self,version,vm_type,role_version):
        self.cursor.execute("SELECT sc.CHECK_UUID,svd.NAME as variable_name,coalesce(svo.OVERRIDE_VALUE,svd.VALUE) as variable_value FROM SEC_APP_POLICY SAP inner join SEC_APP_POLICY_TO_BENCHMARK_CHECK SAPTBC on saptbc.SEC_APP_POLICY_ID=sap.id inner join SEC_BENCHMARK_TO_SEC_CHECK SBTSC on SBTSC.id=SAPTBC.SEC_BENCHMARK_TO_SEC_CHECK_ID inner join SEC_BENCHMARK sb on sb.id=sbtsc.SEC_BENCHMARK_ID inner join SEC_CHECK sc on sc.id=SBTSC.SEC_CHECK_ID inner join SEC_VARIABLE_DEFS SVD on SC.ID=SVD.SEC_CHECK_ID left join SEC_VARIABLE_OVERRIDES svo on saptbc.ID=svo.SEC_APP_POLICY_TO_BENCHMARK_CHECK_ID inner join package p on p.id=sap.PACKAGE_ID inner join vm_type vmty on vmty.id=sap.VM_TYPE_ID inner join ROLE_VERSION rv on rv.id=sap.ROLE_VERSION_ID where p.name='" + version + "' AND VMTY.CODE='" + vm_type + "' AND RV.NAME='" + role_version + "' AND saptbc.ISEXEMPTED=0")
        var = self.cursor.fetchall()
        variables=[]
        for row in var:
          var={
            "check_uuid":row[0],
            "name":row[1],
            "value":row[2]}
          variables.append(var)
        self.conn.close()
        return variables

    def getCPU_COUNT(self,version,role):
        self.cursor.execute("SELECT RV.NAME AS ROLVEVERSION FROM PACKAGE P INNER JOIN PACKAGE_ROLE PR ON P.id = PR.PACKAGE_ID INNER JOIN VM_TYPE VT ON VT.id = PR.VM_TYPE_ID JOIN ROLE_VERSION RV ON RV.id = PR.ROLE_VERSION_ID WHERE P.NAME ='" + version + "' and VT.CODE ='" + role + "'")
        records = self.cursor.fetchone()
        RV = records[0]
        self.cursor.execute("SELECT PR.VM_MEMORY,PR.VM_CPU_COUNT FROM PACKAGE_ROLE PR INNER JOIN VM_TYPE VMTY ON VMTY.ID = PR.VM_TYPE_ID INNER JOIN ROLE_VERSION RV ON RV.ID = PR.ROLE_VERSION_ID INNER JOIN PACKAGE P On P.ID=PR.PACKAGE_ID WHERE VMTY.CODE ='" + role + "' AND RV.NAME='" + RV + "' AND P.NAME='" + version + "'")
        record = self.cursor.fetchone()
        Memory = record[0]
        CPU = record[1]
        self.conn.close()
        return Memory,CPU

    def Nameservers(self,datacenter):
        self.cursor.execute("SELECT INTERNAL_DNS1,INTERNAL_DNS2 from DATACENTER where code ='" + datacenter + "'")
        data = self.cursor.fetchone()
        DNS1 = data[0]
        DNS2 = data[1]
        self.conn.close()
        return DNS1,DNS2

    def defaultGateway(self,networkname):
        self.cursor.execute("select DEFAULT_GATEWAY as RESULT from IP_SUBNET where DIST_PORT_GROUP ='" + networkname + "'")
        record = self.cursor.fetchone()
        self.conn.close()
        return record[0]

    def getpassword(self,source):
        return data.get_PMP_pass(source)

    def getDVS_switch(self,Port_Group):
        try:
            self.cursor.execute("select DVS_SWITCH from IP_SUBNET where DIST_PORT_GROUP = '"+ Port_Group +"'")
            record = self.cursor.fetchone()
        except (Exception) as error:
            raise(error)
        finally:
            self.conn.close()
            return record[0]

    def Splunk(self,datacenter):
        try:
            self.cursor.execute("select CKTD.VALUE AS RESULT from CONFIGURATION_KEY_TO_DATACENTER cktd inner join CONFIGURATION_KEY ck on ck.id = cktd.CONFIGURATION_KEY_ID inner join DATACENTER d on d.ID = cktd.DATACENTER_ID where d.CODE ='" + datacenter + "' and ck.[KEY] = 'LINUX_SPLUNK_INSTALLER'")
            data = self.cursor.fetchone()
        except (Exception) as error:
            print(error)
            print("Cannot locate Splunk binaries for Environment :" + datacenter)
            raise
        finally:
            self.conn.close()
            return data[0]

    def VM_TIER(self,Environment):
        try:
            self.cursor.execute("SELECT [ID] FROM [VM_TIER] WHERE [CODE] ='" + Environment + "'")
            data = self.cursor.fetchone()
        except (Exception) as error:
            print(error)
            print("Cannot locate TIER_ID for Environment :" + Environment)
        finally:
            self.conn.close()
            return str(data[0])

    def TYPE_ID(self,Role):
        try:
            self.cursor.execute("SELECT [ID] FROM [VM_TYPE] WHERE [CODE] ='" + Role + "'")
            record = self.cursor.fetchone()
#            print(Role + " Role VM Type ID : " + str(data[0]))
        except (Exception) as error:
            print(error)
            print("Cannot locate TYPE_ID for role :" + Role)
        finally:
            self.conn.close()
            return str(record[0])

    def get_assocAppClusterId(self,associateClusterName):
        try:
            self.cursor.execute("SELECT ID AS RESULT FROM APP_CLUSTER WHERE NAME = '" + associateClusterName + "'")
            data = self.cursor.fetchone()
            return data[0]
        except (Exception) as error:
            raise Exception(error)
        finally:
            self.conn.close()

    def InsertVMname(self,vmName,vmIP,uuid,os,Role,Environment,fqdn):
        try:
            typeid = SaltJob().TYPE_ID(Role)
            vmTireid = SaltJob().VM_TIER(Environment)
            self.query = ("INSERT INTO VM(DNSNAME, IP, NAME, DESCRIPTION, UID, SERVER_ID, TYPE_ID, TIER_ID, OS, POWERSTATE, FIRST_UPDATED, LAST_UPDATED, FQDN) VALUES (%s,%s,%s,'Provisioned by Salt-Cloud',%s,'48',%s,%s,%s,'poweredOn',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,%s)")
            self.cursor.execute(self.query,(vmName,vmIP,vmName,uuid,str(typeid),str(vmTireid),os,fqdn))
            self.conn.commit()
            if self.cursor.rowcount == 0:
                raise Exception("No records were added to VM Table.  Please investigate")
            else:
                return True
        except (Exception) as error:
            raise Exception(error)
            self.conn.rollback()
        finally:
            self.conn.close()


    def validCluster(self,clusterName):
        try:
            self.query = ("SELECT NAME as RESULT from APP_CLUSTER where name = '" + clusterName + "'")
            self.cursor.execute(self.query)
            record = self.cursor.fetchall()
            if self.cursor.rowcount == 0:
                return True
            else:
                return False
        except Exception:
            raise

    def addNewClusterinfo(self,clusterName,associateClusterName,isDedicated,isValidated,podClusterCode,udaPackage):
        try:
            if SaltJob.validCluster(self,clusterName):
                clusterNameArray = clusterName.upper().split("-")
                datacenter = clusterNameArray[0]
                clusterVersion = clusterNameArray[1]
                environment = clusterNameArray[2]
                clusterRole = clusterNameArray[3]
                if associateClusterName == '':
                    assocAppClusterId = 'null'
                else:
                    assocAppClusterId = SaltJob().get_assocAppClusterId(associateClusterName)
                self.cursor.execute("INSERT INTO APP_CLUSTER(VM_TYPE_ID,VM_TIER_ID,NAME,ROLE_VERSION_ID,DATACENTER_ID,ASSOCIATE_APP_CLUSTER_ID,IS_DEDICATED,IQ_STATUS,PACKAGE_ID,POD_CLUSTER_CODE) " + "(SELECT VM_TYPE.ID,VM_TIER.ID,'" + clusterName + "',RV.ID,DC.ID," + assocAppClusterId + "," + isDedicated + ",'" + isValidated + "',P.ID," + podClusterCode + " " + "FROM VM_TYPE, VM_TIER, ROLE_VERSION RV, DATACENTER DC, PACKAGE_ROLE PR, PACKAGE P  WHERE VM_TYPE.CODE = '" + clusterRole + "' AND VM_TIER.CODE = '" + environment + "' " + "AND RV.NAME = '" + clusterVersion + "' AND PR.VM_TYPE_ID = VM_TYPE.ID AND PR.ROLE_VERSION_ID = RV.ID AND DC.CODE = '" + datacenter + "' " + "AND PR.PACKAGE_ID = P.ID AND P.NAME = '" + udaPackage + "')")
                self.conn.commit()
                if self.cursor.rowcount == 0:
                    raise Exception("No records were added to APP_CLUSTER.  Please investigate")
                else:
                    return True
            else:
                log.debug("Found a existing record with clusterName :%s", clusterName)
                return True

        except (Exception) as error:
            raise Exception(error)
            self.conn.rollback()
        finally:
            self.conn.close()


    def AppClusterVMIDbyVMName(self,vmName):
        try:
            self.cursor.execute("select ACVM.VM_ID as RESULT from vm  INNER JOIN APP_CLUSTER_VM ACVM on ACVM.VM_ID = VM.ID WHERE VM.NAME ='" + vmName + "'")
            data = self.cursor.fetchall()
            if len(data) != 0:
                print(" App cluster VM ID : " + str(data[0]))
        except (Exception) as error:
            print(error)
            logger.error(error)
            raise
        finally:
            self.conn.close()
            return data

    def vmNotAssociatedWithAppCluster(self,vmName,acvmID):
        try:
            self.cursor.execute("select ID as RESULT from vm  WHERE NAME = '" + vmName + "' and ID != '" + acvmID + "'")
            data = self.cursor.fetchall()
            vmIDs = []
            for row in data:
                vmIDs.append(row[0])
        except (Exception) as error:
            print(error)
            logger.error(error)
            raise
        finally:
            self.conn.close()
            return vmIDs

    def FixVM(self,vmIDs):
        try:
            for vmID in vmIDs:
                self.cursor.execute("exec delete_vm " + vmID + " ")
                self.conn.commit()
                print(vmID + " VM ID has been fixed")
        except (Exception) as error:
            print(error)
            logger.error(error)
            raise
        finally:
            self.conn.close()
            return vmIDs

    def InsertAppClusterVM(self,clusterName,uuid):
        try:
            self.query= ("INSERT INTO APP_CLUSTER_VM(APP_CLUSTER_ID,VM_ID) (SELECT AC.ID,VM.ID FROM APP_CLUSTER AC,VM VM WHERE AC.NAME=%s AND VM.[UID]=%s)")
            self.cursor.execute(self.query,(clusterName,uuid))
            self.conn.commit()
            if self.cursor.rowcount == 1:
                return True
            else:
                return False
        except (Exception) as error:
            raise Exception(error)
            self.conn.rollback()

    def UpdateExistingVM(self,vmName,vmIP,os,uuid,Role,Environment,fqdn):
        try:
            typeid = SaltJob().TYPE_ID(Role)
            vmTireid = SaltJob().VM_TIER(Environment)
            self.query= ("UPDATE VM SET DNSNAME=%s,IP=%s,NAME=%s,DESCRIPTION='updated Provisioned by Salt-Cloud',SERVER_ID='48',TYPE_ID=%s,TIER_ID=%s,OS=%s,POWERSTATE='poweredOn', LAST_UPDATED=CURRENT_TIMESTAMP, FQDN=%s WHERE UID=%s")
            self.cursor.execute(self.query,(vmName,vmIP,vmName,typeid,vmTireid,os,uuid,fqdn))
            self.conn.commit()
            return self.cursor.rowcount
        except (Exception) as error:
            print(error)
            raise
            self.conn.rollback()
    def checkVMexits(self,vmName):
        try:
            self.cursor.execute("SELECT VM.NAME AS RESULT FROM VM WHERE VM.NAME='" + vmName + "' AND VM.POWERSTATE != 'deleted'")
            data = self.cursor.fetchall()
            self.conn.close()
        except (Exception) as error:
            raise Exception(error)
        finally:
            self.conn.close()
            return data
           
    def UUID(self,vmName,vmIP,uuid,os,Role,Environment,ClusterName,fqdn):
        try:
            self.cursor.execute("SELECT id FROM VM WHERE UID ='" + str(uuid) + "'")
            if self.cursor.fetchall():
                SaltJob().UpdateExistingVM(vmName,vmIP,os,uuid,Role,Environment,fqdn)
                return SaltJob().InsertAppClusterVM(ClusterName,uuid)
            elif SaltJob().InsertVMname(vmName,vmIP,uuid,os,Role,Environment,fqdn):
                record = SaltJob().checkVMexits(vmName)
                if len(record) != 1:
                    acvmID = SaltJob().AppClusterVMIDbyVMName(vmName)
                    vmIDs = SaltJob().vmNotAssociatedWithAppCluster(vmName,acvmID)
                    return SaltJob().FixVM(vmIDs)
                else:
                    return SaltJob().InsertAppClusterVM(ClusterName,uuid)
            else:
                return False
        except (Exception) as error:
            raise Exception(error)

##########Networkfile

    def ipformat(self,Ip):
        regex = '''^(25[0-5]|2[0-4][0-9]|[0-1]?[0-9][0-9]?)\.(
            25[0-5]|2[0-4][0-9]|[0-1]?[0-9][0-9]?)\.(
            25[0-5]|2[0-4][0-9]|[0-1]?[0-9][0-9]?)\.(
            25[0-5]|2[0-4][0-9]|[0-1]?[0-9][0-9]?)$'''
        if(re.search(regex, Ip)):
            return True
        else:
            return False

    def ping_ip(self,current_ip_address):
        try:
            output = subprocess.check_output("ping -{} 1 {}".format('n' if platform.system().lower(
            ) == "windows" else 'c', current_ip_address), shell=True, universal_newlines=True)
            if 'unreachable' in output:
                return False
            else:
                print ('valid IP')
                return True
        except Exception:
            return False

    def isIpIn_cmdb(self,ipaddress):
        try:
            self.query = ("SELECT NAME as RESULT from VM where POWERSTATE <> 'deleted' and IP = '" + ipaddress + "'")
            self.cursor.execute(self.query)
            record = self.cursor.fetchall()
            if self.cursor.rowcount == 0:
                return False
            else:
                return True
        except Exception as error:
            raise

    def FindIp(self,networkname,datacenter):
        try:
            zonedata = SaltJob.querydns(self,datacenter,'IP')
            for i in range(len(networkname)):
                subnet = networkname[i][0].split("/")[0]
                cidr = networkname[i][0].split("/")[1]
                data = oriondb_IPAM.oriondb().IpList(subnet,cidr)
                if len(data) == 0:
                    print ("No Ips avaiilable for subnet")
                else:
                    for record in data:
                        IPNodeID = record[0]
                        ipaddress = record[1]
                        if SaltJob.ipformat(self,ipaddress):
                            if SaltJob.ping_ip(self,ipaddress):
                                print(ipaddress)
                                oriondb_IPAM.oriondb().UpdateStatus(ipaddress)
                            elif SaltJob.isIpIn_cmdb(self,ipaddress):
                                pass
                            elif ipaddress in zonedata:
                                pass
                            else:
                                data = dict();
                                data['ipaddress'] = ipaddress
                                data['Port_Group'] = networkname[i][1]
                                return data
                                break
        except (Exception) as error:
            raise Exception(error)

    def checkServerExists(self,ClusterName):
        try:
            self.cursor.execute("SELECT V.NAME,V.IP FROM VM V INNER JOIN APP_CLUSTER_VM ACV on ACV.VM_ID = V.ID INNER JOIN APP_CLUSTER AC on AC.ID = ACV.APP_CLUSTER_ID WHERE AC.NAME = '"+ ClusterName +"' AND V.POWERSTATE = 'poweredOn'")
            record = self.cursor.fetchall()
            if len(record) == 0:
                return True
            else:
                return False
        except (Exception) as error:
            raise Exception(error)
        finally:
            self.conn.close()

    def querydns(self,datacenter,value):
        PrimaryDNS = SaltJob.getPrimaryDNS(self,datacenter)
        domain = SaltJob.getDomain(self,datacenter)
        zonefile = dns.zone.from_xfr(dns.query.xfr(PrimaryDNS, domain))
        names = zonefile.nodes.keys()
        nodelist = []
        if value == 'Name':
            array = '0'
        else:
            array = '4'
        for data in names:
            text = zonefile[data].to_text(data)
            validate = text.split(" ")[int(array)]
            nodelist.append(validate)
        return nodelist

    def getservername(self,ClusterName,numOfServers,datacenter):
        try:
            serverlist = []
            ClusterName = ClusterName.split("-")
            serverPrefix = ClusterName[0] + ClusterName[3] + ClusterName[2][0] + str(ClusterName[4][1:5]) + "N"
            zonedata = SaltJob.querydns(self,datacenter,'Name')
            i = 0
            while i < 99:
                i += 1
                serverformat = serverPrefix + '{:03d}'.format(i)
                time.sleep(3)
                if serverformat in zonedata:
                    continue
                else:
                    serverlist.append(serverformat)
                if len(serverlist) == int(numOfServers):
                    break
            return serverlist
        except (Exception) as error:
            raise Exception(error)


    def esxClusterName(self,datacenter,environment,clusterrole):
        self.query = ("SELECT DISTINCT C.NAME AS RESULT FROM APP_FUNCTION_TO_CLUSTER AFTC INNER JOIN APP_FUNCTION AF ON AF.ID=AFTC.APP_FUNCTION_ID INNER JOIN CLUSTER C ON C.ID=AFTC.CLUSTER_ID INNER JOIN VM_TIER VMTI ON VMTI.ID=AFTC.VM_TIER_ID INNER JOIN DATACENTER D ON D.ID=AFTC.DATACENTER_ID INNER JOIN VM_TYPE VMTY ON AFTC.VM_TIER_ID=VMTI.ID AND AF.ID=VMTY.APP_FUNCTION_ID WHERE D.CODE=%s AND VMTI.IS_UDA='TRUE' AND VMTI.CODE=%s AND VMTY.IS_UDA='TRUE' AND VMTY.CODE=%s")
        self.cursor.execute(self.query,(datacenter,environment,clusterrole))
        record = self.cursor.fetchone()
        return record[0]


    def getServers(self,ClusterName):
        try:
            self.cursor.execute("SELECT V.NAME FROM VM V INNER JOIN APP_CLUSTER_VM ACV on ACV.VM_ID = V.ID INNER JOIN APP_CLUSTER AC on AC.ID = ACV.APP_CLUSTER_ID WHERE AC.NAME = '"+ ClusterName +"' AND V.POWERSTATE = 'poweredOn'")
            record = self.cursor.fetchall()
            servers = [i[0] for i in record]
#           ips = [i[1] for i in record]
            self.conn.close()
            return servers
        except (Exception) as error:
            raise Exception(error)

    def getcmdb_clusterVmIps(self,ClusterName):
        try:
            self.cursor.execute("select IP AS RESULT from VM inner join app_cluster_vm on app_cluster_vm.vm_id = vm.id inner join app_cluster on app_cluster.id = app_cluster_vm.APP_CLUSTER_ID where app_cluster.name = '" + ClusterName + "' ORDER BY vm.name")
            data = self.cursor.fetchall()
            VmIps = []
            for row in data:
                VmIps.append(row[0])
        except (Exception,StandardError) as error:
            raise Exception(error)
        finally:
            self.conn.close()
            return VmIps

    def checkConfig(self,config_key,ClusterName):
        self.query= ("SELECT CONFIGURATION_KEY_ID,APP_CLUSTER_ID FROM CONFIGURATION_KEY_TO_APP_CLUSTER WHERE CONFIGURATION_KEY_ID = (select CK.ID FROM CONFIGURATION_KEY CK WHERE CK.[KEY]=%s) and APP_CLUSTER_ID = (Select ID from APP_CLUSTER where name = %s)")
        self.cursor.execute(self.query,(config_key,ClusterName))
        record = self.cursor.fetchone()
        if self.cursor.rowcount == 0:
            return True
        else:
            return False

    def DCC_CONFIGKEYS(self,ClusterName):
        try:
            nodeList = ''
            pwToUse = ''
            iplist = SaltJob().getcmdb_clusterVmIps(ClusterName)
            dccPort = "6379"
            ResourceName = ClusterName
            AccountName = "redis"
            pwToUse = ''.join(random.choice(string.ascii_uppercase + string.ascii_lowercase + string.digits) for _ in range(16))
            pmp_resource.PMP().add_resource(AccountName,pwToUse,ResourceName,"Linux")
            AdminPwd = pmp_resource.PMP().PMP_resource(ResourceName,AccountName)
            for i in range(len(iplist)):
                if i > 0:
                    nodeList = nodeList + ',' + iplist[i]
                else:
                    nodeList = iplist[i]
            cmdbAdditions = [{"CONFIGURATION_KEY_KEY":"DCC_REDIS_PORT","CONFIGURATION_KEY_VALUE":dccPort}];
            cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"DCC_REDIS_NODES","CONFIGURATION_KEY_VALUE":nodeList});
            cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"DCC_REDIS_PWD","CONFIGURATION_KEY_VALUE":AdminPwd});
            for i in range(len(cmdbAdditions)):
                if SaltJob().checkConfig(cmdbAdditions[i]["CONFIGURATION_KEY_KEY"],ClusterName):
                    self.query= ("INSERT INTO CONFIGURATION_KEY_TO_APP_CLUSTER (VALUE,CONFIGURATION_KEY_ID,APP_CLUSTER_ID) (SELECT %s,CK.ID,AC.ID FROM CONFIGURATION_KEY CK,APP_CLUSTER AC WHERE CK.[KEY]=%s AND AC.[NAME]=%s AND NOT EXISTS (SELECT * FROM CONFIGURATION_KEY_TO_APP_CLUSTER WHERE APP_CLUSTER_ID=AC.ID AND CONFIGURATION_KEY_ID=CK.ID))")
                    self.cursor.execute(self.query,(cmdbAdditions[i]["CONFIGURATION_KEY_VALUE"],cmdbAdditions[i]["CONFIGURATION_KEY_KEY"],ClusterName))
                    self.conn.commit()
                    if self.cursor.rowcount == 0:
                        raise Exception("Unable to insert Record into table CONFIGURATION_KEY_TO_APP_CLUSTER for" + cmdbAdditions[i]["CONFIGURATION_KEY_KEY"])
                        return False
            return True 
        except (Exception) as error:
            raise Exception(error)
        finally:
            self.conn.close()


    def UXD_CONFIGKEYS(self,ClusterName):
        try:
            nodeList = ''
            vmList = SaltJob().getServers(ClusterName)
            details = pmp_resource.PMP().get_PMP_details('UXDTemplate')
            dbAdmin = details['account']
            dbAdminPwd = pmp_resource.PMP().get_PMP_pass('UXDTemplate')
            for i in range(len(vmList)):
                if i > 0:
                    nodeList = nodeList + ',' + vmList[i]
                else:
                    nodeList = vmList[i]
            cmdbAdditions = [{"CONFIGURATION_KEY_KEY":"UXD_DB_SERVER","CONFIGURATION_KEY_VALUE":nodeList}]
            cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"UXD_ADMIN_USER","CONFIGURATION_KEY_VALUE":dbAdmin})
            cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"UXD_ADMIN_PASSWORD","CONFIGURATION_KEY_VALUE":dbAdminPwd});
            cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"UXD_DB_PORT","CONFIGURATION_KEY_VALUE":"3306"});
            cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"UXD_DB_INSTANCE","CONFIGURATION_KEY_VALUE":nodeList});
            cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"UXD_DB_TYPE","CONFIGURATION_KEY_VALUE":"MYSQL"})
            for i in range(len(cmdbAdditions)):
                if SaltJob().checkConfig(cmdbAdditions[i]["CONFIGURATION_KEY_KEY"],ClusterName):
                    self.query= ("INSERT INTO CONFIGURATION_KEY_TO_APP_CLUSTER (VALUE,CONFIGURATION_KEY_ID,APP_CLUSTER_ID) (SELECT %s,CK.ID,AC.ID FROM CONFIGURATION_KEY CK,APP_CLUSTER AC WHERE CK.[KEY]=%s AND AC.[NAME]=%s AND NOT EXISTS (SELECT * FROM CONFIGURATION_KEY_TO_APP_CLUSTER WHERE APP_CLUSTER_ID=AC.ID AND CONFIGURATION_KEY_ID=CK.ID))")
                    self.cursor.execute(self.query,(cmdbAdditions[i]["CONFIGURATION_KEY_VALUE"],cmdbAdditions[i]["CONFIGURATION_KEY_KEY"],ClusterName))
                    self.conn.commit()
                    if self.cursor.rowcount == 0:
                        raise Exception("Unable to insert Record into table CONFIGURATION_KEY_TO_APP_CLUSTER for" + cmdbAdditions[i]["CONFIGURATION_KEY_KEY"])
                        return False
            return True
        except (Exception) as error:
            raise Exception(error)
        finally:
            self.conn.close()

    def UMD_CONFIGKEYS(self,ClusterName):
        try:
            nodeList = ''
            vmList = SaltJob().getServers(ClusterName)
            details = pmp_resource.PMP().get_PMP_details('UMDTemplate')
            dbAdmin = details['account']
            dbAdminPwd = pmp_resource.PMP().get_PMP_pass('UMDTemplate')
            for i in range(len(vmList)):
                if i > 0:
                    nodeList = nodeList + ',' + vmList[i]
                else:
                    nodeList = vmList[i]
            cmdbAdditions = [{"CONFIGURATION_KEY_KEY":"UMD_DB_SERVER","CONFIGURATION_KEY_VALUE":nodeList}]
            cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"UMD_ADMIN_USER","CONFIGURATION_KEY_VALUE":dbAdmin});
            cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"UMD_ADMIN_PASSWORD","CONFIGURATION_KEY_VALUE":dbAdminPwd});
            cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"UMD_DB_PORT","CONFIGURATION_KEY_VALUE":"27017"});
            cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"UMD_DB_INSTANCE","CONFIGURATION_KEY_VALUE":nodeList})
            for i in range(len(cmdbAdditions)):
                if SaltJob().checkConfig(cmdbAdditions[i]["CONFIGURATION_KEY_KEY"],ClusterName):
                    self.query= ("INSERT INTO CONFIGURATION_KEY_TO_APP_CLUSTER (VALUE,CONFIGURATION_KEY_ID,APP_CLUSTER_ID) (SELECT %s,CK.ID,AC.ID FROM CONFIGURATION_KEY CK,APP_CLUSTER AC WHERE CK.[KEY]=%s AND AC.[NAME]=%s AND NOT EXISTS (SELECT * FROM CONFIGURATION_KEY_TO_APP_CLUSTER WHERE APP_CLUSTER_ID=AC.ID AND CONFIGURATION_KEY_ID=CK.ID))")
                    self.cursor.execute(self.query,(cmdbAdditions[i]["CONFIGURATION_KEY_VALUE"],cmdbAdditions[i]["CONFIGURATION_KEY_KEY"],ClusterName))
                    self.conn.commit()
                    if self.cursor.rowcount == 0:
                        raise Exception("Unable to insert Record into table CONFIGURATION_KEY_TO_APP_CLUSTER for" + cmdbAdditions[i]["CONFIGURATION_KEY_KEY"])
                        return False
            return True
        except (Exception) as error:
            raise Exception(error)
        finally:
            self.conn.close()


    def UKA_CONFIGKEYS(self,ClusterName):
        try:
            result = ''
            uebresult = ''
            pwToUse = ''
            uebpwToUse = ''
            iplist = SaltJob().getcmdb_clusterVmIps(ClusterName)
            kafkaport = "9092"
            uebport = "15672"
            for i in range(len(iplist)):
                if i > 0:
                    uebresult = uebresult + ',' + iplist[i]
                else:
                    uebresult = iplist[i]

            for i in range(len(iplist)):
                if i > 0:
                    result = result + ',' + iplist[i]+":"+kafkaport
                else:
                    result = iplist[i]+":"+kafkaport
            uebResourceName = ClusterName
            uebAccountName = "rabbitadmin"
            dbAdminResource = ClusterName
            dbAdminUser = "kafkaAppuser"
            pwToUse = ''.join(random.choice(string.ascii_uppercase + string.ascii_lowercase + string.digits) for _ in range(16))
            uebpwToUse = ''.join(random.choice(string.ascii_uppercase + string.ascii_lowercase + string.digits) for _ in range(16))
            pmp_resource.PMP().add_resource(dbAdminUser,pwToUse,dbAdminResource,"Linux")
            pmp_resource.PMP().add_resource(uebAccountName,uebpwToUse,uebResourceName,"Linux")
            dbAdminPwd = pmp_resource.PMP().PMP_resource(dbAdminResource,dbAdminUser)
            uebAdminPwd = pmp_resource.PMP().PMP_resource(uebResourceName,uebAccountName)
            cmdbAdditions = [{"CONFIGURATION_KEY_KEY":"UKA_SERVER_NODES","CONFIGURATION_KEY_VALUE":result}];
            cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"UKA_PORT","CONFIGURATION_KEY_VALUE":kafkaport});
            cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"UKA_APPLICATION_USER","CONFIGURATION_KEY_VALUE":dbAdminUser});
            cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"UKA_APPLICATION_PWD","CONFIGURATION_KEY_VALUE":dbAdminPwd});
            cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"UEB_PORT","CONFIGURATION_KEY_VALUE":uebport});
            cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"UEB_SERVER_NODES","CONFIGURATION_KEY_VALUE":uebresult});
            cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"UEB_USER","CONFIGURATION_KEY_VALUE":uebAccountName});
            cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"UEB_PASSWORD","CONFIGURATION_KEY_VALUE":uebAdminPwd});
            for i in range(len(cmdbAdditions)):
                if SaltJob().checkConfig(cmdbAdditions[i]["CONFIGURATION_KEY_KEY"],ClusterName):
                    self.query= ("INSERT INTO CONFIGURATION_KEY_TO_APP_CLUSTER (VALUE,CONFIGURATION_KEY_ID,APP_CLUSTER_ID) (SELECT %s,CK.ID,AC.ID FROM CONFIGURATION_KEY CK,APP_CLUSTER AC WHERE CK.[KEY]=%s AND AC.[NAME]=%s AND NOT EXISTS (SELECT * FROM CONFIGURATION_KEY_TO_APP_CLUSTER WHERE APP_CLUSTER_ID=AC.ID AND CONFIGURATION_KEY_ID=CK.ID))")
                    self.cursor.execute(self.query,(cmdbAdditions[i]["CONFIGURATION_KEY_VALUE"],cmdbAdditions[i]["CONFIGURATION_KEY_KEY"],ClusterName))
                    self.conn.commit()
                    if self.cursor.rowcount == 0:
                        raise Exception("Unable to insert Record into table CONFIGURATION_KEY_TO_APP_CLUSTER for" + cmdbAdditions[i]["CONFIGURATION_KEY_KEY"])
                        return False
            return True
        except (Exception) as error:
            raise Exception(error)
        finally:
            self.conn.close()


    def CSD_CONFIGKEYS(self,ClusterName):
        try:
            result = ''
            pwToUse = ''
            iplist = SaltJob().getcmdb_clusterVmIps(ClusterName)
            csdport = "9042"
            for i in range(len(iplist)):
                if i > 0:
                    result = result + ',' + iplist[i]
                else:
                    result = iplist[i]
            dbAdminResource = ClusterName
            dbAdminUser = "csdadminuser"
            pwToUse = ''.join(random.choice(string.ascii_uppercase + string.ascii_lowercase + string.digits) for _ in range(16))
            pmp_resource.PMP().add_resource(dbAdminUser,pwToUse,dbAdminResource,"Linux")
            dbAdminPwd = pmp_resource.PMP().PMP_resource(dbAdminResource,dbAdminUser)
            cmdbAdditions = [{"CONFIGURATION_KEY_KEY":"CSD_SERVER_NODES","CONFIGURATION_KEY_VALUE":result}];
            cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"CSD_PORT","CONFIGURATION_KEY_VALUE":csdport});
            cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"CSD_DB_ADMIN_PWD","CONFIGURATION_KEY_VALUE":dbAdminPwd});
            cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"CSD_DB_ADMIN_USER ","CONFIGURATION_KEY_VALUE":dbAdminUser});
            for i in range(len(cmdbAdditions)):
                if SaltJob().checkConfig(cmdbAdditions[i]["CONFIGURATION_KEY_KEY"],ClusterName):
                    self.query= ("INSERT INTO CONFIGURATION_KEY_TO_APP_CLUSTER (VALUE,CONFIGURATION_KEY_ID,APP_CLUSTER_ID) (SELECT %s,CK.ID,AC.ID FROM CONFIGURATION_KEY CK,APP_CLUSTER AC WHERE CK.[KEY]=%s AND AC.[NAME]=%s AND NOT EXISTS (SELECT * FROM CONFIGURATION_KEY_TO_APP_CLUSTER WHERE APP_CLUSTER_ID=AC.ID AND CONFIGURATION_KEY_ID=CK.ID))")
                    self.cursor.execute(self.query,(cmdbAdditions[i]["CONFIGURATION_KEY_VALUE"],cmdbAdditions[i]["CONFIGURATION_KEY_KEY"],ClusterName))
                    self.conn.commit()
                    if self.cursor.rowcount == 0:
                        raise Exception("Unable to insert Record into table CONFIGURATION_KEY_TO_APP_CLUSTER for" + cmdbAdditions[i]["CONFIGURATION_KEY_KEY"])
                        return False
            return True
        except (Exception) as error:
            raise Exception(error)
        finally:
            self.conn.close()


    def UEC_CONFIGKEYS(self,ClusterName):
        try:
            pwToUse = ''
            dbAdminResource = ClusterName
            dbAdminUser = "uecAdminUser"
            pwToUse = ''.join(random.choice(string.ascii_uppercase + string.ascii_lowercase + string.digits) for _ in range(16))
            pmp_resource.PMP().add_resource(dbAdminUser,pwToUse,dbAdminResource,"Linux")
            dbAdminPwd = pmp_resource.PMP().PMP_resource(dbAdminResource,dbAdminUser)
            cmdbAdditions = [{"CONFIGURATION_KEY_KEY":"UEC_ADMIN_USER","CONFIGURATION_KEY_VALUE":dbAdminUser}];
            cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"UEC_ADMIN_PWD","CONFIGURATION_KEY_VALUE":dbAdminPwd});
            for i in range(len(cmdbAdditions)):
                if SaltJob().checkConfig(cmdbAdditions[i]["CONFIGURATION_KEY_KEY"],ClusterName):
                    self.query= ("INSERT INTO CONFIGURATION_KEY_TO_APP_CLUSTER (VALUE,CONFIGURATION_KEY_ID,APP_CLUSTER_ID) (SELECT %s,CK.ID,AC.ID FROM CONFIGURATION_KEY CK,APP_CLUSTER AC WHERE CK.[KEY]=%s AND AC.[NAME]=%s AND NOT EXISTS (SELECT * FROM CONFIGURATION_KEY_TO_APP_CLUSTER WHERE APP_CLUSTER_ID=AC.ID AND CONFIGURATION_KEY_ID=CK.ID))")
                    self.cursor.execute(self.query,(cmdbAdditions[i]["CONFIGURATION_KEY_VALUE"],cmdbAdditions[i]["CONFIGURATION_KEY_KEY"],ClusterName))
                    self.conn.commit()
                    if self.cursor.rowcount == 0:
                        raise Exception("Unable to insert Record into table CONFIGURATION_KEY_TO_APP_CLUSTER for" + cmdbAdditions[i]["CONFIGURATION_KEY_KEY"])
                        return False
            return True
        except (Exception) as error:
            raise Exception(error)
        finally:
            self.conn.close()



    def SCC_CONFIGKEYS(self,ClusterName):
        try:
            nodeList = ''
            pwToUse = ''
            iplist = SaltJob().getcmdb_clusterVmIps(ClusterName)
            sccPort = "6379"
            ResourceName = ClusterName
            AccountName = "redis"
            pwToUse = ''.join(random.choice(string.ascii_uppercase + string.ascii_lowercase + string.digits) for _ in range(16))
            pmp_resource.PMP().add_resource(AccountName,pwToUse,ResourceName,"Linux")
            AdminPwd = pmp_resource.PMP().PMP_resource(ResourceName,AccountName)
            for i in range(len(iplist)):
                if i > 0:
                    nodeList = nodeList + ',' + iplist[i]
                else:
                    nodeList = iplist[i]
            cmdbAdditions = [{"CONFIGURATION_KEY_KEY":"SCC_REDIS_PORT","CONFIGURATION_KEY_VALUE":sccPort}];
            cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"SCC_REDIS_NODES","CONFIGURATION_KEY_VALUE":nodeList});
            cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"SCC_REDIS_PWD","CONFIGURATION_KEY_VALUE":AdminPwd});
            cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"SESSION_REPO_TYPE","CONFIGURATION_KEY_VALUE":AccountName});
            for i in range(len(cmdbAdditions)):
                if SaltJob().checkConfig(cmdbAdditions[i]["CONFIGURATION_KEY_KEY"],ClusterName):
                    self.query= ("INSERT INTO CONFIGURATION_KEY_TO_APP_CLUSTER (VALUE,CONFIGURATION_KEY_ID,APP_CLUSTER_ID) (SELECT %s,CK.ID,AC.ID FROM CONFIGURATION_KEY CK,APP_CLUSTER AC WHERE CK.[KEY]=%s AND AC.[NAME]=%s AND NOT EXISTS (SELECT * FROM CONFIGURATION_KEY_TO_APP_CLUSTER WHERE APP_CLUSTER_ID=AC.ID AND CONFIGURATION_KEY_ID=CK.ID))")
                    self.cursor.execute(self.query,(cmdbAdditions[i]["CONFIGURATION_KEY_VALUE"],cmdbAdditions[i]["CONFIGURATION_KEY_KEY"],ClusterName))
                    self.conn.commit()
                    if self.cursor.rowcount == 0:
                        raise Exception("Unable to insert Record into table CONFIGURATION_KEY_TO_APP_CLUSTER for" + cmdbAdditions[i]["CONFIGURATION_KEY_KEY"])
                        return False
            return True
        except (Exception) as error:
            raise Exception(error)
        finally:
            self.conn.close()


    def HAM_CONFIGKEYS(self,ClusterName):
        try:
            nodeList = ''
            pwToUse = ''
            iplist = SaltJob().getcmdb_clusterVmIps(ClusterName)
            hamSccPort = "26380"
            hamDccPort = "26379"
            for i in range(len(iplist)):
                if i > 0:
                    nodeList = nodeList + ',' + iplist[i]
                else:
                    nodeList = iplist[i]
            cmdbAdditions = [{"CONFIGURATION_KEY_KEY":"HAM_SCC_SENTINEL_PORT","CONFIGURATION_KEY_VALUE":hamSccPort}];
            cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"HAM_DCC_SENTINEL_PORT","CONFIGURATION_KEY_VALUE":hamDccPort});
            cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"HAM_SERVER_NODES","CONFIGURATION_KEY_VALUE":nodeList});
            for i in range(len(cmdbAdditions)):
                if SaltJob().checkConfig(cmdbAdditions[i]["CONFIGURATION_KEY_KEY"],ClusterName):
                    self.query= ("INSERT INTO CONFIGURATION_KEY_TO_APP_CLUSTER (VALUE,CONFIGURATION_KEY_ID,APP_CLUSTER_ID) (SELECT %s,CK.ID,AC.ID FROM CONFIGURATION_KEY CK,APP_CLUSTER AC WHERE CK.[KEY]=%s AND AC.[NAME]=%s AND NOT EXISTS (SELECT * FROM CONFIGURATION_KEY_TO_APP_CLUSTER WHERE APP_CLUSTER_ID=AC.ID AND CONFIGURATION_KEY_ID=CK.ID))")
                    self.cursor.execute(self.query,(cmdbAdditions[i]["CONFIGURATION_KEY_VALUE"],cmdbAdditions[i]["CONFIGURATION_KEY_KEY"],ClusterName))
                    self.conn.commit()
                    if self.cursor.rowcount == 0:
                        raise Exception("Unable to insert Record into table CONFIGURATION_KEY_TO_APP_CLUSTER for" + cmdbAdditions[i]["CONFIGURATION_KEY_KEY"])
                        return False
            return True
        except (Exception) as error:
            raise Exception(error)
        finally:
            self.conn.close()

    def SYSLOG_SERVER(self,datacenter):
        try:
            self.cursor.execute("select CK2DC.VALUE from CONFIGURATION_KEY ck inner join CONFIGURATION_KEY_TO_DATACENTER ck2dc on ck.ID = ck2dc.CONFIGURATION_KEY_ID inner join DATACENTER d  on ck2dc.DATACENTER_ID = d.ID where ck.[key] = 'CO_SYSLOG_SERVER' AND D.CODE = '"+ datacenter +"'")
            data = self.cursor.fetchone()
        except (Exception) as error:
            raise(error)
        finally:
            self.conn.close()
            return data[0]

    def NTP_SERVER(self,datacenter):
        try:
            self.cursor.execute("select CK2DC.VALUE from CONFIGURATION_KEY ck inner join CONFIGURATION_KEY_TO_DATACENTER ck2dc on ck.ID = ck2dc.CONFIGURATION_KEY_ID inner join DATACENTER d  on ck2dc.DATACENTER_ID = d.ID where ck.[key] = 'CO_NTP_SERVER' AND D.CODE = '"+ datacenter +"'")
            data = self.cursor.fetchone()
        except (Exception) as error:
            raise(error)
        finally:
            self.conn.close()
            return data[0]

    def ESET_CONFIG(self,datacenter):
        try:
            self.cursor.execute("select CK.[KEY],CK2DC.VALUE from CONFIGURATION_KEY ck inner join CONFIGURATION_KEY_TO_DATACENTER ck2dc on ck.ID = ck2dc.CONFIGURATION_KEY_ID inner join DATACENTER d  on ck2dc.DATACENTER_ID = d.ID where ck.[key] in ('CO_ESET_SERVER','CO_ESET_PORT','CO_ESET_WEBCONSOLE_PORT','CO_ESET_WEBCONSOLE_RESOURCENAME','CO_ESET_WEBCONSOLE_ACCOUNTNAME') AND D.CODE = '"+ datacenter +"'")
            data = self.cursor.fetchall()
        except (Exception) as error:
            raise(error)
        finally:
            self.conn.close()
            return dict(data)

    def repoServer(self,datacenter):
        try:
            self.cursor.execute("select CKTD.VALUE AS RESULT from CONFIGURATION_KEY_TO_DATACENTER cktd inner join CONFIGURATION_KEY ck on ck.id = cktd.CONFIGURATION_KEY_ID inner join DATACENTER d on d.ID = cktd.DATACENTER_ID where d.CODE = '"+ datacenter +"' and ck.[KEY] = 'CO_REPO_SERVER'")
            record = self.cursor.fetchone()
        except (Exception) as error:
            raise(error)
        finally:
            self.conn.close()
            return record[0]

    def getBaseTemplate(self,datacenter,clusterrole,packageName):
        try:
            self.cursor.execute("SELECT VM_TEMPLATE.NAME AS RESULT FROM VM_TEMPLATE INNER JOIN PACKAGE_ROLE ON PACKAGE_ROLE.ROLE_VERSION_ID=VM_TEMPLATE.ROLE_VERSION_ID INNER JOIN ROLE_VERSION ON PACKAGE_ROLE.ROLE_VERSION_ID=ROLE_VERSION.ID INNER JOIN PACKAGE ON PACKAGE.ID=PACKAGE_ROLE.PACKAGE_ID INNER JOIN VM_TYPE ON VM_TYPE.ID=PACKAGE_ROLE.VM_TYPE_ID INNER JOIN VM_TEMPLATE_TO_DATACENTER ON VM_TEMPLATE.ID = VM_TEMPLATE_TO_DATACENTER.VM_TEMPLATE_ID INNER JOIN DATACENTER ON DATACENTER.ID = VM_TEMPLATE_TO_DATACENTER.DATACENTER_ID WHERE DATACENTER.CODE = '"+ datacenter +"' AND VM_TYPE.CODE = '"+ clusterrole +"' AND PACKAGE.NAME='"+ packageName +"' AND VM_TEMPLATE.VM_TYPE_ID = VM_TYPE.ID AND VM_TEMPLATE.AUTOMATION_TYPE = 'SALT' AND VM_TEMPLATE.APP_FUNCTION_ID = 3")
            record = self.cursor.fetchone()
        except (Exception) as error:
            raise(error)
        finally:
            self.conn.close()
            return record[0]

    def getSubnet(self,Port_Group):
        try:
            self.cursor.execute("select SUBNET from IP_SUBNET where DIST_PORT_GROUP = '"+ Port_Group +"'")
            record = self.cursor.fetchone()
            subnet = record[0].split("/")[0]
        except (Exception) as error:
            raise(error)
        finally:
            self.conn.close()
            return subnet

    def getRoleTemplate(self,datacenter,clusterrole,packageName):
        try:
            self.cursor.execute("SELECT VM_TEMPLATE.NAME AS RESULT FROM VM_TEMPLATE INNER JOIN PACKAGE_ROLE ON PACKAGE_ROLE.ROLE_VERSION_ID=VM_TEMPLATE.ROLE_VERSION_ID INNER JOIN ROLE_VERSION ON PACKAGE_ROLE.ROLE_VERSION_ID=ROLE_VERSION.ID INNER JOIN PACKAGE ON PACKAGE.ID=PACKAGE_ROLE.PACKAGE_ID INNER JOIN VM_TYPE ON VM_TYPE.ID=PACKAGE_ROLE.VM_TYPE_ID INNER JOIN VM_TEMPLATE_TO_DATACENTER ON VM_TEMPLATE.ID = VM_TEMPLATE_TO_DATACENTER.VM_TEMPLATE_ID INNER JOIN DATACENTER ON DATACENTER.ID = VM_TEMPLATE_TO_DATACENTER.DATACENTER_ID WHERE DATACENTER.CODE = '"+ datacenter +"' AND VM_TYPE.CODE = '"+ clusterrole +"' AND PACKAGE.NAME='"+ packageName +"' AND VM_TEMPLATE.VM_TYPE_ID = VM_TYPE.ID AND VM_TEMPLATE.AUTOMATION_TYPE = 'SALT' AND VM_TEMPLATE.APP_FUNCTION_ID != 3")
            record = self.cursor.fetchone()
        except (Exception) as error:
            raise(error)
        finally:
            self.conn.close()
            return record[0]

    def getassociatedcluster(self,cluster):
        try:
            self.cursor.execute("SELECT ISNULL(B.NAME,'') AS ASSCLUSTER FROM APP_CLUSTER A JOIN APP_CLUSTER B ON A.ASSOCIATE_APP_CLUSTER_ID=B.ID WHERE A.NAME = '"+cluster+"'")
            record = self.cursor.fetchall()
        except (Exception) as error:
            raise(error)
        finally:
            self.conn.close()
            return record[0][0]

    def get_install_params(self,query):
        dictdata = {}
        self.cursor.execute(query)
#        self.cursor.execute("select [dbo].[GET_PS_INSTALL_PARAMETERS]('"+params+"')")
        rows = self.cursor.fetchall()
        xml = rows[0][0]
        xmldoc = minidom.parseString(xml)
        udacKeyVals = xmldoc.getElementsByTagName('Key')
        for s in udacKeyVals:
            name = ''
            value = ''
            name = s.attributes['name'].value
            if s.hasAttribute('value'):
                value = s.attributes['value'].value
                if s.hasAttribute('secure') and s.attributes['secure'].value == '1' and value != '':
                    value = value
            dictdata[name] = value
        self.conn.close()
        return dict(dictdata)

    def getVMdata(self,ClusterName):
        VMdata = []
        IPs = ''
        clusterIPs = SaltJob().getcmdb_clusterVmIps(ClusterName)
        for item in clusterIPs:
            IPs = IPs+ ','+item
        IPs = IPs[1:]
        try:
            self.cursor.execute("SELECT IP +' '+NAME+' '+FQDN FROM VM WHERE IP IN (SELECT SPLITDATA FROM DBO.fnSplitString('"+IPs+"',','))")
            rows = self.cursor.fetchall()
            for row in rows:
                VMdata.append(row[0])
        except (Exception) as error:
            raise(error)
        finally:
            self.conn.close()
            return VMdata
