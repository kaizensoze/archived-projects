"""
Based on initial work from django-debug-toolbar
"""

from datetime import datetime
import sys
import traceback

import django
from django.db import connection
from django.db.backends import util
#from django.template import Node

from taste.apps.lumberjack.middleware import LoggingMiddleware
#from devserver.utils.stack import tidy_stacktrace, get_template_info
from taste.apps.lumberjack.utils.time import ms_from_timedelta
from lumberjack import settings

# # TODO:This should be set in the toolbar loader as a default and panels should
# # get a copy of the toolbar object with access to its config dictionary
# SQL_WARNING_THRESHOLD = getattr(settings, 'DEVSERVER_CONFIG', {}) \
#                             .get('SQL_WARNING_THRESHOLD', 500)

class DatabaseStatTracker(util.CursorDebugWrapper):
    """
    Replacement for CursorDebugWrapper which outputs information as it happens.
    """
    logger = None
    
    def execute(self, sql, params=()):
        start = datetime.now()
        try:
            return self.cursor.execute(sql, params)
        finally:
            stop = datetime.now()
            duration = ms_from_timedelta(stop - start)
            # stacktrace = tidy_stacktrace(traceback.extract_stack())
            # template_info = None
            # # TODO: can probably move this into utils
            # cur_frame = sys._getframe().f_back
            # try:
            #     while cur_frame is not None:
            #         if cur_frame.f_code.co_name == 'render':
            #             node = cur_frame.f_locals['self']
            #             if isinstance(node, Node):
            #                 template_info = get_template_info(node.source)
            #                 break
            #         cur_frame = cur_frame.f_back
            # except:
            #     pass
            # del cur_frame
            
            try:
                # XXX: It might just be more sane to not bother relying on this per #12923
                sql = self.db.ops.last_executed_query(self.cursor, sql, params)
            except:
                sql = sql % params
            if self.logger:
                self.logger.debug(sql, extra = {'duration':duration})
                if self.cursor.rowcount >= 0:
                    self.logger.debug('Found %s matching rows', self.cursor.rowcount, extra={'duration':duration})
            
            self.db.queries.append({
                'sql': sql,
                'time': duration,
            })
            
    def executemany(self, sql, param_list):
        start = datetime.now()
        try:
            return self.cursor.executemany(sql, param_list)
        finally:
            stop = datetime.now()
            duration = ms_from_timedelta(stop - start)
            
            if self.logger:
                message = sql

                message = 'Executed %s times\n%s' % message
            
                self.logger.debug(message, extra= {'duration':duration})
                self.logger.debug('Found %s matching rows' % self.cursor.rowcount, extra = {'duration':duration, 'id':'query'})
            
            self.db.queries.append({
                'sql': '%s times: %s' % (len(param_list), sql),
                'time': duration,
            })

class RealTime(LoggingMiddleware):
    """
    Outputs SQL queries as they happen.
    """
    
    logger_name = 'django.db.sql'
    
    def process_request(self, request):
        if not isinstance(util.CursorDebugWrapper, DatabaseStatTracker):
            self.old_cursor = util.CursorDebugWrapper
            util.CursorDebugWrapper = DatabaseStatTracker
        DatabaseStatTracker.logger = self.logger
    
    def process_response(self, request, response):
        if isinstance(util.CursorDebugWrapper, DatabaseStatTracker):
            util.CursorDebugWrapper = self.old_cursor
        return response

class Summary(LoggingMiddleware):
    """
    Outputs a summary SQL queries.
    """
    
    logger_name = 'django.db.summary'
    
    def process_response(self, request, response):
        num_queries = len(connection.queries)

        if num_queries:
            unique = set([s['sql'] for s in connection.queries])
            self.logger.debug('%(calls)s queries with %(dupes)s duplicates' % dict(
                calls = num_queries,
                dupes = num_queries - len(unique),
            ), extra={'duration':sum(float(c.get('time', 0)) for c in connection.queries)})
        return response