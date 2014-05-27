import flask
from flask import request

def create_methods(app, db, models):
    @app.route('/api/v1/user/register')
    def register():
        return 'test'

    @app.route('/api/v1/user/login')
    def login():
        return 'test'

    @app.route('/api/v1/invite/create')
    def invite():
        return 'test'

    @app.route('/api/v1/invite/<int:invite_id>/accept')
    def invite_accept(invite_id):
        return 'test'

    @app.route('/api/v1/invite/<int:invite_id>/reject')
    def invite_reject(invite_id):
        return 'test'

    @app.route('/api/v1/win', methods = ['POST'])
    def win():
        amount = request.form['amount']
        win = models.LastWin(amount)
        db.session.add(win)
        db.session.commit()
        return 'success'

    @app.route('/api/v1/lastwin', methods = ['GET'])
    def lastwin():
        lastwin = models.LastWin.query.order_by('-timestamp').first()
        result = {'amount': lastwin.amount, 'timestamp': lastwin.timestamp}
        return flask.jsonify(result)
