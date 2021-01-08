{% import "./vars.sls" as base %}

extract percona:
  archive.extracted:
    - name: /opt/Percona-Server-5.7.23-25-r7e2732e-el7-x86_64-bundle
    - source: https://www.percona.com/downloads/Percona-Server-5.7/Percona-Server-5.7.23-25/binary/redhat/7/x86_64/Percona-Server-5.7.23-25-r7e2732e-el7-x86_64-bundle.tar
    - enforce_toplevel: false
    - skip_verify: True

download pre-requisite:
  pkg.installed:
    - sources:
        - libaio-devel: http://mirror.centos.org/centos/7/os/x86_64/Packages/libaio-devel-0.3.109-13.el7.x86_64.rpm
        - net-tools: http://mirror.centos.org/centos/7/os/x86_64/Packages/net-tools-2.0-0.25.20131004git.el7.x86_64.rpm

installing rpm1:
  pkg.installed:
    - sources:
        - Percona-Server-shared-compat-57: /opt/Percona-Server-5.7.23-25-r7e2732e-el7-x86_64-bundle/Percona-Server-shared-compat-57-5.7.23-25.1.el7.x86_64.rpm
        - Percona-Server-shared-57: /opt/Percona-Server-5.7.23-25-r7e2732e-el7-x86_64-bundle/Percona-Server-shared-57-5.7.23-25.1.el7.x86_64.rpm
        - Percona-Server-client-57: /opt/Percona-Server-5.7.23-25-r7e2732e-el7-x86_64-bundle/Percona-Server-client-57-5.7.23-25.1.el7.x86_64.rpm
        - Percona-Server-server-57: /opt/Percona-Server-5.7.23-25-r7e2732e-el7-x86_64-bundle/Percona-Server-server-57-5.7.23-25.1.el7.x86_64.rpm


firewalld:
  service.running:
    - enable: true

startservice:
  service.running:
    - name: mysqld

makingmysqlpasswordless:
  cmd.run:
    - name: sudo systemctl set-environment MYSQLD_OPTS="--skip-grant-tables"
restartmysql:
  service.running:
    - name: mysql
    - watch:
      - cmd: makingmysqlpasswordless
changingpwdforroot:
  cmd.run:
    - name: mysql -u root -e "UPDATE mysql.user SET authentication_string = PASSWORD('{{base.defaultuserpwd}}'), password_expired = 'N' WHERE User = '{{base.defaultuser}}' AND Host = 'localhost'; FLUSH PRIVILEGES; "
makingmysqlpassword1:
  cmd.run:
    - name: systemctl unset-environment MYSQLD_OPTS
restartmysql1:
  service.running:
    - name: mysql
    - watch:
      - cmd: makingmysqlpassword1

root_alldb:
  mysql_query.run:
    - database: mysql
    - query: "GRANT ALL ON *.* to '{{base.defaultuser}}'@'%' IDENTIFIED BY '{{base.defaultuserpwd}}';"
    - connection_user: {{base.defaultuser}}
    - connection_pass: {{base.defaultuserpwd}}
    - connection_unix_socket: /var/lib/mysql/mysql.sock

settingpermissions:
  mysql_query.run:
    - database: mysql
    - query: "UPDATE mysql.user SET GRANT_PRIV='Y' WHERE user='{{base.defaultuser}}';"
    - connection_user: {{base.defaultuser}}
    - connection_pass: {{base.defaultuserpwd}}
    - connection_unix_socket: /var/lib/mysql/mysql.sock
flushpriviliges:
  mysql_query.run:
    - database: mysql
    - query: "FLUSH PRIVILEGES;"
    - connection_user: {{base.defaultuser}}
    - connection_pass: {{base.defaultuserpwd}}
    - connection_unix_socket: /var/lib/mysql/mysql.sock
