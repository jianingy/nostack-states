include:
  - nostack.shadowsocks

/etc/sv/shadowsocks/config.json:
  file.managed:
    - source: salt://nostack/shadowsocks/files/config.json.template
    - template: jinja

/etc/sv/shadowsocks/run:
  file.managed:
    - source: salt://nostack/shadowsocks/files/run.template
    - template: jinja

/etc/sv/shadowsocks/log/main:
  file.directory

/service/shadowsocks:
  file.symlink:
    - target: /etc/sv/shadowsocks
    - require:
      - file: /etc/sv/shadowsocks/run

