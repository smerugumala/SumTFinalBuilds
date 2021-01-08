replace_syslogserver:
  file.line:
    - name: /etc/rsyslog.conf
    - mode: delete
    - match: "@"

add syslogserve:
  cmd.run:
    - name: echo "*.* @{{ salt['pillar.get']('syslogServer') }}" >> /etc/rsyslog.conf
