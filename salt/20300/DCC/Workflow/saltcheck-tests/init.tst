{% import "20300/DCC/Workflow/vars.sls" as base %}
{% set trialset = salt['network.ipaddrs']( ) %}
{% set val= trialset | replace("[u'", "") %}
{% set machine_ip= val| replace("']", "") %}
{% set dcc_master = grains['dcc_master'] %}
{% set auth = grains['auth'] %}

check_service_running:
 module_and_function: service.status
 args:
  - redis

 assertion: assertTrue

{% for port in ["26379/tcp","6379/tcp"] %}

check if {{port}} is open:
  module_and_function: firewalld.list_ports
  args:
    - public
  assertion: assertIn
  expected-return: {{port}}
  output_details: True

{% endfor %}

# Validating sysctl configuration file

check sysctl conf file:
  module_and_function: file.read
  args:
    - /etc/sysctl.conf
  assertion: assertIn
  expected_return: "vm.overcommit_memory=1\nvm.swappiness=0\nnet.ipv4.tcp_sack=1\nnet.ipv4.tcp_timestamps=1\nnet.ipv4.tcp_window_scaling=1\nnet.ipv4.tcp_congestion_control=cubic\nnet.ipv4.tcp_syncookies=1\nnet.ipv4.tcp_tw_recycle=1\nnet.ipv4.tcp_max_syn_backlog=65535\nnet.core.somaxconn=65535\nnet.core.rmem_max = 16777216\nnet.core.wmem_max = 16777216"
  output_details: True

# Validating DCC_redis configuration file

check daemonize of DCC_redis conf file:
  module_and_function: file.search
  args:
    - /etc/redis/DCC_redis.conf
    - daemonize no
  assertion: assertTrue
  output_details: True
  
check supervised of DCC_redis conf file:
  module_and_function: file.search
  args:
    - /etc/redis/DCC_redis.conf
    - supervised systemd
  assertion: assertTrue
  output_details: True
  
check dir of DCC_redis conf file:
  module_and_function: file.search
  args:
    - /etc/redis/DCC_redis.conf
    - dir {{base.redis_dir}}
  assertion: assertTrue
  output_details: True
  
check masterauth of DCC_redis conf file:
  module_and_function: file.search
  args:
    - /etc/redis/DCC_redis.conf
    - masterauth {{ auth }}
  assertion: assertTrue
  output_details: True
  
check requirepass of DCC_redis conf file:
  module_and_function: file.search
  args:
    - /etc/redis/DCC_redis.conf
    - requirepass {{ auth }}
  assertion: assertTrue
  output_details: True
  
check appendonly of DCC_redis conf file:
  module_and_function: file.search
  args:
    - /etc/redis/DCC_redis.conf
    - appendonly no
  assertion: assertTrue
  output_details: True
  
check save 900 of DCC_redis conf file:
  module_and_function: file.search
  args:
    - /etc/redis/DCC_redis.conf
    - save 900 1
  assertion: assertTrue
  output_details: True
  
check save 300 of DCC_redis conf file:
  module_and_function: file.search
  args:
    - /etc/redis/DCC_redis.conf
    - save 300 10
  assertion: assertTrue
  output_details: True
  
check save 60 of DCC_redis conf file:
  module_and_function: file.search
  args:
    - /etc/redis/DCC_redis.conf
    - save 60 10000
  assertion: assertTrue
  output_details: True
  
check loglevel of DCC_redis conf file:
  module_and_function: file.search
  args:
    - /etc/redis/DCC_redis.conf
    - loglevel notice
  assertion: assertTrue
  output_details: True
  
check tcp-backlog of DCC_redis conf file:
  module_and_function: file.search
  args:
    - /etc/redis/DCC_redis.conf
    - tcp-backlog 65535
  assertion: assertTrue
  output_details: True
  
check maxclients of DCC_redis conf file:
  module_and_function: file.search
  args:
    - /etc/redis/DCC_redis.conf
    - maxclients 1048544
  assertion: assertTrue
  output_details: True
  
check timeout of DCC_redis conf file:
  module_and_function: file.search
  args:
    - /etc/redis/DCC_redis.conf
    - timeout 900
  assertion: assertTrue
  output_details: True
  
check maxmemory of DCC_redis conf file:
  module_and_function: file.search
  args:
    - /etc/redis/DCC_redis.conf
    - maxmemory 7516192768
  assertion: assertTrue
  output_details: True
  
check maxmemory-policy of DCC_redis conf file:
  module_and_function: file.search
  args:
    - /etc/redis/DCC_redis.conf
    - maxmemory-policy volatile-ttl
  assertion: assertTrue
  output_details: True
  
check repl-diskless-sync of DCC_redis conf file:
  module_and_function: file.search
  args:
    - /etc/redis/DCC_redis.conf
    - repl-diskless-sync yes
  assertion: assertTrue
  output_details: True

# Validating redis service file  
check redis service file:
  module_and_function: file.read
  args:
    - /lib/systemd/system/redis.service
  assertion: assertIn
  expected_return: "[Unit]\nDescription=Redis In-Memory Data Store\nRequires=network-online.target\nAfter=network-online.target\n\n[Service]\nLimitNOFILE=1048576\nUser=redis\nGroup=redis\nPIDFile=/var/run/redis_6379.pid\nTimeoutStopSec=0\nExecStart=/opt/redis-6.0.5/src/redis-server /etc/redis/DCC_redis.conf\nExecStop=/opt/redis-6.0.5/src/redis-cli shutdown\nRestart=always\n[Install]\nWantedBy=multi-user.target"
  output_details: True

check master slave replica:
  module_and_function: cmd.run
  args:
    - redis-cli -h {{ machine_ip }} -a {{ auth }} client list
  assertion: assertIn
  expected_return : "addr={{ dcc_master }}"
  output_details: True
