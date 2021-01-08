set up MS repo:
  pkgrepo.managed:
    - name: packages-microsoft-com-prod
    - baseurl: https://packages.microsoft.com/rhel/7/prod/
    - gpgkey: https://packages.microsoft.com/keys/microsoft.asc
    - gpgcheck: 1

delete potential conflicting packages:
  pkg.removed:
    - pkg_verify: True
    - resolve_capabilities: True
    - pkgs:
      - unixODBC-utf16
      - unixODBC-utf16-devel

install packages:
  pkg.installed:
    - pkg_verify: True
    - resolve_capabilities: True
    - pkgs: #required for python
      - unixODBC-devel
      - python-devel
      - epel-release
      - gcc-c++
# required for rabbitmq
      - policycoreutils-python

install selinux tools:
  pkg.installed:
    - pkgs: #required for python
      - selinux-policy-targeted

install java and MS tools:
  cmd.run:
    - names: 
      - hostname -f
      - yum install vim -y
      - yum install python2-pip python-setuptools -y
      - ACCEPT_EULA=Y yum install -y mssql-tools
      - ACCEPT_EULA=Y yum install msodbcsql -y
      - export PATH="$PATH:/opt/mssql-tools/bin" >> ~/.bash_profile
      - export PATH="$PATH:/opt/mssql-tools/bin" >> ~/.bashrc
      - source ~/.bashrc

install pip tools:
   pip.installed:
     - names:
       - pymssql
       - pycryptodome
       - pyodbc
       - cryptography
       - pymongo

install firewalld package:
  pkg.installed:
    - pkg_verify: True
    - resolve_capabilities: True
    - pkgs:
      - firewalld

firewalld:
  service.running:
    - enable: true

startservice:
  service.running:
    - name: firewalld

