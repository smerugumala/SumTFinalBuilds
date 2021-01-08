{% set target='saltlabmin111' %}
{% set benchmark_ids=salt['cmdb_lib.getBenchmarkID']() %}
{% set check_id1=salt['cmdb_lib.getCheckID']() %}
{% set tar_ret_id  = salt['cmdb_lib3.target_uuid'](target) %}
{% set pol_ret_id = salt['cmdb_lib3.get_polic_ret'](target,tar_ret_id,benchmark_ids,check_id1) %}
{#% set assess_policy = salt['cmdb_lib3.assess_policy'](pol_ret_id) %#}
{#% set remediate_policy = salt['cmdb_lib3.remediate_policy'](pol_ret_id) %#}


check benchmark:
  cmd.run:
    - name: echo {{ benchmark_ids }}

check check IDs:
  cmd.run:
    - name: echo {{ check_id1 }}

check uuid:
  cmd.run:
    - name: echo {{ tar_ret_id }}

check Policy_ID:
  cmd.run:
    - name: echo {{ pol_ret_id }}






