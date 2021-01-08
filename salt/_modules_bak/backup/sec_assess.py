from sseapiclient import APIClient
client = APIClient('http://ldcsaltent003', 'root', 'salt')
client.api.sec.assess_policy(policy_uuid="e02f3510-ae4e-43ff-8e45-2ef07c356d84")