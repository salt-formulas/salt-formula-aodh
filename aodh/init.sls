{%- if pillar.aodh is defined %}
include:
{%- if pillar.aodh.server is defined %}
- aodh.server
{%- endif %}
{%- if pillar.aodh.client is defined %}
- aodh.client
{%- endif %}
{%- endif %}
