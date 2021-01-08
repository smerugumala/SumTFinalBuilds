{% set policy_name = pillar['policy_name'] %}

Assess Policy:
  module.run:
    - name: sec_api.reAssessPolicy
    - policy_name: '{{ policy_name }}'

