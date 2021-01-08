
{% import "./vars.sls" as base %}

{% set trialset = salt['network.ipaddrs']( ) %}
{% set val= trialset | replace("[u'", "") %}
{% set ip_addr= val| replace("']", "") %}

kill kafka:
  service.dead:
    - name: kafka

kill schema-registry:
  service.dead:
    - name: confluent-schema-registry

update the listener values:
  file.replace:
    - name: {{base.kafka_config_path}}
    - pattern: '^(#?listeners=)(.*)$'
    - repl: listeners=PLAINTEXT://{{ip_addr}}:{{base.kafka_port}}

update the advertised listener values:
  file.replace:
    - name: {{base.kafka_config_path}}
    - pattern: '^(#?advertised.listeners=)(.*)$'
    - repl: advertised.listeners=PLAINTEXT://{{ip_addr}}:{{base.kafka_port}}
update the zookeepertimeout values:
  file.replace:
    - name: {{base.kafka_config_path}}
    - pattern: '^(#?zookeeper.connection.timeout.ms=)(.*)$'
    - repl: zookeeper.connection.timeout.ms=60000

update the autotopiccreationtofale:
  file.append:
    - name: {{base.kafka_config_path}}
    - text: auto.create.topics.enable=false



update zk ip configs:
  file.replace:
    - name: {{base.kafka_config_path}}
    - pattern: '^(zookeeper.connect=)(.*)$'
    - repl: zookeeper.connect={{base.zookeeper_ip_string}}

update the schema:
  file.replace:
    - name: {{base.schema_registry_path}}/schema-registry.properties
    - pattern: '^(#?kafkastore.bootstrap.servers=)(.*)$'
    - repl: kafkastore.bootstrap.servers=PLAINTEXT://{{base.kafka_ip_string}}

comment unneeded kafkastore connection url:
  file.replace:
    - name: {{base.schema_registry_path}}/schema-registry.properties
    - pattern: 'kafkastore.connection.url=localhost:2181'
    - repl: "#kafkastore.connection.url=localhost:2181"

ensure rabbitmq is running:
  service.running:
    - name: rabbitmq-server

start kafka:
  service.running:
    - name: kafka

start schema-registry:
  service.running:
    - name: confluent-schema-registry










{% if base.erlang_cookie_contents != base.erlang_cookie_value %}

stop the ctl app:
  module.run:
    - name: rabbitmq.stop_app

reset the ctl app:
  module.run:
    - name: rabbitmq.reset

kill rabbitmq service:
  service.dead:
    - name: rabbitmq-server

copy erlang cookie to file:
  file.replace:
    - name: {{ base.erlang_cookie_path }}
    - pattern: '.*'
    - repl: {{base.erlang_cookie_value }}

start rabbitmq service:
  service.running:
    - name: rabbitmq-server

start the ctl app:
  module.run:
    - name: rabbitmq.start_app

{% endif %}

create rabbit user:
  rabbitmq_user.present:
    - name: {{base.rabbitmq_user}}
    - password: {{base.rabbitmq_password}}
    - force: True

set the rabbitmq user permissions:
  module.run:
    - name: rabbitmq.set_permissions
    - vhost:  /
    - user: {{base.rabbitmq_user}}

set the rabbitmq user tags:
  module.run:
    - m_name: {{base.rabbitmq_user}}
    - name: rabbitmq.set_user_tags 
    - tags: administrator

rabbit_policy:
  rabbitmq_policy.present:
    - name: ha-mode
    - pattern: '^.*'
    - definition: '{"ha-mode": "all", "ha-sync-mode": "automatic"}'

copy in hosts values:
  file.append:
    - name: '/etc/hosts'
    - source: salt://{{ base.templates_folder}}/hosts
    - template: jinja
    - context: 
        dict_hosts: {{ base.dict_hosts }}


