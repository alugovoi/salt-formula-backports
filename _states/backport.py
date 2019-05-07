import logging
from salt.exceptions import CommandExecutionError, SaltInvocationError

log = logging.getLogger(__name__)

def __virtual__():
    return True

def patch_applied(name,
          source=None,
          options='',
          dry_run_first=True,
          **kwargs):

    ret = {
        'name': name,
        'changes': {},
        'comment': '',
        'result': False,
    }

    hash_ = kwargs.pop('hash', None)
    content_pillar = kwargs.pop('content_pillar', None)

    data_pillar = __salt__['pillar.get'](content_pillar)
    log.debug('Patch %s data from pillar %s is going to be applied to  %s' % (name,content_pillar,source))

    try:
        if hash_ and __salt__['file.check_hash'](source, hash_):
            ret['result'] = True
            ret['comment'] = 'Patch is already applied'
            return ret
    except (SaltInvocationError, ValueError) as exc:
        ret['comment'] = exc.__str__()
        return ret
    except IOError:
        log.info("There is no original file %s available" % source)


    if __salt__['file.manage_file']( name=name,
                                     sfn=None,
                                     ret=None,
                                     source=None,
                                     source_sum=None,
                                     user=None,
                                     group=None,
                                     mode=None,
                                     saltenv='base',
                                     backup=None,
                                     makedirs=True,
                                     template=None,
                                     show_changes=False,
                                     contents=data_pillar,
                                     dir_mode=None):
         ret['comment'] = 'Patch file was created'


    patch_ret = __salt__['file.patch'](source, name)
    log.debug('Returning patch status %s' % patch_ret)
    if patch_ret:
        ret['comment'] = 'Patch file was succesfully applied'
        ret['result'] = True
        ret['changes'] = patch_ret.get('stdout',{})

    return ret
