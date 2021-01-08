#-------------------------------
{% set suite_version= "21.1.0.0" %}
{% set version= "21100" %}
{% set workflow = salt['pillar.get']('WORKFLOW', 'provision') %}
{% set cluster = salt['pillar.get']('CLUSTER', '') %}
{#% set asc_cluster = salt['pillar.get']('ASSOCIATE_CLUSTER', '') %#}
{% set server = salt['pillar.get']('SERVER', '') %}


#Default Params
#-------------------------------
{% set role= "CSD" %}
{% set parentfolder = suite_version.split('-')[0]| regex_replace('\\.|\\-', '') %}
{#% set parentfolder = salt['common.getshortversion'](suite_version) %#}
{% set workflow_folder= parentfolder +"/"+ role +"/Workflow" %}


{% set workflow_folder= version +"/"+ role +"/Workflow" %}
{% set templates_folder= version +"/"+ role +"/Templates" %}
{% set cassandra_download_path= "/tmp" %}
{% set cassandra_version= "3.11.5" %}
{% set cassandra_download_file= 'apache-cassandra-' ~ cassandra_version ~ '-bin.tar.gz' %}
{% set cassandra_archive_path= cassandra_download_path ~ '/' ~ cassandra_download_file %}
{% set cassandra_path= '/opt/cassandra' %}
{% set cassandra_download_url= 'http://archive.apache.org/dist/cassandra/' ~ cassandra_version ~ '/' ~ cassandra_download_file %}
{% set cassandra_dir= cassandra_path ~ '/apache-cassandra-' ~ cassandra_version %}
{% set cassandra_tmp_dir= cassandra_dir ~ '/tmp' %}
{% set cassandra_group= 'cassandra' %}
{% set cassandra_user= 'cassandra' %}
{% set cassandra_cluster_name= "Test Cluster" %}
{% set cassandra_config_dir= "/etc/cassandra" %}
{% set cassandra_config_file = templates_folder ~ "cassandra.yaml" %}
{% set cassandra_log_dir= "/var/log/cassandra" %}
{% set commitlog_directory= "/var/lib/cassandra/commitlog" %}
{% set cassandra_data_dir= "/var/lib/cassandra/data" %}
{% set saved_caches_directory= "/var/lib/cassandra/saved_caches" %}
{% set directories = cassandra_path, cassandra_log_dir, cassandra_data_dir , cassandra_config_dir , cassandra_tmp_dir %}



{% if cluster!= '' %}
{% set params =  "'', '" + cluster + "','','" + workflow + "','" + role + "',''" %}
{% set query = "select [dbo].[GET_PS_INSTALL_PARAMETERS](" + params + ")" %}
{% set dict = salt['cmdbconnect.get_install_params'](query) %}
{% set cassandraadminuser= dict['CSD_DB_ADMIN_USER'] %}
{% set cassandraadminpwd= dict['CSD_DB_ADMIN_PWD'] %}
{% set replicationfactor= dict['CSD_DB_REPLICATION_FACTOR'] %}
{% set csdservernodes= dict['CSD_SERVER_NODES'] %}
{% set csdport= dict['CSD_PORT'] %}

{% set csd_master = salt['common.getMaster'](csdservernodes) %}


{% endif %}
#DataCenter/Tier params
#--------------------------------



#Cluster Params
#--------------------------------
{% set cassandra_seed_ips= '127.0.0.1' %}


#Tenant Params
#---------------------------------



#Other/Internal Params
#---------------------------------

