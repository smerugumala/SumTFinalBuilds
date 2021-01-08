# Refresh Grains on Minion Startup
# Needed as workaround to grain data
# disappearing from Enterprise in
# minion version 3002.2

Refresh grains:
  saltutil.sync_grains:
    - refresh: True