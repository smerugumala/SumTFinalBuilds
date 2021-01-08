
{% set udaPackage = salt['pillar.get']('packageName') %}

{% set Cluster = pillar['ClusterName'] %}

{% set podClusterCode = salt['pillar.get']('podClusterCode', 'null') %}

{% set IS_DEDICATED = salt['pillar.get']('IS_DEDICATED', '0') %}

{% set IS_VALIDATED = salt['pillar.get']('IS_VALIDATED', 'none') %}

{% set associateClusterName = salt['pillar.get']('associateClusterName', '') %}


Add Cluster Information in CMDB:
  module.run:
    - name: cmdb_lib3.addClusterinfo
    - clusterName: {{ Cluster }}
    - associateClusterName: "{{ associateClusterName }}"
    - isDedicated: "{{ IS_DEDICATED }}"
    - isValidated: "{{ IS_VALIDATED }}"
    - podClusterCode: "{{ podClusterCode }}"
    - udaPackage: {{ udaPackage }}
