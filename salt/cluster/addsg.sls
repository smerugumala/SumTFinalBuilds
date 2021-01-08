{% set clustername = pillar['cluster'] %}
{% set serverport = pillar['port'] %}
{% set sg = 'sg_'~ clustername ~'_'~ serverport ~'' %}
{% set datacenter = pillar['datacenter'] %}
{% set environment = pillar['environment'] %}
{% set lb = salt['cmdb_lib3.getlb'](datacenter,environment) %}
{% set password = salt['cmdb_lib3.getresource']('network_administrators','vro-admin') %}

addsg:
  module.run:
    - name: netscaler.servicegroup_add
    - sg_name: {{ sg }}
    - maxclient: 0
    - maxreq: 0
    - useip: NO
    - useproxyport: YES
    - clttimeout: 180
    - svrtimeout: 360
    - cka: YES
    - tcpb: NO
    - cmp: YES
    - connection_args: {
        netscaler_host: '{{ lb }}',
        netscaler_user: 'vro-admin',
        netscaler_pass: '{{ password }}',
        netscaler_useSSL: 'False'
      }
