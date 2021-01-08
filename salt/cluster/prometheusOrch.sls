

{% set prometheusserver = salt['cmdb_lib3.prometheusvm'](pillar['datacenter']) %}

{% set clusterservers = salt['cmdb_lib3.getClusterServerList'](pillar['ClusterName']) %}


{% for server in clusterservers %}

addprometheus {{ server }}:
  salt.state:
    - sls:
      - cluster/backupprometheus
      - cluster/addprometheus
    - tgt: {{ prometheusserver.lower() }}
    - pillar:
        vm: {{ server }}
        role: {{ pillar['clusterrole'] }}


addroleprometheus {{ server }}:
  salt.state:
    - sls:
      - cluster/addvmtoroleprometheus
    - tgt: {{ prometheusserver.lower() }}
    - pillar:
        vm: {{ server }}
        role: {{ pillar['clusterrole'] }}

{% endfor %}
