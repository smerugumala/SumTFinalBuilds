import requests

url = "https://172.26.75.134/rpc"

payload = "{\r\n\
          \"resource\":\"tgt\",\r\n\
          \"method\":\"save_target_group\",\r\n\
          \"kwarg\":{\r\n\
            \"tgt_uuid\": \"c888cbb6-d9c4-484c-b5b4-20c19f84861a\",\r\n\
            \"name\":\"saltlabmin077\",\r\n\
            \"tgt\":\
              {\"*\":\
              {\"tgt_type\":\"compound\",\r\n\
              \"tgt\":\"G@host:saltlabmin077\"\
              }}\r\n}\r\n}"
headers = {
  'Authorization': 'Basic cm9vdDpzYWx0',
  'Content-Type': 'text/plain'
}

response = requests.request("POST", url,verify=False,headers=headers,data=payload)

print(response.text.encode('utf8'))
