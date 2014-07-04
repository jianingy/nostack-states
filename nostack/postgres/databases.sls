{% for db, attr in pillar['postgres']['databases'].iteritems() %}
create_db_{{ db }}:
  cmd.run:
    - name: /usr/bin/createdb --owner {{ attr['owner'] }} {{ db }}; exit 0
    - user: postgres
{% endfor %}
