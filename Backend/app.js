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

var api = express.Router();

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

app.use("/api/1.0", api);

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

api.get("/", controllers.index.get);
api.post("/signin", controllers.index.signin);
api.post("/signout", controllers.index.signout);

api.post("/users", controllers.users.post);
api.get("/users/:userId", controllers.users.getOne);

api.post("/accounts", middleware.auth.requiresUser, controllers.accounts.post);

app.get("/", function(req, res) {
  res.send("Welcome to Edge!");
})
app.listen(app.get('port'), function() {
  console.log('Started on port ' + app.get("port") + '!');
});
