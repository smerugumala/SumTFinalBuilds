Add Clusters to CMDB:
  salt.runner:
    - name: state.orch
    - mods: cluster/addClustertoCMDB
    - pillar: {{ pillar | json }}

Provision Cluster Servers:
  salt.runner:
    - name: state.orch
    - mods: cluster/ProvisionOrch1
    - pillar: {{ pillar | json }}

Create DNS record:
  salt.runner:
    - name: state.orch
    - mods: cluster/addDNSrecordOrch
    - pillar: {{ pillar | json }}

Join Domain:
  salt.runner:
    - name: state.orch
    - mods: cluster/DomainOrch2
    - pillar: {{ pillar | json }}

Set Admin Password:
  salt.runner:
    - name: state.orch
    - mods: cluster/ChangepasswdOrch3
    - pillar: {{ pillar | json }}

Create Service Account:
  salt.runner:
    - name: state.orch
    - mods: cluster/addResourceOrch4
    - pillar: {{ pillar | json }}

Configure NTP:
  salt.runner:
    - name: state.orch
    - mods: cluster/ConfigureNTPOrch5
    - pillar: {{ pillar | json }}

Configure Syslog:
  salt.runner:
    - name: state.orch
    - mods: cluster/ConfigureSysLogOrch
    - pillar: {{ pillar | json }}

Install and Configure Splunk:
  salt.runner:
    - name: state.orch
    - mods: cluster/InstallSplunkOrch6
    - pillar: {{ pillar | json }}

Cluster LB Configuration:
  salt.runner:
    - name: state.orch
    - mods: cluster/clusterlbOrch
    - pillar: {{ pillar | json }}

Cluster Client LB Configuration:
  salt.runner:
    - name: state.orch
    - mods: cluster/clientlbOrch
    - pillar: {{ pillar | json }}

Add server to LoadBalancer:
  salt.runner:
    - name: state.orch
    - mods: cluster/addservertolbOrch
    - pillar: {{ pillar | json }}

Add servers to prometheus:
  salt.runner:
    - name: state.orch
    - mods: cluster/prometheusOrch
    - pillar: {{ pillar | json }}

Add Config Key to CMDB:
  salt.runner:
    - name: state.orch
    - mods: cluster/addConfigKeys
    - pillar: {{ pillar | json }}

Post Build Configuration:
  salt.runner:
    - name: state.orch
    - mods: cluster/ConfigureRole
    - pillar: {{ pillar | json }}
