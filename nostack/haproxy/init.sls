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
  service:
    - running
    - enable: True
    - require:
      - pkg: haproxy
    - watch:
      - file: haproxy
