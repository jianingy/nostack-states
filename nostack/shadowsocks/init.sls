
virtualenv:
  pkg.installed:
    - name: python-virtualenv
    - refresh: False

/opt/shadowsocks:
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

shadowsocks:
  module.run:
    - name: pip.install
    - user: nobody
    - bin_env: /opt/shadowsocks
    - pkgs:
      - shadowsocks

