{%- from "aodh/map.jinja" import server,upgrade with context %}

aodh_task_service_stopped:
  test.show_notification:
    - text: "Running aodh.upgrade.service_stopped"

{%- if server.enabled %}
  {%- set aservices = server.services %}
  {%- if server.version not in ['mitaka'] %}
    {%- do aservices.append('apache2') %}
  {%- endif %}
  {%- for aservice in aservices %}
aodh_service_stopped_{{ aservice }}:
  service.dead:
  - name: {{ aservice }}
  - enable: False
  {%- endfor %}
{%- endif %}
