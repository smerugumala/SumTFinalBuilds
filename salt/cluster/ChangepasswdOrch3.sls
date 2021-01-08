{% set clusterservers = salt['cmdb_lib3.getClusterServerList'](pillar['ClusterName']) %}

{% set adminpasswd = salt['cmdb_lib3.getresource'](['vRA_',salt['pillar.get']('datacenter')] | join,salt['pillar.get']('user')) %}

{% for server in clusterservers %}

change Admin passwd {{ server }}:
  salt.state:
    - tgt: {{ server }}
    - sls:
      - cluster/changepassword
    - pillar:
        adminpasswd: {{ adminpasswd }}
        user: {{ salt['pillar.get']('user') }}

{% endfor %}

