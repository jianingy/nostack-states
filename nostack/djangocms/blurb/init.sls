{% from "nostack/supervisor/map.jinja" import supervisor with context %}

python-virtualenv:
  pkg.installed

/opt/blurb.nostack.in:
  virtualenv.managed:
    - system_site_packages: False
    - requirements: salt://nostack/supervisor/files/requirements.txt

