{% import "./vars.sls" as base %}
{% set trialset = salt['network.ipaddrs']( ) %}
{% set val= trialset | replace("[u'", "") %}
{% set ip_addr= val| replace("']", "") %}


stop cassandra:
  service.dead:
    - name: cassandra

config file:
  file.managed:
    - name: {{ base.cassandra_dir }}/conf/cassandra.yaml
    - source: salt://{{base.templates_folder}}/cassandra.yaml
    - template: jinja
    - cassandra_seed_ips: {{base.csdservernodes}}
    - listen_address: {{ip_addr}}
    - rpc_address: {{ip_addr}}
    - endpoint_snitch: 'GossipingPropertyFileSnitch'
    - cassandra_cluster_name: {{ base.cassandra_cluster_name }}

Recursively remove data directory contents:
  file.directory:
    - name: {{base.cassandra_dir}}/data/data/system/           
    - clean: True

start cassandra:
  service.running:
    - name: cassandra
    - watch:
      - file: Recursively remove data directory contents



restart manually:
  cmd.run:
    - name: sudo systemctl restart cassandra