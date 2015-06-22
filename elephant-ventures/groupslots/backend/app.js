
var express = require('express')
  , app = express()
  , Q = require('q')
  , server = require('http').createServer(app)
  , io = require('socket.io').listen(server)
  , Sequelize = require('sequelize')
  , sleep = require('sleep')
  , crypto = require('crypto')
  , bcrypt = require('bcrypt');

var MemoryStore = express.session.MemoryStore
  , sessionStore = new MemoryStore();

// configure app
app.configure(function() {
  app.use(express.cookieParser());
  app.use(express.session({
    secret: 'secret',
    store: sessionStore
  }));
  app.enable('trust proxy');
});

// database connections
var connGroupSlots = new Sequelize('groupslots', 'groupslots', 'groupslots', {
  dialect: 'mysql',
  define: {
    freezeTableName: true,
    underscored: true,
    timestamps: false
  }
});
sessionStore.connGroupSlotsCasino = connGroupSlots;

// routing
app.get('/', function(req, res) {
  res.sendfile(__dirname + '/web/slot.html');
});

// web socket messaging
io.sockets.on('connection', function(socket) {
  // register
  socket.on('register', function(data) {
    register(socket, data);
  })
  .on('login', function(data) {
    login(socket, data);
  });
});

// have server start listening
server.listen(3000);
console.log('server listening on 3000');


// TODO: move everything below into a separate file
function hashPassword(password) {
  var salt = bcrypt.genSaltSync(10);
  var hashedPassword = bcrypt.hashSync(password, salt);
  return hashedPassword;
}

// Client sends fields to server to register.
// Verify that none of those sent fields exist for a user already in the database.
// If ok, create new user and insert into database with hashed password using bcrypt.
function register(socket, data) {
  var User = sessionStore.connGroupSlotsCasino.import(__dirname + '/db/models/User');

  // Verify data.
  User.find({ where: ["players_club_id = ? OR username = ? OR email = ?", data['playersClubId'], data['username'], data['email']] })
  .success(function(user) {
    var json = {};

    if (user == null) {
      var hashedPassword = hashPassword(data['password']);

      // TODO: generate auth token, store in db
      var salt = crypto.randomBytes(64).toString('hex');
      var authToken = crypto.createHmac('sha1', salt).update(data['username']).digest('hex');

      User.create({
        players_club_id: data['playersClubId'],
        username: data['username'],
        first_name: data['firstName'],
        last_name: data['lastName'],
        email: data['email'],
        password: hashedPassword,
        auth_token: authToken
      }).success(function(task) {
        json = {
          status: 'success',
          username: data['username']
        };
        socket.emit("register", json);
      });
    } else {
      var errorMessage;
      if (user['players_club_id'] === data['playersClubId']) {
        errorMessage = 'Players club id is unavailable.';
      } else if (user['username'] === data['username']) {
        errorMessage = 'Username is unavailable.';
      } else if (user['email'] === data['email']) {
        errorMessage = 'Email is unavailable.';
      }

      json = {
        status: 'error',
        message: errorMessage
      };
      socket.emit("register", json);
    }
  });
}

// Client sends players club id and password to the server to login.
// Server uses password to check against bcrypted hash in db
// to verify match. If match, return json with auth token.
function login(socket, data) {
  console.log('here');
  var User = sessionStore.connGroupSlotsCasino.import(__dirname + '/db/models/User');
  User.find({ where: {username: data['username']} }).success(function(user) {
    var json = {};

    if (user == null) {
      json = {
        status: 'error',
        message: 'Invalid username/password.'
      }
      socket.emit("login", json);
    } else {
      var validPassword = bcrypt.compareSync(data['password'], user['password']);
      if (!validPassword) {
        json = {
          status: 'error',
          message: 'Invalid username/password.'
        }
        socket.emit("login", json);
      } else {
        // TODO: return auth token
        json = {
          status: 'success'
        }
        socket.emit("login", json);
      }
    }
  });
}
