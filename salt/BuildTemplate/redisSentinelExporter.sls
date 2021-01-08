{% set reposerver = pillar['reposerver'] %}
node_exporter:
  user.present:
    - fullname: node_exporter
    - shell: /bin/false


extract_redis_sentinal_exporter:
  archive.extracted:
    - name: /tmp/
    - source: http://{{ reposerver }}/prometheus/redis_sentinel_exporter-1.7.1.linux-amd64.tar.gz
    - skip_verify: True
    - user: node_exporter
    - group: node_exporter
    - mode: '755'
    - if_missing: /tmp/redis_sentinel_exporter-1.7.1.linux-amd64.tar.gz

Create hierarchy:
  file.directory:
    - user: node_exporter
    - group: node_exporter
    - makedirs: True
    - names:
      - /opt/redis_sentinel_exporter
      - /opt/redis_sentinel_exporter/scc_sentinel
      - /opt/redis_sentinel_exporter/dcc_sentinel
    - mode: 0755


/opt/redis_sentinel_exporter/dcc_sentinel/config:
  file.append:
    - text: |
        SENTINEL_ADDR="redis://localhost:26379"

/opt/redis_sentinel_exporter/scc_sentinel/config:
  file.append:
    - text: |
        SENTINEL_ADDR="redis://localhost:26380"

copy__files_sentinel:
  file.managed:
    - names:
      - /opt/redis_sentinel_exporter/dcc_sentinel/redis_sentinel_exporter
      - /opt/redis_sentinel_exporter/scc_sentinel/redis_sentinel_exporter
    - source: /tmp/redis_sentinel_exporter-1.7.1.linux-amd64/redis_sentinel_exporter
    - user: node_exporter
    - group: node_exporter
    - mode: 0755

/etc/systemd/system/scc_sentinel_exporter.service:
  file.append:
    - text: |
        [Unit]
        Description=redis_sentinel_exporter
        Requisite=scc_sentinel.service
        After=network-online.target
 
        [Service]
        User=node_exporter
        EnvironmentFile=/opt/redis-sentinel-exporter/scc_sentinel/config
        ExecStart=/opt/redis-sentinel-exporter/scc_sentinel/redis_sentinel_exporter $OPTIONS
 
        [Install]
        WantedBy=multi-user.target

/etc/systemd/system/dcc_sentinel_exporter.service:
  file.append:
    - text: |
        [Unit]
        Description=redis_sentinel_exporter
        Requisite=dcc_sentinel.service
        After=network-online.target

        [Service]
        User=node_exporter
        EnvironmentFile=/opt/redis-sentinel-exporter/dcc_sentinel/config
        ExecStart=/opt/redis-sentinel-exporter/dcc_sentinel/redis_sentinel_exporter $OPTIONS

        [Install]
        WantedBy=multi-user.target

Enable service:
  service.enabled:
    - names: 
      - dcc_sentinel_exporter.service
      - scc_sentinel_exporter.service
