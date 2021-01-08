{% if pillar['datacenter']  == 'LDC' %}
{% set ntpServer = 'dev-time.cotestdev.local' %}
{% set syslogServer = 'dev-syslog.cotestdev.local' %}
{% elif pillar['datacenter']  == 'PCM' %}
{% set ntpServer = 'copci-time.copci.local' %}
{% set syslogServer = 'copci-syslog.copci.local' %}
{% elif pillar['datacenter']  == 'AMS' %}
{% set ntpServer = 'ams-time.od.local' %}
{% set syslogServer = 'ams-syslog.od.local' %}

{% elif pillar['datacenter']  == 'DSM' %}
{% set ntpServer = 'dsm-time.od.local' %}
{% set syslogServer = 'dsm-syslog.od.local' %}

{% elif pillar['datacenter']  == 'GSL' %}
{% set ntpServer = 'dev-time.cotestdev.local' %}
{% set syslogServer = 'dev-syslog.cotestdev.local' %}

{% elif pillar['datacenter']  == 'CMH' %}
{% set ntpServer = 'cmh-time.od.local' %}
{% set syslogServer = 'cmh-syslog.od.local' %}


{% endif %}
