{% import "./vars.sls" as base %}
{% if base.cluster!= '' %}
install HAM on cluster:
  salt.state:
    - tgt: 'cluster:{{ base.cluster }}'
    - pillar: {{pillar | json}}
    - sls:
      - {{base.version}}/Common/redis/pre-provision
      - {{base.version}}/Common/redis/init
      - {{ base.workflow_folder }}/cluster
    - tgt_type: grain



{% elif base.server !='' %}
install HAM on server:
  salt.state:
    - tgt: '{{ base.server }}'
    - pillar: {{pillar | json}}
    - sls:
      - {{ base.workflow_folder }}/pre-provision
      - {{ base.workflow_folder }}/provision
{% endif %}

