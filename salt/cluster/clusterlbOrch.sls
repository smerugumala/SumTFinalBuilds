{% set clustername = pillar['ClusterName'] %}
{% set packagename = pillar['packageName'] %}
{% set role = pillar['clusterrole'] %}
{% if salt['cmdb_lib3.isLoadBalanced']('CLUSTER',packagename,role) %}
{% set dictdata = salt['cmdb_lib3.dictinfo'](clustername,packagename) %}
{% set subnet = salt['cmdb_lib3.ipSublist']('VIP',dictdata['datacenter'],dictdata['environment']) %}

{% set csip = salt['cmdb_lib3.getIP'](subnet,dictdata['datacenter']) %}
{% set zone = salt['cmdb_lib3.zoneForVIP'](dictdata['datacenter'],dictdata['environment']) %}

{% set dnsip = salt['cmdb_lib3.getDNS'](dictdata['datacenter']) %}

addlbmon:
  salt.runner:
    - name: state.orch
    - mods: cluster/addlbmonitor
    - pillar:
        role: {{ dictdata['clusterRole'] }}
        clusterversion: {{ dictdata['clusterVersion'] }}
        response: "{{ dictdata['healthCheckResponse'] }}"
        request: {{ dictdata['healthCheckRequest'] }}
        datacenter: {{ dictdata['datacenter'] }}
        environment: {{ dictdata['environment'] }}

addservicegroup:
  salt.runner:
    - name: state.orch
    - mods: cluster/addsg
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

addcsvserver:
  salt.runner:
    - name: state.orch
    - mods: cluster/addcsvserver
    - pillar:
        cluster: {{ clustername }}
        ip: {{ csip }}
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

bindcsvstopol:
  salt.runner:
    - name: state.orch
    - mods: cluster/bindcsvstopolicy
    - pillar:
        cluster: {{ clustername }}
        policy: {{ dictdata['httpsRedirect'] }}
        datacenter: {{ dictdata['datacenter'] }}
        environment: {{ dictdata['environment'] }}

bindcsvstolbvs:
  salt.runner:
    - name: state.orch
    - mods: cluster/bindlbvstocsvs
    - pillar:
        cluster: {{ clustername }}
        port: {{ dictdata['serverPort'] }}
        datacenter: {{ dictdata['datacenter'] }}
        environment: {{ dictdata['environment'] }}

bindcsvstocer:
  salt.runner:
    - name: state.orch
    - mods: cluster/bindcsvstocert
    - pillar:
        cluster: {{ clustername }}
        cert: {{ dictdata['certificate'] }}
        datacenter: {{ dictdata['datacenter'] }}
        environment: {{ dictdata['environment'] }}

setcsssl:
  salt.runner:
    - name: state.orch
    - mods: cluster/setsslvstosecure
    - pillar:
        cluster: {{ clustername }}
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

{% if role == 'URW' %}
bindlbvstosg:
  salt.runner:
    - name: state.orch
    - mods: cluster/bindlbvstosg
    - pillar:
        cluster: {{ clustername }}
        port: {{ dictdata['serverPort'] }}
        datacenter: {{ dictdata['datacenter'] }}
        environment: {{ dictdata['environment'] }}
{% endif %}

addserver:
  ddns.present:
    - name: {{ clustername }}
    - zone: {{ zone|lower }}
    - ttl: 36
    - data: {{ csip }}
    - nameserver: {{ dnsip }}
    - rdtype: A

{% else %}

Validated:
  test.succeed_without_changes
{% endif %}
