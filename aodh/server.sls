{%- from "aodh/map.jinja" import server with context %}
{%- if server.enabled %}
# Exclude unsupported openstack versions
{%- if server.version not in ['liberty', 'juno', 'kilo'] %}

server_packages:
  pkg.installed:
  - names: {{ server.pkgs }}

/etc/aodh/aodh.conf:
  file.managed:
  - source: salt://aodh/files/{{ server.version }}/aodh.conf.{{ grains.os_family }}
  - template: jinja
  - require:
    - pkg: server_packages

{%- if not grains.get('noservices', False) %}

aodh_syncdb:
  cmd.run:
  - name: aodh-dbsync
  - require:
    - file: /etc/aodh/aodh.conf
    - pkg: server_packages

{%- endif %}

aodh_server_services:
  service.running:
  - names: {{ server.services }}
  - enable: true
  - watch:
    - file: /etc/aodh/aodh.conf

{%- endif %}
{%- endif %}
