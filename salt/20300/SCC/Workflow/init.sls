{% import role_folder~"common/redis/vars.sls" as base %}
{% set machine_ip = salt['network.active_tcp'] %}

{% if machine_ip != base.scc_ip %}

add replica spec to conf file:
  file.append:
    - name: {{ base.redis_config_dir}}/redis.conf
	- text: replicaof {{base.scc_master}}
{% endif %}

enable redis:
  service.enabled:
    - name: redis

start redis:
  service.running:
    - name: redis