addsever:
  module.run:
    - name: ddns.add_host
    - m_name: SALT-20300-DCC
    - ip: 172.26.75.106
    - rdtype: A
    - ttl: 60
    - zone: COTESTDEV.LOCAL
    - nameserver: 172.26.75.10
    - timeout: 10
