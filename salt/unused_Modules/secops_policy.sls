{% set systime = salt["system.get_system_date_time"] () %}
{% set vmName = pillar['name'] %}
{%- set targetOS = salt.cmd.run('salt '~ vmName ~' grains.item osfinger').splitlines() | last %}
{% set uuid_1 = ( pillar['name'] | uuid ) %}
{% set uuid_2 = ( systime | uuid ) %}

cmdr:
  cmd.run:
    - name: echo {{ vmName }}

Create Target Group:
  cmd.run:
    - name: "curl -k --location --request POST 'https://172.26.75.134/rpc'
            --header 'Authorization: Basic cm9vdDpzYWx0'
            --header 'Content-Type: text/plain'
            --header 'Cookie: raas-session=\"2|1:0|10:1600712005|12:raas-session|68:aW50ZXJuYWw6cm9vdDpjNDA4NDM0OC1mYzMyLTExZWEtOTI3My0wMDUwNTY5YWVlOTk=|1ae488bd16cf079b6b075c80036e07b8fac402ff597388f8a55085e8e9192bcb\"'
            --data '{\"resource\":\"tgt\",\"method\":\"save_target_group\",\"kwarg\":{\"tgt_uuid\":\"{{ uuid_1 }}\",\"name\":\"{{ pillar['name'] }}\",\"tgt\":{\"*\":{\"tgt_type\":\"compound\",\"tgt\":\"G@host:{{ pillar['name'] }}\"}}}}'"


Create Secops Policy:
  cmd.run:
    {% if targetOS == '        Windows-2016Server' %}
    - name: "curl -k --location --request POST 'https://172.26.75.134/rpc'
           --header 'Authorization: Basic cm9vdDpzYWx0'
           --header 'Content-Type: text/plain'
           --header 'Cookie: raas-session=\"2|1:0|10:1600712005|12:raas-session|68:aW50ZXJuYWw6cm9vdDpjNDA4NDM0OC1mYzMyLTExZWEtOTI3My0wMDUwNTY5YWVlOTk=|1ae488bd16cf079b6b075c80036e07b8fac402ff597388f8a55085e8e9192bcb\"'
           --data '{\"resource\":\"sec\",\"method\":\"save_policy\",\"kwarg\":{\"policy_uuid\":\"{{ uuid_2 }}\",\"name\":\"{{ pillar['name'] }}\",\"tgt_uuid\":\"{{ uuid_1 }}\",\"benchmark_uuids\":[\"bc54e972-5b2e-423b-a535-9953c7940d43\"],\"check_uuids\":[\"2fd36364-12d3-408a-a6dc-d56c73cd118a\",\"81923b26-e6e8-4b11-a77f-9847621bac6d\"],\"variables\":[{\"check_uuid\":\"2fd36364-12d3-408a-a6dc-d56c73cd118a\",\"name\":\"_locke.system.user.win_rename_administrator_account.RENAME_ADMIN\",\"value\":\"coadmin\"},{\"check_uuid\":\"81923b26-e6e8-4b11-a77f-9847621bac6d\",\"name\":\"_locke.system.user.win_rename_guest_account.RENAME_GUEST\",\"value\":\"stranger\"}]}}'"
    {% elif targetOS == '        CentOS Linux-7' %}
    - name: "curl -k --location --request POST 'https://172.26.75.134/rpc'
           --header 'Authorization: Basic cm9vdDpzYWx0'
           --header 'Content-Type: text/plain'
           --header 'Cookie: raas-session=\"2|1:0|10:1600712005|12:raas-session|68:aW50ZXJuYWw6cm9vdDpjNDA4NDM0OC1mYzMyLTExZWEtOTI3My0wMDUwNTY5YWVlOTk=|1ae488bd16cf079b6b075c80036e07b8fac402ff597388f8a55085e8e9192bcb\"'
           --data '{\"resource\":\"sec\",\"method\":\"save_policy\",\"kwarg\":{\"policy_uuid\":\"{{ uuid_2 }}\",\"name\":\"{{ pillar['name'] }}\",\"tgt_uuid\":\"{{ uuid_1 }}\",\"benchmark_uuids\":[\"d1813b98-c97e-4649-8ef4-dfbd6b8fef40\",\"bd59699d-a4f0-4b46-911c-582a8e89201e\",\"9c1cfac0-82da-4e4d-b12b-fabbe2bbe94d\"],\"check_uuids\":[\"d0d44573-a630-4d67-a2e2-a1fe967ba301\"],\"variables\":[]}}'"
    {% elif targetOS == '        Windows-2012ServerR2' %}
    - name: "curl -k --location --request POST 'https://172.26.75.134/rpc'
            --header 'Authorization: Basic cm9vdDpzYWx0'
            --header 'Content-Type: text/plain'
            --header 'Cookie: raas-session=\"2|1:0|10:1600712005|12:raas-session|68:aW50ZXJuYWw6cm9vdDpjNDA4NDM0OC1mYzMyLTExZWEtOTI3My0wMDUwNTY5YWVlOTk=|1ae488bd16cf079b6b075c80036e07b8fac402ff597388f8a55085e8e9192bcb\"'
            --data '{\"resource\":\"sec\",\"method\":\"save_policy\",\"kwarg\":{\"policy_uuid\":\"{{ uuid_2 }}\",\"name\":\"{{ pillar['name'] }}\",\"tgt_uuid\":\"{{ uuid_1 }}\",\"benchmark_uuids\":[\"bc54e972-5b2e-423b-a535-9953c7940d43\"],\"check_uuids\":[\"2fd36364-12d3-408a-a6dc-d56c73cd118a\",\"81923b26-e6e8-4b11-a77f-9847621bac6d\"],\"variables\":[{\"check_uuid\":\"2fd36364-12d3-408a-a6dc-d56c73cd118a\",\"name\":\"_locke.system.user.win_rename_administrator_account.RENAME_ADMIN\",\"value\":\"coadmin\"},{\"check_uuid\":\"81923b26-e6e8-4b11-a77f-9847621bac6d\",\"name\":\"_locke.system.user.win_rename_guest_account.RENAME_GUEST\",\"value\":\"stranger\"}]}}'"
    {% endif %}