{% import "common/redis/vars.sls" as base %}

{% set machine_ip = salt['network.active_tcp'] %}

{% set trialset = salt['network.ipaddrs']( ) %}
{% set val= trialset | replace("[u'", "") %}
{% set ip_addr= val| replace("']", "") %}



copy_scc_sentinel_service_file:
  file.managed:
    - name: '/lib/systemd/system/sentinel_scc.service'
    - source: salt://files/{{base.sentinel_service_file}}
    - template: jinja
    - user: {{ base.redis_user }}
    - group: {{ base.redis_group }}
    - version: {{base.redis_full_version}}
    - path: {{base.redis_path}}
    - config_dir: {{ base.redis_config_dir}}
	- conf_file: scc.conf
	
copy_dcc_sentinel_service_file:
  file.managed:
    - name: '/lib/systemd/system/sentinel_dcc.service'
    - source: salt://files/{{base.sentinel_service_file}}
    - template: jinja
    - user: {{ base.redis_user }}
    - group: {{ base.redis_group }}
    - version: {{base.redis_full_version}}
    - path: {{base.redis_path}}
    - config_dir: {{ base.redis_config_dir}}
	- conf_file: dcc.conf

copy base sentinel conf to scc file:
  file.copy:
    - name: {{ redis_config_dir}}/scc.conf
	- source {{ redis_config_dir}}/sentinel.conf

copy base sentinel conf to dcc file:
  file.copy:
    - name: {{ redis_config_dir}}/dcc.conf
	- source {{ redis_config_dir}}/sentinel.conf

bind sentinel to IP for scc:
  file.prepend:
    - name: {{ redis_config_dir}}/scc.conf
    - text: "bind {{machine_ip}}"

add sentinel monitor line for scc sentinel
  file.prepend:
    - name: {{ base.redis_config_dir}}/scc.conf
    - text: "sentinel monitor {{ cluster_name }} {{ scc_ip }} {{ redis_port }} {{ groups['redis-hosts'] | length -1 }}"
	
bind sentinel to IP for dcc:
  file.prepend:
    - name: {{ redis_config_dir}}/scc.conf
    - text: "bind {{machine_ip}}"

add sentinel monitor line for dcc sentinel
  file.prepend:
    - name: {{ base.redis_config_dir}}/dcc.conf
    - text: "sentinel monitor {{ cluster_name }} {{ dcc_ip }} {{ redis_port }} {{ groups['redis-hosts'] | length -1 }}"

enable scc sentinel:
  service.enabled:
    - name: sentinel_scc
	
start scc sentinel:
  service.running:
    - name: sentinel_scc
	
enable dcc sentinel:
  service.enabled:
    - name: sentinel_dcc
	
start dcc sentinel:
  service.running:
    - name: sentinel_dcc
