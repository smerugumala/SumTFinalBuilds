{% set vmName = salt['pillar.get']('server') %}

{#% set addgrain = 'salt '~ vmName ~' grains.setval UDA_Cluster '~ salt['pillar.get']('ClusterName') ~'' %#}

{#% set custom = salt.cmd.run(addgrain) %#}

{% set InstanceUuid = salt.cmd.run('salt-cloud -a get_InstanceUuid '~ vmName ~' -y').splitlines() | last |trim %}

{% set vmIP = salt.cmd.run('salt '~ vmName ~' grains.item fqdn_ip4').splitlines() | last | replace("-", "") | trim%}

{% set systemOS = salt.cmd.run('salt '~ vmName ~' grains.item osfinger').splitlines() | last | trim%}

{% set getfqdn = salt.cmd.run('salt '~ vmName ~' grains.item fqdn').splitlines() | last | trim %}

{#% set result = salt['cmdb_lib3.addVMinfo'](vmName,vmIP,uuid,systemOS,clusterrole,environment,clusterName) %#}


Add VM Information into CMDB:
  module.run:
    - name: cmdb_lib3.addVMinfo
    - vmName: {{ vmName }}
    - vmIP: {{ vmIP }}
    - uuid: {{ InstanceUuid }}
    - os: {{ systemOS }}
    - clusterrole: {{ salt['pillar.get']('clusterrole') }}
    - Environment: {{ salt['pillar.get']('environment') }}
    - ClusterName: {{ salt['pillar.get']('ClusterName') }}
    - fqdn: {{ getfqdn }}
