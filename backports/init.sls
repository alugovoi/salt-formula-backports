{%- if pillar.backports is defined %}

{%- if pillar.backports.salt_master is defined %}
include:
- backports.salt_master
{%- endif %}

{%- if pillar.backports.vcp is defined %}
include:
- backports.vcp
{%- endif %}

{%- endif %}
backports.completed:
  test.nop
