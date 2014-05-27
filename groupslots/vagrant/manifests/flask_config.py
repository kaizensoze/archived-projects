# WARNING -- This file is copied from ~/workspace/vagrant/manifests/flask_config.py
# If you do not edit it there, your changes will be overridden and lost
#
# Additionally, any changes to this file which should be reflected on production 
# must be placed in the deployment EV repository

DEBUG = True
SQLALCHEMY_DATABASE_URI = 'mysql://groupslots:groupslots@localhost/groupslots'