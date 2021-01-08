'''
:Module to provide connectivity to the CMDB
:depends:   - FreeTDS
            - pymssql Python module
'''

# Import python libs
from __future__ import absolute_import, print_function, unicode_literals
from json import JSONEncoder, loads
from datetime import datetime

import sys
import logging
import uuid
import threading
import time
import copy
import sec_sseapi
import cmdb_lib

try:
    import sec_sseapi
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
        return False, 'The sec_sseapi file cannot be loaded: dependent package(s) unavailable.'

def target_uuid(target):
    get_class = sec_sseapi.secops()
    data = get_class.get_target(target)
    return data

def get_polic_ret(target,tar_ret_id,benchmark_ids,check_id1):
    get_class = sec_sseapi.secops()
    data = get_class.get_policy(target,tar_ret_id,benchmark_ids,check_id1)
    return data

def assess_policy(policy_id):
    get_class = sec_sseapi.secops()
    data = get_class.assess_policy(policy_id)
    return data

def remediate_policy(policy_id):
    get_class = sec_sseapi.secops()
    data = get_class.remediate_policy(policy_id)
    return data

def delete_policy(policy_id,target_uuid):
    get_class = sec_sseapi.secops()
    data = get_class.delete_policy(policy_id,target_uuid)
    return data

