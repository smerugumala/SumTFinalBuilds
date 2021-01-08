
{% set domainpasswd = salt['cmdb_lib3.getPassword'](salt['pillar.get']('domainuser')) %}

{% set Domain = salt['cmdb_lib3.domain'](pillar['datacenter']) %}


Remove instance from Domain:
  salt.state:
    - tgt: {{ pillar['instance'] }}
    - sls:
      - BuildTemplate/LeaveDomain
    - pillar:
        Domain: {{ Domain }}
        domainpasswd: {{ domainpasswd }}
        domainuser: {{ salt['pillar.get']('domainuser') }}
