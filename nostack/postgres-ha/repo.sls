{% from "nostack/postgres/map.jinja" import postgres with context %}

{% if salt['grains.get']('os_family') in 'RedHat' %}
{% set osarch = salt['grains.get']('osarch') %}
repo-release:
  pkg.installed:
    - sources:
      - pgdg-centos93: "http://yum.postgresql.org/{{ postgres.major_version }}/redhat/rhel-6-{{osarch}}/pgdg-centos93-9.3-1.noarch.rpm"
    - pkg_verify: False

{% endif %}
