{% from "nostack/graphite/map.jinja" import graphiteweb with context %}

graphiteweb_packages:
  pkg.installed:
    - pkgs:
{%- for package in graphiteweb.packages %}
      - {{ package }}
{% endfor -%}

{{ graphiteweb.log_dir }}:
  file.directory:
    - makedirs: True

/opt/graphite/webapp/graphite/graphite_wsgi.py:
  file.managed:
    - source: salt://nostack/graphite/files/graphite_wsgi.py
    - requires:
      - pkg: graphiteweb_packages

/opt/graphite/webapp/graphite/local_settings.py:
  file.managed:
    - source: salt://nostack/graphite/files/local_settings.py.template
    - template: jinja
    - requires:
      - pkg: graphiteweb_packages

syncdb:
  cmd.run:
    - name: {{ graphiteweb.python }} /opt/graphite/webapp/graphite/manage.py syncdb --noinput
    - env:
      - LD_LIBRARY_PATH: {{ graphiteweb.python_lib }}
    - requires:
      - pkg: graphiteweb_packages

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

{{ graphiteweb.python_lib }}/python2.7/site-packages/cairo/__init__.py:
  file.managed:
    - source: salt://nostack/graphite/files/cairo_patch.py
