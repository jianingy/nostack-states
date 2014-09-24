
virtualenv:
  pkg.installed:
    - name: python-virtualenv
    - refresh: False

{% for wiki_name, settings in salt['pillar.get']('moinwiki').iteritems(): %}
{% set wiki_root = settings['wiki_root'] %}

{{ wiki_root }}/requirements.txt:
  file.managed:
    - source: salt://nostack/moinwiki/files/requirements.txt

{{ wiki_root }}:
  virtualenv.managed:
    - system_site_packages: False
  file.directory:
    - user: nobody
    {% if grains['os'] in ('Ubuntu', 'Debian') %}
    - group: nogroup
    {% else %}
    - group: nobody
    {% endif %}
    - recurse:
      - user
      - group

{{ wiki_name }}_pip_install:
  module.run:
    - name: pip.install
    - user: nobody
    - bin_env: {{ wiki_root }}
    - download_cache: {{ pillar.get('pip_download_cache',
                                    '/tmp/pip-nobody-cache') }}
    - index_url: http://pypi.douban.com/simple
    - requirements: {{ wiki_root }}/requirements.txt
    - require:
      - file: {{ wiki_root }}/requirements.txt

{{ wiki_root }}/wiki:
  cmd.run:
    - name: rsync -a --include 'data/***' --include 'underlay/***' --exclude '*' .  {{ wiki_root }}/wiki
    - cwd: {{ wiki_root }}/share/moin/

{{ wiki_root }}/wiki/wsgi.py:
  file.managed:
    - user: nobody
    - source: salt://nostack/moinwiki/files/wsgi.py
    - makedirs: True

{{ wiki_root }}/wiki/wikiconfig.py:
  file.managed:
    - user: nobody
    - source: salt://nostack/moinwiki/files/wikiconfig.py
    - makedirs: True

/etc/sv/{{ wiki_name }}/run:
  file.managed:
    - source: salt://nostack/moinwiki/files/runit.template
    - template: jinja
    - mode: 0755
    - makedirs: True
    - defaults:
      wiki_name: {{ wiki_name }}
      wiki_root: {{ wiki_root }}
      port: {{ settings['port'] }}

/etc/sv/{{ wiki_name }}/log/run:
  file.managed:
    - source: salt://nostack/files/runit-log.template
    - template: jinja
    - mode: 0755
    - makedirs: True

/etc/sv/{{ wiki_name }}/log/main:
  file.directory

/service/{{ wiki_name }}:
  file.symlink:
    - target: /etc/sv/{{ wiki_name }}
    - require:
      - file: /etc/sv/{{ wiki_name }}/run

{% endfor %}
