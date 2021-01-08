{% set role_folder = pillar['version'].pillar['role'] %}
{% import role_folder~"/vars.sls" as base %}
create a user:
  user.present:
    - name: {{base.cassandra_user}}

create cassandra group:
  group.present:
    - name: {{ base.cassandra_group}}
    - system: True
    - addusers:
      - {{base.cassandra_user}}


download cassandra install file:
  file.managed:
    - name: {{base.cassandra_download_path}}/{{base.cassandra_download_file}}
    - source: {{base.cassandra_download_url}}
    - skip_verify: True


extract cassandra zip file:
  archive.extracted:
    - name: {{base.cassandra_path}}
    - source: {{base.cassandra_download_path}}/{{base.cassandra_download_file}}
    - enforce_toplevel: False
    - user: {{base.cassandra_user}}
    - group: {{base.cassandra_group}}

ensure_copy_cassandra_service_file:
  file.managed:
    - name: '/lib/systemd/system/cassandra.service'
    - source: salt://files/{{base.cassandra_service_file}}
    - template: jinja
    - user: {{ base.cassandra_user }}
    - group: {{ base.cassandra_group }}
    - version: {{base.cassandra_full_version}}
    - path: {{base.cassandra_path}}
    - config_dir: {{ base.cassandra_config_dir}}
	
ensure_copy_cassandra_config_file:
  file.managed:
    - name: {{base.cassandra_path}}/config/cassandra.yml
    - source: salt://files/{{base.cassandra_config_file}}
    - template: jinja
    - user: {{ base.cassandra_user }}
    - group: {{ base.cassandra_group }}
    - version: {{base.cassandra_full_version}}
    - path: {{base.cassandra_path}}
    - config_dir: {{ base.cassandra_config_dir}}
	
ensure suite dir has correct permissions:
  file.directory:
    - name: {{base.cassandra_dir}}
    - user: {{base.cassandra_user}}
    - group: {{base.cassandra_group}}
    - dir_mode: 0777
    - file_mode: 0777
    - recurse:
      - user
      - group
      - mode

Load in new service file:
  cmd.run:
   - name: systemctl --system daemon-reload

enable cassandra:
  service.enabled:
    - name: cassandra`

start cassandra:
  service.running:
    - name: cassandra