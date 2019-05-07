{%- from "backports/map.jinja" import backports with context %}

{%- if pillar.backports is defined %}

{% set patch_directory = backports.get('patch_directory','/tmp/patches') %}

{% for fix, fix_data in backports.get('patches').iteritems() %}
{% for patch_source, patch_data in fix_data.iteritems() %}
{% set patch_filename = patch_directory + "/" + fix + patch_source.replace('/','_') + ".diff" %}

apply_patch_{{ fix }}_{{ patch_filename }}:
  backport.patch_applied:
    - name: {{ patch_filename }}
    - source: {{ patch_source }}
    - hash: {{ patch_data.md5sum }}
    - content_pillar: backports:patches:{{ fix }}:{{ patch_source }}:diff

{% endfor %}
{% endfor %}

{%- endif %}
backports.completed:
  test.nop
