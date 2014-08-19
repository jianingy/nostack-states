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

{{ rsyncd.secrets }}:
  file.managed:
    - source: salt://nostack/rsyncd/files/rsyncd.secrets.template
    - template: jinja
    - user: root
    - group: root
    - mode: 600

/etc/sv/rsyncd/run:
  file.managed:
    - source: salt://nostack/rsyncd/files/runit.template
    - template: jinja
    - mode: 0755
    - makedirs: True

/etc/sv/rsyncd/log/run:
  file.managed:
    - source: salt://nostack/files/runit-log.template
    - template: jinja
    - mode: 0755
    - makedirs: True

/etc/sv/rsyncd/log/main:
  file.directory

/service/rsyncd:
  file.symlink:
    - target: /etc/sv/rsyncd
    - require:
      - file: {{ rsyncd.config }}
    - watch:
      - file: {{ rsyncd.config }}
