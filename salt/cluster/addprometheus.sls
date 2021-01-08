{% set vm = pillar['vm'] %}
{% set role = pillar['role'] %}
{% set port = '9100' %}
{% set check = [vm, port]|join(':') %}
{% set nodenumber = salt['cmd.shell']('sudo grep -n  node_exporter /u00/prometheus1/prometheus.yml | cut -d: -f1')|int %}
{% set group = ({"UKA":"kafka","UXD": "mysql","HAM":"sentinal","UMD":"mongo","UEB":"rabbitmq","DCC":"redis","SCC":"redis","UEC":"webhooks","CSD":"cassandra"}) %}

{% set status = salt["file.contains"]('/u00/prometheus1/prometheus.yml',check) %}
{% if status %}
vm exists in node:
  cmd.run:
    - name: echo "{{ vm }} exists under node exporter in yml file."

{% else %}

Add to nodeexporter:
  cmd.run:
    - name: |
        sudo sed -i "{{ nodenumber + 2 }} a \            - targets: ['{{ vm }}:{{ port }}']" /u00/prometheus1/prometheus.yml
        sudo sed -i '{{ nodenumber + 3 }} a \              labels:' /u00/prometheus1/prometheus.yml
        sudo sed -i '{{ nodenumber + 4 }} a \                instance: {{ vm }}' /u00/prometheus1/prometheus.yml
        sudo sed -i '{{ nodenumber + 5 }} a \                group: {{ group[role] }}' /u00/prometheus1/prometheus.yml
{% endif %}
