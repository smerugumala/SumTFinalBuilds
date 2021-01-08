node_exporter:
  user.present:
    - fullname: node_exporter
    - shell: /bin/false


extract_node_exporter:
  archive.extracted:
    - name: /tmp/
    - source: https://github.com/prometheus/node_exporter/releases/download/v0.15.2/node_exporter-0.15.2.linux-amd64.tar.gz
    - source_hash: f4f27720e20e3e811c066fa88e6caf8b
    - user: node_exporter
    - group: node_exporter
    - mode: '755'
    - if_missing: /tmp/node_exporter-0.15.2.linux-amd64.tar.gz

copy__files:
  file.managed:
    - name: /usr/local/sbin/node_exporter
    - source: /tmp/node_exporter-0.15.2.linux-amd64/node_exporter
    - mode: 0755

/etc/systemd/system/node_exporter.service:
  file.append:
    - text: |
        [Unit]
        Description=Node Exporter
        After=network-online.target

        [Service]
        User=node_exporter
        Group=node_exporter
        Type=simple
        ExecStart=/usr/local/sbin/node_exporter

        [Install]
        WantedBy=multi-user.target


Enable node_exporter service:
  service.enabled:
    - name: node_exporter.service

start node_exporter Service:
  service.running:
    - name: node_exporter.service

