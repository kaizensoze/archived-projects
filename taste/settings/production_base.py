from base import *

PIPELINE_ENABLED = False

AWS_ACCESS_KEY = 'AKIAJGARWJ453BAOA3QA'
AWS_SECRET_KEY = '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'
S3_STORAGE_BUCKET = 'storage.tastesavant.com'
S3_CNAME = S3_STORAGE_BUCKET
BACKUP_MEDIA_URL = '/'

DATABASES['default'] = {
    'ENGINE': 'django.db.backends.mysql',
    'NAME': 'caribou',
    'USER': 'caribou',
    'PASSWORD': 'T@s3~A*9',
    'HOST': 'caribou',
    'PORT': '',
}

CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.memcached.MemcachedCache',
        'LOCATION': '127.0.0.1:11211',
    }
}

CITIES = {
    1: 'Domain Root',
    2: 'Chicago',
    3: 'New York',
    5: 'Los Angeles',
    6: 'Boston',
    8: 'Brooklyn',
}
