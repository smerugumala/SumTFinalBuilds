{% set ismachinebound  = 'realm list| grep sssd' %}
{% if not salt['cmd.shell'](ismachinebound) %}

{% set Domain = salt['pillar.get']('Domain') %}
{% set passwd = salt['pillar.get']('passwd') %}

{% set domainuser = salt['pillar.get']('domainuser') %}

{% set server = salt.cmd.run('hostname -s') %}
Join system to AD:
  cmd.run:
    - name: echo {{ passwd  }} | sudo realm join --user={{ domainuser }}  {{ Domain }}


Change Hostname to FQDN:
  module.run:
    - name: system.set_computer_name
    - hostname: {{ server }}.{{ Domain }} --static


Replace use of FQDN in username:
  file.line:
    - name: /etc/sssd/sssd.conf
    - mode: replace
    - match: 'use_fully_qualified_names = True'
    - content: 'use_fully_qualified_names = False'

replace fallback home directory:
  file.line:
    - name: /etc/sssd/sssd.conf
    - mode: replace
    - match: 'fallback_homedir = /home/%u@%d'
    - content: 'fallback_homedir = /home/%u'
    - require:
      - file: Replace use of FQDN in username

restart sssd service:
  cmd.run:
    - name: systemctl restart sssd
    - require:
      - file: replace fallback home directory

{% else %}

Validated:
  test.succeed_without_changes

{% endif %}

