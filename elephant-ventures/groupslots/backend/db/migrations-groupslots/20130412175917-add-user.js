var dbm = require('db-migrate');
var type = dbm.dataType;

exports.up = function(db, callback) {
  db.createTable('user', {
    id: {
      type: 'int',
      autoIncrement: true,
      primaryKey: true
    },
    players_club_id: {
      type: 'string',
      notNull: true,
      unique: true
    },
    username: {
      type: 'string',
      notNull: true,
      unique: true
    },
    first_name: {
      type: 'string',
      notNull: true
    },
    last_name: {
      type: 'string',
      notNull: true
    },
    email: {
      type: 'string',
      notNull: true,
      unique: true
    },
    password: {
      type: 'string',
      length: 60,
      notNull: true
    },
    tier: {
      type: 'int',
      defaultValue: '0'
    },
    status: {
      type: 'string',
      defaultValue: 'NEW'
    }
  }, callback);
};

exports.down = function(db, callback) {
  db.dropTable('user', callback);
};
