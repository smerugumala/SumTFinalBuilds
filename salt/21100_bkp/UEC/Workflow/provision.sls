{% import "./vars.sls" as base %}
{% set patch_path = '/tmp/' + base.release_version + '/Patches/' %}
{% set patch_list = salt['file.find'](patch_path, type= 'f', print= 'name') %}
{% set mylist= [] %}
{% set newlist= [] %}


create a user:
  user.present:
    - name: {{base.user}}

Create group:
  group.present:
    - name: {{ base.group}}
    - system: True
    - addusers:
      - {{base.user}}
    - require:
      - user: create a user

make packageroot directory:
  file.directory:
    - name: {{base.package_root}}/{{base.suite_version}}
    - dir_mode: 755
    - file_mode: 755
    - user: {{base.user}}
    - group: {{base.group}}
    - recurse:
      - mode
      - user
      - group

make log directory:
  file.directory:
    - name: {{base.logdir}}
    - dir_mode: 755
    - file_mode: 755
    - user: {{base.user}}
    - group: {{base.group}}
    - recurse:
      - mode
      - user
      - group

extract main install folder to {{base.suite_version}} package root:
  archive.extracted:
    - source: /tmp/UEC.zip
    - skip_verify: true
    - name: {{base.package_root}}/{{base.suite_version}}
    - archive_format: zip
    - enforce_toplevel: True
    - user: {{base.user}}
    - group: {{base.group}}
