{% import "20300/CSD/Workflow/vars.sls" as base %}

check_cassandra_service_running:
  module_and_function: service.status
  args:
    - cassandra
  assertion: assertTrue
 
{% for package in ["java-1.8.0"] %}
jinja_test_{{ package }}_latest:
  module_and_function: pkg.upgrade_available
  args:
    - {{ package }}
  assertion: assertFalse
{% endfor %}

validate_user_{{ base.cassandra_user }}:
  module_and_function: user.info
  assertion_section: shell
  args:
    - {{ base.cassandra_user }}
  assertion: assertEqual
  expected-return: /bin/bash

