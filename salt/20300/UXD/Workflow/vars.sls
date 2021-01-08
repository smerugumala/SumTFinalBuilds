#-------------------------------
{% set suite_version= salt['pillar.get']('VERSION', '') %}
{% set version= "20300" %}
{% set workflow = salt['pillar.get']('WORKFLOW', 'provision') %}
{% set cluster = salt['pillar.get']('CLUSTER', '') %}


{% set server = salt['pillar.get']('SERVER', '') %}
{% set role= "UXD" %}
{% set percona_version= "57" %}
{% set parentfolder = suite_version.split('-')[0]| regex_replace('\\.|\\-', '') %}
{% set defaultuser = "root"%}
{% set defaultuserpwd = "SumT@M15#" %}
{% set workflow_folder= parentfolder +"/"+ role +"/Workflow" %}

{% if cluster!= '' %}

{% set params =  "'', '" + cluster + "','','" + workflow + "','" + role + "',''" %}
{% set query = "select [dbo].[GET_PS_INSTALL_PARAMETERS](" + params + ")" %}
{% set dict = salt['cmdbconnect.get_install_params'](query) %}
{% set uxdadminuser = dict['UXD_ADMIN_USER']  %}
{% set uxdadminpwd = dict['UXD_ADMIN_PASSWORD']  %}
{% set uxdport = dict['UXD_DB_PORT'] %}

{% endif %}



#Default Params
#-------------------------------




{% set percona_user = "mysql" %}
{% set percona_group = "mysql" %}

#DataCenter/Tier params
#--------------------------------



#Cluster Params
#--------------------------------



#Tenant Params
#---------------------------------



#Other/Internal Params
#---------------------------------
