from sseapiclient import APIClient
import json

__virtualname__ = 'sec_apisalt'

client = APIClient(SSE_URL, SSE_USER, SSE_PASSWORD, ssl_validate_cert=False)

def createTarget(targetName):
    output=client.api.tgt.save_target_group(
    name=TARGET_NAME,
    desc=TARGET_NAME,
    tgt={"*":{"tgt_type":"compound", "tgt":"G@host:{}".format(TARGET_NAME)}})
    target_uuid=json.dumps(output.ret)
    target_uuid=target_uuid.replace('"','')
    return target_uuid

def createPolicy():
    policy_id = client.api.sec.save_policy(
    name=POLICY_NAME,
#   tgt_uuid=client.api.tgt.get_target_group(name=TARGET_NAME).ret["results"][0]["uuid"],
    benchmarks = [benchmark for benchmark in client.api.sec.get_benchmarks().ret["results"]
      if BENCHMARK_SEARCH_TERM in benchmark["name"]]
    checks = [check for check in client.api.sec.get_checks(benchmark_uuids=[b["uuid"] for b in benchmarks], limit=1000).ret["results"]]
    tgt_uuid=target_uuid
    benchmark_uuids=[benchmark["uuid"] for benchmark in benchmarks],
    check_uuids=[check["uuid"] for check in checks])
    policy_id=json.dumps(policy_id.ret)
    policy_id=policy_id.replace('"','')
    return policy_id

def assessPolicy(policy_id):
    client.api.sec.assess_policy(policy_uuid=policy_id)
