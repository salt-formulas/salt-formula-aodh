{%- from "aodh/map.jinja" import server with context %}
{%- if server.enabled %}
# Exclude unsupported openstack versions
{%- if server.version not in ['liberty', 'juno', 'kilo'] %}

aodh_server_packages:
  pkg.installed:
  - names: {{ server.pkgs }}

/etc/aodh/aodh.conf:
  file.managed:
  - source: salt://aodh/files/{{ server.version }}/aodh.conf.{{ grains.os_family }}
  - template: jinja
  - require:
    - pkg: aodh_server_packages

{% for service_name in server.services %}
{{ service_name }}_default:
  file.managed:
    - name: /etc/default/{{ service_name }}
    - source: salt://aodh/files/default
    - template: jinja
    - defaults:
        service_name: {{ service_name }}
        values: {{ server }}
    - require:
      - pkg: aodh_server_packages
    - watch_in:
      - service: aodh_server_services
{% endfor %}

{% if server.logging.log_appender %}

{%- if server.logging.log_handlers.get('fluentd', {}).get('enabled', False) %}
aodh_fluentd_logger_package:
  pkg.installed:
    - name: python-fluent-logger
{%- endif %}

aodh_general_logging_conf:
  file.managed:
    - name: /etc/aodh/logging.conf
    - source: salt://oslo_templates/files/logging/_logging.conf
    - template: jinja
    - user: aodh
    - group: aodh
    - require:
      - pkg: aodh_server_packages
{%- if server.logging.log_handlers.get('fluentd', {}).get('enabled', False) %}
      - pkg: aodh_fluentd_logger_package
{%- endif %}
    - defaults:
        service_name: aodh
        _data: {{ server.logging }}
    - watch_in:
      - service: aodh_server_services
{%- if server.version not in ['mitaka'] %}
      - service: aodh_apache_restart
{%- endif %}

/var/log/aodh/aodh.log:
  file.managed:
    - user: aodh
    - group: aodh
    - watch_in:
      - service: aodh_server_services
{%- if server.version not in ['mitaka'] %}
      - service: aodh_apache_restart
{%- endif %}

{% for service_name in server.services %}
{{ service_name }}_logging_conf:
  file.managed:
    - name: /etc/aodh/logging/logging-{{ service_name }}.conf
    - source: salt://oslo_templates/files/logging/_logging.conf
    - template: jinja
    - user: aodh
    - group: aodh
    - require:
      - pkg: aodh_server_packages
{%- if server.logging.log_handlers.get('fluentd', {}).get('enabled', False) %}
      - pkg: aodh_fluentd_logger_package
{%- endif %}
    - makedirs: True
    - defaults:
        service_name: {{ service_name }}
        _data: {{ server.logging }}
    - watch_in:
      - service: aodh_server_services
{% endfor %}

{% endif %}

aodh_syncdb:
  cmd.run:
  - name: aodh-dbsync
  {%- if grains.get('noservices') %}
  - onlyif: /bin/false
  {%- endif %}
  - require:
    - file: /etc/aodh/aodh.conf
    - pkg: aodh_server_packages

{%- if server.get('role', 'secondary') == 'primary' %}
{%- set cron = server.expirer.cron %}
aodh_expirer_cron:
  cron.present:
    - name: /usr/bin/aodh-expirer
    - user: aodh
    - minute: '{{ cron.minute }}'
    {%- if cron.hour is defined %}
    - hour: '{{ cron.hour }}'
    {%- endif %}
    {%- if cron.daymonth is defined %}
    - daymonth: '{{ cron.daymonth }}'
    {%- endif %}
    {%- if cron.month is defined %}
    - month: '{{ cron.month }}'
    {%- endif %}
    {%- if cron.dayweek is defined %}
    - dayweek: '{{ cron.dayweek }}'
    {%- endif %}
    - require:
      - file: /etc/aodh/aodh.conf
{%- endif %}

# for Newton and newer
{%- if server.version not in ['mitaka'] %}

aodh_api_apache_config:
  file.managed:
  {%- if server.version == 'newton' %}
  - name: /etc/apache2/sites-available/apache-aodh.conf
  {%- else %}
  - name: /etc/apache2/sites-available/aodh-api.conf
  {%- endif %}
  - source: salt://aodh/files/{{ server.version }}/apache-aodh.apache2.conf.Debian
  - template: jinja
  - require:
    - pkg: aodh_server_packages

aodh_api_config:
  file.symlink:
     {%- if server.version == 'newton' %}
     - name: /etc/apache2/sites-enabled/apache-aodh.conf
     - target: /etc/apache2/sites-available/apache-aodh.conf
     {%- else %}
     - name: /etc/apache2/sites-enabled/aodh-api.conf
     - target: /etc/apache2/sites-available/aodh-api.conf
     {%- endif %}

aodh_apache_restart:
  service.running:
  - enable: true
  - name: apache2
  {%- if grains.get('noservices') %}
  - onlyif: /bin/false
  {%- endif %}
  - watch:
    - file: /etc/aodh/aodh.conf
    - file: aodh_api_apache_config

{%- if server.message_queue.get('ssl',{}).get('enabled', False) %}
rabbitmq_ca_aodh_server:
{%- if server.message_queue.ssl.cacert is defined %}
  file.managed:
    - name: {{ server.message_queue.ssl.cacert_file }}
    - contents_pillar: aodh:server:message_queue:ssl:cacert
    - mode: 0444
    - makedirs: true
    - require_in:
      - file: /etc/aodh/aodh.conf
    - watch_in:
      - aodh_server_services
{%- else %}
  file.exists:
   - name: {{ server.message_queue.ssl.get('cacert_file', server.cacert_file) }}
   - require_in:
     - file: /etc/aodh/aodh.conf
   - watch_in:
      - aodh_server_services
{%- endif %}
{%- endif %}


{%- if server.database.get('ssl',{}).get('enabled', False) %}
mysql_ca_aodh_server:
{%- if server.database.ssl.cacert is defined %}
  file.managed:
    - name: {{ server.database.ssl.cacert_file }}
    - contents_pillar: aodh:server:database:ssl:cacert
    - mode: 0444
    - makedirs: true
    - require_in:
      - file: /etc/aodh/aodh.conf
    - watch_in:
      - aodh_server_services
      - aodh_apache_restart

{%- else %}
  file.exists:
   - name: {{ server.database.ssl.get('cacert_file', server.cacert_file) }}
   - require_in:
     - file: /etc/aodh/aodh.conf
   - watch_in:
     - aodh_server_services
     - aodh_apache_restart
{%- endif %}
{%- endif %}

{%- endif %}

aodh_server_services:
  service.running:
  - names: {{ server.services }}
  - enable: true
  {%- if grains.get('noservices') %}
  - onlyif: /bin/false
  {%- endif %}
  - watch:
    - file: /etc/aodh/aodh.conf

{%- endif %}
{%- endif %}
