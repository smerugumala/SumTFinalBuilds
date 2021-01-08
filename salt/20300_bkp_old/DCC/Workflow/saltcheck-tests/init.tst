check_service_running:
 module_and_function: service.status
 args:
  - redis

 assertion: assertTrue
