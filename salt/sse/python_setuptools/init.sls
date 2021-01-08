install_python_setuptools:
  pkg.installed:
    - sources:
      - python-setuptools: salt://{{ slspath }}/files/python-setuptools-0.9.8-7.el7.noarch.rpm
      - python2-pip: salt://{{ slspath }}/files/python2-pip-8.1.2-10.el7.noarch.rpm
