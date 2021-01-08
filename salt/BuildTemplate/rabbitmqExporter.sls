{% set reposerver = pillar['reposerver'] %}
node_exporter:
  user.present:
    - fullname: node_exporter
    - shell: /bin/false


extract_rabbitmq_exporter:
  archive.extracted:
    - name: /tmp/
    - source: http://{{ reposerver }}/prometheus/rabbitmq_exporter-1.0.0-RC7.linux-amd64.tar.gz
    - skip_verify: True
    - user: node_exporter
    - group: node_exporter
    - mode: '755'
    - if_missing: /tmp/rabbitmq_exporter-1.0.0-RC7.linux-amd64.tar.gz

/opt/rabbitmq_exporter:
  file.directory:
    - user: node_exporter
    - group: node_exporter
    - name: /opt/rabbitmq_exporter
    - mode: 0755

/opt/rabbitmq_exporter/config:
  file.append:
    - text: |
        RABBIT_USER=rabbitadmin
        RABBIT_PASSWORD='!2XkX88Y6kTk9Yrz'

copy__files_rabbitmq:
  file.managed:
    - name: /opt/rabbitmq_exporter/rabbitmq_exporter
    - source: /tmp/rabbitmq_exporter-1.0.0-RC7.linux-amd64/rabbitmq_exporter
    - user: node_exporter
    - group: node_exporter
    - mode: 0755

/etc/systemd/system/rabbitmq_exporter.service:
  file.append:
    - text: |
        [Unit]
        Description=rabbitmq_exporter
        After=network.target

        [Service]
        User=node_exporter
        EnvironmentFile=/opt/rabbitmq_exporter/config
        ExecStart=/opt/rabbitmq_exporter/rabbitmq_exporter

        [Install]
        WantedBy=multi-user.target


Enable rabbitmq_exporter service:
  service.enabled:
    - name: rabbitmq_exporter.service
