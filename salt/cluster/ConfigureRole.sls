
{% if salt['pillar.get']('associateClusterName') != '' %}

{% set assoccluster = salt['cmdb_lib3.getassociatedcluster'](salt['pillar.get']('ClusterName')) %}

{% set params = "'', '" + pillar['ClusterName'] + "','" + assoccluster + "','" + pillar['Workflow'] + "','" + pillar['clusterrole'] + "',''" %}

{% else %}

{% set params =  "'', '" + pillar['ClusterName'] + "','','" + pillar['Workflow'] + "','" + pillar['clusterrole'] + "',''" %}

{% endif %}

{% set query = "select [dbo].[GET_PS_INSTALL_PARAMETERS](" + params + ")" %}

{% set Install_params = salt['cmdb_lib3.get_install_params'](query) %}

{% set suiteversion = pillar['packageName'].split('-')[0]| regex_replace('\\.|\\-', '') %}

{% set repoServer = salt['cmdb_lib3.getRepoServer'](salt['pillar.get']('datacenter')) %}

{% set clusterservers = salt['cmdb_lib3.getClusterServerList'](pillar['ClusterName']) %}

{% set VMdata = salt['cmdb_lib3.getVMdata'](pillar['ClusterName']) %}

Post Role Configuration:
  salt.runner:
    - name: state.orch
    - mods: {{ suiteversion }}/{{ pillar['clusterrole'] }}/Workflow/orch
    - pillar:
        VERSION: {{ pillar['packageName'] }}
        WORKFLOW: {{ pillar['Workflow'] }}
        CLUSTER: {{ pillar['ClusterName'] }}
        Install_params: {{ Install_params }}
        repoServer: {{ repoServer }}
        clusterservers: {{ clusterservers }}
        VMdata: {{ VMdata }}
