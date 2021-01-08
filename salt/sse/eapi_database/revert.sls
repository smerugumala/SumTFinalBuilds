revert_all:

  pkg.removed:
    - pkgs:
      - postgresql96-contrib
      - postgresql96-libs
      - postgresql96-server
      - postgresql96

  file.absent:
    - names:
      - /var/lib/pgsql/
      - /etc/pki/postgres/

  user.absent:
    - name: postgres
