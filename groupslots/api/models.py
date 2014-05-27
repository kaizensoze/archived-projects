import datetime

def create_models(db):
    # global User
    # class User(db.Model):
    #     players_club_id = db.Column(db.Unicode(255), unique = True)
    #     username = db.Column(db.Unicode(255), primary_key = True)
    #     first_name = db.Column(db.Unicode(255))
    #     last_name = db.Column(db.Unicode(255))
    #     email = db.Column(db.Unicode(255), unique = True)
    #     password = db.Column(db.Unicode(60))
    #     auth_token = db.Column(db.Unicode(40), unique = True)
    #     auth_token_expire = db.Column(db.DateTime())
    #     tier = db.Column(db.Integer())
    #     status = db.Column(db.Unicode(255))
    #     usergroup_id = db.Column(db.Integer()), db.ForeignKey('usergroup.id')
    #     invites = db.relationship('Invite', backref = 'user', lazy = 'dynamic')

    # global Usergroup
    # class Usergroup(db.Model):
    #     id = db.Column(db.Integer(), primary_key = True)
    #     created = db.Column(db.DateTime(), nullable = False)
    #     users = db.relationship('User', backref = 'usergroup', lazy = 'dynamic')
    #     invites = db.relationship('Invite', backref = 'usergroup', lazy = 'dynamic')
    #     challenges = db.relationship('Challenge', backref = 'usergroup', lazy = 'dynamic')

    # global Reward
    # class Reward(db.Model):
    #     id = db.Column(db.Integer(), primary_key = True)
    #     name = db.Column(db.Unicode(255), unique = True)
    #     category = db.Column(db.Unicode(255))
    #     points = db.Column(db.Integer())
    #     challenges = db.relationship('Challenge', backref = 'reward', lazy = 'dynamic')
    #     status = db.Column(db.Unicode(255))
        
    # global Challenge
    # class Challenge(db.Model):
    #     id = db.Column(db.Integer(), primary_key = True)
    #     reward_id = db.Column(db.Integer(), db.ForeignKey('reward.id'), nullable = False)
    #     usergroup_id = db.Column(db.Integer(), db.ForeignKey('usergroup.id'), nullable = False)
    #     scale = db.Column(db.Unicode(255), nullable = False)
    #     play_mode = db.Column(db.Unicode(255), nullable = False)
    #     meta = db.Column(db.Text(), nullable = False)
    #     expires = db.Column(db.DateTime(), nullable = False)
    #     current_points = db.Column(db.Integer())
    #     total_points = db.Column(db.Integer())
    #     status = db.Column(db.Unicode(255), nullable = False)

    # global Invite
    # class Invite(db.Model):
    #     id = db.Column(db.Integer(), primary_key = True)
    #     expires = db.Column(db.DateTime(), nullable = False)
    #     username = db.Column(db.Unicode(255), db.ForeignKey('user.username'), nullable = False)
    #     usergroup_id = db.Column(db.Integer(), db.ForeignKey('usergroup.id'), nullable = False)

    # global PointsHistory
    # class PointsHistory(db.Model):
    #     id = db.Column(db.Integer(), primary_key = True)
    #     username = db.Column(db.Unicode(255), db.ForeignKey('user.username'), nullable = False)
    #     usergroup_id = db.Column(db.Integer()), db.ForeignKey('usergroup.id')
    #     challenge_id = db.Column(db.Integer()), db.ForeignKey('challenge.id')
    #     points = db.Column(db.Integer(), nullable = False)
    #     timestamp = db.Column(db.DateTime(), nullable = False)

    # global UsergroupHistory
    # class UsergroupHistory(db.Model):
    #     id = db.Column(db.Integer(), primary_key = True)
    #     username = db.Column(db.Unicode(255), db.ForeignKey('user.username'), nullable = False)
    #     usergroup_id = db.Column(db.Integer(), db.ForeignKey('usergroup.id'), nullable = False)
    #     join_date = db.Column(db.DateTime(), nullable = False)
    #     leave_date = db.Column(db.DateTime())

    global LastWin
    class LastWin(db.Model):
        id = db.Column(db.Integer(), primary_key = True)
        amount = db.Column(db.Integer(), nullable = False)
        timestamp = db.Column(db.DateTime(), nullable = False)

        def __init__(self, amount):
            self.amount = amount
            self.timestamp = datetime.datetime.now()

    # commenting out # commenting out for now since we've switched to alembic 
    db.create_all()

