{% set clustername = pillar['ClusterName'] %}
{% set packagename = pillar['packageName'] %}
{% set role = pillar['clusterrole'] %}
{% if salt['cmdb_lib3.isLoadBalanced']('CLIENT',packagename,role) %}
{% set dictdata = salt['cmdb_lib3.dictinfo'](clustername,packagename) %}
addlbmon:
  salt.runner:
    - name: state.orch
    - mods: cluster/addlbmonitor
    - pillar:
        role: {{ dictdata['clusterRole'] }}
        clusterversion: {{ dictdata['clusterVersion'] }}
        response: {{ dictdata['healthCheckResponse'] }}
        request: {{ dictdata['healthCheckRequest'] }}
        datacenter: {{ dictdata['datacenter'] }}
        environment: {{ dictdata['environment'] }}

addpatset:
  salt.runner:
    - name: state.orch
    - mods: cluster/addpatset
    - pillar:
        patset: {{ dictdata['patSetName'] }}
        datacenter: {{ dictdata['datacenter'] }}
        environment: {{ dictdata['environment'] }}

addlbvserver:
  salt.runner:
    - name: state.orch
    - mods: cluster/addlbvserver
    - pillar:
        cluster: {{ clustername }}
        port: {{ dictdata['serverPort'] }}
        persistence: {{ dictdata['persistence'] }}
        backupvs: {{ dictdata['lbMaintainanceServer'] }}
        lbmethod: {{ dictdata['loadDistMethod'] }}
        datacenter: {{ dictdata['datacenter'] }}
        environment: {{ dictdata['environment'] }}

{% if role == 'URW' %}
addservicegroup:
  salt.runner:
    - name: state.orch
    - mods: cluster/addsg
    - pillar:
        cluster: {{ clustername }}
        port: {{ dictdata['serverPort'] }}
        datacenter: {{ dictdata['datacenter'] }}
        environment: {{ dictdata['environment'] }}

setlbvsforurw:
  salt.runner:
    - name: state.orch
    - mods: cluster/setlbvserver
    - pillar:
        cluster: {{ clustername }}
        datacenter: {{ dictdata['datacenter'] }}
        environment: {{ dictdata['environment'] }}

{% else %}

addservicegroup:
  salt.runner:
    - name: state.orch
    - mods: cluster/addsg
    - pillar:
        cluster: {{ clustername }}
        port: {{ dictdata['serverPort'] }}
        datacenter: {{ dictdata['datacenter'] }}
        environment: {{ dictdata['environment'] }}

{% endif %}

addcspolicy:
  salt.runner:
    - name: state.orch
    - mods: cluster/addcspolicy
    - pillar:
        cluster: {{ clustername }}
        role: {{ role }}
        patset: {{ dictdata['patSetName'] }}
        datacenter: {{ dictdata['datacenter'] }}
        environment: {{ dictdata['environment'] }}

bindsgtolbvs:
  salt.runner:
    - name: state.orch
    - mods: cluster/bindlbvstosg
    - pillar:
        cluster: {{ clustername }}
        port: {{ dictdata['serverPort'] }}
        datacenter: {{ dictdata['datacenter'] }}
        environment: {{ dictdata['environment'] }}

bindsglbmon:
  salt.runner:
    - name: state.orch
    - mods: cluster/bindsgtomonitor
    - pillar:
        cluster: {{ clustername }}
        role: {{ dictdata['clusterRole'] }}
        clusterversion: {{ dictdata['clusterVersion'] }}
        port: {{ dictdata['serverPort'] }}
        datacenter: {{ dictdata['datacenter'] }}
        environment: {{ dictdata['environment'] }}

bindcsvslbvstopol:
  salt.runner:
    - name: state.orch
    - mods: cluster/bindcsvslbvstopolicy
    - pillar:
        cluster: {{ clustername }}
        role: {{ dictdata['clusterRole'] }}
        publiccsname: {{ dictdata['publicCsName'] }}
        clusternum: {{ dictdata['clusterNum'] }}
        port: {{ dictdata['serverPort'] }}
        datacenter: {{ dictdata['datacenter'] }}
        environment: {{ dictdata['environment'] }}

{% else %}

Validated:
  test.succeed_without_changes

{% endif %}
