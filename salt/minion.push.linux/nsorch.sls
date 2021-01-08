{% set action = pillar['action'] %}
Check netscaler configurations:
  salt.state:
  - tgt: tower82.cotestdev.local
  - sls:
    - vm_lbcall
  - pillar:
      action: {{ action }}
  
