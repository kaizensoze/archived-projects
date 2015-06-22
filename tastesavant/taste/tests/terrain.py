from django.core import management
from lettuce import before, after, world
from splinter.browser import Browser
from django.test.utils import setup_test_environment


@before.all
def setup_browser():
    setup_test_environment()
    management.call_command('syncdb', all=True, interactive=False, verbosity=0)
    management.call_command('migrate', all=True, fake=True, verbosity=0)
    management.call_command('loaddata', 'minimal', verbosity=0)
    # world.browser = Browser('zope.testbrowser')
    world.browser = Browser()


@after.all
def close_browser(total):
    world.browser.quit()


# @before.each_scenario
# def set_database_to_fixture(scenario):
#     return
#     management.call_command('flush', interactive=False, verbosity=0)
#     management.call_command('migrate', all=True, fake=True, verbosity=0)
#     management.call_command('loaddata', 'test_data', verbosity=0)

from tests.steps import *
