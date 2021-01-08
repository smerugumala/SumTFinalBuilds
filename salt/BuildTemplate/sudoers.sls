/etc/sudoers:
  file.append:
    - source: salt://files/sudoers.jinja
    - template: jinja
