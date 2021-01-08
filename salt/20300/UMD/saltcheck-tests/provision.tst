check_mongo_service_running:
 module_and_function: service.status
 args:
  - mongod

 assertion: assertTrue
check_authentication_enabled:
 module_and_function: file.search
 args:
  - /etc/mongod.conf
  - 'security:'
 assertion: assertTrue
 output_details: True
check_port_is_open:
 module_and_function: firewalld.list_ports
 args:
  - public
 assertion: assertIn
 expected_return: 27017/tcp
