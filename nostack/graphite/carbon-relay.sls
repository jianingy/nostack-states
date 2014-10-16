/etc/sv/carbon-relay/log/main:
  file.directory:
    - makedirs: True
    - mode: 0755

/etc/sv/carbon-relay/log/run:
  file.managed:
    - source: salt://nostack/graphite/files/sv/logrun.template
    - template: jinja
    - mode: 0755

/etc/sv/carbon-relay/run:
  file.managed:
    - source: salt://nostack/graphite/files/sv/carbon-relay/run.template
    - template: jinja
    - mode: 0755

/service/carbon-relay:
  file.symlink:
    - target: /etc/sv/carbon-relay
    - requires:
      - file: /etc/sv/carbon-relay/run
