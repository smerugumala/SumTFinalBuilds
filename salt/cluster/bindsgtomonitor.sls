{% set clustername = pillar['cluster'] %}
{% set role = pillar['role'] %}
{% set clusterversion = pillar['clusterversion'] %}
{% set port = pillar['port'] %}
{% set sg = 'sg_'~ clustername ~'_'~ port ~'' %}
{% set monitor = 'mon_'~ clusterversion ~'-'~ role ~'' %}
{% set datacenter = pillar['datacenter'] %}
{% set environment = pillar['environment'] %}
{% set lb = salt['cmdb_lib3.getlb'](datacenter,environment) %}
{% set password = salt['cmdb_lib3.getresource']('network_administrators','vro-admin') %}

bindsgtomonitor:
  module.run:
    - name: netscaler.sglbmonitorbinding_add
    - mon_name: {{ monitor }}
    - sg_name: {{ sg }}
    - connection_args: {
        netscaler_host: '{{ lb }}',
        netscaler_user: 'vro-admin',
        netscaler_pass: '{{ password }}',
        netscaler_useSSL: 'False'
      }
