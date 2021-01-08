{% set clusterservers = salt['cmdb_lib3.getClusterServerList'](pillar['ClusterName']) %}

{% set ntp_server = salt['cmdb_lib3.get_ntp_server'](salt['pillar.get']('datacenter')) %}



{% for server in clusterservers %}

Configure ntp {{ server }}:
  salt.state:
    - sls:
      - cluster/ntp
    - tgt: {{ server }}
    - pillar:
        ntpServer: {{ ntp_server }}

{% endfor %}

