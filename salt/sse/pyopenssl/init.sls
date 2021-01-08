install_pyopenssl:
  pkg.installed:
    - sources:
      - python2-pyasn1: salt://{{ slspath }}/files/python2-pyasn1-0.1.9-7.el7.noarch.rpm
      - python-enum34: salt://{{ slspath }}/files/python-enum34-1.0.4-1.el7.noarch.rpm
      - python-ply: salt://{{ slspath }}/files/python-ply-3.4-11.el7.noarch.rpm
      - python-pycparser: salt://{{ slspath }}/files/python-pycparser-2.14-1.el7.noarch.rpm
      - python-cffi: salt://{{ slspath }}/files/python-cffi-1.6.0-5.el7.x86_64.rpm
      - python-idna: salt://{{ slspath }}/files/python-idna-2.4-1.el7.noarch.rpm
      - python2-cryptography: salt://{{ slspath }}/files/python2-cryptography-1.7.2-2.el7.x86_64.rpm
      - pyOpenSSL: salt://{{ slspath }}/files/pyOpenSSL-0.15.1-1.el7.noarch.rpm
