{% from "nostack/postgres/map.jinja" import postgres with context %}
{% from "nostack/supervisor/map.jinja" import supervisor with context %}

{% for name in postgres.packages %}
{{ name }}:
  pkg.installed:
    - refresh: False
    - fromrepo: pgdg93
{% endfor %}

postgres:
  user.present:
    - system: True
  group.present:
    - system: True

pg_hba.conf:
  file.managed:
    - name: /etc/postgres/{{ postgres.major_version }}/nostack/pg_hba.conf
    - source: salt://nostack/postgres/files/pg_hba.conf.template
    - template: jinja
    - mode: 640
    - user: postgres
    - group: postgres

postgresql.conf:
  file.managed:
    - name: /etc/postgres/{{ postgres.major_version }}/nostack/postgresql.conf
    - source: salt://nostack/postgres/files/postgresql.conf.template
    - template: jinja
    - mode: 644
    - user: postgres
    - group: postgres

conf_directory:
  file.directory:
    - name: /etc/postgres/{{ postgres.major_version }}/nostack
    - user: postgres
    - group: postgres
    - makedirs: true

log_directory:
  file.directory:
    - name: {{ postgres.log_directory }}
    - user: postgres
    - group: postgres
    - makedirs: true

run_directory:
  file.directory:
    - name: {{ postgres.run_directory }}
    - user: postgres
    - group: postgres
    - makedirs: true

data_directory:
  file.directory:
    - name: {{ postgres.data_directory }}
    - user: postgres
    - group: postgres
    - makedirs: true

initdb:
  cmd.run:
    - name: >
            {{ postgres.bin_directory }}/initdb
            -E {{ postgres.default_encoding }}
            -D {{ postgres.data_directory }}
    - user: postgres
    - unless: test -e {{ postgres.data_directory }}/PG_VERSION

{{ supervisor.config_directory }}/postgresql-server.conf:
  file.managed:
    - source: salt://nostack/postgres/files/run.conf.template
    - template: jinja

/etc/init.d/postgresql-9.3:
  file.managed:
    - mode: 400

postgresql-server:
  supervisord:
    - running
    - update: True
    - bin_env: {{ supervisor.root }}
    - conf_file: {{ supervisor.config }}
    - require:
      - file: {{ supervisor.config_directory }}/postgresql-server.conf
    - watch:
      - file: pg_hba.conf
      - file: postgresql.conf
