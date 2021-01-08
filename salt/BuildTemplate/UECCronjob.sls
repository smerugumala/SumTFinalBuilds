{% set reposerver = pillar['reposerver'] %}
servicestatus:
  file.managed:
    - name: /opt/services_status.sh
    - source: http://{{ reposerver }}/prometheus/services_status.sh
    - skip_verify: True
    - mode: '755'
    - if_missing: /opt/services_status.sh

checkuecservices:
  cron.present:
    - name: /opt/services_status.sh > /opt/services_status.log
    - user: root
    - minute: 10
    - hour: '*'
    - daymonth: '*'
    - month: '*'
    - dayweek: '*'
