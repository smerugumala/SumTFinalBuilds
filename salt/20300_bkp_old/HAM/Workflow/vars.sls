{% import "../../Common/redis/vars.sls" as base %}

#-------------------------------
{% set suite_version= salt['pillar.get']('VERSION', '') %}
{% set version= "20300" %}
{% set workflow = salt['pillar.get']('WORKFLOW', 'provision') %}
{% set cluster = salt['pillar.get']('CLUSTER', '') %}
{% set server = salt['pillar.get']('SERVER', '') %}

{% set role= "HAM" %}
{% set parentfolder = suite_version.split('-')[0]| regex_replace('\\.|\\-', '') %}
{% set workflow_folder= parentfolder +"/"+ role +"/Workflow" %}

{% if cluster!= '' %}

{% set assoccluster = salt['cmdbconnect.getassociatedcluster'](cluster) %}
{% set params =  "'', '" + cluster + "','" + assoccluster + "','" + workflow + "','" + role + "',''" %}
{% set query = "select [dbo].[GET_PS_INSTALL_PARAMETERS](" + params + ")" %}
{% set dict = salt['cmdbconnect.get_install_params'](query) %}
{% set dccservernodes = dict['DCC_REDIS_NODES']  %}
{% set dccredispwd = dict['DCC_REDIS_PWD']  %}
{% set dccport = dict['DCC_REDIS_PORT'] %}
{% set dcc_master = salt['common.getMaster'](dccservernodes) %}
{% set sccservernodes = dict['SCC_REDIS_NODES']  %}
{% set sccredispwd = dict['SCC_REDIS_PWD']  %}
{% set sccport = dict['SCC_REDIS_PORT'] %}
{% set scc_master = salt['common.getMaster'](sccservernodes) %}
{% set hamdccport = dict['HAM_DCC_SENTINEL_PORT'] %}
{% set hamsccport = dict['HAM_SCC_SENTINEL_PORT'] %}

{% endif %}
{% set dccuser = 'dccsentinel'%}
{% set sccuser = 'sccsentinel' %}

{% set sccdir = '/var/log/scc_sentinel','/etc/scc' %}
{% set dccdir = '/var/log/dcc_sentinel','/etc/dcc' %}

#Default Params
#-------------------------------
{% set redis_version = base.redis_version %}
{% set redis_full_version = base.redis_full_versio %}
{% set redis_download = base.redis_download %}
{% set redis_user = base.redis_user %}
{% set redis_group = base.redis_group %}
{% set redis_path = base.redis_path %}
{% set redis_dir  = base.redis_dir %}
{% set redis_download_file = base.redis_download_file %}
{% set redis_download_url = base.redis_download_url %}

{% set redis_install_as_service = base.redis_install_as_service %}
{% set redis_config_path = base.redis_config_path %}
{% set redis_install_path = base.redis_install_path %}

{% set redis_data_dir = base.redis_data_dir  %}
{% set redis_config_dir = base.redis_config_dir %}
{% set redis_scripts_dir = base.redis_scripts_dir %}
{% set redis_log_dir = base.redis_log_dir %}
{% set redis_service_file  = base.redis_service_file %}

