{% set clusterservers = salt['cmdb_lib3.getClusterServerList'](pillar['ClusterName']) %}

{% set syslog_server = salt['cmdb_lib3.get_syslog_server'](salt['pillar.get']('datacenter')) %}



{% for server in clusterservers %}

Configure SysLog {{ server }}:
  salt.state:
    - sls:
      - cluster/syslog
    - tgt: {{ server }}
    - pillar:
        syslogServer: {{ syslog_server }}

{% endfor %}

