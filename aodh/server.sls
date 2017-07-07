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
