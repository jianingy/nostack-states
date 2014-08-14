{% if grains['os_family'] in ('Debian',) %}
runit:
  pkg.installed:
    - refresh: False

/usr/sbin/runsvdir-start:
  file.replace:
    - pattern: '^runsvdir -P /etc/service'
    - repl: 'runsvdir -P /service'

/etc/service:
  file.absent

/service:
  file.directory:
    - makedirs: True
    - mode: 0755
    - user: root

runsvdir:
  service.running:
    - require:
      - file: /service
    - watch:
      - file: /usr/sbin/runsvdir-start

{% endif %}
