{% set Nameservers = salt['cmdb_lib3.getNameservers'](pillar['datacenter']) %}

{% set passwd = salt['cmdb_lib3.getPassword'](salt['pillar.get']('user')) %}

{% set baseTemplate = salt['cmdb_lib3.getRoleTemplate'](pillar['datacenter'],pillar['clusterrole'],pillar['packageName']) %}

{% set Domain = salt['cmdb_lib3.domain'](pillar['datacenter']) %}

{% set vmSize = salt['cmdb_lib3.getMemory'](pillar['packageName'],pillar['clusterrole']) %}

{% set esxCluster = salt['cmdb_lib3.getesxClusterName'](pillar['datacenter'],pillar['environment'],pillar['clusterrole']) %}

{% set Datastore = salt['cmdb_lib3.getDatastore'](pillar['datacenter'],pillar['environment'],pillar['clusterrole'],pillar['packageName'],esxCluster) %}

{% set domainpasswd = salt['cmdb_lib3.getPassword'](salt['pillar.get']('domainuser')) %}

{% set repoServer = salt['cmdb_lib3.getRepoServer'](salt['pillar.get']('datacenter')) %}
