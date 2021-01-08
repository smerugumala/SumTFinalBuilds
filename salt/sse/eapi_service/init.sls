{#
  Salt State to Install and Configure SaltStack Enterprise Service "raas"
#}

{% set sse_pg_endpoint = salt['pillar.get']('sse_pg_endpoint', "localhost") %}
{% set sse_pg_port = salt['pillar.get']('sse_pg_port', "5432") %}

{% set sse_pg_username = salt['pillar.get']('sse_pg_username', "salt_eapi") %}
{% set sse_pg_password = salt['pillar.get']('sse_pg_password', "abc123") %}

{% set sse_redis_endpoint = salt['pillar.get']('sse_redis_endpoint', "localhost") %}
{% set sse_redis_port = salt['pillar.get']('sse_redis_port', "6379") %}
{% set sse_redis_username = salt['pillar.get']('sse_redis_username', "salt_eapi") %}
{% set sse_redis_password = salt['pillar.get']('sse_redis_password', "abc123") %}

{% set sse_eapi_username = salt['pillar.get']('sse_eapi_username', "root") %}
{% set sse_eapi_password = salt['pillar.get']('sse_eapi_password', "salt") %}

{% set sse_eapi_key = salt['pillar.get']('sse_eapi_key', "auto") %}

{% set sse_eapi_ssl_enabled = salt['pillar.get']('sse_eapi_ssl_enabled', True) %}
{% if sse_eapi_ssl_enabled %}
{% set http_prefix = "https://" %}
{% else %}
{% set http_prefix = "http://" %}
{% endif %}

{% set sse_customer_id = salt['pillar.get']('sse_customer_id', '43cab1f4-de60-4ab1-85b5-1d883c5c5d09') %}

{% set cachedir = opts['cachedir'] + "/SSEAPE/" %}

include:
  - sse.pyopenssl

install_python35:
  pkg.installed:
    - sources:
      - python35u-libs: salt://{{ slspath }}/files/python35u-libs-3.5.6-1.ius.el7.x86_64.rpm
      - python35u: salt://{{ slspath }}/files/python35u-3.5.6-1.ius.el7.x86_64.rpm
      - python3-pip: salt://{{ slspath }}/files/python3-pip-9.0.3-5.el7.noarch.rpm

install_xmlsec:
  pkg.installed:
    - sources:
      - openssl: salt://{{ slspath }}/files/openssl-1.0.2k-19.el7.x86_64.rpm
      - xmlsec1: salt://{{ slspath }}/files/xmlsec1-1.2.20-7.el7_4.x86_64.rpm
      - xmlsec1-openssl: salt://{{ slspath }}/files/xmlsec1-openssl-1.2.20-7.el7_4.x86_64.rpm

install_raas:
  pkg.installed:
    - sources:
      - raas: salt://{{ slspath }}/files/raas-6.2.0+5.el7.x86_64.rpm

  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
      - pkg: install_raas

create_pki_raas_path_eapi:
  file.directory:
    - name: /etc/pki/raas/certs
    - makedirs: True
    - dir_mode: 755

create_ssl_certificate_eapi:
  module.run:
    - name: tls.create_self_signed_cert
    - tls_dir: raas
    - require:
      - file: create_pki_raas_path_eapi
    - onchanges:
      - pkg: install_raas

set_certificate_permissions_eapi:
  file.managed:
    - name: /etc/pki/raas/certs/localhost.crt
    - user: raas
    - group: raas
    - mode: 400
    - replace: False
    - create: False

set_key_permissions_eapi:
  file.managed:
    - name: /etc/pki/raas/certs/localhost.key
    - user: raas
    - group: raas
    - mode: 400
    - replace: False
    - create: False

raas_owns_raas:
  file.directory:
    - name: /etc/raas/
    - user: raas
    - group: raas
    - dir_mode: 750

configure_raas:
  file.managed:
    - name: /etc/raas/raas
    - source: salt://{{ slspath }}/files/raas.jinja
    - template: jinja
    - user: raas
    - group: raas
    - mode: 660
    - context:
        sse_customer_id: {{ sse_customer_id }}
        sse_eapi_ssl_enabled: {{ sse_eapi_ssl_enabled }}
        sse_pg_endpoint: {{ sse_pg_endpoint }}
        sse_pg_port: {{ sse_pg_port }}
        sse_pg_username: {{ sse_pg_username }}
        sse_pg_password: {{ sse_pg_password }}
        sse_redis_endpoint: {{ sse_redis_endpoint }}
        sse_redis_port: {{ sse_redis_port }}
        sse_redis_username: {{ sse_redis_username }}
        sse_redis_password: {{ sse_redis_password }}
    - require:
      - pkg: install_raas

save_credentials:
  cmd.run:
    - require:
      - file: raas_owns_raas
      - file: configure_raas
{% if not salt['file.file_exists']('/etc/raas/pki/.raas.key') and sse_eapi_key != "auto" %}
      - cmd: set_raas_key
{% endif %}
    - runas: raas
    - names:
      - "/opt/saltstack/raas/venv/bin/raas save_creds
            'postgres={\"username\": \"{{ sse_pg_username }}\", \"password\": \"{{ sse_pg_password }}\"}'
            'redis={\"password\": \"{{ sse_redis_password }}\"}'"
    - creates:
      - /etc/raas/raas.secconf

set_secconf_permissions:
  file.managed:
    - name: /etc/raas/raas.secconf
    - user: raas
    - group: raas
    - mode: 600
    - create: False
    - replace: False
    - require:
      - cmd: save_credentials

ensure_raas_pki_directory:
  file.directory:
    - name: /etc/raas/pki
    - user: raas
    - group: raas
    - dir_mode: 700

{% if not salt['file.file_exists']('/etc/raas/pki/.raas.key') and sse_eapi_key != "auto" %}
set_raas_key:
  cmd.run:
    - name: echo "${RAAS_KEY}" > /etc/raas/pki/.raas.key
    - env:
        RAAS_KEY: '{"priv": "{{ sse_eapi_key }}"}'
    - require:
      - file: ensure_raas_pki_directory
{% endif %}

change_owner_to_raas:
  file.directory:
    - name: /etc/raas/pki
    - user: raas
    - group: raas
    - dir_mode: 700
    - recurse:
      - user
      - group
      - mode

start_raas:
  service.running:
    - name: raas
    - enable: True
    - require:
      - pkg: install_raas
    - watch:
      - file: configure_raas
    - check_cmd:
      - "until curl -k {{ http_prefix }}localhost/version > /dev/null 2>&1; do sleep 2 && ((x++)); if [[ x -eq 30 ]]; then break; fi; done"

# Under certain conditions, such as initial provisioning of the raas database with multiple raas heads,
# the raas process may need to wait for the initial raas head to complete database initialization.
# In this case, we will restart raas after a delay.  The raas head that initializes the database will
# also import the default set of objects.  Which does not need to be repeated.
restart_raas_and_confirm_connectivity:
  cmd.run:
    - names: 
      - "salt-call service.restart raas"
    - check_cmd:
      - "until curl -k {{ http_prefix }}localhost/version > /dev/null 2>&1; do sleep 2 && ((x++)); if [[ x -eq 30 ]]; then break; fi; done"
    - unless:
      - "curl -k
              -c {{ cachedir }}eapi_cookie.txt
              -u {{ sse_eapi_username }}:{{ sse_eapi_password }} '{{ http_prefix }}localhost/version' >/dev/null"

get_initial_objects_file:
  file.managed:
    - name: /tmp/sample-resource-types.raas
    - source: salt://{{ slspath }}/files/sample-resource-types.raas

import_initial_objects:
  cmd.run:
    - names:
      - "/opt/saltstack/raas/venv/bin/raas-dump --insecure --raas {{ http_prefix }}localhost --auth {{ sse_eapi_username }}:{{ sse_eapi_password }} import < /tmp/sample-resource-types.raas"
