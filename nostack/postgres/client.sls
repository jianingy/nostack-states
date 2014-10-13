{% if salt['grains.get']('os') == 'CentOS' %}
pgdg-centos93:
  pkg.installed:
    - sources:
      - pgdg-centos93: http://yum.postgresql.org/9.3/redhat/rhel-6-{{ salt['grains.get']('osarch') }}/pgdg-centos93-9.3-1.noarch.rpm
{% endif %}

postgresql93:
  pkg.installed
