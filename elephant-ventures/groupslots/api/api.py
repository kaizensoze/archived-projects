import flask
import flask.ext.restless
import flask.ext.sqlalchemy
import flask_config

import datetime
import models
import methods
import pytz


app = flask.Flask(__name__)
app.config['DEBUG'] = flask_config.DEBUG
app.config['SQLALCHEMY_DATABASE_URI'] = flask_config.SQLALCHEMY_DATABASE_URI
db = flask.ext.sqlalchemy.SQLAlchemy(app)
models.create_models(db)

methods.create_methods(app, db, models)

_right_now = pytz.utc.localize(
    datetime.datetime.utcnow()).astimezone(pytz.timezone('America/New_York'))

@app.route('/')
def hello_world():
    return 'Hello World!\nStarted on {}\n'.format(
        _right_now.strftime('%Y-%m-%d %I:%M:%S %p'))
    
# manager = flask.ext.restless.APIManager(app, flask_sqlalchemy_db = db)
# manager.create_api(models.User, methods = ['GET', 'PUT'], url_prefix = '/api/v1')
# manager.create_api(models.Usergroup, methods = ['GET'], url_prefix = '/api/v1')
# manager.create_api(models.Reward, methods = ['GET', 'POST', 'PUT'], url_prefix = '/api/v1')
# manager.create_api(models.Challenge, methods = ['GET', 'POST', 'PUT'], url_prefix = '/api/v1')
# manager.create_api(models.Invite, methods = ['GET', 'POST', 'DELETE', 'PUT'], url_prefix = '/api/v1')

