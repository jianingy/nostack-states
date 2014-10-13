{% if salt['grains.get']('os') == 'CentOS' %}
pgdg-centos93:
  pkg.installed:
    - sources:
      - pgdg-centos93: http://yum.postgresql.org/9.3/redhat/rhel-6-{{ salt['grains.get']('osarch') }}/pgdg-centos93-9.3-1.noarch.rpm
{% endif %}

postgresql93-server:
  pkg.installed

postgresql93-contrib:
  pkg.installed

{{ salt['pillar.get']('postgres:log', '/export/pgsql/log') }}:
  file.directory:
    - makedirs: True

/etc/sysconfig/pgsql/postgresql-9.3:
  file.managed:
    - source: salt://nostack/postgres/files/sysconfig.template
    - template: jinja


initdb:
  cmd.run:
    - name: /etc/init.d/postgresql-9.3 initdb
    - unless: test -r {{ salt['pillar.get']('postgres:data', '/export/pgsql/data') }}/PG_VERSION
    - requires:
      - pkg: postgresql93-server
      - pkg: postgresql93-contrib

pg_hba.conf:
  file.managed:
    - name: {{ salt['pillar.get']('postgres:data', '/export/pgsql/data') }}/pg_hba.conf
    - source: salt://nostack/postgres/files/pg_hba.template
    - template: jinja

postgresql.conf:
  file.append:
    - name: {{ salt['pillar.get']('postgres:data', '/export/pgsql/data') }}/postgresql.conf
    - text: include 'postgresql_local.conf'

postgresql_local.conf:
  file.managed:
    - name: {{ salt['pillar.get']('postgres:data', '/export/pgsql/data') }}/postgresql_local.conf
    - source: salt://nostack/postgres/files/postgresql_local.template
    - template: jinja

postgresql-9.3:
  service:
    - running
    - enable: True
    - reload: True
    - requires:
      - cmd: initdb
    - watch:
      - file: pg_hba.conf
      - file: postgresql.conf
      - file: postgresql_local.conf
