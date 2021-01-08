{% import "./vars.sls" as base %}

{% set ip_list = '192.168.3.207, 192.168.2.173, 192.168.3.174' %}
{% set current_hostname = salt['grains.get']('host') %}
{% if mv == current_hostname %}
print IAMMASTER{{mv}}:
  cmd.run:
    - name: echo {{mv}}

stop on master:
  module.run:
    - name: rabbitmq.stop_app

{% endif %}

{% if mv != current_hostname %}
print host:
  cmd.run:
    - name: {{current_hostname}}

insert hosts values for master:
  host.present:
    - ip: {{base.rabbitmq_master}}
    - names:
      - {{mv}}
      - {{mv}}.devlab.local

join to the cluster of {{base.rabbitmq_master}}:
  rabbitmq_cluster.joined:
    - host: {{mv}}

{% endif %}
