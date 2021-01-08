{% import "./vars.sls" as base %}

create mongo user:
  mongodb_user.present:
  - name: {{base.umd_user}}
  - passwd: {{base.umd_password}}
  - database: admin
  - roles:
      - root

enable mongo authorization:
  file.append:
    - name: '/etc/mongod.conf'
    - require:
      - mongodb_user: create mongo user
    - text: |
        security:
          authorization: enabled

remove ip binding:
  file.replace:
    - name: /etc/mongod.conf
    - pattern: '^.*bindIp.*$'
    - repl: ''

restart service:
  service.running:
    - name: mongod
    - require:
      - file: remove ip binding