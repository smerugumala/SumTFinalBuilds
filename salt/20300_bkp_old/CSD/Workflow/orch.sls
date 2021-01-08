{% import "./vars.sls" as base %}
{% if base.cluster!= '' %}
install csd on cluster:
  salt.state:
    - tgt: 'cluster:{{ base.cluster }}'
    - pillar: {{pillar | json}}
    - sls:
      - {{ base.workflow_folder }}/provision
      - {{ base.workflow_folder }}/cluster
      - {{ base.workflow_folder }}/keyspace
      - {{ base.workflow_folder }}/finish
    - tgt_type: grain



{% elif base.server !='' %}
install csd on server:
  salt.state:
    - tgt: '{{ base.server }}'
    - pillar: {{pillar | json}}
    - sls:
      - {{ base.workflow_folder }}/pre-provision
      - {{ base.workflow_folder }}/provision
{% endif %}

