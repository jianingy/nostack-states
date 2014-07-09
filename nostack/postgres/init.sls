{% from "nostack/postgres/map.jinja" import postgres with context %}
{% from "nostack/supervisor/map.jinja" import supervisor with context %}

{% for name in postgres.packages %}
{{ name }}:
  pkg.installed:
    - refresh: True
    - fromrepo: pgdg93
{% endfor %}

# for omnipitr (pg replication)
perl-Time-HiRes:
  pkg.installed

postgres:
  user.present:
    - system: True
  group.present:
    - system: True

postgres_conf:
  file.directory:
    - name: {{ postgres.postgres_conf }}
    - user: postgres
    - group: postgres
    - dir_mode: 755
    - makedirs: true

pg_hba.conf:
  file.managed:
    - name: {{ postgres.postgres_conf }}/pg_hba.conf
    - source: salt://nostack/postgres/files/pg_hba.conf.template
    - template: jinja
    - mode: 640
    - user: postgres
    - group: postgres

postgresql.conf:
  file.managed:
    - name: {{ postgres.postgres_conf }}/postgresql.conf
    - source: salt://nostack/postgres/files/postgresql.conf.template
    - template: jinja
    - mode: 644
    - user: postgres
    - group: postgres

recovery.conf:
  file.managed:
    - name: {{ postgres.postgres_conf }}/recovery.conf.disable
    - source: salt://nostack/postgres/files/recovery.conf.template
    - template: jinja
    - mode: 644
    - user: postgres
    - group: postgres

postgres_log_directory:
  file.directory:
    - name: {{ postgres.postgres_log }}
    - user: postgres
    - group: postgres
    - makedirs: true

postgres_run_directory:
  file.directory:
    - name: {{ postgres.postgres_run }}
    - user: postgres
    - group: postgres
    - makedirs: true

postgres_data_directory:
  file.directory:
    - name: {{ postgres.postgres_data }}
    - user: postgres
    - group: postgres
    - makedirs: true

omnipitr_log_directory:
  file.directory:
    - name: {{ postgres.omnipitr_log }}
    - user: postgres
    - group: postgres
    - makedirs: true

omnipitr_state_directory:
  file.directory:
    - name: {{ postgres.omnipitr_state }}
    - user: postgres
    - group: postgres
    - makedirs: true

omnipitr_tmp_directory:
  file.directory:
    - name: {{ postgres.omnipitr_tmp }}
    - user: postgres
    - group: postgres
    - makedirs: true

initdb:
  cmd.run:
    - name: >
            {{ postgres.postgres_bin }}/initdb
            -E {{ postgres.default_encoding }}
            -D {{ postgres.postgres_data }}
    - user: postgres
    - unless: test -e {{ postgres.postgres_data }}/PG_VERSION

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
    - require:
      - file: {{ supervisor.config_directory }}/postgresql-server.conf
    - watch:
      - file: pg_hba.conf
      - file: postgresql.conf
