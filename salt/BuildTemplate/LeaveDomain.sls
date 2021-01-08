Leave Domain:
  cmd.run:
    - name: echo '{{ pillar['domainpasswd'] }}' | sudo realm leave --user={{ pillar['domainuser'] }} {{ pillar['Domain'] }}

