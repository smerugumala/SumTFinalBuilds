{% import "./vars.sls" as base %}

{% set machine_ip = salt['network.active_tcp'] %}

{% set trialset = salt['network.ipaddrs']( ) %}
{% set val= trialset | replace("[u'", "") %}
{% set ip_addr= val| replace("']", "") %}

create dcc user:
  user.present:
    - name: {{base.dccuser}}
create scc user:
  user.present:
    - name: {{base.sccuser}}

Create dcc Group:
  group.present:
    - name: {{ base.dccuser}}
    - system: True
    - addusers:
      - {{base.dccuser}}
Create scc Group:
  group.present:
    - name: {{ base.sccuser}}
    - system: True
    - addusers:
      - {{base.sccuser}}

{% for dir in base.sccdir %}
creating {{dir}} directory:
  file.directory:
    - name: {{dir}}
    - user: {{base.sccuser}}
    - group: {{base.sccuser}}
    - dir_mode: 777
    - file_mode: 777
    - makedirs: True
    - recurse:
      - user
      - group
      - mode
{% endfor %}
{% for dir in base.dccdir %}
creating {{dir}} directory:
  file.directory:
    - name: {{dir}}
    - user: {{base.dccuser}}
    - group: {{base.dccuser}}
    - dir_mode: 777
    - file_mode: 777
    - makedirs: True
    - recurse:
      - user
      - group
      - mode

{% endfor %}



copy_scc_sentinel_service_file:
  file.managed:
    - name: '/lib/systemd/system/scc_sentinel.service'
    - source: salt://20300/Common/redis/Templates/sentinel.template
    - template: jinja
    - user: {{ base.sccuser }}
    - group: {{ base.sccuser }}
    - cache: scc






copy_dcc_sentinel_service_file:
  file.managed:
    - name: '/lib/systemd/system/dcc_sentinel.service'
    - source: salt://20300/Common/redis/Templates/sentinel.template
    - template: jinja
    - user: {{ base.dccuser }}
    - group: {{ base.dccuser }}
    - cache: dcc


copy base sentinel conf to scc file:
  file.managed:
    - name: {{base.sccdir[1]}}/scc_sentinel.conf
    - source: salt://20300/HAM/Templates/sentinel.conf
    - user: {{ base.sccuser }}
    - group: {{ base.sccuser }}
    - template: jinja
    - machineip: {{ip_addr}}
    - masterip: {{base.scc_master}}
    - masterport: {{base.sccport}}
    - password: {{base.sccredispwd}}
    - cache: scc
    - port: {{base.hamsccport}}


copy base sentinel conf to dcc file:
  file.managed:
    - name: {{base.dccdir[1]}}/dcc_sentinel.conf
    - source: salt://20300/HAM/Templates/sentinel.conf
    - user: {{ base.dccuser }}
    - group: {{ base.dccuser }}
    - template: jinja
    - machineip: {{ip_addr}}
    - masterip: {{base.dcc_master}}
    - masterport: {{base.dccport}}
    - password: {{base.dccredispwd}}
    - cache: dcc
    - port: {{base.hamdccport}}
copy redis-cli to scc:
  file.copy:
    - name: {{base.sccdir[1]}}
    - source: {{base.redis_dir}}/src/redis-cli
    - subdir: true
    - user: {{ base.sccuser }}
    - group: {{ base.sccuser }}
copy redis-server to scc:
  file.copy:
    - name: {{base.sccdir[1]}}
    - source: {{base.redis_dir}}/src/redis-server
    - subdir: true
    - user: {{ base.sccuser }}
    - group: {{ base.sccuser }}
copy redis-clito dcc:
  file.copy:
    - name: {{base.dccdir[1]}}
    - source: {{base.redis_dir}}/src/redis-cli
    - subdir: true
    - user: {{ base.dccuser }}
    - group: {{ base.dccuser }}
copy redis-server to dcc:
  file.copy:
    - name: {{base.dccdir[1]}}
    - source: {{base.redis_dir}}/src/redis-server
    - subdir: true
    - user: {{ base.dccuser }}
    - group: {{ base.dccuser }}

enable scc sentinel:
  service.enabled:
    - name: scc_sentinel

start scc sentinel:
  service.running:
    - name: scc_sentinel

enable dcc sentinel:
  service.enabled:
    - name: dcc_sentinel

start dcc sentinel:
  service.running:
    - name: dcc_sentinel
