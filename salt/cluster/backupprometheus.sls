{% set mydatetime = salt["system.get_system_date_time"]() %}
copyfile {{ mydatetime }}:
  file.copy:
    - name: /u00/prometheus1/backups/prometheus.yml.{{ mydatetime }}
    - source: /u00/prometheus1/prometheus.yml
    - force: True
