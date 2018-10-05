{%- from "aodh/map.jinja" import server with context %}

aodh_syncdb:
  cmd.run:
  - name: aodh-dbsync
  {%- if grains.get('noservices') or server.get('role', 'primary') == 'secondary' %}
  - onlyif: /bin/false
  {%- endif %}
