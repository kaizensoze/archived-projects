"""create base tables

Revision ID: 4c0c8006891f
Revises: None
Create Date: 2013-09-24 17:59:41.245338

"""

# revision identifiers, used by Alembic.
revision = '4c0c8006891f'
down_revision = None

from alembic import op
import sqlalchemy as sa


def upgrade():
    op.create_table(
        'users',
        sa.Column('players_club_id',sa.Unicode(255), unique = True),
        sa.Column('username',sa.Unicode(255), primary_key = True),
        sa.Column('first_name',sa.Unicode(255)),
        sa.Column('last_name',sa.Unicode(255)),
        sa.Column('email',sa.Unicode(255), unique = True),
        sa.Column('password',sa.Unicode(60)),
        sa.Column('auth_token',sa.Unicode(40), unique = True),
        sa.Column('auth_token_expire',sa.DateTime()),
        sa.Column('tier',sa.Integer()),
        sa.Column('status',sa.Unicode(255)),
        sa.Column('usergroup_id',sa.Integer()),
        )

    op.create_table(
        'last_win',
        sa.Column('players_club_id',sa.Unicode(255), unique = True),
        sa.Column('time',sa.DateTime()),
        sa.Column('amount',sa.Numeric()),
        )

def downgrade():
    op.drop_table('users')
    op.drop_table('last_win')
