{%- from "aodh/map.jinja" import server with context %}

include:
 - aodh.upgrade.service_stopped
 - aodh.upgrade.pkgs_latest
 - aodh.upgrade.render_config
 - aodh.db.offline_sync
 - aodh.upgrade.service_running
