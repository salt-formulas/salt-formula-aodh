
==================================
aodh
==================================

Aodh is an alarming service for OpenStack. It used to be a part of Ceilometer, but starting from Mitaka it
is a separate project. Aodh supports several types of alarms like threshold, event, composite and gnocchi-specific.
In cluster mode, coordination is enabled via tooz with Redis backend.
MySQL is used as a data backend for alarms and alarm history.

Sample pillars
==============

Cluster aodh service

.. code-block:: yaml

    aodh:
      server:
        enabled: true
        version: mitaka
        ttl: 86400
        cluster: true
      database:
        engine: "mysql+pymysql"
        host: 10.0.106.20
        port: 3306
        name: aodh
        user: aodh
        password: password
      bind:
        host: 10.0.106.20
        port: 8042
      identity:
        engine: keystone
        host: 10.0.106.20
        port: 35357
        tenant: service
        user: aodh
        password: password
      message_queue:
        engine: rabbitmq
        port: 5672
        user: openstack
        password: password
        virtual_host: '/openstack'
      cache:
        members:
        - host: 10.10.10.10
            port: 11211
        - host: 10.10.10.11
            port: 11211
        - host: 10.10.10.12
            port: 11211


Enhanced logging with logging.conf
----------------------------------

By default logging.conf is disabled.

That is possible to enable per-binary logging.conf with new variables:
  * openstack_log_appender - set it to true to enable log_config_append for all OpenStack services;
  * openstack_fluentd_handler_enabled - set to true to enable FluentHandler for all Openstack services.
  * openstack_ossyslog_handler_enabled - set to true to enable OSSysLogHandler for all Openstack services.

Only WatchedFileHandler, OSSysLogHandler and FluentHandler are available.

Also it is possible to configure this with pillar:

.. code-block:: yaml

  aodh:
    server:
      logging:
        log_appender: true
        log_handlers:
          watchedfile:
            enabled: true
          fluentd:
            enabled: true
          ossyslog:
            enabled: true

Development and testing
=======================

Development and test workflow with `Test Kitchen <http://kitchen.ci>`_ and
`kitchen-salt <https://github.com/simonmcc/kitchen-salt>`_ provisioner plugin.

Test Kitchen is a test harness tool to execute your configured code on one or more platforms in isolation.
There is a ``.kitchen.yml`` in main directory that defines *platforms* to be tested and *suites* to execute on them.

Kitchen CI can spin instances locally or remote, based on used *driver*.
For local development ``.kitchen.yml`` defines a `vagrant <https://github.com/test-kitchen/kitchen-vagrant>`_ or
`docker  <https://github.com/test-kitchen/kitchen-docker>`_ driver.

To use backend drivers or implement your CI follow the section `INTEGRATION.rst#Continuous Integration`__.

The `Busser <https://github.com/test-kitchen/busser>`_ *Verifier* is used to setup and run tests
implementated in `<repo>/test/integration`. It installs the particular driver to tested instance
(`Serverspec <https://github.com/neillturner/kitchen-verifier-serverspec>`_,
`InSpec <https://github.com/chef/kitchen-inspec>`_, Shell, Bats, ...) prior the verification is executed.

Usage:

.. code-block:: shell

  # list instances and status
  kitchen list

  # manually execute integration tests
  kitchen [test || [create|converge|verify|exec|login|destroy|...]] [instance] -t tests/integration

  # use with provided Makefile (ie: within CI pipeline)
  make kitchen



Read more
=========

* https://docs.openstack.org/cli-reference/aodh.html
* https://docs.openstack.org/developer/aodh/

Documentation and Bugs
======================

To learn how to install and update salt-formulas, consult the documentation
available online at:

    http://salt-formulas.readthedocs.io/

In the unfortunate event that bugs are discovered, they should be reported to
the appropriate issue tracker. Use Github issue tracker for specific salt
formula:

    https://github.com/salt-formulas/salt-formula-aodh/issues

For feature requests, bug reports or blueprints affecting entire ecosystem,
use Launchpad salt-formulas project:

    https://launchpad.net/salt-formulas

You can also join salt-formulas-users team and subscribe to mailing list:

    https://launchpad.net/~salt-formulas-users

Developers wishing to work on the salt-formulas projects should always base
their work on master branch and submit pull request against specific formula.

    https://github.com/salt-formulas/salt-formula-aodh

Any questions or feedback is always welcome so feel free to join our IRC
channel:

    #salt-formulas @ irc.freenode.net
