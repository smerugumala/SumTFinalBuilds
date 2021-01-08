addsever:
  module.run:
    - name: ddns.add_host
    - m_name: SALT-20300
    - ip: 172.26.102.111
    - ttl: 60
    - zone: COTESTDEV.LOCAL
    - nameserver: 172.26.75.10
    - timeout: 10
    - port: 53
