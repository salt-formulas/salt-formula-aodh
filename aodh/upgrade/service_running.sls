{%- from "aodh/map.jinja" import server,upgrade with context %}

aodh_task_service_running:
  test.show_notification:
    - text: "Running aodh.upgrade.service_running"

{%- if server.enabled %}
  {%- set aservices = server.services %}
  {%- if server.version not in ['mitaka'] %}
    {%- do aservices.append('apache2') %}
  {%- endif %}
  {%- for aservice in aservices %}
aodh_service_running_{{ aservice }}:
  service.running:
  - name: {{ aservice }}
  - enable: True
  {%- endfor %}
{%- endif %}
