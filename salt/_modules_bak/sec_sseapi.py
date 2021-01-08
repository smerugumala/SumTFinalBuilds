import json
from sseapiclient import APIClient
client = APIClient('http://ldcsaltent003', 'root', 'salt')

__virtualname__ = 'sec_sseapi'

class secops:

    def __init__(self):
        self.client  = APIClient('http://ldcsaltent003', 'root', 'salt')

    #### CREATE TARGET GROUP  ####
    def get_target(self,target):
        output=self.client.api.tgt.save_target_group(
        name=target,
        desc=target,
        tgt={"*":{"tgt_type":"compound", "tgt":"G@host:{}".format(target)}})
        target_uuid=json.dumps(output.ret)
        target_uuid=target_uuid.replace('"','')
        return target_uuid

    #### CREATE POLICY  ####
    def get_policy(self,target,tar_ret_id,benchmark_ids,check_id1):
        output = self.client.api.sec.save_policy(
        name=target,
        tgt_uuid=tar_ret_id,
        benchmark_uuids=[benchmark_ids],
        check_uuids=[check for check in check_id1])
        policy_id=json.dumps(output.ret)
        policy_id=policy_id.replace('"','')
        return policy_id

    ####  ASSESS POLICY  ####
    def assess_policy(self,policy_id):
        return self.client.api.sec.assess_policy(policy_uuid=policy_id)

    ####  REMEDIATE POLICY  ####
    def remediate_policy(self,policy_id):
        return self.client.api.sec.remediate_policy(policy_uuid=policy_id)

    ####  CLEANUP  ####
    def delete_policy(self,policy_id,target_uuid):
        self.client.api.sec.delete_policy(policy_uuid=policy_id)
        return self.client.api.tgt.delete_target_group(tgt_uuid=target_uuid)





