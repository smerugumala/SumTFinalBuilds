{% set cluster = pillar['cluster'] %}
{% set patset = pillar['patset'] %}
{% set role = pillar['role'] %}
{% set cspol = 'pol_'~ cluster ~'_fqdn_match' %}
{% set datacenter = pillar['datacenter'] %}
{% set environment = pillar['environment'] %}
{% set lb = salt['cmdb_lib3.getlb'](datacenter,environment) %}
{% set password = salt['cmdb_lib3.getresource']('network_administrators','vro-admin') %}
{% if role == 'UUW' %}
{% set rule = 'HTTP.REQ.HOSTNAME.SET_TEXT_MODE(IGNORECASE).EQUALS_ANY(\\"'~ patset ~'\\")' %}
{% endif %}

{% if role == 'URW' %}

{% set rule = 'HTTP.REQ.HOSTNAME.SET_TEXT_MODE(IGNORECASE).EQUALS_ANY(\\"'~ patset ~'\\") && (HTTP.REQ.URL.PATH.SET_TEXT_MODE(IGNORECASE).GET(1).EQ(\\"jasperserver-pro\\") || HTTP.REQ.URL.PATH.SET_TEXT_MODE(IGNORECASE).GET(1).EQ(\\"monitor\\") || HTTP.REQ.URL.PATH.SET_TEXT_MODE(IGNORECASE).GET(1).EQ(\\"ReportingMobile\\")))'%}

{% endif %}

{% if role == 'UUW' or role == 'URW' %}
addcspolicy:
  module.run:
    - name: netscaler.cspolicy_add
    - cspol_name: {{ cspol }}
    - rule: "{{ rule }}"
    - connection_args: {
        netscaler_host: '{{ lb }}',
        netscaler_user: 'vro-admin',
        netscaler_pass: '{{ password }}',
        netscaler_useSSL: 'False'
      }
{% endif %}
