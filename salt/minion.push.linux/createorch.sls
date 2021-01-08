Check VM Creation:
  salt.state:
  - tgt: tower82.cotestdev.local
  - sls:
    - CreateVMstate
  
