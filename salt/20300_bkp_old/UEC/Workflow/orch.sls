{% import "./vars.sls" as base %}

install UEC:
  salt.state:
    - tgt: 'cluster:{{ base.cluster }}'
    - pillar: {{pillar | json}}
    - sls:
      - {{ base.workflow_folder }}/pre-provision
      - {{ base.workflow_folder }}/copy
      - {{ base.workflow_folder }}/provision

    - tgt_type: grain

