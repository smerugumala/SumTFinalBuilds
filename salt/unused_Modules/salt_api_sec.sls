{% set SSE_URL = "http://ldcsaltent003" %}
{% set SSE_USER = "root" %}
{% set SSE_PASSWORD = "salt" %}

{% set POLICY_NAME = "Test1" %}
{% set TARGET_NAME = "saltlabmin111" %}
{% set BENCHMARK_SEARCH_TERM = "CIS_CentOS_Linux_7_Benchmark_v2.2.0-1" %}

{% set tar_ret_id  = salt['sec_apisalt.createTarget'](TARGET_NAME) %}
{#% set pol_ret_id = salt['sec_apisalt.createPolicy']() %#}



# check target uuid:
#   event.send:
#     - name: 'target uuid'
#     - data:
#         title: 'target_uuid'
#         message: '{{ tar_ret_id }}'

# check policy uuid:
#   event.send:
#     - name: 'policy uuid'
#     - data:
#         title: 'policy_uuid'
#         message: '{{ pol_ret_id }}'