#################################################
###        BASE TEMPLATE SETUP STATE          ###
###  ---------------------------------------  ###
###  To be applied to bare-metal OS template  ###
###  This will set required base options for  ###
###  SaltStack SecOps policies to be applied  ###
###                                           ###
#################################################


{% set saltpass = salt['pillar.get']('saltpass') %}
{% set rootpass = salt['pillar.get']('rootpass') %}
{% set repoServer = salt['pillar.get']('repoServer') %}
{% set Domain = salt['pillar.get']('Domain') %}
{% set subnet = salt['pillar.get']('subnet') %}


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

### SET LOGIN BANNERS
Set /etc/issue:
  file.managed:
    - name: /etc/issue
    - source: http://{{ repoServer }}.{{ Domain }}/files/issue
    - skip_verify: True

Set /etc/issue.net:
  file.managed:
    - name: /etc/issue.net
    - source: http://{{ repoServer }}.{{ Domain }}/files/issue.net
    - skip_verify: True

Set MOTD:
  file.managed:
    - name: /etc/motd
    - source: http://{{ repoServer }}.{{ Domain }}/files/motd
    - skip_verify: True

### ADD DOMAIN ADMINS AND SVC_SALTSTACK TO SUDOERS
Set Sudoers:
  file.append:
    - name: /etc/sudoers
    - text: |
        %domain\ admins     ALL=(ALL)       ALL
        svc_saltstack       ALL=(ALL)    NOPASSWD: ALL

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

### ENABLE PRE-BOOT AUDIT
Set audit options in grub config:
  cmd.run:
    - name: "sed -i 's/crashkernel=auto/crashkernel=auto audit=1 ipv6.disable=1/g' /etc/default/grub"

### REBUILD GRUB CONFIG
Rebuild grub config:
  cmd.run:
    - name: "grub2-mkconfig -o /boot/grub2/grub.cfg"

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
        echo {{ saltpass }} | sudo realm join --user=svc_ansible {{ Domain }}
        hostnamectl set-hostname $(hostname).{{ Domain }} --static
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
