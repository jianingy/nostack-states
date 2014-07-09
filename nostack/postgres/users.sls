{% from "nostack/postgres/map.jinja" import postgres with context %}
{%- for item in salt['pillar.get']('postgres:users') %}
{%- set user, rights = item.items()[0] %}
create_user_{{ user }}:
  cmd.run:
    - user: postgres
    - name: >
            {{ postgres.postgres_bin }}/createuser -h localhost
            {%- for right in rights %}
               {{- ' -s ' if right.get('superuser', False) else ' ' }}
               {{- ' -d ' if right.get('createdb', False) else ' ' }}
               {{- ' -r ' if right.get('createrole', False) else ' ' }}
           {%- endfor %}
           {{- user }}; exit 0
{%- endfor %}