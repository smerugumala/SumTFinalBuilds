#mport pymssql
import requests
import json
import socket
from requests.packages.urllib3.exceptions import InsecureRequestWarning
requests.packages.urllib3.disable_warnings(InsecureRequestWarning)
from json import JSONEncoder, loads
from datetime import datetime
import logging

try:
    import requests
    HAS_ALL_IMPORTS = True
except ImportError:
    HAS_ALL_IMPORTS = False
    print('Import Failed')

log = logging.getLogger(__name__)

__virtualname__ = 'pmp_resource'

def __virtual__():
    '''
    Only load if import successful
    '''
    if HAS_ALL_IMPORTS:
        return __virtualname__
    else:
        return False, 'The cmdb_lib3 module cannot be loaded: dependent package(s) unavailable.'

class PMP:
    def get_PMP_details(self,source):
        if source == 'cmdb':
            return {'resource' : 'DEV_CMDB_AG', 'account' : 'installer' }
        elif source == 'svc_saltstack':
            return {'resource' : 'svc_saltstack', 'account' : 'svc_saltstack' }
        elif source == 'UXDTemplate':
            return {'resource' : 'vraUXDTemplate', 'account' : 'coadminauto' }
        elif source == 'UMDTemplate':
            return {'resource' : 'vraUMDTemplate', 'account' : 'coumdadminauto' }
        elif source == 'root':
            return {'resource' : 'vRATemplate', 'account' : 'root' }
        elif source == 'vro-admin':
            return {'resource' : 'network_administrators', 'account' : 'vro-admin' }
    
    def get_pmp_token(self):
        if socket.gethostname() == 'ldcsaltmas003.cotestdev.local':
           token = 'CA679C6B-FC12-4196-A029-7C4D38480F1C'
        elif socket.gethostname() == 'newhost':
           token = 'some unique token get from CMDB'
        return token
    
    def get_resource(self,getaccount):
        token = self.get_pmp_token()
        details = self.get_PMP_details(getaccount)
        resource = details['resource']
        account = details['account']
        response = requests.get('https://devutlupv001:7272/restapi/json/v1/resources/resourcename/%s/accounts/accountname/%s?AUTHTOKEN=%s' % (resource,account,token), verify=False)
        pmp_json = json.loads(response.text)
        RESOURCEID = pmp_json['operation']['Details']['RESOURCEID']
        ACCOUNTID = pmp_json['operation']['Details']['ACCOUNTID']
        return RESOURCEID,ACCOUNTID
    
    def get_PMP_pass(self,getaccount):
        token = self.get_pmp_token()
        RESOURCEID,ACCOUNTID = self.get_resource(getaccount)
        response = requests.get('https://devutlupv001:7272/restapi/json/v1/resources/%s/accounts/%s/password?AUTHTOKEN=%s' % (RESOURCEID,ACCOUNTID,token), verify=False)
        if response.status_code == 200:
            pmp_json = json.loads(response.text)
            pp = pmp_json['operation']['Details']['PASSWORD']
            return pp
        else:
            raise Exception(pmp_json)

    def add_resource(self,accountName,accountPassword,resourceName,resourceType):
        token = self.get_pmp_token()
        changeControl = 'SaltCluster' #as of now hardcorded
        content = 'INPUT_DATA={"operation":{"Details":{"ACCOUNTNAME": "' + accountName + '","PASSWORD": "' + accountPassword + '","RESOURCENAME": "' + resourceName + '","RESOURCETYPE": "' + resourceType + '","RESOURCECUSTOMFIELD": [{"CUSTOMLABEL": "CHANGE_CONTROL","CUSTOMVALUE": "' + changeControl + '"}],"ACCOUNTCUSTOMFIELD":[{"CUSTOMLABEL":"CHANGE_CONTROL","CUSTOMVALUE":"' + changeControl + '"}]}}}'
        url = "https://devutlupv001:7272/restapi/json/v1/resources?AUTHTOKEN=%s" % token
        headers = {'Content-type': 'application/json'}
        response = requests.post(url, data=content, headers=headers, verify=False)
        pmp_json = json.loads(response.text)
        if pmp_json['operation']['result']['status'] != 'Success':
            if 'Resource already exists' in pmp_json['operation']['result']['message']:
                return True
            else:
                raise Exception(pmp_json['operation']['result']['message'])
        else:
            return pmp_json['operation']['result']['message']


    def PMP_resource(self,resource,account):
        token = self.get_pmp_token()
        response = requests.get('https://devutlupv001:7272/restapi/json/v1/resources/resourcename/%s/accounts/accountname/%s?AUTHTOKEN=%s' % (resource,account,token), verify=False)
        pmp_json = json.loads(response.text)
        RESOURCEID = pmp_json['operation']['Details']['RESOURCEID']
        ACCOUNTID = pmp_json['operation']['Details']['ACCOUNTID']
        response = requests.get('https://devutlupv001:7272/restapi/json/v1/resources/%s/accounts/%s/password?AUTHTOKEN=%s' % (RESOURCEID,ACCOUNTID,token), verify=False)
        if response.status_code == 200:
            pmp_json = json.loads(response.text)
            data = pmp_json['operation']['Details']['PASSWORD']
            return data
        else:
            raise Exception(pmp_json)



