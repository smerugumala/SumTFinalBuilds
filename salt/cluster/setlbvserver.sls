{% set clustername = pillar['cluster'] %}
{% set serverport = '80' %}
{% set lbvs = 'vs_'~ clustername ~'_'~ serverport ~'' %}
{% set datacenter = pillar['datacenter'] %}
{% set environment = pillar['environment'] %}
{% set lb = salt['cmdb_lib3.getlb'](datacenter,environment) %}
{% set password = salt['cmdb_lib3.getresource']('network_administrators','vro-admin') %}


setlbvserverfroURW:
  module.run:
    - name: netscaler.lbvserver_update
    - lbvs_name: {{ lbvs }}
    - persistencetype: 'RULE'
    - rule: 'jsession_persistence_req'
    - resrule: 'jsession_persistence_res'
    - connection_args: {
        netscaler_host: '{{ lb }}',
        netscaler_user: 'vro-admin',
        netscaler_pass: '{{ password }}',
        netscaler_useSSL: 'False'
      }
