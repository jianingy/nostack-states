{% from "nostack/graphite/map.jinja" import graphiteweb with context %}

{{ graphiteweb.pkg}}:
  pkg.installed

{{ graphiteweb.log_dir }}:
  file.directory:
    - makedirs: True

/opt/graphite/webapp/graphite/graphite_wsgi.py:
  file.managed:
    - source: salt://nostack/graphite/files/graphite_wsgi.py

/opt/graphite/webapp/graphite/local_settings.py:
  file.managed:
    - source: salt://nostack/graphite/files/local_settings.py.template
    - template: jinja

syncdb:
  cmd.run:
    - name: {{ graphiteweb.python }} /opt/graphite/webapp/graphite/manage.py syncdb --noinput


/etc/sv/graphite-web/log/main:
  file.directory:
    - makedirs: True

/etc/sv/graphite-web/run:
  file.managed:
    - source: salt://nostack/graphite/files/sv/graphite-web/run.template
    - template: jinja
    - mode: 0755

/etc/sv/graphite-web/log/run:
  file.managed:
    - source: salt://nostack/graphite/files/sv/logrun.template
    - mode: 0755
    - template: jinja
