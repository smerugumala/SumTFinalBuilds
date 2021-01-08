
{% set dict = salt['cmdbconnect.getpatchlist']('20.2.4.0') %}


ptint start:
  cmd.run:
     - name: echo "START"
print dict:
  cmd.run: 
    - name: echo {{dict}}
{% for var in dict %}
print {{var}}:
  cmd.run:
     - name: echo {{var}}
{% endfor %}




