{% from "nostack/supervisor/map.jinja" import supervisor with context %}
{% from "nostack/rsyncd/map.jinja" import rsyncd with context %}

rsync:
  pkg.installed

{{ rsyncd.config }}:
  file.managed:
    - source: salt://nostack/rsyncd/files/rsyncd.conf.template
    - template: jinja
    - user: root
    - group: root
    - mode: 600

{{ supervisor.config_directory }}/rsyncd.conf:
  file.managed:
    - source: salt://nostack/rsyncd/files/run.conf.template
    - template: jinja

rsyncd:
  supervisord:
    - running
    - update: True
    - watch:
      - file: {{ rsyncd.config }}