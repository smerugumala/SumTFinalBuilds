{% import "./vars.sls" as base %}
createuser:
  mysql_user.present:
    - name: {{base.uxdadminuser}}
    - password: {{base.uxdadminpwd}}
    - connection_user: {{base.defaultuser}}
    - connection_pass: {{base.defaultuserpwd}}
    - connection_unix_socket: /var/lib/mysql/mysql.sock
setting cluster permissions:
  mysql_query.run:
    - database: mysql
    - query: "GRANT ALL ON *.* to '{{base.uxdadminuser}}'@'%' IDENTIFIED BY '{{base.uxdadminpwd}}';"
    - connection_user: {{base.defaultuser}}
    - connection_pass: {{base.defaultuserpwd}}
    - connection_unix_socket: /var/lib/mysql/mysql.sock

grantingpermissions:
  mysql_query.run:
    - database: mysql
    - query: "UPDATE mysql.user SET GRANT_PRIV='Y' WHERE user='{{base.uxdadminuser}}';"
    - connection_user: {{base.defaultuser}}
    - connection_pass: {{base.defaultuserpwd}}
    - connection_unix_socket: /var/lib/mysql/mysql.sock

