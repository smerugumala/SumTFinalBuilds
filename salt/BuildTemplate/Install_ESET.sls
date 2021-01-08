{% set eset_config = pillar['eset_dict'] %}


Get_ESET_binaries:
  file.managed:
    - name: /var/agent-linux-x86_64.sh
    - source: https://download.eset.com/com/eset/apps/business/era/agent/v6/latest/agent-linux-x86_64.sh
    - source_hash: a9abb2e9865c4209d2264d556a43079a
    - mode: '775'
    - if_missing: /var/agent-linux-x86_64.sh

Install_ESET:
  cmd.run:
    - name: sudo /var/agent-linux-x86_64.sh --skip-license --hostname={{ eset_config['CO_ESET_SERVER'] }} --port={{ eset_config['CO_ESET_PORT'] }} --webconsole-user={{ eset_config['CO_ESET_WEBCONSOLE_ACCOUNTNAME'] }} --webconsole-password={{ salt['pillar.get']('ESET:password') }} --webconsole-port={{ eset_config['CO_ESET_WEBCONSOLE_PORT'] }} --cert-auto-confirm
