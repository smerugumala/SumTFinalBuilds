from __future__ import absolute_import, print_function, unicode_literals
import json
from sseapiclient import APIClient
client = APIClient("http://ldcsaltent003", "svc_saltstack", "1Hundred%")

try:
    import json
    HAS_ALL_IMPORTS = True
except ImportError:
    HAS_ALL_IMPORTS = False
    print('Import Failed')

import logging
log = logging.getLogger(__name__)

__virtualname__ = 'sec_api'

def __virtual__():
    '''
    Only load if import successful
    '''
    if HAS_ALL_IMPORTS:
        return __virtualname__
    else:
        return False, 'The sec_sseapi file cannot be loaded: dependent package(s) unavailable.'

#### CREATE TARGET GROUP  ####
def createTarget(target):
    output=client.api.tgt.save_target_group(
    name=target,
    desc=target,
    tgt={"*":{"tgt_type":"compound", "tgt":"G@host:{}".format(target)}})
    target_uuid=json.dumps(output.ret)
    target_uuid=target_uuid.replace('"','')
    return target_uuid

#### CREATE POLICY  ####
def createPolicy(target,tar_ret_id,benchmark_ids,check_id1,variables):
    output = client.api.sec.save_policy(
    name=target,
    tgt_uuid=tar_ret_id,
    benchmark_uuids=[benchmark_ids],
    check_uuids=[
        check
        for check in check_id1
        ],
    variables=[
        var
        for var in variables
        ])
    policy_id=json.dumps(output.ret)
    policy_id=policy_id.replace('"','')
    return policy_id

####  ASSESS POLICY  ####
def assessPolicy(policy_id):
    return client.api.sec.assess_policy(policy_uuid=policy_id)

####  REMEDIATE POLICY  ####
def remediatePolicy(policy_id):
    return client.api.sec.remediate_policy(policy_uuid=policy_id)

####  CLEANUP  ####
def deletePolicy(policy_id,target_uuid):
    client.api.sec.delete_policy(policy_uuid=policy_id)
    return client.api.tgt.delete_target_group(tgt_uuid=target_uuid)

#### RE-ASSESS POLICY ####
def reAssessPolicy(policy_name):
    policies = [
        policy
        for policy in client.api.sec.get_policies().ret["results"]
        if policy_name in policy["name"]
        ]
    for policy in policies:
        policy_uuid=policy["uuid"]
    return client.api.sec.assess_policy(policy_uuid)

def DeleteMinionKey(target,cluster):
    list = [cluster,target]
    return client.api.minions.set_minion_key_state(minions=[list],state='delete')

def AcceptMinionKey(target,cluster):
    list = [cluster,target]
    return client.api.minions.set_minion_key_state(minions=[list],state='accept')

#### DELETE POLICY ####
def deletePolicy(policy_name):
    policies = [
        policy
        for policy in client.api.sec.get_policies().ret["results"]
        if policy_name in policy["name"]
        ]
    for policy in policies:
        policy_uuid=policy["uuid"]
    return client.api.sec.delete_policy(policy_uuid)

#### DELETE TARGET ####
def deleteTarget(policy_name):
    targets = [
        target
        for target in client.api.tgt.get_target_group().ret["results"]
        if policy_name in target["name"]
        ]
    for target in targets:
        target_uuid=target["uuid"]
    return client.api.tgt.delete_target_group(target_uuid)
