
{% set Nameservers = salt['cmdb_lib3.getNameservers'](pillar['datacenter']) %}

{% set passwd = salt['cmdb_lib3.getPassword'](salt['pillar.get']('user')) %}

{% set Domain = salt['cmdb_lib3.domain'](pillar['datacenter']) %}

{% set domainpasswd = salt['cmdb_lib3.getPassword'](salt['pillar.get']('domainuser')) %}

{% set repoServer = salt['cmdb_lib3.getRepoServer'](salt['pillar.get']('datacenter')) %}

{% for role in pillar['clusterroles'] %}

{% set Roleversion = salt['cmdb_lib3.getRoleversion'](pillar['packageName'],role) %}

{% set esxCluster = salt['cmdb_lib3.getesxClusterName'](pillar['datacenter'],pillar['environment'],role) %}

{% set Datastore = salt['cmdb_lib3.getDatastore'](pillar['datacenter'],pillar['environment'],role,pillar['packageName'],esxCluster) %}

{% set Networks = salt['cmdb_lib3.ipSublist'](role,pillar['datacenter'],pillar['environment']) %}

{% set baseTemplate = salt['cmdb_lib3.getBaseTemplate'](pillar['datacenter'],role,pillar['packageName']) %}

{% set vmSize = salt['cmdb_lib3.getMemory'](pillar['packageName'],role) %}

{% set retriveIP = salt['cmdb_lib3.getIP'](Networks,pillar['datacenter']) %}

{% set gateway = salt['cmdb_lib3.gateway'](retriveIP["Port_Group"]) %}

{% set switch = salt['cmdb_lib3.getDVS_switch'](retriveIP["Port_Group"]) %}

{% set suiteversion = pillar['packageName'].split('-')[0]| regex_replace('\\.|\\-', '') %}

{% set shortversion = pillar['packageName'] | regex_replace('\\.|\\-', '') %}

{% set instance = ['SALT1-',shortversion,'-',Roleversion,'-',role] | join %}

{% set ReserveIP = salt['cmdb_lib3.SetStatus'](retriveIP["ipaddress"]) %}


Create instance {{ instance }}:
  salt.runner:
    - name: cloud.create
    - provider: vmware
    - clonefrom: {{ baseTemplate }}
    - instances:
      - {{ instance }}
    - cluster: {{ esxCluster }}
    - memory: {{ vmSize[0] }}MB
    - num_cpus: {{ vmSize[1] }}
    - customization: True
    - devices:
        disk:
          Hard disk 1:
            size: 100
        network:
          Network adapter 1:
            switch_type: distributed
            dvs_switch: {{ switch }}
            name: {{ retriveIP["Port_Group"] }}
            ip: {{ retriveIP["ipaddress"]  }}
            gateway: {{ gateway }}
            subnet_mask: 255.255.255.0
            domain: {{ Domain }}
    - domain: {{ Domain }}
    - dns_servers:
      - {{ Nameservers[0] }}
      - {{ Nameservers[1] }}
    - folder: inf/Salt Templates
    - power_on: True
    - tmp_dir: /var
    - ssh_username: {{ salt['pillar.get']('domainuser') }}
    - password: {{ domainpasswd }}
    - sudo_password: {{ domainpasswd }}
    - script_args: -l -r -R {{ repoServer }}
    - plain_text: True
    - deploy: True
    - minion:
        master:
          - ldcsaltmas003
          - ldcsaltmas004
    - retry:
        attempts: 3
        until: True
        interval: 60
        splay: 10

Run Base Setup {{ instance }}:
  salt.runner:
    - name: state.orch
    - mods: BuildTemplate/baseTemplateSetupOrch
    - pillar:
        datacenter: {{ pillar['datacenter'] }}
        instance: {{ instance }}
        Port_Group: {{ retriveIP["Port_Group"] }}

Update patches {{ role }}:
  salt.state:
    - sls:
      - BuildTemplate/patches
    - tgt: {{ instance }}
    - retry:
        attempts: 3
        until: True
        interval: 60
        splay: 10

Install_Packages {{ role }}:
  salt.state:
    - sls:
      - BuildTemplate/Install_utils
    - tgt: {{ instance }}
    - retry:
        attempts: 3
        until: True
        interval: 60
        splay: 10

Node_exporter {{ role }}:
  salt.state:
    - sls:
      - BuildTemplate/Install_nodeExporter
    - tgt: {{ instance }}
    - retry:
        attempts: 3
        until: True
        interval: 60
        splay: 10

Sudo access {{ instance }}:
  salt.state:
    - sls:
      - BuildTemplate/sudoers
    - tgt: {{ instance }}
    - pillar: 
        datacenter: {{ pillar['datacenter'] }}
        role: {{ role }}

Install ESET {{ role }}:
  salt.runner:
    - name: state.orch
    - mods: BuildTemplate/Install_esetOrch
    - pillar:
        instance: {{ instance }}
        datacenter: {{ pillar['datacenter'] }}
    - retry:
        attempts: 3
        until: True
        interval: 60
        splay: 10

Install Role Prerequisites {{ instance }}:
  salt.runner:
    - name: state.orch
    - mods: {{ suiteversion }}/{{ role }}/Workflow/orch
    - pillar:
        VERSION: {{ pillar['packageName'] }}
        WORKFLOW: "PROVISION"
        SERVER: {{ instance }}
    - retry:
        attempts: 3
        until: True
        interval: 60
        splay: 10


Configure Role Exporter {{ instance }}:
  salt.runner:
    - name: state.orch
    - mods: BuildTemplate/roleExporterOrch
    - pillar:
        role: {{ role }}
        repoServer: {{ repoServer }}
        instance: {{ instance }}
    - retry:
        attempts: 3
        until: True
        interval: 60
        splay: 10
    - require:
      - salt: Install Role Prerequisites {{ instance }}

Wait to apply {{ instance }}:
  salt.runner:
    - name: test.sleep
    - s_time: 30

Apply SecOps policies {{ instance }}:
  salt.runner:
    - name: state.orch
    - mods: BuildTemplate/newstatesecops
    - pillar:
        name: {{ instance }}
        packageName: {{ pillar['packageName'] }}
        role: {{ role }}
        Roleversion: {{ Roleversion }}
    - require:
      - salt: Configure Role Exporter {{ instance }}

Wait to apply SecOps policies {{ instance }}:
  salt.runner:
    - name: test.sleep
    - s_time: 300

reboot_minion {{ instance }}:
  salt.function:
    - name: system.reboot
    - tgt: {{ instance }}
    - check_cmd:
      - /bin/true

Wait for reboot {{ instance }}:
  salt.runner:
    - name: test.sleep
    - s_time: 80

Re-apply SecOps policies {{ instance }}:
  salt.runner:
    - name: state.orch
    - mods: BuildTemplate/sec_reAssess
    - pillar:
        policy_name: {{ instance }}
    - require:
      - salt: reboot_minion {{ instance }}

Wait to re-apply SecOps policies {{ instance }}:
  salt.runner:
    - name: test.sleep
    - s_time: 300

Leave domain {{ instance }}:
  salt.runner:
    - name: state.orch
    - mods: BuildTemplate/LeaveDomainOrch
    - pillar:
        datacenter: {{ pillar['datacenter'] }}
        instance: {{ instance }}

Remove Minion Configuration {{ instance }}:
  salt.runner:
    - name: state.orch
    - mods: BuildTemplate/removeminion
    - pillar:
        instance: {{ instance }}
    - require:
      - salt: Leave domain {{ instance }}

Shutdown Template VM {{ instance }}:
  salt.runner:
    - name: cloud.action
    - func: stop
    - instance: {{ instance }}
    - require:
      - salt: Remove Minion Configuration {{ instance }}

Convert to template {{ instance }}:
  salt.runner:
    - name: cloud.action
    - func: convert_to_template
    - instance: {{ instance }}
    - require:
      - salt: Shutdown Template VM {{ instance }}

{% endfor %}
