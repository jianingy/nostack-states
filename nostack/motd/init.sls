/etc/motd:
  file.managed:
    - source: salt://nostack/motd/files/nostack.template
    - template: jinja
