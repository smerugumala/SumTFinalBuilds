{% set eset_dict = salt['cmdb_lib3.get_eset_config'](pillar['datacenter']) %}

{% set server = pillar['instance'] %}

Install ESET:
  salt.state:
    - sls:
      - BuildTemplate/Install_ESET
    - tgt: {{ server }}
    - pillar:
        eset_dict: {{ eset_dict }}

