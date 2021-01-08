
{% set domainpasswd = salt['cmdb_lib3.getPassword'](salt['pillar.get']('domainuser')) %}

{% set server = pillar['instance'] %}

Remove Minion:
  cmd.run:
    - name: salt-ssh {{ server }} --user={{ salt['pillar.get']('domainuser') }} --passwd={{ domainpasswd }} -i --sudo --no-host-keys -r 'sudo yum -y remove salt-minion && sudo rm -rf /etc/salt/'
