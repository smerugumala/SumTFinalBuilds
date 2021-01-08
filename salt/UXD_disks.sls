detect /dev/sdc:
  cmd.run:
    - name: fdisk -l | grep "^Disk /dev/sdc:"
    - unless: fdisk -l | grep /dev/sdc1

create label on /dev/sdc:
  module.run:
    - name: partition.mklabel
    - device: /dev/sdc
    - label_type: msdos

create_partition_disk on /dev/sdc:
  module.run:
    - name: partition.mkpart
    - device: /dev/sdc
    - fs_type: ext2
    # using percent permit to have maximum size
    - start: 0%
    - end: 100%
    - part_type: primary
    - unless: blkid /dev/sdc1

Create XFS File System on /dev/sdc:
  module.run:
    - name: xfs.mkfs
    - device: /dev/sdc1
    - fs_type: xfs
    - unless: blkid /dev/sdc1 | grep xfs

Mount the new device on /dev/sdc:
  mount.mounted:
    - name: /var/lib/mysql
    - device: /dev/sdc1
    - fstype: xfs
    - opts: defaults
    - pass_num: 0
    - dump: 0
    - mkmnt: true

detect_new_disk /dev/sdd:
  cmd.run:
    - name: fdisk -l | grep "^Disk /dev/sdd:"
    - unless: fdisk -l | grep /dev/sdd1

create label on /dev/sdd:
  module.run:
    - name: partition.mklabel
    - device: /dev/sdd
    - label_type: msdos

create_partition_disk on /dev/sdd:
  module.run:
    - name: partition.mkpart
    - device: /dev/sdd
    - fs_type: ext2
    # using percent permit to have maximum size
    - start: 0%
    - end: 100%
    - part_type: primary
    - unless: blkid /dev/sdd1

Create XFS File System on /dev/sdd:
  module.run:
    - name: xfs.mkfs
    - device: /dev/sdd1
    - fs_type: xfs
    - unless: blkid /dev/sdd1 | grep xfs

Mount the new device /dev/sdd:
  mount.mounted:
    - name: /var/log/mysql
    - device: /dev/sdd1
    - fstype: xfs
    - opts: defaults
    - pass_num: 0
    - dump: 0
    - mkmnt: true
