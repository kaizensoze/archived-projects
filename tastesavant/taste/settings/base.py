from django.template.defaultfilters import slugify

import os
import sys
import djcelery
from os.path import join, abspath, dirname
here = lambda *x: join(abspath(dirname(__file__)), *x)
# We're not in a modern Django layout, so this is shallower than it would
# otherwise be.
PROJECT_ROOT = here("..")
root = lambda *x: join(abspath(PROJECT_ROOT), *x)

## GLOBAL PATHS
# ---------------------------------------------------------------------------

ez_path = lambda p1, p2: os.path.abspath(os.path.join(p1, p2))

APPLICATIONS = root('apps')
MEDIA_ROOT = root('media')
STATIC_ROOT = root('static_root')

sys.path.insert(0, APPLICATIONS)

TEMPLATE_DIRS = (
    root('templates'),
)

## VERSION
# ---------------------------------------------------------------------------
VERSION = '1.6.7'

## DEBUGGING
# ---------------------------------------------------------------------------

DEBUG = False
TEMPLATE_DEBUG = False

ADMINS = (
    ('Taste Savant', 'errors@tastesavant.com'),
    ('Joe Gallo', 'gallo.j+errors@gmail.com'),
)

MANAGERS = ADMINS

ALLOWED_HOSTS = (
    '.tastesavant.com',
    # Elastic IP, which is for some reason being passed as the host header?
    '50.16.202.217',
)

## DATABASE
# ---------------------------------------------------------------------------

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': 'caribou',
        'USER': 'caribou',
        'PASSWORD': 'T@s3~A*9',
        'HOST': '',
        'PORT': '',
    }
}

## TASK QUEUE
# ---------------------------------------------------------------------------

djcelery.setup_loader()
CELERYBEAT_SCHEDULER = "djcelery.schedulers.DatabaseScheduler"

# BROKER_BACKEND = 'redis'
# BROKER_USER = 'redis'
# BROKER_HOST = 'localhost'
# BROKER_PORT = 6379
# BROKER_VHOST = '0'

BROKER_URL = 'redis://caribou:6379/0'

CELERY_IMPORTS = (
    "taste.apps.restaurants.tasks",
    "taste.apps.profiles.tasks",
    "taste.apps.invite.tasks",
    "taste.apps.seamless.tasks",
    "taste.apps.grubhub.tasks",
    "taste.apps.singleplatform.tasks",
)

CELERY_RESULT_BACKEND = BROKER_URL
CELERY_IGNORE_RESULT = False


## LOCALE
# ---------------------------------------------------------------------------

TIME_ZONE = 'America/New_York'
LANGUAGE_CODE = 'en-us'

CITIES = {
    1: 'Domain Root',
    2: 'Chicago',
    3: 'New York',
    4: 'London',
    5: 'Los Angeles',
    6: 'Boston',
    8: 'Brooklyn',
}

API_PRIVATE_CITIES = (
)

LAT_LNG = {
    'Domain Root': ('0', '0'),
    'New York': ('40.733785', '-74.002328'),
    'Chicago': ('41.8819', '-87.6278'),
    'London': ('51.507222', '-0.1275'),
    'Los Angeles': ('34.05', '-118.25'),
    'Boston': ('42.358056', '-71.063611'),
    'Brooklyn': ('40.703518', '-73.960743'),
}

GEOIP_RADIUS = {  # In miles:
    'Domain Root': 0,
    'New York': 100,
    'Chicago': 300,
    'London': 1500,
    'Los Angeles': 300,
    'Boston': 100,
    'Brooklyn': 100
}

#SITE_ID = Defined in the outer settings: nyc_settings, chi_settings, etc.
USE_I18N = True    # load the internationalization
USE_L10N = False   # format time accounding to current locale
USE_TZ = True

DATE_INPUT_FORMATS = (
    '%m-%d-%Y', '%m/%d/%Y', '%m/%d/%y', # '2006-10-25', '10/25/2006', '10/25/06'
    '%b %d %Y', '%b %d, %Y',            # 'Oct 25 2006', 'Oct 25, 2006'
    '%d %b %Y', '%d %b, %Y',            # '25 Oct 2006', '25 Oct, 2006'
    '%B %d %Y', '%B %d, %Y',            # 'October 25 2006', 'October 25, 2006'
    '%d %B %Y', '%d %B, %Y',            # '25 October 2006', '25 October, 2006'
)

## MEDIA
# ---------------------------------------------------------------------------

MEDIA_URL = '/media/'
COMPRESS_URL = '/static/'
# STATIC_URL = '/static/'
ADMIN_MEDIA_PREFIX = '/media/admin/'
DEFAULT_FILE_STORAGE = 'taste.custom_storages.FixedS3BotoStorage'
AWS_ACCESS_KEY_ID = 'AKIAJGARWJ453BAOA3QA'
AWS_SECRET_ACCESS_KEY = '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'
AWS_STORAGE_BUCKET_NAME = 'storage.tastesavant.com'
S3_URL = 'http://%s.s3.amazonaws.com/' % AWS_STORAGE_BUCKET_NAME
STATIC_URL = S3_URL
AWS_QUERYSTRING_AUTH = False
AWS_S3_SECURE_URLS = False

STATICFILES_FINDERS = (
    'django.contrib.staticfiles.finders.FileSystemFinder',
    'django.contrib.staticfiles.finders.AppDirectoriesFinder',
)
STATICFILES_DIRS = (
    root('static'),
)

STATICFILES_STORAGE = 'taste.custom_storages.FixedS3BotoStorage'

AVATAR_MAX_AVATARS_PER_USER = 1
AVATAR_AUTO_GENERATE_SIZES = (105, 30, 45)
AVATAR_GRAVATAR_BACKUP = False
AVATAR_DEFAULT_URL = '/images/profile-default-105px-105px.png'

########## PIPELINE CONFIGURATION
PIPELINE_CSS = {
    'base': {
        'source_filenames': (
            'css/base.css',
            'js/modal/FloatBox.css',
            'css/message-embedded.css',
        ),
        'output_filename': 'css/base-all.css',
    },
    'homepage': {
        'source_filenames': (
            'css/homepage.css',
            'css/checkbox-tree.css',
            'css/toplist.css',
            'css/registration.css',
        ),
        'output_filename': 'css/homepage-all.css',
    },
    'restaurants': {
        'source_filenames': (
            'css/restaurant.css',
            'css/small-search-widget.css',
            'css/checkbox-tree.css',
            'js/modal/FloatBox.css',
            'css/opentable-widget.css',
            'css/ranking-legend.css',
        ),
        'output_filename': 'css/restaurants-all.css',
    },
    'singleplatform': {
        'source_filenames': (
            'css/restaurant.css',
            'css/small-search-widget.css',
            'css/checkbox-tree.css',
            'js/modal/FloatBox.css',
            'css/opentable-widget.css',
            'css/ranking-legend.css',
            'css/menu.css',
        ),
        'output_filename': 'css/singleplatform-all.css',
    },
    'search': {
        'source_filenames': (
            'css/search.css',
            'css/small-search-widget.css',
            'css/ranking-legend.css',
            'css/checkbox-tree.css',
        ),
        'output_filename': 'css/search-all.css',
    },
    'search-users': {
        'source_filenames': (
            'css/search.css',
        ),
        'output_filename': 'css/search-users.css',
    },
    'profiles-delete': {
        'source_filenames': (
            'css/profiles.css',
        ),
        'output_filename': 'css/profiles-delete.css',
    },
    'profiles-edit': {
        'source_filenames': (
            'css/profiles.css',
            'css/ui-lightness/jquery-ui-1.8.16.custom.css',
            'css/containers.css',
        ),
        'output_filename': 'css/profiles-edit.css',
    },
    'profiles-detail': {
        'source_filenames': (
            'css/profiles.css',
            'css/search.css',
        ),
        'output_filename': 'css/profiles-detail.css',
    },
    'messages': {
        'source_filenames': (
            'css/messages.css',
        ),
        'output_filename': 'css/messages-all.css',
    },
    'messages-list': {
        'source_filenames': (
            'css/messages.css',
        ),
        'output_filename': 'css/messages-list.css',
    },
    'invite': {
        'source_filenames': (
            'css/invite.css',
            'css/multi-select.css',
        ),
        'output_filename': 'css/invite-all.css',
    },
    'critics': {
        'source_filenames': (
            'css/search.css',
            'css/restaurant.css',
            'css/critic-reviews.css',
        ),
        'output_filename': 'css/critics-all.css',
    },
    'blackbook': {
        'source_filenames': (
            'css/select2/select2.css',
            'css/blackbook.css',
        ),
        'output_filename': 'css/blackbook-all.css',
    },
    'mobile_splash': {
        'source_filenames': (
            'css/mobile_splash.css',
        ),
        'output_filename': 'css/mobile_splash-all.css',
    },
}

PIPELINE_JS = {
    'base': {
        'source_filenames': (
            'js/mootools.core.js',
            'js/mootools.more.js',
            'js/jquery-1.8.3.min.js',
            'js/jquery.tokeninput.js',
            'js/ajax-csrf.js',
            'js/Autocompleter.js',
            'js/Autocompleter.Local.js',
            'js/Autocompleter.Request.js',
            'js/Observer.js',
            # Above are common to all pages?
            'js/token-input.js',
            'js/clientcide.form.tips.js',
            'js/modal/FloatBox.js',
            'js/growing_packer.js',
            'js/masonry.pkgd.js',
            'js/base.js',
        ),
        'output_filename': 'js/base-all.js',
    },
    'homepage': {
        'source_filenames': (
            'js/toplist.js',
            'js/Fx.Scroll.Carousel.js',
            'js/checkbox-tree.js',
            'js/homepage.js',
            'js/activity.js',
        ),
        'output_filename': 'js/homepage-all.js',
    },
    'restaurants': {
        'source_filenames': (
            'js/checkbox-tree.js',
            'js/search-widget-small.js',
            'js/opentable-widget.js',
            'js/restaurant-images.js',
            'js/maps.js',
            'js/jquery.expander.min.js',
        ),
        'output_filename': 'js/restaurants-all.js'
    },
    'search': {
        'source_filenames': (
            'js/checkbox-tree.js',
            'js/search-widget-small.js',
            'js/maps.js',
        ),
        'output_filename': 'js/search-all.js'
    },
    'profiles-detail': {
        'source_filenames': (
            'js/jquery-ui.js',
            'js/activity.js',
            'js/profile-blackbook.js',
        ),
        'output_filename': 'js/profiles-detail.js',
    },
    'invite-facebook': {
        'source_filenames': (
            'js/typewatch.js',
        ),
        'output_filename': 'js/invite-facebook.js',
    },
    'invite-yahoo': {
        'source_filenames': (
            # 'js/jquery-1.8.3.min.js',
            'js/jquery.multi-select.js',
            'js/invite.js',
        ),
        'output_filename': 'js/invite-yahoo.js',
    },
    'blackbook': {
        'source_filenames': (
            'js/underscore-min.js',
            'js/backbone-min.js',
            'js/select2.js',
            'js/blackbook.js',
        ),
        'output_filename': 'js/blackbook-all.js',
    },
}
PIPELINE_CSS_COMPRESSOR = None  # No compression; GZip transfer will be enough.
PIPELINE_JS_COMPRESSOR = None  # No compression; GZip transfer will be enough.
PIPELINE_DISABLE_WRAPPER = True
########## END PIPELINE CONFIGURATION

## INTERNALS
# ---------------------------------------------------------------------------

SESSION_COOKIE_DOMAIN = '.tastesavant.com'

TEMPLATE_LOADERS = (
    'django.template.loaders.filesystem.Loader',
    'django.template.loaders.app_directories.Loader',
)

TEMPLATE_CONTEXT_PROCESSORS = (
    'django.contrib.auth.context_processors.auth',
    'django.core.context_processors.request',
    'django.core.context_processors.debug',
    'django.core.context_processors.i18n',
    'django.core.context_processors.media',
    'django.core.context_processors.tz',
    'django.contrib.messages.context_processors.messages',
    'django_messages.context_processors.inbox',

    'taste.context_processors.keys',
    'taste.context_processors.flatpages',
    'taste.context_processors.search',
    'taste.context_processors.tracking',
    'taste.context_processors.current_path',
    'taste.context_processors.all_cities',
    'taste.context_processors.current_city',
    'taste.context_processors.current_city_lat_lng',
    'taste.context_processors.debug_setting',
)

MIDDLEWARE_CLASSES = (
    # Johnny Cache
    # 'johnny.middleware.LocalStoreClearMiddleware',
    # 'johnny.middleware.QueryCacheMiddleware',

    # Django
    'django.middleware.gzip.GZipMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'taste.apps.middleware.CustomHoneypotMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.contrib.flatpages.middleware.FlatpageFallbackMiddleware',
    # 3rd party
    'minidetector.Middleware',
    # Custom
    'taste.apps.middleware.CustomGeoIPMiddleware',
    'taste.apps.middleware.RedirectIfMobileMiddleware',
)

ROOT_URLCONF = 'taste.urls'

INSTALLED_APPS = (
    'admin_tools',
    'avatar',
    'django_extensions',
    'djcelery',
    'djrill',
    'gunicorn',
    'haystack',
    'imagekit',
    'django_messages',
    'mptt',
    'pure_pagination',
    'registration',
    'social_auth',
    'south',
    'storages',
    'pipeline',
    'easy_thumbnails',
    'mailchimp',
    'minidetector',
    'rest_framework',
    'rest_framework.authtoken',
    'django_nose',
    'honeypot',

    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.sites',
    'django.contrib.staticfiles',
    'django.contrib.messages',
    'django.contrib.admin',
    'django.contrib.flatpages',
    'django.contrib.humanize',
    'django.contrib.sitemaps',

    'taste.apps.comingsoon',
    'taste.apps.critics',
    'taste.apps.homepage',
    'taste.apps.profiles',
    'taste.apps.reviews',
    'taste.apps.restaurants',
    'taste.apps.search',
    'taste.apps.signup_codes',
    'taste.apps.tracking',
    'taste.apps.blackbook',
    'taste.apps.newsfeed',
    'taste.apps.invite',
    'taste.apps.toplist',
    'taste.apps.singleplatform',
    'taste.apps.api',
    'taste.apps.press',
    'taste.apps.lumberjack',
    'taste.apps.simplestorage',
    'taste.apps.userfiles',
)

## HONEYPOT
# ---------------------------------------------------------------------------
HONEYPOT_FIELD_NAME = "password_check"


## DJANGO NOSE
# ---------------------------------------------------------------------------

TEST_RUNNER = 'django_nose.NoseTestSuiteRunner'
NOSE_ARGS = ['--exe', '--with-yanc']

## PAGINATION
# ---------------------------------------------------------------------------

PAGINATION_SETTINGS = {
    'PAGE_RANGE_DISPLAYED': 8,
    'MARGIN_PAGES_DISPLAYED': 2,
}

## OAUTH CONSUMER KEY/SECRET
# ---------------------------------------------------------------------------

TWITTER_CONSUMER_KEY = '31Wf8BAqUWgp8EJMINclRnZzk'
TWITTER_CONSUMER_SECRET = 'M0CfbIjl0qdG6UxzEEA2OdClc27aDGcINwWjHafTnCivIl8VKu'

FOURSQUARE_CONSUMER_KEY = 'CZIDKCSMWVZAYWIEPBZHU0RJOU5ZJQ1MNXGCWCW02YK3D2ZR'
FOURSQUARE_CONSUMER_SECRET = 'APVEZDN05PRDLNRAMG3ZIN25X2M0S4DQXBMNA3OZGXCS2HR4'
FOURSQUARE_SOCIAL_AUTH_NEW_ASSOCIATION_REDIRECT_URL = '/profiles/edit/'

# FACEBOOK_APP_ID = '221610771211198'
# FACEBOOK_API_SECRET = '4cd6adf1bab5236a94216e43218a755b'

FACEBOOK_APP_ID = '383119498397626'
FACEBOOK_API_SECRET = 'a912b2ed312389cb5845203f030c6f0e'

SECRET_KEY = '#f*er*0vqmy_s0lxqd*a=d(ni)#ra%=w8xc2a--z(ns@06w@#r'
GOOGLE_MAPS_KEY = ('ABQIAAAAMOGY88WF3qvtCxT1CF2ZFBTRaYC5CfhE_ZJHiTB82gmUQEWcJB'
                   'Q2kWJ54Yq6VVG99Avm8q_ptdXPpw')

#OAUTH
GOOGLE_CONSUMER_KEY = '523190991524.apps.googleusercontent.com'
GOOGLE_CONSUMER_SECRET = 's1PR_EgKYVarGp0Pvv036kui'

GOOGLE_OAUTH2_CLIENT_ID      = '523190991524.apps.googleusercontent.com'
GOOGLE_OAUTH2_CLIENT_SECRET  = 's1PR_EgKYVarGp0Pvv036kui'
GOOGLE_OAUTH_EXTRA_SCOPE = ['https://www.google.com/m8/feeds']

## USERS & AUTHENTICATION
# ---------------------------------------------------------------------------

AUTHENTICATION_BACKENDS = (
    'social_auth.backends.twitter.TwitterBackend',
    'social_auth.backends.facebook.FacebookBackend',
    'social_auth.backends.contrib.foursquare.FoursquareBackend',
    'social_auth.backends.google.GoogleOAuth2Backend',
    'social_auth.backends.yahoo.YahooBackend',
    'django.contrib.auth.backends.ModelBackend',
)

FACEBOOK_EXTENDED_PERMISSIONS = [
    'email',
    'user_birthday',
    'user_about_me',
    'user_hometown',
    'offline_access',
    'publish_actions',
]

GOOGLE_EXTENDED_PERMISSIONS = [
    'http://www.google.com/m8/feeds/'
]

LOGIN_REDIRECT_URL = '/'

# redirect to edit profile whenever a new user or association occurs.
SOCIAL_AUTH_NEW_USER_REDIRECT_URL = '/profiles/create/'
SOCIAL_AUTH_NEW_ASSOCIATION_REDIRECT_URL = '/profiles/create/'

# Try and associate multiple OAuth accounts by email address.
SOCIAL_AUTH_ASSOCIATE_BY_MAIL = True
SOCIAL_AUTH_SESSION_EXPIRATION = False

# Preferences for social-auth when creating new user accounts
SOCIAL_AUTH_USERNAME_FIXER = lambda u: slugify(u)

# If username generated is already in use, a UUID will be appended to avoid
# conflict - this UUID will be trucated to avoid ugly usernames.
SOCIAL_AUTH_UUID_LENGTH = 2

SOCIAL_AUTH_ASSOCIATION_SERVER_URL_LENGTH = 165
SOCIAL_AUTH_ASSOCIATION_HANDLE_LENGTH = 165

SOCIAL_AUTH_PIPELINE = (
    'taste.apps.profiles.backends.social_auth_link',
    #'social_auth.backends.pipeline.social.social_auth_user',
    # Removed by default since it can be a dangerouse behavior that
    # could lead to accounts take over.
    'social_auth.backends.pipeline.associate.associate_by_email',
    'social_auth.backends.pipeline.user.get_username',
    'social_auth.backends.pipeline.user.create_user',
    'social_auth.backends.pipeline.social.associate_user',
    'social_auth.backends.pipeline.social.load_extra_data',
    'social_auth.backends.pipeline.user.update_user_details',
    'taste.apps.profiles.backends.get_user_avatar',
)


# SEE: https://developer.apps.yahoo.com/projects
f_APP_ID = 'TZTrSp5i'
YAHOO_APP_ID = 'TZTrSp5i'
YAHOO_CONSUMER_KEY = ('dj0yJmk9ZDNIVmFNZ0JDVWR0JmQ9WVdrOVZGcFVjbE53TldrbWNHbzlOalF5T0RNeE5qWXkmcz1jb25zdW1lcnNlY3JldCZ4PTcy')
YAHOO_CONSUMER_SECRET = '6715b51f87ece9b2d361855a3d13a44f54248d74'

## SEARCH
# ---------------------------------------------------------------------------
HAYSTACK_CONNECTIONS = {
    'default': {
        'ENGINE': 'haystack.backends.solr_backend.SolrEngine',
        'URL': 'http://caribou:8080/solr',
    }
}

## EMAIL
# ---------------------------------------------------------------------------

ACCOUNT_ACTIVATION_DAYS = 7

DEFAULT_FROM_EMAIL = "'Taste Savant' <hello@tastesavant.com>"
SERVER_EMAIL = DEFAULT_FROM_EMAIL

MANDRILL_API_KEY = "S5XnIPQANHf5eDcu1zJdNQ"
EMAIL_BACKEND = "djrill.mail.backends.djrill.DjrillBackend"

## PROFILES
# ---------------------------------------------------------------------------

AUTH_PROFILE_MODULE = 'profiles.Profile'

## CACHING
# ---------------------------------------------------------------------------

# DISABLE_QUERYSET_CACHE = True
# CACHES = {
#    'default' : dict(
#        BACKEND = 'johnny.backends.memcached.MemcachedCache',
#        LOCATION = ['127.0.0.1:11211'],
#        JOHNNY_CACHE = False,
#    )
# }
# JOHNNY_MIDDLEWARE_KEY_PREFIX='beta_tastesavant'

CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.dummy.DummyCache',
    }
}

## REST FRAMEWORK
# ---------------------------------------------------------------------------
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': (
        'rest_framework.authentication.BasicAuthentication',
        'rest_framework.authentication.SessionAuthentication',
        'rest_framework.authentication.TokenAuthentication',
    )
}

## MAILCHIMP
# ---------------------------------------------------------------------------

MAILCHIMP_WEBHOOK_KEY = "Some arbitrary value, it doesn't matter, we don't use this."
MAILCHIMP_API_KEY = 'dce8c76ef081c99157b4b9f1cff4bc69-us2'
MAILCHIMP_LISTS = {
    'User Sign Ups': '9e81c4feb0',
    'Newsletter Sign Ups': 'c718fc2ad8'
}

## GEOIP
# ---------------------------------------------------------------------------
GEOIP_PATH = '/usr/share/GeoIP/'
GEOIP_LIBRARY_PATH = '/usr/lib/libGeoIP.so.1.4.6'

## SINGLEPLATFORM
# ---------------------------------------------------------------------------
SINGLEPLATFORM_API_KEY = 'kxqxse93go9gjnxz9tk0z78i5'
SINGLEPLATFORM_CLIENT_ID = 'cgnbbou7eduuybm5gxi1baf2n'
SINGLEPLATFORM_SIGNING_KEY = 'VvQWvsfbe4DSVyjJFIVJiO6KLveILTxSf-hB8rRIk-k'

## SEAMLESS
# ---------------------------------------------------------------------------
SEAMLESS_PARTNER_ID = '1002'
SEAMLESS_XML_TRACKING = '&cm_mmc=OTH-_-BizDev-_-Savant-_-Link'
SEAMLESS_XML_FEED_URL = 'http://content.seamlessweb.com/Partners/Feeds/ConsumerDirectURLs.xml'

## GRUBHUB
# ---------------------------------------------------------------------------
GRUBHUB_PARTNER_ID = '1087'
GRUBHUB_XML_FEED_URL = 'http://feeds.grubhub.com/r15xn2ruy2vbfnjm.xml'

## SOUTH
# ---------------------------------------------------------------------------
SOUTH_TESTS_MIGRATE = False
