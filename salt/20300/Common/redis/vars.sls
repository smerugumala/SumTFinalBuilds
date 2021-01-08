{% set redis_version= "6.0.5" %}
{% set redis_full_version= "2.12-2.2.2" %}
{% set redis_download= '' %}
{% set redis_user= "redis" %}
{% set redis_group= "redis" %}
{% set redis_path= "/opt/" %}
{% set redis_dir = redis_path ~ "redis-" ~ redis_version %}
{% set redis_download_file= 'redis-' + redis_version + '.tgz' %}
{% set redis_download_url= 'http://download.redis.io/releases/redis-' ~ redis_version ~ '.tar.gz'  %}

 

{% set redis_install_as_service= 1 %}
{% set redis_config_path= redis_path + 'redis_' + redis_full_version + '/config/server.properties' %}
{% set redis_install_path= redis_path + 'redis_' + redis_full_version  %}

 

{% set redis_data_dir= "/data/redis/" %}
{% set redis_config_dir= redis_path + 'redis_' + redis_version + '/config/' %}
{% set redis_scripts_dir=  redis_path + '/redis_' + redis_full_version + '/bin/' %}
{% set redis_log_dir= "/var/log/redis/" %}
{% set redis_service_file = 'redis.template' %}
{% set redis_conf_dir = '/etc/redis' %}

 

 

{% set directories = redis_log_dir, redis_config_dir,redis_conf_dir %}
