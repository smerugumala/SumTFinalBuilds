replace_ntpserver:
  file.line:
    - name: /etc/ntp.conf
    - mode: replace
    - match: ^server.*
    - content: server {{ salt['pillar.get']('ntpServer') }}
