{% import "UMD/vars.sls" as base %}

set up percona repo:
  cmd.run:
    - name: sudo yum install {{base.percona_rpm}}

enable version release:
  cmd.run:
    - name: sudo percona-release enable psmdb-{{ base.percona_server_version | replace('.', '')}} release

install percona-mongod:
  pkg.installed:
    - name: Percona-Server-MongoDB

enable mongod:
  service.enabled:
    - name: mongod

start service:
  service.running:
    - name: mongod
