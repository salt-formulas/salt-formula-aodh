aodh:
  server:
    region: RegionOne
    enabled: true
    version: mitaka
    cluster: true
    ttl: 86400
    event_alarm_topic: alarm.all
    bind:
      host: 127.0.0.1
      port: 8042
    identity:
      engine: keystone
      host: 127.0.0.1
      port: 35357
      tenant: service
      user: ceilometer
      password: password
      endpoint_type: internalURL
    logging:
      log_appender: false
      log_handlers:
        watchedfile:
          enabled: true
        fluentd:
          enabled: false
    message_queue:
      engine: rabbitmq
      members:
      - host: 127.0.0.1
      - host: 127.0.0.1
      - host: 127.0.0.1
      user: openstack
      password: password
      virtual_host: '/openstack'
      # Workaround for https://bugs.launchpad.net/ceilometer/+bug/1337715
      rpc_thread_pool_size: 5
    database:
      engine: mysql
      host: 127.0.0.1
      port: 3306
      name: aodh
      user: aodh
      password: test
    notifications:
      store_events: default
    cache:
      engine: memcached
      members:
      - host: 127.0.0.1
        port: 11211
      - host: 127.0.0.1
        port: 11211
      security:
        enabled: true
        strategy: ENCRYPT
        secret_key: secret
apache:
  server:
    enabled: true
    default_mpm: event
    mpm:
      prefork:
        enabled: true
        servers:
          start: 5
          spare:
            min: 2
            max: 10
        max_requests: 0
        max_clients: 20
        limit: 20
    site:
      aodh:
        enabled: false
        available: true
        type: wsgi
        name: aodh
        host:
          name: 127.0.0.1
          address: 127.0.0.1
          port: 8042
        log:
          custom:
            format: >-
              %v:%p %{X-Forwarded-For}i %h %l %u %t \"%r\" %>s %D %O \"%{Referer}i\" \"%{User-Agent}i\"
        wsgi:
          daemon_process: aodh-api
          processes: ${_param:aodh_api_workers}
          threads: 1
          user: aodh
          group: aodh
          display_name: '%{GROUP}'
          script_alias: '/ /usr/share/aodh/app.wsgi'
          application_group: '%{GLOBAL}'
          authorization: 'On'
