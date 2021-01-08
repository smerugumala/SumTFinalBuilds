
{% import "./vars.sls" as base %}

create kafka user:
  user.present:
    - name: {{base.kafka_user}}

Create Kafka Group:
  group.present:
    - name: {{ base.kafka_group}}
    - gid: 7648
    - system: True
    - addusers:
      - {{base.kafka_user}}
    - require:
      - user: create kafka user

{% for directory in base.directories %}

create {{directory}} for:
  file.directory:
    - name: {{directory}}
    - makedirs: True

{% endfor %}

download kafka install file:
  file.managed:
    - name: {{base.kafka_download_path}}/{{base.kafka_download_file}}
    - source: {{base.kafka_download_url}}
    - skip_verify: True

extract kafka zip file:
  archive.extracted:
    - name: {{base.kafka_path}}
    - source: {{base.kafka_download_path}}/{{base.kafka_download_file}}
    - enforce_toplevel: False
    - watch:
      - file: download kafka install file

ensure_copy_kafka_service_file:
  file.managed:
    - name: '/lib/systemd/system/kafka.service'
    - source: salt://{{ base.templates_folder}}/{{base.kafka_service_file}}
    - template: jinja
    - user: {{ base.kafka_user }}
    - group: {{ base.kafka_group }}
    - kafka_install_path: {{base.kafka_install_path}}


update broker ID values:
  file.replace:
    - name: {{base.kafka_config_path}}
    - pattern: '^(broker.id=)(.*)$'
    - repl: 'broker.id.generation.enable=true'
    - watch:
      - file: ensure_copy_kafka_service_file


assign kafka permissions:
  file.directory:
    - name: {{base.kafka_path}}
    - user: {{base.kafka_user}}
    - group: {{base.kafka_group}}
    - dir_mode: 0777
    - file_mode: 0777
    - recurse:
      - user
      - group
      - mode
    - watch:
      - file: ensure_copy_kafka_service_file

Load in new service files:
  cmd.run:
    - name: systemctl --system daemon-reload
    - watch:
      - file: ensure_copy_kafka_service_file

enable kafka:
  service.enabled:
    - name: kafka
    - watch:
      - file: ensure_copy_kafka_service_file

install rabbit prereqs:
  pkg.installed:
    - pkgs:
      - dkms
      - make
      - bzip2
      - perl
      - kernel-headers

add_erlang_pkg_repo:
  pkgrepo.managed:
    - humanname: erlang-solutions
    - name: erlang
    - baseurl: {{base.erlang_url}}
    - gpgkey: {{base.erlang_key}}
    - enabled: 1

install_esl_erlang_solutions:
  pkg.installed:
    - name: esl-erlang
    - version: {{base.erlang_version}}
    - require:
      - pkgrepo: add_erlang_pkg_repo

create rabbitmq repo file:
  file.managed:
    - name: /etc/yum.repos.d/rabbitmq.repo
    - source: salt://{{ base.templates_folder }}/rabbitmq.repo
    - failhard: True

yum clean:
  cmd.run:
    - name: yum clean all
    - watch:
      - file: create rabbitmq repo file

install_rabbitmq_server:
  pkg.installed:
    - name: rabbitmq-server
    - version: {{base.rabbitmq_version}}
    - failhard: True
    - require:
      - file: create rabbitmq repo file

open ports for rabbitmq:
  firewalld.present:
    - name: public
    - failhard: True
    - ports:
      - 15672/tcp
      - 5672/tcp
      - 4369/tcp
      - 25672/tcp
      - 4369/tcp
      - 44001/tcp
      - 22/tcp #for ssh
      

enable rabbitmq:
  service.enabled:
    - name: rabbitmq-server
    - watch:
      - pkg: install_rabbitmq_server

start rabbitmq:
  service.running:
    - name: rabbitmq-server
    - watch:
      - pkg: install_rabbitmq_server

enable management plugin:
  rabbitmq_plugin.enabled:
    - name: rabbitmq_management
    - watch:
      - pkg: install_rabbitmq_server

enable tracing plugin:
  rabbitmq_plugin.enabled:
    - name: rabbitmq_tracing
    - watch:
      - pkg: install_rabbitmq_server

enable federation plugin:
  rabbitmq_plugin.enabled:
    - name: rabbitmq_federation
    - watch:
      - pkg: install_rabbitmq_server

Set SELinux boolean for nis:
  selinux.boolean:
    - name: nis_enabled
    - value: 1
    - persist: True

create confluent repo file:
  file.managed:
    - name: /etc/yum.repos.d/confluent.repo
    - source: salt://{{ base.templates_folder }}/confluent.repo

yum clean dists:
  cmd.run:
   - name: yum clean all

install schema-registry:
  pkg.installed:
    - name: confluent-schema-registry

enable schema:
  service.enabled:
    - name: confluent-schema-registry

#start schema:
 # service.running:
  #  - name: confluent-schema-registry