{% if salt['cmdb_lib3.ClusterServerExists'](pillar['ClusterName']) %}

{% import "./defaultValues.sls" as data %}

{% import "./buildClusterserverList.sls" as input %}

{% for i in range(0,input.ClusterServers|length) %}

{% set gateway = salt['cmdb_lib3.gateway'](input.iplist[i]["Port_Group"]) %}

{% set switch = salt['cmdb_lib3.getDVS_switch'](input.iplist[i]["Port_Group"]) %}

Create instance {{ input.ClusterServers[i] }}:
  salt.runner:
    - name: cloud.create
    - provider: vmware
    - clonefrom: {{ data.baseTemplate }}
    - instances:
      - {{ input.ClusterServers[i] }}
    - cluster: {{ data.esxCluster }}
    - memory: {{ data.vmSize[0] }}MB
    - num_cpus: {{ data.vmSize[1] }}
    - customization: True
    - datastore: {{ data.Datastore }}
    - devices:
        disk:
          Hard disk 1:
            size: 100
        network:
          Network adapter 1:
            switch_type: distributed
            dvs_switch: {{ switch }}
            name: {{ input.iplist[i]["Port_Group"] }}
            ip: {{ input.iplist[i]["ipaddress"] }}
            gateway: {{ gateway }}
            subnet_mask: 255.255.255.0
            domain: {{ data.Domain }}
    - domain: {{ data.Domain }}
    - dns_servers:
      - {{ data.Nameservers[0] }}
      - {{ data.Nameservers[1] }}
    - folder: inf/Salt Templates
    - power_on: True
    - tmp_dir: /var
    - ssh_username: {{ salt['pillar.get']('domainuser') }}
    - password: {{ data.domainpasswd }}
    - sudo_password: {{ data.domainpasswd }}
    - script_args: -l -r -R {{ data.repoServer }}
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

Add VM to CMDB {{ input.ClusterServers[i] }}:
  salt.runner:
    - name: state.orch
    - mods: cluster/addvmCMDB
    - pillar:
        server: {{ input.ClusterServers[i] }}
        clusterrole: {{ salt['pillar.get']('clusterrole') }}
        environment: {{ salt['pillar.get']('environment') }}
        ClusterName: {{ salt['pillar.get']('ClusterName') }}

{% endfor %}
{% else %}

Validated:
  test.succeed_without_changes

{% endif %}
