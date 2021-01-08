{% set adminpasswd = salt['cmdb_lib3.resource'](['vRA_',salt['pillar.get']('datacenter')] | join, salt['pillar.get']('user')) %}

{% set target =  salt['pillar.get']('server') %}

{% set user = salt['pillar.get']('user') %}


Add resource in PMP:
  salt.state:
    - sls:
      - cluster/addResource
    - tgt: {{ target }}
    - pillar:
        passwd: {{ adminpasswd }}
        user: {{ salt['pillar.get']('user') }}
