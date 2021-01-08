{% import "./vars.sls" as base %}
{% set patch_set = salt['file.find']( base.patch_folder, type='d', print= 'name', maxdepth=1, mindepth=1) %}
{% set install_list= [] %}


ensure installation directory exists:
  file.directory:
    - name: {{base.package_root}}

#Create directoriess, copy in directories and service files for release version 
{% for service in base.services %}

#Create service directory
ensure {{service}} directory exists:
  file.directory:
    - name: {{ base.services[service]['destination'] }}
    - makedirs: True

#Copy in service file
ensure_copy_{{service}}_service_file:
  file.managed:
    - name: {{ base.services[service]['servicefile'] }}
    - source: {{base.template_directory}}/{{ base.services[service]['template'] }}
    - source: salt://{{base.templates_folder}}/{{ base.services[service]['template'] }}
    - template: jinja
    - user: {{ base.user }}
    - group: {{ base.group }}
    - start: {{ base.install_root }}
    - work_location: {{base.install_root}}



{% endfor %}


{% for service in base.services %}

Copy {{service}} directory for main:
  cmd.run:
    - name: cp {{base.package_root}}/{{base.release_version}}/{{ base.services[service]['directory'] }}/* {{base.install_root}}/{{service}}


{% endfor %}



Load in new service files:
  cmd.run:
   - name: systemctl --system daemon-reload

#Add release version to installed list
{% do install_list.append(base.release_version) %}

#Loop through patches

{% for patch in patch_set %}

#set a variable to hold the path to this patch's  manifest file
{% set varpath = base.patch_folder + patch + '/PATCH_MANIFEST.XML' %}

#only proceed if manifest has UEC changes
{% if salt['file.search']( varpath, 'UEC') == True %}

{% do install_list.append(patch) %}

extract UEC zip for {{patch}}:
  archive.extracted:
    - name: {{base.patch_folder}}{{patch}}/
    - source: {{base.patch_folder}}/{{patch}}/UEC.zip
    - enforce_toplevel: False

{% for service in base.services %}
make {{service}} directory for {{patch}} run:
  file.directory:
    - name: {{ base.services[service]['destination'] }}

copy {{service}} servicefile for {{patch}}:
  file.managed:
    - name: {{ base.services[service]['servicefile'] }}
    - source: {{base.template_directory}}/{{ base.services[service]['template'] }}
    - template: jinja
    - user: {{ base.user }}
    - group: {{ base.group }}
    - start: {{ base.install_root }}
    - work_location: {{ base.install_root }}

copy {{service}} directory for {{patch}}:
  cmd.run:
    - name: cp {{base.package_root}}/{{base.release_version}}/{{ base.services[service]['directory'] }}/* {{base.install_root}}/{{service}}


{% endfor %}
{% endif %}
{% endfor %}

reload systemd after patches were copied run:
  cmd.run:
    - name: systemctl --system daemon-reload


ensure suite dir has correct permissions:
  file.directory:
    - name: {{base.install_root}}
    - user: {{base.user}}
    - group: {{base.group}}
    - dir_mode: 0777
    - file_mode: 0777
    - recurse:
      - user
      - group
      - mode

update {{base.udac_appsettings_location}}:
  file.replace:
    - name: {{base.udac_appsettings_location}}
    - pattern: ^.*("DefaultConnection":)
    - repl: '		"DefaultConnection": "Data Souce = ; Initial Catalog={{base.udac_db_name}}; User ID={{base.udac_db_user}};Password={{base.udac_db_password}}"'

update {{base.webhook_appsettings_location}}:
  file.replace:
    - name: {{base.webhook_appsettings_location}}
    - pattern: '^.*"BrokerNodes.*'
    - repl: '    "BrokerNodes": "{{base.uka_server_nodes}}",'

update schema nodes in{{base.webhook_appsettings_location}}:
  file.replace:
    - name: {{base.webhook_appsettings_location}}
    - pattern: '^.*"SchemaRegistryNodes.*'
    - repl: '    "SchemaRegistryNodes": "{{ base.replace[0] }}:8081,{{ base.replace[1] }}:8081,{{ base.replace[2] }}:8081",'

write installed version to file:
  file.managed:
    - name: {{ base.install_root}}/version.xml
    - source: salt://{{base.templates_folder}}/{{base.versionfile}}
    - template: jinja
    - target: {{install_list|last}}


{% for service in base.services %}
enable {{service}}:
  service.enabled:
    - name: {{service}}

start {{service}}:
  service.running:
    - name: {{service}}

{% endfor %}

