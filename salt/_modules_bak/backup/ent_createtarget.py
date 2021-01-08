from sseapiclient import APIClient

def create_target_group():
    client = APIClient('http://ldcsaltent003', 'root', 'salt')
    client.api.tgt.save_target_group(
    name="ldcsaltmin01",
    desc="ldcsaltmin01",
    tgt={"*":{"tgt_type":"compound", "tgt":"G@host:ldcsaltmin01"}})
