{% set role = pillar['role'] %}
{% set clusterversion = pillar['clusterversion']%}
{% set request = pillar['request'] %}
{% set req = 'GET '~ request ~''%}
{% set response = pillar['response'] %}
{% set monitor = 'mon_'~ clusterversion ~'-'~ role ~'' %}
{% set datacenter = pillar['datacenter'] %}
{% set environment = pillar['environment'] %}
{% set lb = salt['cmdb_lib3.getlb'](datacenter,environment) %}
{% set password = salt['cmdb_lib3.getresource']('network_administrators','vro-admin') %}

addmonitor:
  module.run:
    - name: netscaler.monitor_add
    - mon_name: {{ monitor }}
    - mon_type: HTTP-ECV
    - mon_recv: {{ response }}
    - mon_send: {{ req }}
    - lrtm: 'ENABLED'
    - resptimeout: 5
    - interval: 10
    - connection_args: {
        netscaler_host: '{{ lb }}',
        netscaler_user: 'vro-admin',
        netscaler_pass: '{{ password }}',
        netscaler_useSSL: 'False'
      }
