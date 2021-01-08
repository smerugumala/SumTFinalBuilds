{% set clusterservers = salt['cmdb_lib3.getClusterServerList'](pillar['ClusterName']) %}

{% set adminpasswd = salt['cmdb_lib3.getresource'](['vRA_',salt['pillar.get']('datacenter')] | join,salt['pillar.get']('user')) %}

{% for server in clusterservers %}

Add Service account {{ server }}:
  salt.runner:
    - name: state.orch
    - mods: cluster/addResource
    - pillar:
        server: {{ server }}
        adminpasswd: {{ adminpasswd }}
        user: {{ salt['pillar.get']('user') }}

{% endfor %}

