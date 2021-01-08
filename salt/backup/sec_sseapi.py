from sseapiclient import APIClient

def getbenchmark():
  client = APIClient('http://ldcsaltent003', 'root', 'salt',ssl_validate_cert=False)
  return client.api.sec.get_benchmarks()
