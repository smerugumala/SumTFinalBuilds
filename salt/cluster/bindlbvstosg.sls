{% set clustername = pillar['cluster'] %}
{% set port = pillar['port'] %}
{% set lbvs = 'vs_'~ clustername ~'_'~ port ~'' %}
{% set sg = 'sg_'~ clustername ~'_'~ port ~'' %}
{% set datacenter = pillar['datacenter'] %}
{% set environment = pillar['environment'] %}
{% set lb = salt['cmdb_lib3.getlb'](datacenter,environment) %}
{% set password = salt['cmdb_lib3.getresource']('network_administrators','vro-admin') %}

bindlbvstosg:
  module.run:
    - name: netscaler.vserver_servicegroup_add
    - v_name: {{ lbvs }}
    - sg_name: {{ sg }}
    - connection_args: {
        netscaler_host: '{{ lb }}',
        netscaler_user: 'vro-admin',
        netscaler_pass: '{{ password }}',
        netscaler_useSSL: 'False'
      }
