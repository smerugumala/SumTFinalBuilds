
{% set adminpasswd = salt['pillar.get']('adminpasswd') %}

{% set user = salt['pillar.get']('user') %}

{% set genPasscode = salt['shadow.gen_password'](adminpasswd) %}

{#% set replace = salt['shadow.set_password'](user,genPasscode) %#}


Set system password:
  module.run:
    - name: shadow.set_password
    - m_name: {{ user }}
    - password: {{ genPasscode }}


