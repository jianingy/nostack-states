{% from "nostack/graphite/map.jinja" import graphite_api with context -%}

graphite_api_packages:
  pkg.installed:
    - pkgs:
{%- for package in graphite_api.packages %}
      - {{ package }}
{% endfor -%}

/etc/sv/graphite-api/log/main:
  file.directory:
    - makedirs: True
    - mode: 0755

/etc/sv/graphite-api/log/run:
  file.managed:
    - source: salt://nostack/graphite/files/sv/logrun.template
    - template: jinja
    - mode: 0755

/etc/sv/graphite-api/run:
  file.managed:
    - source: salt://nostack/graphite/files/sv/graphite-api/run.template
    - template: jinja
    - mode: 0755

/service/graphite-api:
  file.symlink:
    - target: /etc/sv/graphite-api
    - requires:
      - file: /etc/sv/graphite-api/run
