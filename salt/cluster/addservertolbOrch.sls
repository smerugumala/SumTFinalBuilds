{% set clusterservers = salt['cmdb_lib3.getClusterServerList'](pillar['ClusterName']) %}

{% set clusterserversIP = salt['cmdb_lib3.getClusterServerIP'](pillar['ClusterName']) %}

{% set datacenter = pillar['datacenter'] %}
{% set environment = pillar['environment'] %}
{% set clustername = pillar['ClusterName'] %}
{% set packagename = pillar['packageName'] %}
{% set role = pillar['clusterrole'] %}


{% for i in range(0,clusterservers|length) %}

addservertolb {{ clusterservers[i] }}:
  salt.runner:
    - name: state.orch
    - mods: cluster/addservertolb
    - pillar:
        clustername: {{ clustername }}
        packagename: {{ packagename }}
        role: {{ role }}
        ip: {{ clusterserversIP[i] }}
        server: {{ clusterservers[i] }}
        datacenter: {{ datacenter }}
        environment: {{ environment }}

{% endfor %}
