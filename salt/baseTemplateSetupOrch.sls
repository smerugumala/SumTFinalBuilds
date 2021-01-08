
{% set saltpass = salt['cmdb_lib3.getPassword'](salt['pillar.get']('domainuser')) %}
{% set rootpass = salt['cmdb_lib3.getPassword'](salt['pillar.get']('user')) %}
{% set repoServer = salt['cmdb_lib3.getRepoServer'](salt['pillar.get']('datacenter')) %}
{% set server = salt['pillar.get']('instance') %}
{% set Domain = salt['cmdb_lib3.domain'](pillar['datacenter']) %}
{% set subnet = salt['cmdb_lib3.getSubnet'](pillar['Port_Group']) %}


Run Base Template setup  {{ server }}:
  salt.state:
    - tgt: {{ server }}
    - sls:
      - baseTemplateSetup
    - pillar:
        Domain: {{ Domain }}
        saltpass: {{ saltpass }}
        rootpass: {{ rootpass }}
        repoServer: {{ repoServer }}
        subnet: {{ subnet }}




