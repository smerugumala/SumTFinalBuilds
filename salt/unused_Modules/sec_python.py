###  DEFINE VARIABLE FOR MINION NAME  ####
target="saltlabmin111"
benchmark_ids="e4e7e4bf-a1df-4346-a3f3-b3d7d61853e8"
check_id1="007d7ab0-2ab6-46ba-b221-34d8bd385f94"
check_id2="0495cb0f-9382-4e57-943b-b0fbf8ef1858"

####  IMPORT OBJECTS AND CONNECT  ####
import json
from sseapiclient import APIClient
client = APIClient('http://ldcsaltent003', 'root', 'salt')

#### CREATE TARGET GROUP  ####
output=client.api.tgt.save_target_group(
name=target,
desc=target,
tgt={"*":{"tgt_type":"compound", "tgt":"G@host:{}".format(target)}})
target_uuid=json.dumps(output.ret)
target_uuid=target_uuid.replace('"','')
print(target_uuid)

#### CREATE POLICY  ####
output = client.api.sec.save_policy(
name=target,
tgt_uuid=target_uuid,
benchmark_uuids=[benchmark_ids],
check_uuids=[check_id1,check_id2])
policy_id=json.dumps(output.ret)
policy_id=policy_id.replace('"','')
print(policy_id)

####  ASSESS POLICY  ####
client.api.sec.assess_policy(policy_uuid=policy_id)

####  REMEDIATE POLICY  ####
client.api.sec.remediate_policy(policy_uuid=policy_id)



####  CLEANUP  ####
# client.api.sec.delete_policy(policy_uuid=policy_id)
# client.api.tgt.delete_target_group(tgt_uuid=target_uuid)