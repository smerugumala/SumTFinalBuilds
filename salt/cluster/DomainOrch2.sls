{% set clusterservers = salt['cmdb_lib3.getClusterServerList'](pillar['ClusterName']) %}

{% set Domain = salt['cmdb_lib3.domain'](pillar['datacenter']) %}

{% set domainpasswd = salt['cmdb_lib3.getPassword'](salt['pillar.get']('domainuser')) %}

{% for server in clusterservers %}

Join Domain {{ server }}:
  salt.state:
    - sls:
      - cluster/domain
    - tgt: {{ server }}
    - pillar:
        Domain: {{ Domain }}
        passwd: {{ domainpasswd }}
        domainuser: {{ salt['pillar.get']('domainuser') }}
    - retry:
        attempts: 3
        until: True
        interval: 60
        splay: 10
{% endfor %}

