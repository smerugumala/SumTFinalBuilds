{% import "./vars.sls" as base %}
{% set trialset = salt['network.ipaddrs']( ) %}
{% set val= trialset | replace("[u'", "") %}
{% set ip_addr= val| replace("']", "") %}


join to the cluster of ip {{base.rabbitmq_master}} hostname {{base.master_hostname[1:-1]}}:
  rabbitmq_cluster.joined:
    - host: {{base.master_hostname[1:-1]}}


restart the rabbitctl app:
  module.run:
    - name: rabbitmq.start_app