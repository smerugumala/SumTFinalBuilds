{% set clustername = pillar['cluster'] %}
{% set httpport = '80' %}
{% set cshttp = 'cs_'~ clustername ~'_'~ httpport ~'' %}
{% set policy = pillar['policy'] %}
{% set datacenter = pillar['datacenter'] %}
{% set environment = pillar['environment'] %}
{% set lb = salt['cmdb_lib3.getlb'](datacenter,environment) %}
{% set password = salt['cmdb_lib3.getresource']('network_administrators','vro-admin') %}

bindcsvstopol:
  module.run:
    - name: netscaler.csvspolbind_add
    - csvs_name: {{ cshttp }}
    - pol_name: {{ policy }}
    - priority: 100
    - priorityexpr: 'END'
    - connection_args: {
        netscaler_host: '{{ lb }}',
        netscaler_user: 'vro-admin',
        netscaler_pass: '{{ password }}',
        netscaler_useSSL: 'False'
      }
