629a630,631
>                 image_meta = objects.ImageMeta.from_image_ref(
>                     context, self.image_api, image_ref)
631c633,638
<                     context, image_ref, [instance])
---
>                     context, image_meta, [instance])
>                 filter_properties = {
>                     'scheduler_hints': {
>                         'match_host': host
>                     }
>                 }
633,638c640,647
<                     hosts = self._schedule_instances(
<                         context, request_spec, {})
<                     if host not in [h["host"] for h in hosts]:
<                         raise exception.NoValidHost(
<                             reason="Image is prohibited on this host."
<                         )
---
>                     # we only try to schedule the instance with the custom hint
>                     # if the source host doesn't allow rebuilding to the new
>                     # image scheduler throws an exception
>                     self._schedule_instances(
>                         context,
>                         request_spec,
>                         filter_properties
>                     )
645c654
<                         LOG.warning(_LW("No valid host found for rebuild"),
---
>                         LOG.warning(_LW("Image is prohibited on this host"),
