109a110
>         match_host = spec_obj.get_scheduler_hint('match_host')
115a117,120
>                 break
>             if (match_host is not None) and (match_host not in
>                                              [host.host for host in hosts]):
>                 # The requested host is not found in filtered hosts
