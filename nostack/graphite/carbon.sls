{% from "nostack/graphite/map.jinja" import carbon with context -%}

carbon_packages:
  pkg.installed:
    - pkgs:
{%- for package in carbon.packages %}
      - {{ package }}
{% endfor -%}

{{ carbon.storage_dir }}:
  file.directory:
    - makedirs: True

{{ carbon.local_data_dir }}:
  file.directory:
    - makedirs: True

{{ carbon.whitelists_dir }}:
  file.directory:
    - makedirs: True

{{ carbon.log_dir }}:
  file.directory:
    - makedirs: True

{{ carbon.pid_dir }}:
  file.directory:
    - makedirs: True

/opt/graphite/conf/carbon.conf:
  file.managed:
    - source: salt://nostack/graphite/files/carbon.conf.template
    - template: jinja
    - mode: 644

/opt/graphite/conf/storage-schemas.conf:
  file.managed:
    - source: salt://nostack/graphite/files/storage-schemas.conf.template
    - template: jinja
    - mode: 644

{% for instance in salt['pillar.get']('carbon_cache:instances', [])  %}
/etc/sv/carbon-cache-{{ instance['name'] }}/log/main:
  file.directory:
    - makedirs: True
    - mode: 0755

/etc/sv/carbon-cache-{{ instance['name'] }}/log/run:
  file.managed:
    - source: salt://nostack/graphite/files/sv/logrun.template
    - template: jinja
    - mode: 0755

/etc/sv/carbon-cache-{{ instance['name'] }}/run:
  file.managed:
    - source: salt://nostack/graphite/files/sv/carbon/run.template
    - template: jinja
    - mode: 0755
    - defaults:
      instance_name: {{ instance['name'] }}

/service/carbon-cache-{{ instance['name'] }}:
  file.symlink:
    - target: /etc/sv/carbon-cache-{{ instance['name'] }}
    - requires:
      - file: /etc/sv/carbon-cache-{{ instance['name'] }}/run
{% endfor %}
