import urllib
import urlparse

from django.contrib.staticfiles.storage import CachedFilesMixin

from pipeline.storage import PipelineMixin

from storages.backends.s3boto import S3BotoStorage


# CachedFilesMixin doesn't play well with Boto and S3. It over-quotes things,
# causing erratic failures. So we subclass.
# (See http://stackoverflow.com/questions/11820566/inconsistent-
#    signaturedoesnotmatch-amazon-s3-with-django-pipeline-s3boto-and-st)
class PatchedCachedFilesMixin(CachedFilesMixin):
    def url(self, *a, **kw):
        s = super(PatchedCachedFilesMixin, self).url(*a, **kw)
        if isinstance(s, unicode):
            s = s.encode('utf-8', 'ignore')
        scheme, netloc, path, qs, anchor = urlparse.urlsplit(s)
        path = urllib.quote(path, '/%')
        qs = urllib.quote_plus(qs, ':&=')
        return urlparse.urlunsplit((scheme, netloc, path, qs, anchor))

class FixedS3BotoStorage(S3BotoStorage):
    def url(self, name):
        url = super(FixedS3BotoStorage, self).url(name)
        if name.endswith('/') and not url.endswith('/'):
            url += '/'
        return url

class S3PipelineStorage(
        PipelineMixin,
        # PatchedCachedFilesMixin,
        FixedS3BotoStorage):
    # For now, we take out the caching, as it's causing incredible slowness.
    pass
