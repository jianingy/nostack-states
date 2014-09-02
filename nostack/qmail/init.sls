ucspi-tcp:
  pkg.installed

nofiles:
  group.present

qmail:
  group.present

{% for user in ['qmaild', 'qmaill', 'qmailp', 'alias'] %}
{{ user }}:
  user.present:
    - home: /var/qmail
    - system: True
    - shell: /sbin/nologin
    - groups:
        - qmail
    - require:
        - group: nofiles
{% endfor %}

{% for user in ['qmailq', 'qmailr', 'qmails'] %}
{{ user }}:
  user.present:
    - home: /var/qmail
    - system: True
    - shell: /sbin/nologin
    - groups:
        - qmail
    - require:
        - group: qmail
{% endfor %}

/usr/local/src:
  file.directory:
    - makedirs: True

qmail-source:
  archive.extracted:
    - name: /usr/local/src
    - source: http://qmail.org/netqmail-1.06.tar.gz
    - source_hash: md5=c922f776140b2c83043a6195901c67d3
    - tar_options: z
    - archive_format: tar
    - if_missing: /usr/local/src/netqmail-1.06
    - require:
        - file: /usr/local/src

salt://nostack/qmail/files/install.sh:
  cmd.script:
    - require:
        - archive: qmail-source
    - unless: test -x /var/qmail/bin/qmail-smtpd

/etc/init.d/qmailctl:
  file.managed:
    - source: salt://nostack/qmail/files/qmailctl

/etc/sv/qmail-send:
  file.directory:
    - makedirs: True

/etc/sv/qmail-send/log:
  file.directory

/etc/sv/qmail-smtpd:
  file.directory:
    - makedirs: True

/etc/sv/qmail-smtpd/log:
  file.directory

/etc/sv/qmail-send/run:
  file.managed:
    - source: salt://nostack/qmail/files/qmail-send.run
    - mode: 0755
    - require:
        - file: /etc/sv/qmail-send

/etc/sv/qmail-send/log/run:
  file.managed:
    - source: salt://nostack/qmail/files/log.run
    - mode: 0755
    - require:
        - file: /etc/sv/qmail-send/log

/etc/sv/qmail-smtpd/run:
  file.managed:
    - source: salt://nostack/qmail/files/qmail-smtpd.run
    - mode: 0755
    - require:
        - file: /etc/sv/qmail-smtpd

/etc/sv/qmail-smtpd/log/run:
  file.managed:
    - source: salt://nostack/qmail/files/log.run
    - mode: 0755
    - require:
        - file: /etc/sv/qmail-smtpd/log

/usr/sbin/qmailctl:
  file.managed:
    - source: salt://nostack/qmail/files/qmailctl
    - mode: 0755
