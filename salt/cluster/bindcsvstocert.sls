{% set clustername = pillar['cluster'] %}
{% set sslport = '443' %}
{% set csvs = 'cs_'~ clustername ~'_'~ sslport ~'' %}
{% set cert = pillar['cert'] %}
{% set datacenter = pillar['datacenter'] %}
{% set environment = pillar['environment'] %}
{% set lb = salt['cmdb_lib3.getlb'](datacenter,environment) %}
{% set password = salt['cmdb_lib3.getresource']('network_administrators','vro-admin') %}

bindcsvstocert:
  module.run:
    - name: netscaler.bindcsvstocert_add
    - csvs_name: {{ csvs }}
    - cert_name: {{ cert }}
    - connection_args: {
        netscaler_host: '{{ lb }}',
        netscaler_user: 'vro-admin',
        netscaler_pass: '{{ password }}',
        netscaler_useSSL: 'False'
      }
