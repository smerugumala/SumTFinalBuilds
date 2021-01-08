{% import "./vars.sls" as base %}
{% if base.cluster!= '' %}

{% for server in pillar['clusterservers'] %}

Install mongoDB on cluster server {{ server }}:
  salt.state:
    - tgt: {{ server }}
    - pillar: {{pillar | json}}
    - sls:
      - {{ base.workflow_folder }}/pre-provision
      - {{ base.workflow_folder }}/provision
      - {{ base.workflow_folder }}/cluster

{% endfor %}

{% elif base.server !='' %}
install mongoDB on server:
  salt.state:
    - tgt: '{{ base.server }}'
    - pillar: {{pillar | json}}
    - sls:
      - {{ base.workflow_folder }}/pre-provision
      - {{ base.workflow_folder }}/provision
{% endif %}

