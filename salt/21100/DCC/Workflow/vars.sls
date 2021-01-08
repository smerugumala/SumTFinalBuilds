{% import "../../Common/redis/vars.sls" as base %}

#-------------------------------
{% set suite_version= salt['pillar.get']('VERSION', '') %}
{% set version= "21100" %}
{% set workflow = salt['pillar.get']('WORKFLOW', 'provision') %}
{% set cluster = salt['pillar.get']('CLUSTER', '') %}
{% set server = salt['pillar.get']('SERVER', '') %}

{% set role= "DCC" %}

{% set parentfolder = suite_version.split('-')[0]| regex_replace('\\.|\\-', '') %}
{#% set parentfolder = salt['common.getshortversion'](suite_version) %#}
{% set workflow_folder= parentfolder +"/"+ role +"/Workflow" %}

{% if cluster!= '' %}
{% set redis_dir= base.redis_dir%}
{% set params =  "'', '" + cluster + "','','" + workflow + "','" + role + "',''" %}
{% set query = "select [dbo].[GET_PS_INSTALL_PARAMETERS](" + params + ")" %}
{#% set dict = salt['cmdbconnect.get_install_params'](query) %#}
{% set dict = salt['pillar.get']('Install_params') %}
{% set dccservernodes = dict['DCC_REDIS_NODES']  %}
{% set dccredispwd = dict['DCC_REDIS_PWD']  %}
{% set dccport = dict['DCC_REDIS_PORT'] %}
{% set dcc_master = dccservernodes.split(',')[0] %}
{% endif %}


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
