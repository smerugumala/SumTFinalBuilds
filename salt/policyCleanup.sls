{% set target = pillar['name'] %}

Delete Policy:
  module.run:
    - name: sec_api.deletePolicy
      policy_name: '{{ target }}'

Delete Target Group:
  module.run:
    - name: sec_api.deleteTarget
      policy_name: '{{ target }}'