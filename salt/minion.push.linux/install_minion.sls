Copy Minion RPM file into place:
  file.managed:
    - name: /tmp/packages.tar
    - source: salt://packages.tar
    - mode: 0755

untar_file:
  archive.extracted:
    - name: /tmp/
    - source: /tmp/packages.tar
    - tar_options: xvf
    - archive_format: tar

Clean Yum Cache:
  cmd.run:
    - name: yum clean expire-cache

Install Minion:
  cmd.run:
    - name: /tmp/packages/install_salt.sh

Restart minion services:
  cmd.run:
    - name: systemctl restart salt-minion

{% set host = salt['cmd.shell']('hostname') %}
{% set hostname = salt['cmd.shell']('hostname -f') %}

Set minion ID:
  file.replace:
    - name: '/etc/salt/minion_id'
    - pattern: '^{{ hostname }}'
    - repl: '{{ host }}'

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

Restart Minion Services:
  cmd.run:
    - name: systemctl restart salt-minion
