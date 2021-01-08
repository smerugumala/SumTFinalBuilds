#################################################
###        BASE TEMPLATE SETUP STATE          ###
###  ---------------------------------------  ###
###  To be applied to bare-metal OS template  ###
###  This will set required base options for  ###
###  SaltStack SecOps policies to be applied  ###
###                                           ###
#################################################

{% set saltpass = pillar.get('salt_pass') %}
{% set rootpass = pillar.get('root_pass') %}

### INSTALL NECESSARY YUM PACKAGES
install epel:
  pkg.installed:
    - pkg_verify: True
    - resolve_capabilities: True
    - pkgs:
      - epel-release

install_packages:
  pkg.installed:
    - pkg_verify: True
    - resolve_capabilities: True
    - pkgs:
      - sssd
      - realmd
      - oddjob
      - oddjob-mkhomedir
      - adcli
      - samba-common
      - samba-common-tools
      - krb5-workstation
      - openldap-clients
      - policycoreutils-python
      - syslog-ng

### SET DEFAULT DENY
Set hosts.deny:
  file.append:
    - name: '/etc/hosts.deny'
    - text: 'ALL: ALL'

### ALLOW OUR MGMT SUBNET
Set hosts.allow:
  file.append:
    - name: '/etc/hosts.allow'
    - text: 'ALL: 172.26.75.0/255.255.255.0'

### SET LOGIN BANNERS
Set /etc/issue:
  file.managed:
    - name: /etc/issue
    - source: http://ldcsaltrep001.cotestdev.local/files/issue
    - skip_verify: True

Set /etc/issue.net:
  file.managed:
    - name: /etc/issue.net
    - source: http://ldcsaltrep001.cotestdev.local/files/issue.net
    - skip_verify: True

Set MOTD:
  file.managed:
    - name: /etc/motd
    - source: http://ldcsaltrep001.cotestdev.local/files/motd
    - skip_verify: True

### ADD DOMAIN ADMINS AND SVC_SALTSTACK TO SUDOERS
Set Sudoers:
  file.append:
    - name: /etc/sudoers
    - text: |
        %domain\ admins ALL=(ALL)       ALL
        svc_saltstack ALL=(ALL) NOPASSWD: ALL

### CREATE ROOT BIN DIRECTORY
Create /root/bin:
  file.directory:
    - user: root
    - name: /root/bin
    - group: root
    - mode: 755

### HARDEN IPv6
Update IPv6 settings:
  file.append:
    - name: /etc/sysctl.conf
    - text: |
        net.ipv6.conf.all.accept_ra = 0
        net.ipv6.conf.default.accept_ra = 0

### SET SSH LOGIN BANNER
Update SSH Banner:
  file.append:
    - name: /etc/ssh/sshd_config
    - text: Banner = /etc/issue.net

### CREATE GRUB2 PASSWORD HASH
Set grub2 password:
  cmd.run:
    - name: "echo -e '{{ rootpass }}\n{{ rootpass }}' | grub2-mkpasswd-pbkdf2 | awk '/grub.pbkdf/{print$NF}' | tee /boot/grub2/user.cfg"

### UPDATE GRUB CONFIG WITH PASSWORD VARIABLE
Set Grub Password variable:
  cmd.run:
    - name: "sed -i 's/grub.pbkdf2.sha512./GRUB2_PASSWORD=grub.pbkdf2.sha512./g' /boot/grub2/user.cfg"

### ENABLE PRE-BOOT AUDIT
Set audit options in grub config:
  cmd.run:
    - name: "sed -i 's/crashkernel=auto/crashkernel=auto audit=1/g' /etc/default/grub"

### REBUILD GRUB CONFIG
Rebuild grub config:
  cmd.run:
    - name: "grub2-mkconfig -o /boot/grub2/grub.cfg"

### START & ENABLE SYSLOG-NG SERVICE
syslog-ng:
  service.running:
    - enable: True
    - reload: True

### SET PERMISSIONS ON USER FILES
Find and set permissions on user files:
  cmd.run:
    - name: 'find /home/ -name ".*" -perm /g+w,o+w -exec chmod g-w,o-w "{}" \;'

### SET PERMISSIONS ON LOG FILES
Find and set permissions on log files:
  cmd.run:
    - name: 'find /var/log -type f -exec chmod g-wx,o-rwx {} +'

### JOIN DOMAIN (REMOVE THIS FROM FINAL STATE)
Join domain:
  cmd.run:
    - name: |
        echo {{ saltpass }} | realm join --user=svc_ansible cotestdev.local
        hostnamectl set-hostname $(hostname).cotestdev.local --static
        sed -i 's/use_fully_qualified_names = True/use_fully_qualified_names = False/g' /etc/sssd/sssd.conf
        sed -i 's/fallback_homedir = \/home\/%u@%d/fallback_homedir = \/home\/%u/g' /etc/sssd/sssd.conf
        systemctl restart sssd

### ADD CRON JOB FOR AIDE
Add cron job for AIDE:
  cron.present:
    - identifier: AIDE_CHECK_CRON
    - name: /usr/sbin/aide --check
    - user: root
    - minute: '0'
    - hour: '5'
    - daymonth: '*'
    - month: '*'
    - dayweek: '*'
    - comment: 'Check filesystem integrity with aide'
