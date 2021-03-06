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
    - pkg_verify: False
    - resolve_capabilities: True
    - pkgs: #required for python
      - unixODBC-devel
      - python-devel
      - epel-release
      - gcc-c++
      - MySQL-python
      - centos-release-scl
      - tcl
      - wget
      - make 
      - bzip2 
      - perl 
      - kernel-headers 
      - kernel-devel


#enable gcc:
#  file.managed:
#    - name: '/etc/profile.d/enablegcc.sh'
#    - source: salt://21100/Common/redis/Templates/enablegcc.sh

install java and MS tools:
  cmd.run:
    - reload_modules: true
    - name: |
        yum install python2-pip python-setuptools devtoolset-7 dkms -y
        ACCEPT_EULA=Y yum install -y mssql-tools
        pip3 install pymysql
        pip3 install pycryptodome
        pip3 install cryptography
        ACCEPT_EULA=Y yum install msodbcsql -y
        export PATH="$PATH:/opt/mssql-tools/bin" >> ~/.bash_profile
        export PATH="$PATH:/opt/mssql-tools/bin" >> ~/.bashrc
        source ~/.bashrc


install pip tools:
   pip.installed:
     - names:
       - pymssql
       - pycryptodome
