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

