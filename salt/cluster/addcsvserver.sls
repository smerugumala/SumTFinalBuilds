{% set clustername = pillar['cluster'] %}
{% set csip = pillar['ip'] %}
{% set httpport = '80' %}
{% set sslport = '443' %}
{% set cshttp = 'cs_'~ clustername ~'_'~ httpport ~'' %}
{% set csssl = 'cs_'~ clustername ~'_'~ sslport ~'' %}
{% set datacenter = pillar['datacenter'] %}
{% set environment = pillar['environment'] %}
{% set lb = salt['cmdb_lib3.getlb'](datacenter,environment) %}
{% set password = salt['cmdb_lib3.getresource']('network_administrators','vro-admin') %}

{#% if salt['netscaler.csvserver_get'](cshttp) %}
cshttpdata:
  cmd.run:
    - name: echo "{{ cshttp }} exists"
{% else %#}
addhttpcsvserver:
  module.run:
    - name: netscaler.csvserver_add
    - csvs_name: {{ cshttp }}
    - csvs_type: HTTP
    - csip: {{ csip }}
    - csvs_port: {{ httpport }}
    - clttimeout: 180
    - connection_args: {
        netscaler_host: '{{ lb }}',
        netscaler_user: 'vro-admin',
        netscaler_pass: '{{ password }}',
        netscaler_useSSL: 'False'
      }
{#% endif %#}

{#% if salt['netscaler.csvserver_get'](csssl) %}
csssldata:
  cmd.run:
    - name: echo "{{ csssl }} exists"
{% else %#}
addsslcsvserver:
  module.run:
    - name: netscaler.csvserver_add
    - csvs_name: {{ csssl }}
    - csvs_type: SSL
    - csip: {{ csip }}
    - csvs_port: {{ sslport }}
    - clttimeout: 180
    - connection_args: {
        netscaler_host: '{{ lb }}',
        netscaler_user: 'vro-admin',
        netscaler_pass: '{{ password }}',
        netscaler_useSSL: 'False'
      }
{#% endif %#}
