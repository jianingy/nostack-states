{% from "nostack/tinydns/map.jinja" import tinydns with context %}

djbdns:
  pkg.installed:
    - refresh: False

init:
  cmd.run:
    - name: >
            tinydns-conf nobody nobody
            {{ tinydns.root }} 
            {{ salt['grains.get']('fqdn_ip4', ['127.0.0.1'])[0] }}
    - user: root
    - unless: test -e {{ tinydns.root }}
