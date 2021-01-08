#Workflow Params
#-------------------------------
{% set suite_version= "21.1.0.0" %}
{% set version= "21100" %}
{% set workflow = salt['pillar.get']('WORKFLOW', 'provision') %}
{% set cluster = salt['pillar.get']('CLUSTER', '') %}
{% set server = salt['pillar.get']('SERVER', '') %}





#Default Params
#-------------------------------

{% set role= "UMD" %}
{% set percona_server_version= "4.0" %}
{% set percona_rpm= 'https://repo.percona.com/yum/percona-release-latest.noarch.rpm' %}

{% set parentfolder = suite_version.split('-')[0]| regex_replace('\\.|\\-', '') %}
{#% set parentfolder = salt['common.getshortversion'](suite_version) %#}
{% set workflow_folder= parentfolder +"/"+ role +"/Workflow" %}

{% if cluster!= '' %}
{% set params =  "'', '" + cluster + "','','" + workflow + "','" + role + "',''" %}
{% set query = "select [dbo].[GET_PS_INSTALL_PARAMETERS](" + params + ")" %}
{% set dict = salt['pillar.get']('Install_params') %}
{#% set dict = salt['cmdbconnect.get_install_params'](query) %#}
{% set umd_user = dict['UMD_ADMIN_USER']  %}
{% set umd_password = dict['UMD_ADMIN_PASSWORD']  %}
{% set umd_port = dict['UMD_DB_PORT'] %}

{% endif %}

#DataCenter/Tier params
#--------------------------------



#Cluster Params
#--------------------------------



#Tenant Params
#---------------------------------



#Other/Internal Params
#---------------------------------
{% set percona_config_path=  '/etc/mongod.conf' %}
{% set percona_rpm_version = '3.4.17-2.15.el7.x86_64.rpm' %}
{% set percona_archive_url = 'https://www.percona.com/downloads/percona-server-mongodb-3.4/percona-server-mongodb-3.4.17-2.15/binary/redhat/7/x86_64/percona-server-mongodb-3.4.17-2.15-r6edc441-el7-x86_64-bundle.tar' %}
{% set percona_tmp_path = '/tmp/Percona-Server-MongoDB' %}

#Prerequsite Packages
#----------------------
{% set openssl_rpm = 'http://mirror.centos.org/centos/7/os/x86_64/Packages/openssl-1.0.2k-21.el7_9.x86_64' %}
{% set byobu_rpm = 'https://download-ib01.fedoraproject.org/pub/epel/7/x86_64/Packages/b/byobu-5.73-4.el7.noarch.rpm' %}
{% set tmux_rpm =  'http://mirror.centos.org/centos/7/os/x86_64/Packages/tmux-1.8-4.el7.x86_64.rpm' %}
{% set screen_rpm = 'http://mirror.centos.org/centos/7/os/x86_64/Packages/screen-4.1.0-0.26.20120314git3c2946.el7.x86_64.rpm' %}
{% set openssllib_rpm = 'http://mirror.centos.org/centos/7/os/x86_64/Packages/openssl-libs-1.0.2k-19.el7.x86_64.rpm' %}
{#% set openssllib_rpm = 'http://ldcsaltrep001.cotestdev.local/common/openssl-libs-1.0.2k-19.el7.x86_64.rpm' %#}

