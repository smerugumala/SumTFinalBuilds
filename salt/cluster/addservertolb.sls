{% set clustername = pillar['clustername'] %}
{% set packagename = pillar['packagename'] %}
{% set role = pillar['role'] %}
{% set ip = pillar['ip'] %}
{% set server = pillar['server'] %}
{% set datacenter = pillar['datacenter'] %}
{% set environment = pillar['environment'] %}
{% set lb = salt['cmdb_lib3.getlb'](datacenter,environment) %}
{% set password = salt['cmdb_lib3.getresource']('network_administrators','vro-admin') %}

{% if salt['cmdb_lib3.isLoadBalanced']('ANY',packagename,role) %}
{% set dictdata = salt['cmdb_lib3.dictinfo'](clustername,packagename) %}
{% set serverport = dictdata['serverPort'] %}
{% set sg = 'sg_'~ clustername ~'_'~ serverport ~'' %}
addserver {{ server }}:
  module.run:
    - name: netscaler.server_add
    - s_name: {{ server }}
    - s_ip: {{ ip }}
    - connection_args: {
        netscaler_host: '{{ lb }}',
        netscaler_user: 'vro-admin',
        netscaler_pass: '{{ password }}',
        netscaler_useSSL: 'False'

bindservertosg {{ server }}:
  module.run:
    - name: netscaler.servicegroup_server_add
    - sg_name: {{ sg }}
    - s_name: {{ server }}
    - s_port: {{ serverport }}
    - s_id: "None"
    - connection_args: {
        netscaler_host: '{{ lb }}',
        netscaler_user: 'vro-admin',
        netscaler_pass: '{{ password }}',
        netscaler_useSSL: 'False'
{% else %}

Validated:
  test.succeed_without_changes

{% endif %}
