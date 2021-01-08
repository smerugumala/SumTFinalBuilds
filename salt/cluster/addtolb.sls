{% set islb =  salt['cmdb_lib3.isLoadBalanced']('ANY','20.3.0.0-265','USA') %}
data:
  cmd.run:
    - name: echo {{ islb }}

{% set zone = salt['cmdb_lib3.zoneForVIP'](pillar['datacenter'],pillar['environment']) %}
{% if salt['cmdb_lib3.isLoadBalanced']('ANY','20.3.0.0-265','USA') %}
aname:
  cmd.run:
    - name: echo {{ islb }}
{% else %}
addcname:
  ddns.present:
    - name: {{ pillar['clustername'] }}
    - zone: {{ zone }}
    - ttl: 36
    - data: {{ pillar['vmname'] }}
    - nameserver: {{ pillar['dnsserver'] }}
    - rdtype: {{ pillar['recordtype'] }}

{% endif %}
