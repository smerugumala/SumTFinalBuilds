{% import "20300/UMD/Workflow/vars.sls" as base %}

check_service_running:
 module_and_function: service.status
 args:
  - mongod

 assertion: assertTrue

validate_user_{{ base.percona_user }}:
  module_and_function: user.info
  assertion_section: shell
  args:
    - {{ base.percona_user }}
  assertion: assertEqual
  expected-return: /bin/false
