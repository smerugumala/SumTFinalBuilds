
Add Config Keys into CMDB:
  module.run:
    - name: cmdb_lib3.{{ salt['pillar.get']('clusterrole') }}_CONFIGKEYS
    - ClusterName: {{ salt['pillar.get']('ClusterName') }}
    - retry:
        attempts: 3
        until: True
        interval: 60
        splay: 10

