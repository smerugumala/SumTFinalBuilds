{% set clusterservers = salt['cmdb_lib3.getClusterServerList'](pillar['ClusterName']) %}

{% set domainpasswd = salt['cmdb_lib3.getPassword'](salt['pillar.get']('domainuser')) %}

{% set Binary = salt['cmdb_lib3.GetSplunk'](pillar['datacenter']) %}

{% set Domain = salt['cmdb_lib3.domain'](pillar['datacenter']) %}


{% for server in clusterservers %}

InstallSplunk {{ server }}:
  salt.state:
    - tgt: {{ server }}
    - sls:
      - cluster/splunk
    - pillar:
        Domain: {{ Domain }}
        passwd: {{ domainpasswd }}
        domainuser: {{ salt['pillar.get']('domainuser') }}
        Binary: {{ Binary }}


{% endfor %}

