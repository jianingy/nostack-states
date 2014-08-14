haproxy:
  pkg:
    - installed
  file:
    - managed
    - name: /etc/haproxy/haproxy.cfg
    - source: salt://nostack/haproxy/files/haproxy.cfg.template
    - user: root
    - group: root
    - mode: 644
    - template: jinja

/etc/sv/haproxy:
  file.recurse:
    - source: salt://nostack/haproxy/files/runit
    - file_mode: 0755

/service/haproxy:
  file.symlink:
    - target: /etc/sv/haproxy
