create_instance:
  salt.runner:
    - name: cloud.map_run
    - path: /etc/salt/cloud.maps.d/vmware.map

deploy_web_servers:
  salt.state:
    - tgt: '*'
    - sls:
      - UEC.copy_and_extract

again_deploy_web_servers:
  salt.state:
    - tgt: '*'
    - sls:
      - UEC.copy_and_extract

patch_web_servers:
  salt.state:
    - tgt: '*'
    - sls:
      - UEC.install_and_patch


