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
