{%- from "backports/map.jinja" import salt_master with context %}

{%- if salt_master.maas is defined %}
{%- if salt_master.get('maas', {}).get('enabled', False) %}
# ihttps://mirantis.jira.com/browse/PROD-16139
salt_master.maas:
  file.patch:
    - source: salt://backports/files/patch-maas
    - hash: md5:6a77cfa56a833ad0c635c2102ccd8893
    - name: /usr/share/salt-formulas/env/_modules/maas.py

{%- endif %}
{%- endif %}

{%- if salt_master.openssh is defined %}
{%- if salt_master.get('openssh', {}).get('enabled', False) %}
# https://mirantis.jira.com/browse/PROD-17770
salt_master.openssh:
  file.patch:
    - source: salt://backports/files/patch-openssh
    - hash: md5:a6b295870eecbddac98f5829244335b2
    - name: /usr/share/salt-formulas/env/openssh/files/ssh_config

{%- endif %}
{%- endif %}

{%- if salt_master.contrail_snmp is defined %}
{%- if salt_master.get('contrail_snmp', {}).get('enabled', False) %}
# https://mirantis.jira.com/browse/PROD-17823

salt_master.contrail_snmp:
  file.patch:
    - source: salt://backports/files/patch-contrail-snmp-collector.conf
    - hash: md5:9e9a469b5e42d460de2869c6fb5e9a7d
    - name: /srv/salt/env/prd/opencontrail/files/3.0/contrail-snmp-collector.conf

{%- endif %}
{%- endif %}

{%- if salt_master.rabbitmq_telegraf is defined %}
{%- if salt_master.get('rabbitmq_telegraf', {}).get('enabled', False) %}
# https://mirantis.jira.com/browse/PROD-17026

salt_master.rabbitmq_telegraf_meta:
  file.patch:
    - source: salt://backports/files/patch-rabbitmq.meta.telegraf
    - hash: md5:207d92629eea72c8ab87fca03d653d7f
    - name: /srv/salt/env/prd/rabbitmq/meta/telegraf.yml

salt_master.rabbitmq_telegraf_files:
  file.patch:
    - source: salt://backports/files/patch-rabbitmq.files.telegraf
    - hash: md5:167d675af0f9e2739aea567bc9cc1156
    - name: /srv/salt/env/prd/rabbitmq/files/telegraf.conf

{%- endif %}
{%- endif %}

backports.salt_master.completed:
  test.nop
