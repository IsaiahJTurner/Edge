var express = require('express');
var bodyParser = require('body-parser');
var mongoose = require('mongoose');
var plaid = require('plaid');
const session = require('express-session');
const MongoStore = require('connect-mongo')(session);
 

var Transaction = require('./models/Transaction');
var User = require('./models/User');

var mongoURL = "mongodb://edge:4bOw3B2XffjE0gZ79uPzTCc0YhtQbvyY8bvAufu61evJuTwoCZ@ds059185.mongolab.com:59185/edge";
mongoose.connect(mongoURL);


// public key: db0c7fe8afdfac06b1997b0d4a1b96
var plaidClient = new plaid.Client("56b96681db2afcb6184d2b85", "1940fb678863766d4068499b725774", plaid.environments.tartan);


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
  users: require('./controllers/users')
}
app.use(function(req,res,next) {
  console.log(req.method + " " + req.path + req.session.id, req.session);
  next();
})
app.get("/", controllers.index.get);
app.post("/login", controllers.index.login);

app.post("/users", controllers.users.post);
app.get("/users/:userId", controllers.users.getOne);

app.listen(app.get('port'), function() {
  console.log('Started!')
});