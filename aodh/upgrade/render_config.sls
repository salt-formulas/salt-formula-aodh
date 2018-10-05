{%- from "aodh/map.jinja" import server with context %}

aodh_render_config:
  test.show_notification:
    - text: "Running aodh.upgrade.render_config"

{%- if server.enabled %}
/etc/aodh/aodh.conf:
  file.managed:
  - source: salt://aodh/files/{{ server.version }}/aodh.conf.{{ grains.os_family }}
  - template: jinja
{%- endif %}
