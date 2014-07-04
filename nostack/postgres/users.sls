{% for user, attr in pillar['postgres']['users'].iteritems() %}
create_user_{{ user }}:
  cmd.run:
    - name: >
            /usr/bin/createuser
            {%- if attr.get('superuser', False): %}
            -s
            {%- else: %}
            -S
            {%- endif %}
            {%- if attr.get('createdb', False): %}
            -d
            {%- else: %}
            -D
            {%- endif %}
            {%- if attr.get('createrole', False): %}
            -r
            {%- else: %}
            -R
            {%- endif %}
            {{ user }}; exit 0
    - user: postgres
{% endfor %}
