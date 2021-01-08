from sseapiclient import APIClient
client = APIClient('http://ldcsaltent003', 'root', 'salt')
client.api.sec.get_check_variables()
