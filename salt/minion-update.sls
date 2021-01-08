{% if 'CentOS Linux-7' in grains['osfinger'] %}
{% if 'mas' not in grains['host'] %}
Setup new repo:
  pkgrepo.managed:
    - name: saltstack
    - humanname: saltstack
    - baseurl: http://ldcsaltrep001/py3/redhat/7
    - gpgcheck: 1
    - gpgkey: http://ldcsaltrep001/py3/redhat/7/x86_64/latest/SALTSTACK-GPG-KEY.pub
    - enabled: 1


Upgrade Salt-Minion:
  cmd.run:
    - name: |
        exec 0>&- # close stdin
        exec 1>&- # close stdout
        exec 2>&- # close stderr
        nohup /bin/sh -c 'salt-call --local pkg.install salt-minion && salt-call --local service.restart salt-minion' &
    - onlyif: "[[ $(salt-call --local pkg.upgrade_available salt-minion 2>&1) == *'True'* ]]"
{% endif %}
{% endif %}

{% if 'CentOS Linux-8' in grains['osfinger'] %}
Setup new repo:
  pkgrepo.managed:
    - name: saltstack
    - humanname: saltstack
    - baseurl: http://ldcsaltrep001/py3/redhat/8
    - gpgcheck: 1
    - gpgkey: http://ldcsaltrep001/py3/redhat/8/x86_64/latest/SALTSTACK-GPG-KEY.pub
    - enabled: 1


Upgrade Salt-Minion:
  cmd.run:
    - name: |
        exec 0>&- # close stdin
        exec 1>&- # close stdout
        exec 2>&- # close stderr
        nohup /bin/sh -c 'salt-call --local pkg.install salt-minion && salt-call --local service.restart salt-minion' &
    - onlyif: "[[ $(salt-call --local pkg.upgrade_available salt-minion 2>&1) == *'True'* ]]"
{% endif %}