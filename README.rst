=======================
 Salt formula backports
=======================
------------
 Readme file
------------

Setting up downstream mirror
============================

Setup formula syncronisation after you deployed Drivertain.

Step 1:
Check jenkins_admin_public_key and add it to service user in gerrit(git repo).

Got to https://gerrit.mirantis.com/login/
Login as "service" user.
Navigate to Setting -> SSH Public Keys.
Add new key.

Step 2:

Add following pillar to cicd leader::

  parameters:
    _param:
      jenkins_git_mirror_downstream_jobs:
        - name: salt-formula-backports
          downstream: formulas/salt-formula-backports
          upstream: "ssh://robot@gerrit.example.com:29418/formulas/salt-formula-backports"
          branches: master
    gerrit:
      client:
        project:
          formulas/salt-formula-backports:
            enabled: true
            description: Backport formula
            upstream: "ssh://robot@gerrit.example.com:29418/formulas/salt-formula-backports"
            access: ${gerrit:client:default_access}
            require_change_id: true
            require_agreement: false
            merge_content: true

Step 3:
Run the highstate on cid01 node::

  salt "cid01*" state.highstate

Setting up downstream mirror
============================

This this is how you can setup automated formula installation on salt master from local gerrit.
Step 1:
Add following pillar to config::

  root@cfg01:/srv/salt/reclass# cat  ./classes/cluster/mlab/infra/backports/formula.yml
  parameters:
    _param:
      local_salt_formulas: http://${_param:cicd_control_address}:8080/formulas
      local_salt_formulas_revision: master
    salt:
      master:
        environment:
          prd:
            formula:
              backports:
                source: git
                address: '${_param:local_salt_formulas}/salt-formula-backports'
                revision: ${_param:local_salt_formulas_revision}


Step 2:

Run the highstate on cfg01 node::

  salt 'cfg01*' state.highstate

How to enable specific patch
============================
For eample to enable nova init patch on compute

Add following class or define the  pillar on the compute::

  root@cfg01:/srv/salt/reclass# cat  ./classes/cluster/lab/infra/backports/os_compute.yml
  applications:
    - backports

  parameters:
    backports:
      vcp:
        os_compute:
          nova_init:
            enabled: True


How to create a new patch
=========================

Back original file::

  cp /etc/init/nova-compute-kvm-upstart.conf nova-compute-kvm-upstart.conf.orig

Make the necessary  change::

  vim  /etc/init/nova-compute-kvm-upstart.conf

Run the diff command to see the difference between files::

  diff nova-compute-kvm-upstart.conf.orig /etc/init/nova-compute-kvm-upstart.conf
  4c4
  < start on started libvirt-bin
  ---
  > start on started libvirtd

Save the output into files direcotry in formula::

  files/patch-init-nova-compute.conf

check the md5 sum for the file and add into resource::

  md5sum /etc/init/nova-compute-kvm-upstart.conf
  34dd520613bda0bf572a3bcee5767d29  /etc/init/nova-compute-kvm-upstart.conf

This info should be enough to create the resource::

  vcp.os_controller.nova.init:
    file.patch:
      - source: salt://backports/files/patch-init-nova-compute.conf
      - hash: md5:34dd520613bda0bf572a3bcee5767d29
      - name: /etc/init/nova-compute-kvm-upstart.conf

Best practice:
==============

1. Make sure product bug/ticket/review is created to resolve the problem in upstream.
2. Add a link to the product ticket/review next to the resource in the formula.
3. Make sure to add service restart if needed.
4. Pay attention to failed patch resources. Most likely this means that file was changed.  review the file and update or disable the patch if necessary.


Full pillar list:
=================

Pillar::

  applications:
    - backports

  parameters:
    backports:
      vcp:
        os_compute:
          nova_init:
            enabled: True
          apparmor_libvirt:
            enabled: True
          libvirt_exporter:
            enabled: True
        os_controller:
          nova_scheduler:
            enabled: True
      salt_master:
          maas:
           enabled: True
          openssh:
           enabled: True
          contrail_snmp:
           enabled: True
          rabbitmq_telegraf:
           enabled: True
