check_sentinel_scc_service_running:
 module_and_function: service.status
 args:
  - sentinel_scc

 assertion: assertTrue
 
 
check_sentinel_dcc_service_running:
 module_and_function: service.status
 args:
  - sentinel_dcc

 assertion: assertTrue

