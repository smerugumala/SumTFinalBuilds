{% import "20300/UXD/Workflow/vars.sls" as base %}

validate_user_{{ base.defaultuser }}:
  module_and_function: user.info
  assertion_section: shell
  args:
    - {{ base.defaultuser }}
  assertion: assertEqual
  expected-return: /bin/bash
  
{% for package in ["libaio-devel", "net-tools"] %}

test_{{ package }}_latest:
  module_and_function: pkg.upgrade_available
  args:
    - {{ package }}
  assertion: assertFalse
{% endfor %}


{% for port in ["3306/tcp"] %}

check if {{ port }} is open:
  module_and_function: firewalld.list_ports
  args:
    - public
  assertion: assertIn
  expected-return: {{port}}
  output_details: True
  
{% endfor %}

check_mysql_running:
  module_and_function: service.status
  args:
   - mysql
  assertion: assertTrue
  
  
check_mysql_password:
  module_and_function: cmd.run
  args:
    - mysql -u {{ base.defaultuser }} -p{{ base.defaultuserpwd }}
  assertion: assertEqual
  expected-return: "mysql: [Warning] Using a password on the command line interface can be insecure."

