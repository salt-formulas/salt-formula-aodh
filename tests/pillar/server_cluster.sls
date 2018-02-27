aodh:
  server:
    region: RegionOne
    enabled: true
    version: mitaka
    cluster: true
    ttl: 86400
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
