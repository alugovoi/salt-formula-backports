{%- from "backports/map.jinja" import vcp with context %}

{%- if vcp.get('os_compute', {}).nova_init is defined %}
{%- if vcp.get('os_compute', {}).get('nova_init', {}).get('enabled', False) %}
# https://mirantis.jira.com/browse/PROD-16018
vcp.os_controller.nova.init:
  file.patch:
    - source: salt://backports/files/patch-init-nova-compute.conf
    - hash: md5:34dd520613bda0bf572a3bcee5767d29
    - name: /etc/init/nova-compute-kvm-upstart.conf

{%- endif %}
{%- endif %}

{%- if vcp.get('os_compute', {}).apparmor_libvirt is defined %}
{%- if vcp.get('os_compute', {}).get('apparmor_libvirt', {}).get('enabled', False) %}
# https://bugs.launchpad.net/ubuntu/+source/libvirt/+bug/1403648

vcp.os_compute.apparmor:
  file.patch:
    - source: salt://backports/files/patch-apparmor-libvirt-qemu
    - hash: md5:6e41b6084b13861eddb1679371904391
    - name: /etc/apparmor.d/abstractions/libvirt-qemu

backport.apparmor.reload:
  service.running:
    - enable: True
    - reload: True
    - name: apparmor
    - watch:
      - file: vcp.os_compute.apparmor

{%- endif %}
{%- endif %}

{%- if vcp.get('os_compute', {}).libvirt_exporter is defined %}
{%- if vcp.get('os_compute', {}).get('libvirt_exporter', {}).get('enabled', False) %}
# https://mirantis.jira.com/browse/PROD-17421

vcp.os_compute.libvirt_exporter:
  file.patch:
    - source: salt://backports/files/patch-libvirt-exporter
    - hash: md5:9b397f26f3e9c2373a31e7e0decae833
    - name: /etc/init.d/libvirt-exporter

backport.libvirt_exporter.restart:
  service.running:
    - enable: True
    - reload: True
    - name: libvirt-exporter
    - watch:
      - file: vcp.os_compute.libvirt_exporter

{%- endif %}
{%- endif %}

{%- if vcp.get('os_controller', {}).nova_scheduler is defined %}
{%- if vcp.get('os_controller', {}).get('nova_scheduler', {}).get('enabled', False) %}
# https://review.fuel-infra.org/#/c/37638
# https://review.fuel-infra.org/#/c/37615

vcp.os_controller.nova.filter_scheduler:
  file.patch:
    - source: salt://backports/files/patch-nova-scheduler-filter_scheduler.py
    - hash: md5:97b61fd93ff4030d43eb6d6ea7090e7b
    - name: /usr/lib/python2.7/dist-packages/nova/scheduler/filter_scheduler.py

vcp.os_controller.nova.conductor.manager:
  file.patch:
    - source: salt://backports/files/patch-nova-conductor-manager.py
    - hash: md5:5da941d18424626a6b2bf0e25071743c
    - name: /usr/lib/python2.7/dist-packages/nova/conductor/manager.py

backport.nova.conductor.restart:
  service.running:
    - enable: True
    - name: nova-conductor
    - watch:
      - file: vcp.os_controller.nova.conductor.manager

backport.nova.scheduler.restart:
  service.running:
    - enable: True
    - name: nova-scheduler
    - watch:
      - file: vcp.os_controller.nova.filter_scheduler

{%- endif %}
{%- endif %}

backports.vcp.completed:
  test.nop
