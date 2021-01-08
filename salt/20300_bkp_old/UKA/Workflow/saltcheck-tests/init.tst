{% import "20300/UKA/Workflow/vars.sls" as base %}


check_kafka_service_running:
  module_and_function: service.status
  args:
    - kafka
  assertion: assertTrue



 
{% for package in ["java-1.8.0"] %}
jinja_test_{{ package }}_latest:
  module_and_function: pkg.upgrade_available
  args:
    - {{ package }}
  assertion: assertFalse
{% endfor %}

validate_user_{{ base.kafka_user }}:
  module_and_function: user.info
  assertion_section: shell
  args:
    - {{ base.kafka_user }}
  assertion: assertEqual
  expected-return: /bin/bash
  
check listener values{{base.zookeeper_ip_string}}:
  module_and_function: file.search
  args:
    - {{ base.kafka_config_path }}
    - SASL_PLAINTEXT://*

  assertion: assertTrue
  output_details: True

