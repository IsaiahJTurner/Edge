var express = require('express');
var bodyParser = require('body-parser');
var mongoose = require('mongoose');
var session = require('express-session');
var MongoStore = require('connect-mongo')(session);
var _ = require('underscore');

var config = require('./config');

var Transaction = require('./models/Transaction');
var User = require('./models/User');
var Auth = require('./models/Auth');
var Account = require('./models/Account');
var AppleDevice = require('./models/AppleDevice');

var apn = require('apn');

var service = require("./apns/service");

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
  users: {
    index: require('./controllers/users'),
    user: require('./controllers/users/user'),
  },
  auths: {
    index: require('./controllers/auths'),
    auth: require('./controllers/auths/auth')
  },
  accounts: require('./controllers/accounts'),
  passes: require('./controllers/passes'),
  webhooks: require('./controllers/webhooks'),
  appledevices: {
    index: require('./controllers/appledevices'),
    appledevice: require('./controllers/appledevices/appledevice'),
  },
  transactions: {
    index: require('./controllers/transactions'),
    transaction: require('./controllers/transactions/transaction'),
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

api.post("/users", controllers.users.index.post);
api.get("/users/:userId", controllers.users.user.get);
api.patch("/users/:userId", controllers.users.user.patch);

api.post("/auths", middleware.auth.requiresUser, controllers.auths.index.post);
api.get("/auths", middleware.auth.requiresUser, controllers.auths.index.get);
api.delete("/auths/:authId", middleware.auth.requiresUser, controllers.auths.auth.delete);

api.get("/accounts", middleware.auth.requiresUser, controllers.accounts.get);

api.get("/passes", middleware.auth.requiresUser, controllers.passes.get);
api.get("/passes/:passId", middleware.auth.requiresUser, controllers.passes.getOne);

api.post("/transactions", middleware.auth.requiresUser, controllers.transactions.index.post);
api.get("/transactions", middleware.auth.requiresUser, controllers.transactions.index.get);
api.get("/transactions/:transactionId", middleware.auth.requiresUser, controllers.transactions.transaction.get);
api.delete("/transactions/:transactionId", middleware.auth.requiresUser, controllers.transactions.transaction.delete);

api.post("/appledevices", controllers.appledevices.index.post);
api.get("/appledevices/:deviceId", middleware.auth.requiresUser, controllers.appledevices.appledevice.get);
api.patch("/appledevices/:deviceId", middleware.auth.requiresUser, controllers.appledevices.appledevice.patch);

api.post("/webhooks/plaid", controllers.webhooks.plaid);

app.get("/p", controllers.webhooks.phone);


app.get("/push", function(req, res) {
  AppleDevice.find({
    _owner: req.query.owner
  }, function(err, appledevices) {
    if (err) {
      return res.send({
        title: "Could not notify your devices.",
        err: err
      });
    }
    setTimeout(function() {
      var note = new apn.notification();
      note.setAlertText(req.query.text);
      note.badge = 0;
      service.pushNotification(note, _.pluck(appledevices, "token"));
    }, 10000)
    res.send("Sent to " + appledevices.length + " devices.")
  });
})
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
