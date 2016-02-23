var express = require('express');
var bodyParser = require('body-parser');
var mongoose = require('mongoose');
var session = require('express-session');
var MongoStore = require('connect-mongo')(session);

var config = require('./config');

var Transaction = require('./models/Transaction');
var User = require('./models/User');
var Auth = require('./models/Auth');
var Account = require('./models/Account');
var AppleDevice = require('./models/AppleDevice');


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
  }),
  cookie: {
    maxAge: 24 * 60 * 60 * 1000
  }
}));

app.use(function(req, res, next) {
  if (req.session._user) {
    req.session._user = mongoose.Types.ObjectId(req.session._user.toString());
  }
  next();
})
app.use("/api/v1.0", api);

var controllers = {
  index: require('./controllers/'),
  users: require('./controllers/users'),
  auths: require('./controllers/auths'),
  accounts: require('./controllers/accounts'),
  webhooks: require('./controllers/webhooks'),
  appledevices: require('./controllers/appledevices'),
  transactions: {
    index: require('./controllers/transactions'),
    transactionId: require('./controllers/transactions/transaction'),
  }
};
var middleware = {
  auth: require('./middleware/auth')
};
api.use(function(req, res, next) {
  console.log(req.method + " " + req.path);
  next();
});

api.get("/", controllers.index.get);
api.post("/signin", controllers.index.signin);
api.post("/signout", controllers.index.signout);

api.post("/users", controllers.users.post);
api.get("/users/:userId", controllers.users.getOne);

api.post("/auths", middleware.auth.requiresUser, controllers.auths.post);
api.get("/auths", middleware.auth.requiresUser, controllers.auths.get);

api.get("/accounts", middleware.auth.requiresUser, controllers.accounts.get);

api.post("/transactions", middleware.auth.requiresUser, controllers.transactions.index.post);
api.get("/transactions", middleware.auth.requiresUser, controllers.transactions.index.get);
api.get("/transactions/:transactionId", middleware.auth.requiresUser, controllers.transactions.transactionId.get);

api.post("/appledevices", controllers.appledevices.index.post);

api.post("/webhooks/plaid", controllers.webhooks.post);

app.get("/", function(req, res) {
  res.send("Welcome to Edge!");
})
app.get("/reset", function(req, res) {
  Transaction.remove({}).exec();
  Account.remove({}).exec();
  Auth.remove({}).exec();
  User.update({}, {
    $unset: {
      _auths: 1
    }
  }, function(err, updated) {
    res.json({
      err: err,
      updated: updated
    })
  });
})
app.listen(app.get('port'), function() {
  console.log('Started on port ' + app.get("port") + '!');
});
