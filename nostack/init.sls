{%- from "nostack/common.jinja" import nostack with context -%}

saltutil.sync_all:
  module.run

include:
  - formula.openssh.config
  - formula.users
  - formula.sudoers
  - nostack.motd

zsh:
  pkg.installed
