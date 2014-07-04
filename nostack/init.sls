{%- from "nostack/common.jinja" import nostack with context -%}

saltutil.sync_all:
  module.run
