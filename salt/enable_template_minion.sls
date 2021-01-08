{% set host = salt['cmd.shell']('hostname -s') %}

Set minion ID:
  file.append:
    - name: '/etc/salt/minion_id'
    - text: '{{ host }}'

Create master.conf file:
  file.append:
    - name: /etc/salt/minion.d/masters.conf
    - text: |
        master:
          - ldcsaltmas003
          - ldcsaltmas004

/etc/salt/minion.d/masters.conf:
  file.managed:
    - mode: '0555'

Start Minion Services:
  cmd.run:
    - name: systemctl start salt-minion && systemctl enable salt-minion
