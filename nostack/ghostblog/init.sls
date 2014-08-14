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

/etc/sv/{{ blog_name }}/run:
  file.managed:
    - source: salt://nostack/ghostblog/files/runit.template
    - template: jinja
    - mode: 0755
    - makedirs: True
    - defaults:
      blog_name: {{ blog_name }}
      blog_root: {{ blog_root }}
      port: {{ settings['port'] }}

/etc/sv/{{ blog_name }}/log/run:
  file.managed:
    - source: salt://nostack/files/runit-log.template
    - template: jinja
    - mode: 0755
    - makedirs: True

/etc/sv/{{ blog_name }}/log/main:
  file.directory

/service/{{ blog_name }}:
  file.symlink:
    - target: /etc/sv/{{ blog_name }}
    - require:
      - file: /etc/sv/{{ blog_name }}/run


{% endfor %}
