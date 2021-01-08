{% set clustername = pillar['cluster'] %}
{% set serverport = pillar['port'] %}
{% set sslport = '443' %}
{% set lbvs = 'vs_'~ clustername ~'_'~ serverport ~'' %}
{% set csvs = 'cs_'~ clustername ~'_'~ sslport ~'' %}
{% set datacenter = pillar['datacenter'] %}
{% set environment = pillar['environment'] %}
{% set lb = salt['cmdb_lib3.getlb'](datacenter,environment) %}
{% set password = salt['cmdb_lib3.getresource']('network_administrators','vro-admin') %}

bindcsvstolbvs:
  module.run:
    - name: netscaler.csvslbvs_bind
    - csvs_name: {{ csvs }}
    - lbvs_name: {{ lbvs }}
    - connection_args: {
        netscaler_host: '{{ lb }}',
        netscaler_user: 'vro-admin',
        netscaler_pass: '{{ password }}',
        netscaler_useSSL: 'False'
      }
