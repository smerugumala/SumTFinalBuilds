{% import "./vars.sls" as base %}
{% set trialset = salt['network.ipaddrs']( ) %}
{% set val= trialset | replace("[u'", "") %}
{% set ip_addr= val| replace("']", "") %}


{% if ip_addr == base.csd_master %}
wait for minute:
  cmd.run:
    - name: sleep 60

Create CSD user with user {{base.cassandraadminuser}} {{base.cassandraadminpwd}} :
  cmd.script:
    - name: salt://21100/CSD/Templates/user.sh
    - cwd: {{base.cassandra_dir}}
    - args: {{base.csd_master}} {{base.cassandraadminuser}} {{base.cassandraadminpwd}}

Delete default user:
  cmd.script:
    - name: salt://21100/CSD/Templates/delete.sh
    - cwd: {{base.cassandra_dir}}
    - args: {{base.csd_master}} {{base.cassandraadminuser}} {{base.cassandraadminpwd}}

second restart cassandra:
  service.running:
    - name: cassandra
    - watch:
      - cmd: Delete default user
{% endif %}
