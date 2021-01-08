base:

  {# Target SSE Servers, according to Pillar data #}

  # SSE PostgreSQL Server
  'I@sse_pg_server:{{ grains.id }}':
    - sse.eapi_database

  # SSE Redis Server
  'I@sse_redis_server:{{ grains.id }}':
    - sse.eapi_cache

  # SSE eAPI Servers
  'I@sse_eapi_servers:{{ grains.id }}':
    - sse.eapi_service

  # SSE Salt Masters
  'I@sse_salt_masters:{{ grains.id }}':
    - sse.eapi_plugin
