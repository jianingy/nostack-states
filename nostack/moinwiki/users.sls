
{% for wiki_name, settings in salt['pillar.get']('moinwiki').iteritems(): %}
{% set wiki_root = settings['wiki_root'] %}
{% set wiki_url = settings['wiki_url'] %}
{% for name, values in settings.get('users', []).iteritems() %}
create_user:
  cmd.run:
    - name: >
        {{ wiki_root }}/bin/moin \
            --wiki-url="{{ wiki_url }}" \
            --config-dir="{{ wiki_root }}/wiki" \
            account create  \
            --name "{{ name }}" \
            --alias "{{ values.get('alias', name) }}" \
            --email "{{ values['email'] }}" \
            --password "{{ values['password'] }}"
{% endfor %}
{% endfor %}
