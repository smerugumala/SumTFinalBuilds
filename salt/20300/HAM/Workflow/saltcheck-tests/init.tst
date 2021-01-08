{% import "20300/SCC/Workflow/vars.sls" as base %}
{% set trialset = salt['network.ipaddrs']( ) %}
{% set val= trialset | replace("[u'", "") %}
{% set machine_ip= val| replace("']", "") %}

{% for port in ["26379/tcp","6379/tcp","26380/tcp"] %}

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

# Validating SCC_sentinel configuration file

check scc_sentinal.conf file:
  module_and_function: file.read
  args:
    - /etc/scc/scc_sentinel.conf
  assertion: assertIn
  expected_return: "bind {{ machine_ip }}"
  output_details: True

# Validating DCC_sentinel configuration file

check dcc_sentinal.conf file:
  module_and_function: file.read
  args:
    - /etc/dcc/dcc_sentinel.conf
  assertion: assertIn
  expected_return: "bind {{ machine_ip }}"
  output_details: True

# Validating redis service file  
check scc sentinel service file:
  module_and_function: file.read
  args:
    - /lib/systemd/system/scc_sentinel.service
  assertion: assertIn
  expected_return: "[Unit]\nDescription=scc Sentinel\nAfter=network.target\n\n[Service]\nLimitNOFILE=1048576\nUser=sccsentinel\nGroup=sccsentinel\nExecStart=/etc/scc/redis-server /etc/scc/scc_sentinel.conf --sentinel\nExecStop=/etc/scc/redis-cli shutdown\nRestart=always\n[Install]\nWantedBy=multi-user.target"
  output_details: True

check dcc sentinel service file:
  module_and_function: file.read
  args:
    - /lib/systemd/system/dcc_sentinel.service
  assertion: assertIn
  expected_return: "[Unit]\nDescription=dcc Sentinel\nAfter=network.target\n\n[Service]\nLimitNOFILE=1048576\nUser=dccsentinel\nGroup=dccsentinel\nExecStart=/etc/dcc/redis-server /etc/dcc/dcc_sentinel.conf --sentinel\nExecStop=/etc/dcc/redis-cli shutdown\nRestart=always\n[Install]\nWantedBy=multi-user.target"
  output_details: True

check_sentinel_scc_service_running:
  module_and_function: service.status
  args:
    - scc_sentinel
  assertion: assertTrue


check_sentinel_dcc_service_running:
  module_and_function: service.status
  args:
    - dcc_sentinel
  assertion: assertTrue


