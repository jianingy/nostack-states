{% from "nostack/supervisor/map.jinja" import supervisor with context %}

python-virtualenv:
  pkg.installed

{{ supervisor.root }}:
  virtualenv.managed:
    - system_site_packages: False
    - requirements: salt://nostack/supervisor/files/requirements.txt


/usr/bin/sv:
  file.symlink:
    - target: {{ supervisor.root }}/bin/supervisorctl
  require:
    - virtualenv: /opt/supervisor

/etc/supervisor:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 700
    - file_mode: 700
    - recurse:
      - user
      - group
      - mode

/etc/supervisor/conf.d:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 700
    - file_mode: 700
    - recurse:
      - user
      - group
      - mode

supervisor.conf:
  file.managed:
    - name: {{ supervisor.config }}
    - source: salt://nostack/supervisor/files/supervisord.conf
    - mode: 600

/etc/init/supervisor.conf:
  file.managed:
    - source: salt://nostack/supervisor/files/init.conf.template
    - template: jinja

supervisor:
  service.running
