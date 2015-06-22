from django.core.cache import cache

from taste.apps.lumberjack.middleware import LoggingMiddleware

class Summary(LoggingMiddleware):
    """
    Outputs a summary of cache events once a response is ready.
    """

    logger_name = LoggingMiddleware.logger_name +'.cache'

    attrs_to_track = ['set', 'get', 'delete', 'add', 'get_many']
    
    def process_request(self, request):
        from taste.apps.lumberjack.utils.stats import track
        from taste.apps.lumberjack.utils.stats import stats
        stats.reset()

        # save our current attributes
        self.old = dict((k, getattr(cache, k)) for k in self.attrs_to_track)

        for k in self.attrs_to_track:
            setattr(cache, k, track(getattr(cache, k), 'cache'))

    def process_response(self, request, response):
        from taste.apps.lumberjack.utils.stats import stats

        calls = stats.get_total_calls('cache')
        hits = stats.get_total_hits('cache')
        misses = stats.get_total_misses_for_function('cache', cache.get) + stats.get_total_misses_for_function('cache', cache.get_many)

        if calls:
            ratio = int(hits / float(misses + hits) * 100)
        else:
            ratio = 100
        
        self.logger.info('%(calls)s calls made with a %(ratio)d%% hit percentage (%(misses)s misses)' % dict(
            calls = calls,
            ratio = ratio,
            hits = hits,
            misses = misses,
        ), extra = {'duration':stats.get_total_time('cache')})

        # set our attributes back to their defaults
        for k, v in self.old.iteritems():
            setattr(cache, k, v)

        return response