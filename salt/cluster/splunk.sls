{% if not salt['file.directory_exists' ]('/opt/splunkforwarder') %}

{% set Domain = salt['pillar.get']('Domain') %}
{% set passwd = salt['pillar.get']('passwd') %}
{% set domainuser = salt['pillar.get']('domainuser') %}
{% set Binary = salt['pillar.get']('Binary') %}

{% if not salt['file.directory_exists' ]('/mnt/splunk') %}
/mnt/splunk:
  file.directory:
    - name: /mnt/splunk
    - mode: 755
{% endif %}

splunk:
  user.present:
    - fullname: splunk
    - shell: /bin/bash
    - home: /home/splunk

Mount:
  cmd.run:
    - name: mount -t cifs -o username={{ domainuser }},password={{ passwd }} '\\{{ Domain }}\UDASHARE\ldc-packages\Infra\splunk\linux_x64' /mnt/splunk

{% set tmp = "/tmp/InstallSplunk" %}

copy_files:
  file.copy:
    - name: {{ tmp }}
    - source: /mnt/splunk
    - mode: 0755
    - makedirs: True
    - preserve: True
    - subdir: True
    - force: True
    - require:
      - cmd: Mount


extract_Splunk:
  archive.extracted:
    - name: /opt/
    - source: {{ tmp }}/{{ Binary }}
    - source_hash: fad82115e58eb3246592aa5321012c1a
    - user: splunk
    - group: splunk
    - mode: 755
    - if_missing: /opt/splunkforwarder
    - require:
      - file: copy_files

{% set path = "/opt/splunkforwarder/etc/apps/sumt_deploymentclient_all/local/" %}

{% if not salt['file.directory_exists' ](path) %}

Create sumT Directory:
  file.directory:
    - name: {{ path }}
    - user: splunk
    - group: splunk
    - mode:  755
    - makedirs: True
    - include_empty: True
    - require: 
      - archive: extract_Splunk

{% endif %}

copy_configureation file:
  file.managed:
    - name: {{ path }}/deploymentclient.conf
    - source: {{ tmp }}/deploymentclient.conf
    - mode: 0755
    - user: splunk
    - group: splunk
    - require:
      - file: Create sumT Directory

Install Splunk:
  cmd.run:
    - name: sudo -H -u splunk /opt/splunkforwarder/bin/splunk start --accept-license --answer-yes --auto-ports --no-prompt  -auth admin:changeme
    - require:
      - file: copy_configureation file

unmount:
  mount.unmounted:
    - name: /mnt/splunk

remove directory:
  file.absent:
    - names: 
      - /mnt/splunk
      - {{ tmp }}

{% endif %}

{% if not salt['file.file_exists' ]('/etc/init.d/splunk') %}

Enable service:
  cmd.run:
    - name: sudo /opt/splunkforwarder/bin/splunk enable boot-start -user splunk -systemd-managed 0
    - require:
      - cmd: Install Splunk

{% endif %}

Start service:
  cmd.run:
    - name: sudo -H -u splunk /opt/splunkforwarder/bin/splunk restart
