{% set role = pillar['role'] %}
{% set reposerver = pillar['repoServer'] %}
{% set server = pillar['instance'] %}

{% if role == 'UKA' %}

{{ role }}roleexporter:
  salt.state:
    - sls:
      - BuildTemplate/kafkaExporter
      - BuildTemplate/rabbitmqExporter
    - tgt: {{ server }}
    - pillar:
        reposerver: {{ reposerver }}

{% elif ((role == 'SCC') or (role == 'DCC')) %}

{{ role }}roleexporter:
  salt.state:
    - sls:
      - BuildTemplate/redisExporter
    - tgt: {{ server }}
    - pillar:
        reposerver: {{ reposerver }}

{% elif role == 'CSD' %}

{{ role }}roleexporter:
  salt.state:
    - sls:
      - BuildTemplate/cassandraExporter
    - tgt: {{ server }}
    - pillar:
        reposerver: {{ reposerver }}

{% elif role == 'HAM' %}

{{ role }}roleexporter:
  salt.state:
    - sls:
      - BuildTemplate/redisSentinelExporter
    - tgt: {{ server }}
    - pillar:
        reposerver: {{ reposerver }}

{% elif role == 'UXD' %}

{{ role }}roleexporter:
  salt.state:
    - sls:
      - BuildTemplate/mysqldExporter
    - tgt: {{ server }}
    - pillar:
        reposerver: {{ reposerver }}

{% elif role == 'UMD' %}

{{ role }}roleexporter:
  salt.state:
    - sls:
      - BuildTemplate/mongodbExporter
    - tgt: {{ server }}
    - pillar:
        reposerver: {{ reposerver }}

{% elif role == 'UEB' %}

{{ role }}roleexporter:
  salt.state:
    - sls:
      - BuildTemplate/rabbitmqExporter
    - tgt: {{ server }}
    - pillar:
        reposerver: {{ reposerver }}

{% elif role == 'UEC' %}

{{ role }}roleexporter:
  salt.state:
    - sls:
      - BuildTemplate/UECCronjob
    - tgt: {{ server }}
    - pillar:
        reposerver: {{ reposerver }}

{% endif %}
