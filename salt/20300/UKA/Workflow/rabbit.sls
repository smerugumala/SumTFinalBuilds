{% import "./vars.sls" as base %}
{# set command = 'grep  ' ~ base.erlang_cookie_value ~ ' ' ~ base.erlang_cookie_path ~ ' |cat' #}

{% set trialset = salt['network.ipaddrs']( ) %}
{% set val= trialset | replace("[u'", "") %}
{% set ip_addr= val| replace("']", "") %}
{% set master_hostname = salt['grains.get']('host') %}
{% set mv = '' %}


{# set erlang_cookie_contents = salt['cmd.shell'] (command) #}
{% set first_string = base.dict_hosts[0] %}
{% set trystring = base.dict_hosts | first %}
{% set thirdvar = first_string | yaml_dquote | string() %}
{% set another = first_string | string() %}
{% set second_string = base.dict_hosts[0] | string() %}
{% set maybe = second_string | regex_search('bc\s{4}(.*)\s{4}') %}
{% set also = maybe | tojson %}
{% set retry = base.dict_hosts[0] | regex_search('\s{4}(.*)\s{4}') | tojson  %}
{% set final = retry | safe | string() %}
{% set last = base.dict_hosts[0] | regex_search('\s{4}(.*)\s{4}') %}

check the value {{base.dict_hosts[0] | regex_search('\s{4}(.*)\s{4}')}}:
  cmd.run:
    - name: echo {{ retry[1:-1]}}



#print the val {{ retry }}:
#  file.append:
#    - name: /opt/hosts.txt
#    - text: {{ "192.168.2.173    QA-UTA22A    QA-UTA22A.devlab.local" | regex_search('\s{4}(.*)\s{4}') | tojson }}

#print the dict:
#  file.append:
#    - name: /opt/hosts.txt
#    - text: {{ trystring | regex_match('^.*\s{4}.*(?=\s{4})') }}

#ensure_copy_kafka_service_file:
#  file.append:
#    - name: '/etc/hosts'
#    - source: salt://{{ base.templates_folder}}/hosts
#    - template: jinja
#    - context: 
#        dict_hosts: {{ base.dict_hosts }}

#print the val {{ base.dict_hosts[0] | tojson | regex_search('bc\s{4}(.*)\s{4}') }}:

