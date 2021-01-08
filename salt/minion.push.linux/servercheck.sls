{% set sg = 'ldc_salt_enterprise' %}
{% set servers = ['ldcsaltent004', 'ldcsaltent003'] %}
{% set IP = ['172.26.75.236', '172.26.75.234'] %}

Check servicegroup:
  salt.function:
    - name: netscaler.servicegroup_exists
    - tgt: 'tower82.cotestdev.local'
    - arg:
      - {{ sg }}


{% for serv in servers %}
Check {{ serv }} in sg:
  salt.function:
    - name: netscaler.servicegroup_server_exists
    - tgt: 'tower82.cotestdev.local'
    - arg:
      - {{ sg }}
      - {{ serv }}
    - require:
      - salt: Check servicegroup
{% endfor %}


{% for serv in servers %}
Check server enabled{{ serv }}: 
  salt.function:
    - name: netscaler.server_enabled
    - tgt: 'tower82.cotestdev.local'
    - arg:
      - {{ serv }}
    - require:
      - salt : Check {{ serv }} in sg
{% endfor %}


{% for i in range(0,servers|length) %}
{% if i is divisibleby 2 %}
Server disable{{ i }}:
  salt.function:
    - name: netscaler.servicegroup_server_disable
    - tgt: 'tower82.cotestdev.local'
    - arg:
      - {{ sg }}
      - {{ servers[i] }}
      - {{ IP[i] }}
    - require:
      - salt: Check server enabled{{ servers[i] }}
{% endif %}
{% endfor %}

Server disablesg:
  salt.function:
    - name: netscaler.servicegroup_server_up
    - tgt: 'tower82.cotestdev.local'
    - arg:
      - {{ sg }}
      - {{ servers[1] }}
      - 80

