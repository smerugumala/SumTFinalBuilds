{% set reposerver = pillar['reposerver'] %}
node_exporter:
  user.present:
    - fullname: node_exporter
    - shell: /bin/false


extract_mysqld_exporter:
  archive.extracted:
    - name: /tmp/
    - source: http://{{ reposerver }}/prometheus/mysqld_exporter-0.12.1.linux-amd64.tar.gz
    - skip_verify: True
    - user: node_exporter
    - group: node_exporter
    - mode: '755'
    - if_missing: /tmp/mysqld_exporter-0.12.1.linux-amd64.tar.gz

/opt/mysqld_exporter:
  file.directory:
    - user: node_exporter
    - group: node_exporter
    - name: /opt/mysqld_exporter
    - mode: 0755

/opt/mysqld_exporter/config:
  file.append:
    - text: |
        config.my-cnf /opt/mysqld_exporter/.my.cnf

copy__files_mysql:
  file.managed:
    - name: /opt/mysqld_exporter/mysqld_exporter
    - source: /tmp/mysqld_exporter-0.12.1.linux-amd64/mysqld_exporter
    - user: node_exporter
    - group: node_exporter
    - mode: 0755

/etc/systemd/system/mysqld_exporter.service:
  file.append:
    - text: |
        [Unit]
        Description=mysqld_exporter
        Wants=network-online.target
        After=network-online.target

        [Service]
        User=node_exporter
        EnvironmentFile=/opt/mysqld_exporter/config
        ExecStart=/opt/mysqld_exporter/mysqld_exporter $MYSQLD_EXPORTER_OPTS

        [Install]
        WantedBy=multi-user.target


Enable mysqld_exporter service:
  service.enabled:
    - name: mysqld_exporter.service
