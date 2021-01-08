check_mysql_running:
 module_and_function: service.status
 args:
  - mysql

 assertion: assertTrue

