{%- from "aodh/map.jinja" import client with context %}
{%- if client.enabled %}

aodh_client_packages:
  pkg.installed:
  - names: {{ client.pkgs }}

{%- endif %}
