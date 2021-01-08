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

{% set parentfolder = suite_version.split('-')[0]| regex_replace('\\.|\\-', '') %}
{% set targetpatchversion = salt['pillar.get']('TARGETPATCHVERSION', '') %}

{% set workflow_folder= parentfolder +"/"+ role +"/Workflow" %}
{% set templates_folder= version +"/"+ role +"/Templates" %}
{% if targetpatchversion != '' %}

{% set params =  "'" + targetpatchversion + "'" %}
{% set query = "exec dbo.GET_PREREQUISITE_PATCHES (" + params + ")" %}
{% set dict = salt['cmdbconnect.db_return_array'](query) %}
{% endif %}



{% set role = 'UEC' %}
{% set release_version = '20.1.0.0' %}
{% set target = '20.1.2.1' %}
{% set package_root = '/opt/install' %}
{% set install_root = '/opt/suite' %}
{% set versionfile = 'versionfile.template' %}
{% set logdir = '/var/log/uec' %}


#set file specific variables
{% set udac_appsettings = 'udac_appsettings.json' %}
{% set webhook_appsettings = 'webhook_appsettings.json' %}
{% set udac_appsettings_location = '/opt/udac.json' %}
{% set webhook_appsettings_location = '/opt/webhooks.json' %}


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
