import os

from fabric import utils
from fabric.api import sudo, env, require, cd, run, prefix
from fabric.contrib import console


env.hosts = (
    # 'elk.tastesavant.com',
    'ec2-54-226-95-41.compute-1.amazonaws.com',
)
env.cities = (
    'www.tastesavant.com',
    'celeryd.tastesavant.com',
    'newyork.tastesavant.com',
    'chicago.tastesavant.com',
)
env.user = 'web'
env.password = ''
env.key_filename = 'taste.pem'


def update_webheads(tag):
    require('root', provided_by=('production'))
    codebase = env.codebase
    try:
        with cd(codebase):
            run('git fetch')
            run('git checkout %s -f' % tag)
            for city in env.cities:
                try:
                    sudo("supervisorctl restart %s" % city)
                except:
                    print "Error restarting %s" % city
    except:
        pass


def _setup_path():
    env.root = os.path.join('/var', 'www', env.environment)
    env.codebase = os.path.join(env.root, env.project)


def staging():
    env.hosts = (
        'caribou.tastesavant.com',
    )
    env.name = 'staging'
    env.project = 'taste'
    env.environment = 'playground.tastesavant.com'
    env.branch = 'develop'
    env.gunicorn = [
        'playground.tastesavant.com',
        'nyc.playground.tastesavant.com',
        'chi.playground.tastesavant.com',
        'london.playground.tastesavant.com',
        'la.playground.tastesavant.com',
        'bos.playground.tastesavant.com',
        'bklyn.playground.tastesavant.com',
        'celeryd.playground.tastesavant.com',
    ]
    _setup_path()


def production():
    env.name = 'production'
    env.project = 'taste'
    env.environment = 'www.tastesavant.com'
    env.branch = 'master'
    env.gunicorn = [
        'www.tastesavant.com',
        'chicago.tastesavant.com',
        'newyork.tastesavant.com',
        'celeryd.beta.tastesavant.com',
    ]
    _setup_path()


def git_pull():
    require('root', provided_by=('staging', 'production'))
    codebase = env.codebase
    with cd(codebase):
        run("git pull origin %(branch)s" % env)


def collect_static():
    with cd(env.codebase):
        with prefix('. /usr/local/bin/virtualenvwrapper.sh'):
            with prefix('workon {env}'.format(env=env.environment)):
                run(
                    "./manage.py collectstatic"
                    " --noinput --setting={settings}".format(
                        settings="settings." + env.name + "_base"
                    )
                )


def gunicorn_restart():
    require('root', provided_by=('staging', 'production'))
    for gunicorn_process in env.gunicorn:
        sudo("supervisorctl restart %s" % gunicorn_process)


def deploy():
    require('root', provided_by=('staging', 'production'))
    if env.name == 'production':
        confirm_message = 'Are you sure you want to deploy production?'
        if not console.confirm(confirm_message, default=False):
            utils.abort('Production deployment aborted.')
    git_pull()
    collect_static()
    gunicorn_restart()
