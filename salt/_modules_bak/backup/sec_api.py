import requests

url = "https://172.26.75.134/rpc"

payload = "{\r\n\
         \"resource\":\"sec\",\r\n\
         \"method\":\"get_checks\",\r\n\
         \"kwarg\":{\r\n\
         \"benchmark_uuids\":[\"bc54e972-5b2e-423b-a535-9953c7940d43\"],\r\n\
         \"limit\":500,\r\n\
         \"sort_by\":\"display_name\",\r\n\
         \"reverse\":false,\r\n\
         \"page\":0\r\n\
         }\
         \r\n}"
headers = {
  'Authorization': 'Basic cm9vdDpzYWx0',
  'Content-Type': 'text/plain',
}

response = requests.request("POST", url, verify=False,headers=headers, data = payload)

print(response.text.encode('utf8'))
