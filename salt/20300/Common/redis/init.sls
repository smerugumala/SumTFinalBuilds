{% import "20300/Common/redis/vars.sls" as base %}

{% set trialset = salt['network.ipaddrs']( ) %}
{% set val= trialset | replace("[u'", "") %}
{% set ip_addr= val| replace("']", "") %}

create a user:
  user.present:
    - name: {{base.redis_user}}

Create redis Group:
  group.present:
    - name: {{ base.redis_group}}
    - system: True
    - addusers:
      - {{base.redis_user}}

{% for dir in base.directories %}
creating {{dir}} directory:
  file.directory:
    - name: {{dir}}
    - user: {{base.redis_user}}
    - group: {{base.redis_group}}
    - dir_mode: 777
    - file_mode: 777
    - makedirs: True
    - recurse:
      - user
      - group
      - mode

{% endfor %}




download and extract redis zip file:
  archive.extracted:
    - name: {{base.redis_path}}
    - source: {{base.redis_download_url}}
    - enforce_toplevel: true
    - skip_verify: true
    - user: {{base.redis_user}}
    - group: {{base.redis_group}}



Add in sysctl vals:
  file.append:
    - name: /etc/sysctl.conf
    - text:
      - vm.overcommit_memory=1
      - vm.swappiness=0
      - net.ipv4.tcp_sack=1
      - net.ipv4.tcp_timestamps=1
      - net.ipv4.tcp_window_scaling=1
      - net.ipv4.tcp_congestion_control=cubic
      - net.ipv4.tcp_syncookies=1
      - net.ipv4.tcp_tw_recycle=1
      - net.ipv4.tcp_max_syn_backlog=65535
      - net.core.somaxconn=65535
      - net.core.rmem_max = 16777216
      - net.core.wmem_max = 16777216



save the sysctl values:
  cmd.run:
    - name: "sudo sysctl -p"




install with script:
  cmd.script:
    - source: salt://20300/Common/redis/Templates/script.sh
    - cwd:  /opt/
    - template: jinja
    - redis_dir: {{ base.redis_dir }}






#ensure_copy_redis_service_file:
#  file.managed:
#    - name: '/lib/systemd/system/redis.service'
#    - source: salt://20300/Common/redis/Templates/{{base.redis_service_file}}
#    - template: jinja
#    - user: {{ base.redis_user }}
#    - group: {{ base.redis_group }}
#    - version: {{base.redis_version}}
#    - path: {{base.redis_path}}
#    - config_dir: {{ base.redis_config_dir}}

