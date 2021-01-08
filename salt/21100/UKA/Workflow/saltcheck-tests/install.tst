{% import "20300/UKA/Workflow/vars.sls" as base %}

{% set trialset = salt['network.ipaddrs']( ) %}
{% set val= trialset | replace("[u'", "") %}
{% set ip_addr= val| replace("']", "") %}

check values for listeners{{ip_addr}}:
  module_and_function: file.search
  args:
    - {{ base.kafka_config_path }}
    - listeners=PLAINTEXT://{{ip_addr}}
  assertion: assertTrue
  output_details: True
