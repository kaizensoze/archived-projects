from base import *

DEBUG = True
# PIPELINE_ENABLED = True

AWS_ACCESS_KEY = 'AKIAJGARWJ453BAOA3QA'
AWS_SECRET_KEY = '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'
S3_STORAGE_BUCKET = 'storage.tastesavant.com'
S3_CNAME = S3_STORAGE_BUCKET
BACKUP_MEDIA_URL = '/'

DATABASES['default'] = {
    'ENGINE': 'django.db.backends.mysql',
    'NAME': 'playground',
    'USER': 'caribou',
    'PASSWORD': 'T@s3~A*9',
    'HOST': 'caribou',
    'PORT': '',
}

## CACHING
# ---------------------------------------------------------------------------
CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.memcached.MemcachedCache',
        'LOCATION': '127.0.0.1:11211',
    }
}

## EMAIL
# ---------------------------------------------------------------------------
EMAIL_USE_TLS = True
EMAIL_HOST = 'smtp.gmail.com'
EMAIL_HOST_USER = 'hello@tastesavant.com'
EMAIL_HOST_PASSWORD = 'PXr7QWyZ'
EMAIL_PORT = 587

EMAIL_BACKEND = 'taste.admins_only.EmailBackend'

## TASK QUEUE
# ---------------------------------------------------------------------------
BROKER_URL = 'redis://caribou:6380/0'
CELERY_RESULT_BACKEND = "amqp"
CELERY_IGNORE_RESULT = True

## TESTING SEARCH
# ---------------------------------------------------------------------------
HAYSTACK_CONNECTIONS['default']['URL'] = 'http://caribou:8080/solr-test'

## FILE BACKEND
# ---------------------------------------------------------------------------
DEFAULT_FILE_STORAGE = 'django.core.files.storage.FileSystemStorage'

INSTALLED_APPS += (
    'debug_toolbar',
)

MIDDLEWARE_CLASSES += (
    'debug_toolbar.middleware.DebugToolbarMiddleware',
)

DEBUG_TOOLBAR_PANELS = (
    'debug_toolbar.panels.version.VersionDebugPanel',
    'debug_toolbar.panels.timer.TimerDebugPanel',
    'debug_toolbar.panels.settings_vars.SettingsVarsDebugPanel',
    'debug_toolbar.panels.headers.HeaderDebugPanel',
    'debug_toolbar.panels.request_vars.RequestVarsDebugPanel',
    'debug_toolbar.panels.template.TemplateDebugPanel',
    'debug_toolbar.panels.sql.SQLDebugPanel',
    'debug_toolbar.panels.signals.SignalDebugPanel',
    'debug_toolbar.panels.logger.LoggingPanel',
)

DEBUG_TOOLBAR_CONFIG = {
    "INTERCEPT_REDIRECTS": False,
}

INTERNAL_IPS = (
    '*',
)

CITIES = {
    1: 'Domain Root',
    2: 'Chicago',
    3: 'New York',
    4: 'London',
    5: 'Los Angeles',
    6: 'Boston',
    8: 'Brooklyn',
}
