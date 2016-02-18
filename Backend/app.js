var express = require('express');
var bodyParser = require('body-parser');
var mongoose = require('mongoose');
var session = require('express-session');
var MongoStore = require('connect-mongo')(session);

var config = require('./config');


var Transaction = require('./models/Transaction');
var User = require('./models/User');
var Account = require('./models/Account');

mongoose.connect(config.mongoURL);

var app = express();

app.set('port', (process.env.PORT || 3002));

app.use(bodyParser.json({
  type: ['application/json', 'application/vnd.api+json']
}));
app.use(session({
  secret: '@IsaiahJTurner-T1KYLDZRnBh7RompRhyNqx356EnY1yWg9AnYaSy8MGvQN0ZMw5',
  saveUninitialized: true,
  resave: false,
  name: "edge-session",
  store: new MongoStore({
    mongooseConnection: mongoose.connection
  })
}));

var controllers = {
  index: require('./controllers/'),
  users: require('./controllers/users'),
  accounts: require('./controllers/accounts')
};
var middleware = {
  auth: require('./middleware/auth')
};
app.use(function(req, res, next) {
  console.log(req.method + " " + req.path);
  next();
});
app.get("/", function(req, res) {
  res.json({
    "jsonapi": {
      "version": "1.0"
    }
  });
});
app.post("/signin", controllers.index.signin);
app.post("/signout", controllers.index.signout);

app.post("/users", controllers.users.post);
app.get("/users/:userId", controllers.users.getOne);

app.post("/accounts", middleware.auth.requiresUser, controllers.accounts.post);

app.listen(app.get('port'), function() {
  console.log('Started on port ' + app.get("port") + '!');
});
