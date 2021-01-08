{% set target = pillar['name'] %}
{% set version = pillar['packageName'] %}
{% set vm_type = pillar['role'] %}
{% set role_version = pillar['Roleversion'] %}

{% set benchmark_ids = salt['cmdb_lib3.getBenchmarkID'](version,vm_type,role_version) %}
{% set check_id1 = salt['cmdb_lib3.getCheckID'](version,vm_type,role_version) %}
{% set variables = salt['cmdb_lib3.getVariables'](version,vm_type,role_version)%}
{% set tar_ret_id = salt['sec_api.createTarget'](target) %}
{% set pol_ret_id = salt['sec_api.createPolicy'](target,tar_ret_id,benchmark_ids,check_id1,variables) %}
{% set assess_policy = salt['sec_api.assessPolicy'](pol_ret_id) %}
Pause to allow assessment to finish:
  cmd.run:
    - name: sleep 10
{% set remediate_policy = salt['sec_api.remediatePolicy'](pol_ret_id) %}

