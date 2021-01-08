{############################################################################}
{# Description: Check the service group and see what's up, then disable a 50 percentage of them, then send an email saying it's done #}
{# Author : SaiKrishna Merugumala <SaiKrishna.Merugumala@sumtotalsystems.com> #}
{# Version : 1.0.0 #}
{# Note : Each state has its own function and action. #}
{# Pre-requisites: Netscaler module #}
{# Parameters : In line pillar - ex : pillar='{"action":"disable"}' (or) pillar='{"action":"enable"}' #}
{# Sample Command : # salt-run state.orch nsorch  pillar='{"action":"disable"}' #}
{# Created Date : 04/08/2020 #}
{############################################################################}

{# Defining the variables #}

{% set sg = 'ldc_salt_enterprise' %}                      {# Defining service group variable #}
{% set servers = ['ldcsaltent004', 'ldcsaltent003'] %}    {# Defining list of servers #}
{% set IP = ['172.26.75.236', '172.26.75.234'] %}         {# Defining list of IP's #}


#This function is to check if service group exists or not 

Check servicegroup {{ sg }}:                  # Declaring State ID 
  salt.function:
    - name: netscaler.servicegroup_exists     # Module name and it's function we are going to use 
    - tgt: 'tower82.cotestdev.local'          # This is the target where this function need to be executed
    - arg:
      - {{ sg }}


#This function is to check if server exists under servicegroup 

{% for server in servers %}                   # This for loop is to get the server individually from an servers list
Check {{ server }} exists in sg:              # Declaring State ID which includes server name over the loop
  salt.function:
    - name: netscaler.servicegroup_server_exists
    - tgt: 'tower82.cotestdev.local'          # This is the target where this function need to be executed
    - arg:                                    # Arguments to this function
      - {{ sg }}
      - {{ server }}
    - require:                                # Require requisite is used to check the status of mentioned state ID and proceed if state returns True
      - salt: Check servicegroup

# This below function is to check the server status under service group

Check {{ server }} status:                    # Declaring State ID which includes server name over the loop
  salt.function:
    - name: netscaler.servicegroup_server_up
    - tgt: 'tower82.cotestdev.local'
    - arg:
      - {{ sg }}
      - {{ server }}
      - 80
    - requires:
      - salt: Check {{ server }} in sg
    - onlyif:                                 # Onlyif requisite helps to ensure that if any of the specified commands return False, the state will not run
      - {{ pillar['action'] }} == 'disable'
	  
# This below function checks if the server is enabled globally

Check server enabled globally {{ server }}:
  salt.function:
    - name: netscaler.server_enabled
    - tgt: 'tower82.cotestdev.local'
    - arg:
      - {{ server }}
    - require:
      - salt : Check {{ server }} status
{% endfor %}                                  # Server loop end's here


{% for i in range(0,servers|length) %}        # This for loop to get the index value individually in servers list variable 
{% if i is divisibleby 2 %}                   # This condition is to check if the index value is divisibleby value 2 inorder to disable/enable 50% servers in servicegroup

Server disable in {{ sg }} {{ i }}:           # Declaring State ID which includes servicegroup name and index value
  salt.function:
    - name: netscaler.servicegroup_server_{{ pillar['action'] }}          # Here the action comes from inline pillar data enable/disable
    - tgt: 'tower82.cotestdev.local'
    - arg:
      - {{ sg }}
      - {{ servers[i] }}                      # Get's server from servers list based on index value - i refers to index value
      - {{ IP[i] }}
    - require:
      - salt: Check server enabled globally {{ servers[i] }}


server-failure-message {{ servers[i] }}:      # Declaring State ID for failure mail 
  smtp.send_msg:                              # This refers to module and followed by function name
    - name: This email from Salt Master - There were NO changes happened in the loadbalacer - {{ sg }}
    - use_ssl: True
    - sender: SaltMaster
    - recipient: saikrishna.merugumala@sumtotalsystems.com
    - subject: Loadbalancing Changes Fail
    - onfail:                                 # This state executes only mentioned state returns False
      - Server disable in {{ sg }} {{ i }}

server-success-message {{ servers[i] }}:       # Declaring State ID for success mail 
  smtp.send_msg:
    - name: This email from Salt Master - To inform this server {{ servers[i] }} is {{ pillar['action'] }}d from the LoadBalancer {{ sg }}
    - use_ssl: True
    - sender: SaltMaster
    - recipient: saikrishna.merugumala@sumtotalsystems.com
    - subject: Loadbalancing Changes Success
    - onchanges:
      - Server disable in {{ sg }} {{ i }}     # This state executes only mentioned state returns True
	  
{% endif %}                                    # If condition end's here
{% endfor %}                                   # Server range loop end's here

