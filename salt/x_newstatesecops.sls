{% set target = pillar['name'] %}
{% set version = '21.1.0.0-166' %}
{% set vm_type = 'CSD' %}
{% set role_version = 'cassandra30' %}
{#%- set targetOS = salt['cmd.run']('salt '~ target ~' grains.item os').splitlines() | last | replace("        ", "") | trim-%#}
{#% set osVersion = salt['cmd.run']('salt '~ target ~' grains.item osfinger').splitlines() | last | replace("        ", "") | trim-%#}
{% set benchmark_ids = salt['x_cmdb_lib.getBenchmarkID'](version,vm_type,role_version) %}
{% set check_id1 = salt['x_cmdb_lib.getCheckID'](version,vm_type,role_version) %}
{% set variables = salt['x_cmdb_lib.getVariables'](version,vm_type,role_version)%}
{% set tar_ret_id = salt['x_sec_api.createTarget'](target) %}
{% set pol_ret_id = salt['x_sec_api.createPolicy'](target,tar_ret_id,benchmark_ids,check_id1,variables) %}
{% set assess_policy = salt['x_sec_api.assessPolicy'](pol_ret_id) %}
Pause to allow assessment to finish:
  cmd.run:
    - name: sleep 10
{% set remediate_policy = salt['x_sec_api.remediatePolicy'](pol_ret_id) %}

