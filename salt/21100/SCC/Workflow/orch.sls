{% import "./vars.sls" as base %}
{% if base.cluster!= '' %}
{% for server in pillar['clusterservers'] %}

Install SCC on Cluster server {{ server }}:
  salt.state:
    - tgt: {{ server }}
    - pillar: {{pillar | json}}
    - sls:
      - {{base.version}}/Common/redis/init
      - {{ base.workflow_folder }}/cluster

{% endfor %}

{% elif base.server !='' %}
install scc on server:
  salt.state:
    - tgt: '{{ base.server }}'
    - pillar: {{pillar | json}}
    - sls:
      - {{ base.version }}/Common/redis/pre-provision
      - {{ base.version }}/Common/redis/init

{% endif %}

