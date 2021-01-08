
#Workflow Params
#-------------------------------
{% set suite_version = salt['pillar.get']('VERSION', '') %}
{% set workflow = salt['pillar.get']('WORKFLOW', 'provision') %}
{% set cluster = salt['pillar.get']('CLUSTER', '') %}
{% set server = salt['pillar.get']('SERVER', '') %}


{% set role= "UKA" %}
{% set parentfolder = suite_version.split('-')[0]| regex_replace('\\.|\\-', '') %}
{#% set parentfolder = salt['common.getshortversion'](suite_version) %#}


{% if cluster!= '' %}

{#% set assoccluster = salt['cmdbconnect.getassociatedcluster'](cluster) %#}
{#% set params =  "'', '" + cluster + "','" + assoccluster + "','" + workflow + "','" + role + "',''" %#}
{#% set query = "select [dbo].[GET_PS_INSTALL_PARAMETERS](" + params + ")" %#}
{% set dict = salt['pillar.get']('Install_params') %}
{#% set dict = salt['cmdbconnect.get_install_params'](query) %#}
{% set zookeeper_nodes = dict['USM_CLUSTER_NODES']  %}
{% set zookeeper_port = '2181' %}

{% set zookeeper_temp = zookeeper_nodes|replace(",", ':'~ zookeeper_port  ~',') %}
{% set zookeeper_temp_string = zookeeper_temp + ":" + zookeeper_port %}

{#% set zookeeper_temp_string = salt['common.appendPortToNodes'](zookeeper_nodes, zookeeper_port) %#}


{% set zookeeper_ip_string = zookeeper_temp_string ~ '/kafka' %}
{% set kafka_ip_string = dict['UKA_SERVER_NODES']  %} # also need a key to capture this
{% set kafka_port = dict['UKA_PORT'] or 9092 %}
{#% set rabbitmq_master = kafka_ip_string.split(',')[0] %#}

{% set rabbit_ip_string = kafka_ip_string |replace(':'~ kafka_port  ~'',"") %}
{% set rabbitmq_master = rabbit_ip_string.split(',')[0] %}
{#% set rabbit_ip_string = salt['common.removePortFromNodes'](kafka_ip_string) %#}

{#% set ip_query = "SELECT IP +'    '+NAME+'    '+FQDN FROM VM WHERE IP IN (SELECT SPLITDATA FROM DBO.fnSplitString('"+rabbit_ip_string+"',','))" %#}

{% set dict_hosts = salt['pillar.get']('VMdata') %}
{#% set dict_hosts = salt['cmdbconnect.db_return_array'](ip_query) %#}
{#% set master_hostname = dict_hosts[0] | regex_search('\s{4}(.*)\s{4}') | tojson %#} #set the master_hostname to the first value returned from cmdb

{% set master_hostname = dict_hosts[0].split(' ')[1] %}
{% set rabbitmq_user = dict['UEB_USER'] %}
{% set rabbitmq_password = dict['UEB_PASSWORD'] %}
{% set erlang_cookie_path = '/var/lib/rabbitmq/.erlang.cookie' %}
{% set erlang_cookie_value = 'AHOVMJCVEBPIPKGZNACI' %}

{% set command = 'grep  ' ~ erlang_cookie_value ~ ' ' ~ erlang_cookie_path ~ ' |cat' %}
{% set erlang_cookie_contents = salt['cmd.shell'] (command) %}

{% endif %}







#Default Params
#-------------------------------
{% set kafka_version= "2.2.2" %}
{% set kafka_full_version= "2.12-2.2.2" %}
{% set kafka_download= "" %}
{% set kafka_download_path= "/tmp" %}
{% set kafka_download_file= "kafka_" + kafka_full_version + ".tgz" %}
{% set kafka_download_url= "http://mirrors.ocf.berkeley.edu/apache/kafka/" + kafka_version + "/" + kafka_download_file  %}
{% set kafka_extraction_path= kafka_download_path + "/" + kafka_download_file %}
{% set kafka_install_as_service= 1 %}
{% set kafka_user= "kafka" %}
{% set kafka_group= "kafka" %}
{% set workflow_folder= parentfolder +"/"+ role +"/Workflow" %}
{% set templates_folder= parentfolder +"/"+ role +"/Templates" %}
{% set kafka_path = "/opt/kafka" %}

{% set erlang_version = '23.0' %}
{% set erlang_url = 'http://packages.erlang-solutions.com/rpm/centos/7/x86_64' %}
{% set erlang_key = 'https://packages.erlang-solutions.com/rpm/erlang_solutions.asc' %}
{% set rabbitmq_version = '3.7.18-1.el7' %}


#Other/Internal Params
#---------------------------------
{% set schema_registry_path= "/etc/schema-registry" %}
{# set kafka_opts= "-Djava.security.auth.login.config={{kafka_config_dir}}kafka_jaas.template" #}
{% set kafka_service_file = 'kafka.template' %}
{% set directories = kafka_path,schema_registry_path  %}
{% set kafka_config_path= kafka_path + '/kafka_' + kafka_full_version + '/config/server.properties' %}
{% set kafka_install_path= kafka_path + '/kafka_' + kafka_full_version  %}




