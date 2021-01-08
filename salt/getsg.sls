{% set datacenter = 'LDC' %}
{% set environment = 'PROD' %}
{% set lb = salt['cmdb_lib3.getlb'](datacenter,environment) %}
{% set password = salt['cmdb_lib3.getresource']('network_administrators','vro-admin') %}
data:
  cmd.run: 
    - name: echo "{{ lb }} {{ password }}"

getsg:
  module.run:
    - name: netscaler.servicegroup_exists
    - sg_name: 'sg_LDC-21100166-PROD-UGM-C0458_3000'
    - connection_args: { 
        netscaler_host: 'devlb-prod',
        netscaler_user: 'vro-admin',
        netscaler_pass: '{{ password }}',
        netscaler_useSSL: 'False'
      }
