{% import "./vars.sls" as base %}
{% if base.cluster!= '' %}
install mongoDB on cluster:
  salt.state:
    - tgt: 'cluster:{{ base.cluster }}'
    - pillar: {{pillar | json}}
    - sls:
      - {{ base.workflow_folder }}/pre-provision
      - {{ base.workflow_folder }}/provision
      - {{ base.workflow_folder }}/cluster
    - tgt_type: grain



{% elif base.server !='' %}
install mongoDB on server:
  salt.state:
    - tgt: '{{ base.server }}'
    - pillar: {{pillar | json}}
    - sls:
      - {{ base.workflow_folder }}/pre-provision
      - {{ base.workflow_folder }}/provision
{% endif %}

