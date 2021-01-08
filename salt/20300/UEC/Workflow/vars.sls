#template-required variables
{% set user = "uecserviceuser" %}
{% set group = "uecserviceuser" %}


#-------------------------------
{% set suite_version= salt['pillar.get']('VERSION', '') %}
{% set version= "20300" %}
{% set role = 'UEC' %}
{% set workflow = salt['pillar.get']('WORKFLOW', 'provision') %}
{% set cluster = salt['pillar.get']('CLUSTER', '') %}
{% set package_share = salt['pillar.get']('PACKAGE_SHARE', 'ftp://deployteam:D3pl0y%4015%23@ftp.devlab.local') %}
{% set parentfolder = salt['common.getshortversion'](suite_version) %}
{% set targetpatchversion = salt['pillar.get']('TARGETPATCHVERSION', '') %}

{% set workflow_folder= parentfolder +"/"+ role +"/Workflow" %}
{% set templates_folder= version +"/"+ role +"/Templates" %}
{% if targetpatchversion != '' %}

{% set patchparams =  "'" + targetpatchversion + "'" %}
{% set query = "exec dbo.GET_PREREQUISITE_PATCHES (" + patchparams + ")" %}
{% set patchdict = salt['cmdbconnect.db_return_array'](query) %}
{% endif %}

{% set params =  "'', '" + cluster + "','','" + workflow + "','" + role + "',''" %}
{% set query = "select [dbo].[GET_PS_INSTALL_PARAMETERS](" + params + ")" %}
{% set dict = salt['cmdbconnect.get_install_params'](query) %}
{% set udac_db_name= dict['UDAC_DB_NAME'] %}
{% set udac_db_user= dict['UDAC_DB_USER'] %}
{% set udac_db_password= dict['UDAC_DB_PASSWORD'] %}
{% set uka_server_nodes= dict['UKA_SERVER_NODES'] %}
{% set uka_port= dict['UKA_PORT'] %}


{% set replace = uka_server_nodes.split(':') %}





{% set release_version = '20.1.0.0-256' %}
{% set target = '20.1.2.1' %}
{% set package_root = '/opt/install' %}
{% set install_root = '/opt/suite' %}
{% set template_directory = '/tmp/' + release_version + '/templates' %}
{% set versionfile = 'versionfile.template' %}
{% set logdir = '/var/log/uec' %}


#set file specific variables
{% set udac_appsettings = 'udac_appsettings.json' %}
{% set webhook_appsettings = 'webhook_appsettings.json' %}
{% set udac_appsettings_location = install_root ~ '/udac/appsettings.json' %}
{% set webhook_appsettings_location = install_root ~ '/webhooks/appsettings.json' %}


#changes
{% set patch_folder = package_root + '/' + release_version + '/Patches/' %}

 {% set apps= 'webhooks','cdcprocessor','eventgenerator','notificationprocessor','useractionhistory','apiservice' %}

{% set services = {
'webhooks': {'template': 'webhooks.template', 'directory': 'Package/webhooks', 'servicefile': '/lib/systemd/system/webhooks.service', 'destination': '/opt/suite/webhooks'},
'cdc': {'template': 'cdc.template', 'directory': 'Package/cdcprocessor', 'servicefile': '/lib/systemd/system/cdc.service', 'destination': '/opt/suite/cdc'},
'eventgenerator': {'template': 'eventgenerator.template', 'directory': 'Package/eventgenerator', 'servicefile': '/lib/systemd/system/eventgenerator.service', 'destination': '/opt/suite/eventgenerator'},
'useractionhistory': {'template': 'useractionhistory.template', 'directory': 'Package/useractionhistory', 'servicefile': '/lib/systemd/system/useractionhistory.service', 'destination': '/opt/suite/useractionhistory'},
'udac': {'template': 'udac.template' , 'directory': 'Package/apiservice', 'servicefile': '/lib/systemd/system/udac.service', 'destination': '/opt/suite/udac'}
} %}



#A list of the directories under /opt/install/Patches
{% set patch_set = salt['file.find']( patch_folder, type='d', print= 'name', maxdepth=1, mindepth=1) %}
