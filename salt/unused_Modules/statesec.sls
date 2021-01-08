{% set target='saltlabmin111' %}
{% set check_id1='007d7ab0-2ab6-46ba-b221-34d8bd385f94' %}
{% set check_id2='0495cb0f-9382-4e57-943b-b0fbf8ef1858' %}

{% set benchmark_ids=salt['cmdb_lib.getBenchmarkID']() %}
{% set check_ids=salt['cmdb_lib.getCheckID']() %}
{#% set tar_ret_id  = salt['cmdb_lib3.target_uuid'](target) %}
{#% set pol_ret_id = salt['cmdb_lib3.get_polic_ret'](target,tar_ret_id,benchmark_ids,check_id1) %}
{% set assess_policy = salt['cmdb_lib3.assess_policy'](pol_ret_id) %}
{% set remediate_policy = salt['cmdb_lib3.remediate_policy'](pol_ret_id) %#}


check benchmark:
  cmd.run:
    - name: echo {{ benchmark_ids }}

check check IDs:
  cmd.run:
    - name: echo {{ check_ids }}






