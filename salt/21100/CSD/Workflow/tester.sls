{% import "./vars.sls" as base %}
install csd on cluster:
  salt.state:
    - tgt: 'cluster:{{ base.cluster }}'
    - pillar: {{pillar | json}}
    - sls:
      - {{ base.workflow_folder }}/pre-provision
    - tgt_type: grain

