#-------------------------------
{% set suite_version= salt['pillar.get']('VERSION', '') %}
{% set version= "21100" %}
{% set workflow = salt['pillar.get']('WORKFLOW', 'provision') %}
{% set cluster = salt['pillar.get']('CLUSTER', '') %}


{% set server = salt['pillar.get']('SERVER', '') %}
{% set role= "UXD" %}
{% set percona_version= "57" %}
{% set libaio_rpm_url= "http://mirror.centos.org/centos/7/os/x86_64/Packages/libaio-devel-0.3.109-13.el7.x86_64.rpm" %}
{% set nettools_rpm_url= "http://mirror.centos.org/centos/7/os/x86_64/Packages/net-tools-2.0-0.25.20131004git.el7.x86_64.rpm" %}
{% set percona_downloadurl= "https://www.percona.com/downloads/Percona-Server-5.7/Percona-Server-5.7.23-25/binary/redhat/7/x86_64/Percona-Server-5.7.23-25-r7e2732e-el7-x86_64-bundle.tar" %}

{% set parentfolder = suite_version.split('-')[0]| regex_replace('\\.|\\-', '') %}

{% set defaultuser = "root"%}
{% set defaultuserpwd = "SumT@M15#" %}
{% set workflow_folder= parentfolder +"/"+ role +"/Workflow" %}

{% if cluster!= '' %}

{#% set params =  "'', '" + cluster + "','','" + workflow + "','" + role + "',''" %#}
{#% set query = "select [dbo].[GET_PS_INSTALL_PARAMETERS](" + params + ")" %#}
{#% set dict = salt['cmdbconnect.get_install_params'](query) %#}
{% set dict = salt['pillar.get']('Install_params') %}
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

