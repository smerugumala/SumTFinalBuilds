{% import "./vars.sls" as base %}


Download and extract percona archive:
  archive.extracted:
    - name: {{base.percona_tmp_path}}
    - source: {{base.percona_archive_url}}
    - enforce_toplevel: False
    - skip_verify: True



download pre-requisites:
  pkg.installed:
    - sources:
        - openssl: {{base.openssl_rpm}}
        - byobu: {{base.byobu_rpm}}
        - tmux: {{base.tmux_rpm}}
        - screen: {{base.screen_rpm}}

installing mongo rpms:
  pkg.installed:
    - sources: 
        - Percona-Server-MongoDB-34-mongos: {{base.percona_tmp_path}}/Percona-Server-MongoDB-34-mongos-{{base.percona_rpm_version}}
        - Percona-Server-MongoDB-34-tools:  {{base.percona_tmp_path}}/Percona-Server-MongoDB-34-tools-{{base.percona_rpm_version}}
        - Percona-Server-MongoDB-34-shell:  {{base.percona_tmp_path}}/Percona-Server-MongoDB-34-shell-{{base.percona_rpm_version}}
        - Percona-Server-MongoDB-34-server: {{base.percona_tmp_path}}/Percona-Server-MongoDB-34-server-{{base.percona_rpm_version}}

enable mongod:
  service.enabled:
    - name: mongod

start service:
  service.running:
    - name: mongod
