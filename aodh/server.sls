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
    - source: salt://aodh/files/logging.conf
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
        values: {{ server }}
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
    - source: salt://aodh/files/logging.conf
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
        values: {{ server }}
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
  - watch:
    - file: /etc/aodh/aodh.conf
    - file: aodh_api_apache_config

{%- endif %}

aodh_server_services:
  service.running:
  - names: {{ server.services }}
  - enable: true
  - watch:
    - file: /etc/aodh/aodh.conf

{%- endif %}
{%- endif %}
