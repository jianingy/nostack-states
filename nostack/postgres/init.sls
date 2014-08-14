{% from "nostack/postgres/map.jinja" import postgres with context %}

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

/etc/init.d/postgresql-9.3:
  file.managed:
    - mode: 400

/etc/sv/postgresql/run:
  file.managed:
    - source: salt://nostack/postgres/files/runit.template
    - template: jinja
    - mode: 0755
    - makedirs: True

/etc/sv/postgresql/log/run:
  file.managed:
    - source: salt://nostack/files/runit-log.template
    - template: jinja
    - mode: 0755
    - makedirs: True

/etc/sv/postgresql/log/main:
  file.directory

/service/postgresql:
  file.symlink:
    - target: /etc/sv/postgresql
    - require:
      - file: /etc/sv/postgresql/run
      - file: pg_hba.conf
      - file: postgresql.conf
