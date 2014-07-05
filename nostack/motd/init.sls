/etc/motd:
  file.managed:
    - source: salt://nostack/motd/files/motd.template
    - template: jinja
