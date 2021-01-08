{% set reposerver = pillar['reposerver'] %}
node_exporter:
  user.present:
    - fullname: node_exporter
    - shell: /bin/false


extract_mongodb_exporter:
  file.managed:
    - name: /tmp/mongodb_exporter
    - source: http://{{ reposerver }}/prometheus/mongodb_exporter-linux-amd64
    - skip_verify: True
    - user: node_exporter
    - group: node_exporter
    - mode: '755'
    - if_missing: /tmp/mongodb_exporter-linux-amd64

/opt/mongodb_exporter:
  file.directory:
    - user: node_exporter
    - group: node_exporter
    - name: /opt/mongodb_exporter
    - mode: 0755

/opt/mongodb_exporter/config:
  file.append:
    - text: |
        OPTIONS=mongodb://'pmm:Marvin1022!'@localhost:27017

copy__files_mongo:
  file.managed:
    - name: /opt/mongodb_exporter/mongodb_exporter
    - source: /tmp/mongodb_exporter
    - user: node_exporter
    - group: node_exporter
    - mode: 0755

/etc/systemd/system/mongodb_exporter.service:
  file.append:
    - text: |
        [Unit]
        Description=mongodb_exporter
        After=network.target

        [Service]
        User=node_exporter
        EnvironmentFile=/opt/mongodb_exporter/config
        ExecStart=/opt/mongodb_exporter/mongodb_exporter $OPTIONS

        [Install]
        WantedBy=multi-user.target


Enable mongodb_exporter service:
  service.enabled:
    - name: mongodb_exporter.service
