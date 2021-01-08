check_webhooks_service_running:
 module_and_function: service.status
 args:
  - webhooks

 assertion: assertTrue

check_cdc_service_running:
 module_and_function: service.status
 args:
  - cdc

 assertion: assertTrue

check_eventgenerator_service_running:
 module_and_function: service.status
 args:
  - eventgenerator

 assertion: assertTrue

check_useractionhistory_service_running:
 module_and_function: service.status
 args:
  - useractionhistory

 assertion: assertTrue

check_udac_service_running:
 module_and_function: service.status
 args:
  - udac

 assertion: assertTrue

 
{% for package in ["java-1.8.0", "kernel-devel"] %}
jinja_test_{{ package }}_latest:
  module_and_function: pkg.upgrade_available
  args:
    - {{ package }}
  assertion: assertFalse
{% endfor %}

{% set user = 'vagrant'}
validate_user_{{ usr }}:
  module_and_function: user.info
  assertion_section: shell
  args:
    - {{ usr }}
  assertion: assertEqual
  expected-return: /bin/bash
  
  
ensure_correct_file:
  module_and_function: file.contains
  args:
    - {{ base.udac_appsettings_file }}
    - ':2000'
  assertion: assertTrue

