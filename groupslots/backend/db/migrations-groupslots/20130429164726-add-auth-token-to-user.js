var dbm = require('db-migrate');
var type = dbm.dataType;

exports.up = function(db, callback) {
  db.addColumn('user', 'auth_token', {
    type: 'string',
    notNull: true,
    unique: true,
    length: 40
  }, callback);
};

exports.down = function(db, callback) {
  db.removeColumn('user', 'auth_token', callback);
};
