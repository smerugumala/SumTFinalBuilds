{% set saltpass = pillar.get('salt_pass') %}
{% set rootpass = pillar.get('root_pass') %}

echo the password:
  cmd.run:
    - name: 'echo {{ saltpass }}'