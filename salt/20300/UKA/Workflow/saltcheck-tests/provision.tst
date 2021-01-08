{% import "20300/UKA/Workflow/vars.sls" as base %}

{% set trialset = salt['network.ipaddrs']( ) %}
{% set val= trialset | replace("[u'", "") %}
{% set ip_addr= val| replace("']", "") %}


validate_user_{{ base.kafka_user }}:
  module_and_function: user.info
  assertion_section: shell
  args:
    - {{ base.kafka_user }}
  assertion: assertEqual
  expected-return: /bin/bash

{% for port in ["15672/tcp","5672/tcp","4369/tcp","25672/tcp","44001/tcp","22/tcp"] %}

check if {{port}} is open:
  module_and_function: firewalld.list_ports
  args:
    - public
  assertion: assertIn
  expected-return: {{port}}
  output_details: True

{% endfor %}

{% for package in ["java-1.8.0","gcc-c++"] %}
jinja_test_{{ package }}_latest{{base.role}}:
  module_and_function: pkg.upgrade_available
  args:
    - {{ package }}
  assertion: assertFalse
{% endfor %}

check values for listeners{{ip_addr}}hello:
  module_and_function: file.search
  args:
    - {{ base.kafka_config_path }}
    - listeners=PLAINTEXT://{{ip_addr}}
  assertion: assertTrue
  output_details: True

check values for advertised listeners:
  module_and_function: file.search
  args:
    - {{ base.kafka_config_path }}
    - advertised.listeners=PLAINTEXT://{{ip_addr}}
  assertion: assertTrue
  output_details: True

check_kafka_service_running:
  module_and_function: service.status
  args:
    - kafka
  assertion: assertFalse

check_kafka_service_enabled:
  module_and_function: service.enabled
  args:
    - kafka
  assertion: assertTrue

check_schema_registry_service_running:
  module_and_function: service.status
  args:
    - confluent-schema-registry
  assertion: assertFalse

check_schema_registry_service_enabled:
  module_and_function: service.enabled
  args:
    - confluent-schema-registry
  assertion: assertTrue

check_rabbitmq_running:
  module_and_function: service.status
  args:
    - rabbitmq-server
  assertion: assertTrue

check_rabbitmq_enabled:
  module_and_function: service.enabled
  args:
    - rabbitmq-server
  assertion: assertTrue
