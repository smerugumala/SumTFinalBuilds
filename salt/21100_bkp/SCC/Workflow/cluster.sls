{% import "./vars.sls" as base %}

{% set trialset = salt['network.ipaddrs']( ) %}
{% set val= trialset | replace("[u'", "") %}
{% set machine_ip= val| replace("']", "") %}



copy redis conf file:
  file.managed:
    - name: /etc/redis/{{base.role}}_redis.conf
    - source: salt://21100/SCC/Templates/redis.conf
    - makedirs: True
    - template: jinja
    - password: {{base.sccredispwd}}
    - redis_dir: {{base.redis_dir}}
    - logfile: {{base.redis_log_dir}}/{{base.role}}_redis.log
    - user: {{base.redis_user}}
    - group: {{base.redis_group}}




bind to ip:
  file.replace:
    - name: /etc/redis/{{base.role}}_redis.conf
    - pattern: '^(#?bind)(.*)$'
    - repl: bind  {{machine_ip}}

{% if machine_ip != base.scc_master %}
add replica spec to conf file:
  file.append:
    - name: /etc/redis/{{base.role}}_redis.conf
    - text: replicaof {{base.scc_master}} {{base.sccport}}

{% endif %}


ensure_copy_service_file:
  file.managed:
    - name: '/lib/systemd/system/redis.service'
    - source: salt://21100/Common/redis/Templates/{{base.redis_service_file}}
    - template: jinja
    - user: {{ base.redis_user }}
    - group: {{ base.redis_group }}
    - version: {{base.redis_version}}
    - path: {{base.redis_path}}
    - config_dir: {{ base.redis_config_dir}}
    - role: {{base.role}}

enable redis:
  service.enabled:
    - name: redis

start redis:
  service.running:
    - name: redis