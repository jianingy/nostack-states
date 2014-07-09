{% from "nostack/postgres/map.jinja" import postgres with context %}
{% for item in salt['pillar.get']('postgres:databases') %}
{% set db, attrs = item.items()[0] %}
create_db_{{ db }}:
  cmd.run:
    - name: {{ postgres.postgres_bin }}/createdb -h localhost
      {%- for attr in attrs %}
      {{- ' --owner %s ' % attr['owner'] if 'owner' in attr else ' ' }}
      {%- endfor %}
      {{- db }}; exit 0
    - user: postgres
{% endfor %}
