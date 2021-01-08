from __future__ import absolute_import, print_function, unicode_literals
from json import JSONEncoder, loads

import sys
import logging
import re

try:
    import pymssql
    HAS_ALL_IMPORTS = True
except ImportError:
    HAS_ALL_IMPORTS = False
    print('Import Failed')

log = logging.getLogger(__name__)

__virtualname__ = 'Oriondb_IPAM'


def __virtual__():
    '''
    Only load if import successful
    '''
    if HAS_ALL_IMPORTS:
        return __virtualname__
    else:
        return False, 'The Orion_LIB module cannot be loaded: pymssql package unavailable.'


class oriondb:
    def __init__(self):
        self.conn = pymssql.connect(host=r'oriondb1.cotestdev.local\local',
                                    user='SolarWindsOrionDatabaseUser', password='N3wN3tw0rk!', database='SolarWindsOrion')
        self.cursor = self.conn.cursor()

    def connectCMDB():
        self.conn = pymssql.connect(host=r'oriondb1.cotestdev.local\local',
                                    user='SolarWindsOrionDatabaseUser', password='N3wN3tw0rk!', database='SolarWindsOrion')
        return conn

    def getNextAvaliableIP(self):
        self.cursor.execute("select TOP 1 IPAddress from IPAM_Node where IPAddress LIKE '%172.26.75.%' and Status = '2' FOR XML PATH ('')")
        record = self.cursor.fetchone()
        trim = record[0].replace("<IPAddress>", "")
        data = trim.replace("</IPAddress>", " ")
        self.conn.close
        return data

    def UpdateStatus(self, ServerIP):
        self.query = ("UPDATE IPAM_Node SET Status = '4',StatusBy = '3',LastSync = NULL,Description = 'Set by SaltStack Automation' WHERE IPAddress =%s")
        self.cursor.execute(self.query, (ServerIP))
        self.conn.commit()
        self.conn.close()
        if self.cursor.rowcount == 0:
            return False
        else:
            return True

    def ping_ip(current_ip_address):
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

    def IpList(self,subnet,cidr):
        self.query = ("SELECT distinct IPN.IPNodeID,IPN.IPAddress FROM IPAM_Node IPN INNER JOIN IPAM_Group IPG ON IPG.GroupId = IPN.SubnetId WHERE IPN.Status = '2' AND IPG.Address =%s AND IPG.CIDR =%s")
        self.cursor.execute(self.query,(subnet,cidr))
        record = self.cursor.fetchall()
        data = list(record)
        self.conn.close()
        return data

    def reserveIP(self,IPNodeID,ipaddress):
        try:
            self.cursor.execute("UPDATE IPAM_Node SET Status = '4',StatusBy = '3',LastSync = NULL,Description = 'Set by SaltStack Automation' WHERE IPNodeId = '" + IPNodeID + "' AND IPAddress = '" + ipaddress + "'")
            self.conn.commit()
            if self.cursor.rowcount == 0:
                raise
            else:
                print(self.cursor.rowcount + " record added to row to IPAM Database table IPAM_Node")
        except (Exception,StandardError) as error:
            raise Exception(error)
        finally:
            self.conn.close()
            return self.cursor.rowcount
