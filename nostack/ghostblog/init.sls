{% from "nostack/supervisor/map.jinja" import supervisor with context %}

nodejs:
{% if grains['os'] in ('Ubuntu',) %}
  pkgrepo.managed:
    - ppa: chris-lea/node.js
{% endif %}
  pkg.installed:
    - refresh: False
    - pkgs:
      - nodejs
      - npm

{% for blog_name, settings in salt['pillar.get']('ghostblog').iteritems(): %}
{% set blog_root = settings['blog_root'] %}

ghostblog:
  archive:
    - extracted
    - name: {{ blog_root }}
    - source: salt://nostack/ghostblog/files/ghost-0.4.2.zip
#    - source_hash: sha1=21c123bcdc4bc366261d8026d485b887bb448b60
    - archive_format: zip
    - if_missing: {{ blog_root }}

{{ blog_root }}:
  file.directory:
    - user: nobody
    - recurse:
      - user
    - require:
      - archive: ghostblog

prepare:
  cmd.run:
    - name: |
        npm install --production;
    - user: nobody
    - cwd: {{ blog_root }}
    - env:
      - HOME: /tmp
    - require:
      - file: {{ blog_root }}

{{ blog_root }}/config.js:
  file.managed:
    - source: salt://nostack/ghostblog/files/config.js.template
    - user: nobody
    - template: jinja
    - defaults:
      blog_name: {{ blog_name }}
      blog_root: {{ blog_root }}
      port: {{ settings['port'] }}

{{ blog_root }}/content/themes:
  file.recurse:
    - source: salt://nostack/ghostblog/files/themes
    - user: nobody

/etc/supervisor/conf.d/{{ blog_name }}.conf:
  file.managed:
    - source: salt://nostack/ghostblog/files/run.conf.template
    - template: jinja
    - defaults:
      blog_name: {{ blog_name }}
      blog_root: {{ blog_root }}
      port: {{ settings['port'] }}


{{ blog_name }}:
  supervisord:
    - running
    - restart: True
    - update: True
    - require:
      - file: /etc/supervisor/conf.d/{{ blog_name }}.conf
      - file: {{ blog_root }}/config.js

{% endfor %}
