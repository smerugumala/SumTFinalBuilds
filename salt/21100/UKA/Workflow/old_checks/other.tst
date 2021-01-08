{% import "20300/UKA/Workflow/vars.sls" as base %}

#check services enabled, running
check_kafka_service_running:
  module_and_function: service.status
  args:
    - kafka
  assertion: assertTrue 

check_kafka_service_enabled:
  module_and_function: service.enabled
  args:
    - kafka
  assertion: assertTrue

check_schema_registry_service_running:
  module_and_function: service.status
  args:
    - confluent-schema-registry
  assertion: assertTrue
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
#check kafka configs
check values for listeners:
  module_and_function: file.search
  args:
    - {{ base.kafka_config_path }}
    - listeners=PLAINTEXT://{{ip_addr}}:{{base.kafka_port}}
  assertion: assertTrue
  output_details: True

check values for advertised listeners:
  module_and_function: file.search
  args:
    - {{ base.kafka_config_path }}
    - advertised.listeners=PLAINTEXT://{{ip_addr}}:{{base.kafka_port}}
  assertion: assertTrue
  output_details: True

check listener values{{base.zookeeper_ip_string}}:
  module_and_function: file.search
  args:
    - {{ base.kafka_config_path }}
    - {{base.kafka_ip_string}}
  assertion: assertTrue
  output_details: True
