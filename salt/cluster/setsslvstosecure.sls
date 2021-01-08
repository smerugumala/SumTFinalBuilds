{% set clustername = pillar['cluster'] %}
{% set port = '443' %}
{% set csvs = 'cs_'~ clustername ~'_'~ port ~'' %}
{% set datacenter = pillar['datacenter'] %}
{% set environment = pillar['environment'] %}
{% set lb = salt['cmdb_lib3.getlb'](datacenter,environment) %}
{% set password = salt['cmdb_lib3.getresource']('network_administrators','vro-admin') %}

setsslvstosec:
  module.run:
    - name: netscaler.setsslvs_update
    - csvs_name: {{ csvs }}
    - sslprofile: 'SECURE'
    - connection_args: {
        netscaler_host: '{{ lb }}',
        netscaler_user: 'vro-admin',
        netscaler_pass: '{{ password }}',
        netscaler_useSSL: 'False'
      }
