import os
import sys
import site

path = lambda p1,p2: os.path.abspath(os.path.join(p1,p2))

VIRTUALENV_PATH = '/home/web/.virtualenvs'
SITE_PACKAGES_PATH = path(VIRTUALENV_PATH,'playground.tastesavant.com/lib/python2.6/site-packages')

WORKING_PATH = os.path.abspath(os.path.dirname(__file__))
ROOT_PATH = path(WORKING_PATH, '../')

site.addsitedir(SITE_PACKAGES_PATH)

# Indicates to Celery to get its configuration info from Django settings file.
os.environ["CELERY_LOADER"] = "django"
os.environ['DJANGO_SETTINGS_MODULE'] = 'taste.settings.staging_bklyn'

# check virtualenv site-packages first.
sys.path.insert(0, SITE_PACKAGES_PATH)
sys.path.append(ROOT_PATH)
sys.path.append(path(ROOT_PATH, 'taste'))

bind = "0.0.0.0:8056"
logfile = "/var/log/gunicorn/bklyn.playground.tastesavant.com.log"
workers = 3
timeout = 60 * 5
