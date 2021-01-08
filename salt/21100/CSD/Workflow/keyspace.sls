{% import "./vars.sls" as base %}
{% set trialset = salt['network.ipaddrs']( ) %}
{% set val= trialset | replace("[u'", "") %}
{% set ip_addr= val| replace("']", "") %}


{% if ip_addr == base.csd_master %}
Change strategy and increase replication:
  cmd.script:
    - name: salt://21100/CSD/Templates/replication.sh
    - cwd: {{base.cassandra_dir}}
    - args: {{base.csd_master}} {{base.replicationfactor}}
{% endif %}

update the authorizer values:
  file.replace:
    - name: {{base.cassandra_dir}}/conf/cassandra.yaml
    - pattern: '^(#authorizer)(.*)$'
    - repl: 'authorizer: CassandraAuthorizer'


update the authenticator values:
  file.replace:
    - name: {{base.cassandra_dir}}/conf/cassandra.yaml
    - pattern: '^(#?authenticator)(.*)$'
    - repl: 'authenticator: PasswordAuthenticator'



first restart cassandra:
  service.running:
    - name: cassandra
    - watch:
      - file: update the authenticator values

