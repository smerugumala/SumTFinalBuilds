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
    - mode: 777
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

ensure_copy_cassandra_service_file:
  file.managed:
    - name: '/lib/systemd/system/cassandra.service'
    - source: salt://{{base.templates_folder}}/cassandra.template
    - template: jinja
    - user: {{ base.cassandra_user }}
    - group: {{ base.cassandra_group }}
    - cassandra_dir: {{ base.cassandra_dir}}

Load in new service file:
  cmd.run:
   - name: systemctl daemon-reload

start the cassandra service:
  service.running:
    - name: cassandra
    - enable: true

