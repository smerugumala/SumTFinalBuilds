
{% set Networks = salt['cmdb_lib3.ipSublist'](pillar['clusterrole'],pillar['datacenter'],pillar['environment']) %}


{% set ClusterServers = salt['cmdb_lib3.buildServerlist'](pillar['ClusterName'],pillar['numOfServers'],pillar['datacenter']) %}

{% set lb = salt['cmdb_lib3.getlb'](pillar['datacenter'],pillar['environment']) %}

{% set lbpassword = salt['cmdb_lib3.getresource']('network_administrators','vro-admin') %}

{% set args = {"netscaler_host": lb,"netscaler_user": "vro-admin","netscaler_pass": lbpassword,"netscaler_useSSL": "False"} %}

{% set iplist = [] %}
{% for i in range(0,99) %}

{% set retriveIP = salt['cmdb_lib3.getIP'](Networks,pillar['datacenter']) %}

{% if salt['netscaler.server_getall'](retriveIP["ipaddress"], **args) %}

{% set stat = salt['cmdb_lib3.SetStatus'](retriveIP["ipaddress"]) %}

cmdd:
  cmd.run:
    - name: echo {{ retriveIP["ipaddress"] }}

{% else %}

{% set ReserveIP = salt['cmdb_lib3.SetStatus'](retriveIP["ipaddress"]) %}

{% do iplist.append(retriveIP) %}

{% endif %}

{% if iplist|length == pillar['numOfServers']|int %}{% break %}{% endif %}

{% endfor %}

