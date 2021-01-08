{% import "./vars.sls" as base %}
create a user:
  user.present:
    - name: {{base.cassandra_user}}

create cassandra group:
  group.present:
    - name: {{ base.cassandra_group}}
    - system: True
    - addusers:
      - {{base.cassandra_user}}

{% for dir in base.directories %}
create {{dir}} with  correct permissions:
  file.directory:
    - name: {{dir}}
    - makedirs: true
    - user: {{base.cassandra_user}}
    - group: {{base.cassandra_group}}
    - dir_mode: 0777
    - file_mode: 0777
    - recurse:
      - user
      - group
      - mode

{% endfor %}



extract cassandra zip file:
  archive.extracted:
    - name: {{base.cassandra_path}}
    - source: {{base.cassandra_download_url}}
    - enforce_toplevel: true
    - skip_verify: true
    - user: {{base.cassandra_user}}
    - group: {{base.cassandra_group}}

setting  permissions:
  file.directory:
    - name: {{base.cassandra_path}}
    - user: {{base.cassandra_user}}
    - group: {{base.cassandra_group}}
    - dir_mode: 0777
    - file_mode: 0777
    - recurse:
      - user
      - group
      - mode

ensure_copy_cassandra_service_file:
  file.managed:
    - name: '/lib/systemd/system/cassandra.service'
    - source: salt://{{base.templates_folder}}/cassandra.template
    - template: jinja
    - user: {{ base.cassandra_user }}
    - group: {{ base.cassandra_group }}
    - cassandra_dir: {{ base.cassandra_dir}}

updating_the_tmppath_in_cassandra:
  file.append: 
    - name: {{base.cassandra_dir}}/conf/cassandra-env.sh
    - text: JVM_OPTS="$JVM_OPTS -Djna.tmpdir=$CASSANDRA_HOME/tmp"






Load in new service file:
  cmd.run:
   - name: systemctl daemon-reload



start the cassandra service:
  service.running:
    - name: cassandra
    - enable: true
