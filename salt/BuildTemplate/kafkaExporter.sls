{% set reposerver = pillar['reposerver'] %}

extract_kakfka_exporter:
  archive.extracted:
    - name: /tmp
    - source: http://{{ reposerver }}/prometheus/kafka.tar.gz
    - skip_verify: True
    - user: kafka
    - group: kafka
    - mode: '755'
    - makedirs: True
    - if_missing: /tmp/kafka.tar.gz

get jmx jar file:
  file.managed:
    - source: http://{{ reposerver }}/prometheus/jmx_prometheus_javaagent-0.12.0.jar
    - name: /opt/exporter/jmx_prometheus_javaagent-0.12.0.jar
    - skip_verify: True
    - user: kafka
    - group: kafka
    - mode: 0755
    - makedirs: True

get kafka yml file:
  file.managed:
    - source: /tmp/kafka/kafka-2_0_0.yml
    - name: /opt/exporter/kafka-2_0_0.yml
    - skip_verify: True
    - user: kafka
    - group: kafka
    - mode: 0755
    - makedirs: True
