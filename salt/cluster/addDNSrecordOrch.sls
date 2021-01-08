{% set clusterservers = salt['cmdb_lib3.getClusterServerList'](pillar['ClusterName']) %}

{% set clusterserversIP = salt['cmdb_lib3.getClusterServerIP'](pillar['ClusterName']) %}

{% set Domain = salt['cmdb_lib3.domain'](pillar['datacenter']) %}

{% set Nameservers = salt['cmdb_lib3.getNameservers'](pillar['datacenter']) %}


{% for i in range(0,clusterservers|length) %}

add DNS Record {{ clusterservers[i] }}:
  ddns.present:
    - name: {{ clusterservers[i] }}
    - zone: {{ Domain }}
    - ttl: 3600
    - data: {{ clusterserversIP[i] }}
    - nameserver: {{ Nameservers[0] }}
    - rdtype: 'A'
    - retry:
        attempts: 3
        until: True
        interval: 60
        splay: 10

{% endfor %}
