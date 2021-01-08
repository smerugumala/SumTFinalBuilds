{% set reposerver = pillar['reposerver'] %}

create a user:
  user.present:
    - name: cassandra

create cassandra group:
  group.present:
    - name: cassandra
    - system: True
    - addusers:
      - cassandra

extract_cassandra_exporter:
  archive.extracted:
    - name: /tmp
    - source: http://{{ reposerver }}/prometheus/cassandra.tar.gz
    - skip_verify: True
    - user: cassandra
    - group: cassandra
    - mode: '755'
    - makedirs: True
    - if_missing: /tmp/cassandra.tar.gz

get jmx jar file:
  file.managed:
    - source: http://{{ reposerver }}/prometheus/jmx_prometheus_javaagent-0.12.0.jar
    - name: /opt/exporter/jmx_prometheus_javaagent-0.12.0.jar
    - skip_verify: True
    - user: cassandra
    - group: cassandra
    - mode: 0755

get cassandra yml file:
  file.managed:
    - source: /tmp/cassandra/cassandra.yml
    - name: /opt/exporter/cassandra.yml
    - skip_verify: True
    - user: cassandra
    - group: cassandra
    - mode: 0755
    - makedirs: True

/opt/cassandra/apache-cassandra-3.11.5/conf/cassandra-env.sh:
  file.append:
    - text: |
        JVM_OPTS="$JVM_OPTS -javaagent:/opt/exporter/jmx_prometheus_javaagent-0.12.0.jar=7070:/opt/exporter/cassandra.yml"
    - makedirs: True
