{% from "nostack/postgres/map.jinja" import postgres with context %}
{% from "nostack/supervisor/map.jinja" import supervisor with context %}

{% if salt['grains.get']('os_family') in 'RedHat' %}
{% set osarch = salt['grains.get']('osarch') %}
repo-release:
  pkg.installed:
    - sources:
      - pgdg: "http://yum.postgresql.org/{{ postgres.major_version }}/redhat/rhel-6-{{osarch}}/pgdg-centos93-9.3-1.noarch.rpm"
{% endif %}

postgresql:
  pkg.installed:
    - refresh: False
    - name: {{ postgres.package }}
  service:
    - running
    - enable: true
    - name: {{ postgres.service }}
    - require:
      - pkg: {{ postgres.package }}
    - watch:
      - file: pg_hba.conf
      - file: postgresql.conf

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

log_directory:
  file.directory:
    - name: {{ postgres.log_directory }}
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

postgresql-server:
  supervisord.running
  require:
    - file: {{ supervisor.config_directory }}/postgresql-server.conf