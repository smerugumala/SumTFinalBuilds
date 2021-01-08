{% set reposerver = pillar['reposerver'] %}
node_exporter:
  user.present:
    - fullname: node_exporter
    - shell: /bin/false


extract_redis_exporter:
  archive.extracted:
    - name: /tmp/
    - source: http://{{ reposerver }}/prometheus/redis_exporter-v1.14.0.linux-amd64.tar.gz
    - skip_verify: True
    - user: node_exporter
    - group: node_exporter
    - mode: '755'
    - if_missing: /tmp/redis_exporter-v1.14.0.linux-amd64.tar.gz

/opt/redis_exporter:
  file.directory:
    - user: root
    - name: /opt/redis_exporter
    - mode: 0755

/opt/redis_exporter/config:
  file.append:
    - text: |
        REDIS_ADDR='redis://localhost:6379'
        REDIS_USER=redis
        REDIS_PASSWORD=8vUqoIO8Na01c1V

copy__files_redis:
  file.managed:
    - name: /opt/redis_exporter/redis_exporter
    - source: /tmp/redis_exporter-v1.14.0.linux-amd64/redis_exporter
    - user: node_exporter
    - group: node_exporter
    - mode: 0755

/etc/systemd/system/redis_exporter.service:
  file.append:
    - text: |
        [Unit]
        Description=redis_exporter
        After=syslog.target network.target

        [Service]
        User=node_exporter
        EnvironmentFile=/opt/redis_exporter/config
        ExecStart=/opt/redis_exporter/redis_exporter $OPTIONS

        [Install]
        WantedBy=multi-user.target


Enable redis_exporter service:
  service.enabled:
    - name: redis_exporter.service
