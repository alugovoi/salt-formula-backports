=======================
 Salt formula backports
=======================
------------
 Readme file
------------

Setting up downstream mirror
============================

Setup formula syncronisation after you deployed Drivertain. The backport state can be used to apply any patches/modification which hadn't been included to offical packages. The state uses the backports:patches pillar to keep the neccessary information.

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
For example to enable patch on salt master's ntp formula

Add following class or define the  pillar on the salt master (make sure pillar is visible only for this particular node)::

  root@cfg01:/srv/salt/reclass# cat  ./classes/cluster/lab/infra/config/patches.yml
  applications:
    - backports

  parameters:
    backports:
      patches:
        compute_patch:    												# you can refer to jira issue, gerrit CR, salesforce ID or any other id.
          /etc/init/nova-compute-kvm-upstart.conf:       								# file to apply the patch
            md5sum: 34dd520613bda0bf572a3bcee5767d29									# md5sum of resulted file
            diff: |
                    --- /etc/init/nova-compute-kvm-upstart.conf     2018-03-31 20:48:30.000000000 +0800
                    +++ nova-compute-kvm-upstart.conf.orig  2019-05-07 20:58:26.601836128 +0800
                    @@ -1,7 +1,7 @@
                     description "OpenStack Compute"
                     author "Thomas Goirand <zigo@debian.org>"

                    -start on started libvirt-bin
                    +start on started libvirtd
                     stop on runlevel [!2345]

                     chdir /var/run


How to create a new patch
=========================

Back original file::

  cp /etc/init/nova-compute-kvm-upstart.conf nova-compute-kvm-upstart.conf.orig

Make the necessary  change::

  vim  /etc/init/nova-compute-kvm-upstart.conf

Run the diff command to see the difference between files::

  diff -u nova-compute-kvm-upstart.conf.orig /etc/init/nova-compute-kvm-upstart.conf

  --- /etc/init/nova-compute-kvm-upstart.conf     2018-03-31 20:48:30.000000000 +0800
  +++ nova-compute-kvm-upstart.conf.orig  2019-05-07 20:58:26.601836128 +0800
  @@ -1,7 +1,7 @@
   description "OpenStack Compute"
   author "Thomas Goirand <zigo@debian.org>"

  -start on started libvirt-bin
  +start on started libvirtd
   stop on runlevel [!2345]

   chdir /var/run

Save the output into files direcotry in formula::

  files/patch-init-nova-compute.conf

check the md5 sum for the file and add into resource::

  md5sum /etc/init/nova-compute-kvm-upstart.conf
  34dd520613bda0bf572a3bcee5767d29  /etc/init/nova-compute-kvm-upstart.conf

This info should be enough to create the pillar data::

  backports:
    patches:
      compute_patch:
        /etc/init/nova-compute-kvm-upstart.conf:
          md5sum: 34dd520613bda0bf572a3bcee5767d29
          diff: |
                  --- /etc/init/nova-compute-kvm-upstart.conf     2018-03-31 20:48:30.000000000 +0800
                  +++ nova-compute-kvm-upstart.conf.orig  2019-05-07 20:58:26.601836128 +0800
                  @@ -1,7 +1,7 @@
                   description "OpenStack Compute"
                   author "Thomas Goirand <zigo@debian.org>"

                  -start on started libvirt-bin
                  +start on started libvirtd
                   stop on runlevel [!2345]

                   chdir /var/run

If the patch data contains any special characters and pillar is failed to build you can use base64 enconding for patch code::


  backports:
    patches:
      compute_patch:
        /usr/share/salt-formulas/env/oslo_templates/files/queens/oslo/messaging/_rabbit.conf:
          md5sum: 73a3eebf769b3038a7c65a5019141938
          encoding: base64
          diff: |
                   RnJvbSBiOTIzMGIzMGYwNGRkOTE4YzliOWI0NzkzYjIwNWYwYTZmM2M2ZDZmIE1vbiBTZXAgMTcg
                     ...
                   ID0ge3sgX2RhdGEucnBjX3JldHJ5X2RlbGF5IH19Cit7JS0gZW5kaWYgJX0K


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
      patch_directory: "/tmp/patches"
      patches:
        PROD-26834:
          /usr/share/salt-formulas/env/jenkins/client/init.sls:
             md5sum: bdce63b782f9056338cd43114b9b7dfc
             diff: |
                    diff --git a/jenkins/client/init.sls b/jenkins/client/init.sls
                    index 9c8509c..85cacb3 100644
                     ......
                       - jenkins.client.throttle_category
                     {%- endif %}
          /usr/share/salt-formulas/env/jenkins/_states/jenkins_location.py:
            md5sum: e9212236971306230710b41493d7d2fa
            diff: |
                    diff --git a/_states/jenkins_location.py b/_states/jenkins_location.py
                    new file mode 100644
                    index 0000000..7aac8bf
                    ......
                    +                        ['CHANGED', 'EXISTS'],
                    +                        {'url': url, 'email': email},
                    +                        'location config')

