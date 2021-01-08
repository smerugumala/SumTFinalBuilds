{% set suite_version = salt['pillar.get']('VERSION', '') %}
{% set workflow = salt['pillar.get']('WORKFLOW', 'provision') %}
{% set role= "UKA" %}
{% set parentfolder = suite_version.split('-')[0]| regex_replace('\\.|\\-', '') %}
{#% set parentfolder = salt['common.getshortversion'](suite_version) %#}
{% set workflow_folder= parentfolder +"/"+ role +"/Workflow" %}
Run pre provsion states:
  salt.state:
    - tgt: '*'
    - pillar: {{pillar | json}}
    - sls:
      - {{ workflow_folder }}/pre-provision

run the orch:
  salt.runner:
    - name: state.orchestrate
    - mods: {{ workflow_folder }}/orch
    - pillar: {{pillar | json}}

