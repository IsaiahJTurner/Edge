var _ = require('underscore');
var mongoose = require('mongoose');
var plaid = require('plaid');
var User = mongoose.model('User');
var Auth = mongoose.model('Auth');
var config = require("../../config");
var sync = require("../../sync");

var plaidClient = config.plaid.client;
/*Auth.findOne({}, function(err, auth) {
  console.log(auth)
  plaidClient.getConnectUser(auth.accessToken, {
    gte: '30 days ago',
  }, function(err, response) {
    console.log(err, response);
    console.log('You have ' + response.transactions.length +
      ' transactions from the last thirty days.');
  });
})*/
exports.post = function(req, res) {
  if (!_.isObject(req.body.data)) {
    var error = "Please include data with your request.";
    return res.json({
      errors: [{
        title: error
      }]
    });
  }
  if (!_.isObject(req.body.data.attributes)) {
    var error = "Please include attributes with your request.";
    return res.json({
      errors: [{
        title: error
      }]
    });
  }
  var publicToken = req.body.data.attributes.publicToken;
  if (!_.isString(publicToken)) {
    var error = "Please include a public token with your request.";
    return res.json({
      errors: [{
        title: error
      }]
    });
  }
  plaidClient.exchangeToken(publicToken, function(err, response) {
    if (err) {
      if (!err.code) {
        var error = "There was an error validating your token.";
        console.log(error, err);
        return res.json({
          errors: [{
            title: error
          }]
        });
      }
      if (err.code) {
        if (err.code === 1106) {
          var error = "Your public token could not be validated.";
          console.log(error, err);
          return res.json({
            errors: [{
              title: error
            }]
          });
        }
        var error = "An unknown error occurred while validating your token.";
        console.log(error, err);
        return res.json({
          errors: [{
            title: error
          }]
        });
      }
    }
    plaidClient.patchConnectUser(response.access_token, {}, {
      webhook: config.plaid_webhook,
    }, function(err, mfaResponse, response) {
      if (err) {
        var error = "Failed to register for new transaction notifications.";
        console.log(error, err);
        return res.json({
          errors: [{
            title: error
          }]
        });
      }
      console.log(err, mfaResponse, response);
      plaidClient.getConnectUser(response.access_token, {
        gte: '3 days ago',
      }, function(err, response) {
        if (err) {
          var error = "Could not retrieve your user information";
          console.log(error, err);
          return res.json({
            errors: [{
              title: error
            }]
          });
        }
        console.log('You have ' + response.transactions.length +
          ' transactions from the last three days.');
        var auth = Auth({
          _owner: req.session._user,
          publicToken: publicToken,
          accessToken: response.access_token
        });
        auth.save(function(err, auth) {
          if (err) {
            var error = "Failed to save your auth.";
            console.log(error, err);
            return res.json({
              errors: [{
                title: error
              }]
            });
          }
          User.update({
            _id: req.session._user
          }, {
            $push: {
              _auths: auth._id
            }
          }, {

          }, function(err, updated) {
            if (err) {
              var error = "Could not assign the authentication to your account.";
              console.log(error, err);
              return res.json({
                errors: [{
                  title: error
                }]
              });
            }
            sync.accounts(response.accounts, {
              _owner: req.session._user,
              auth: auth
            }, function(err, accounts) {
              if (err) {
                var error = err.title;
                console.log(error, err);
                return res.json({
                  errors: [{
                    title: error
                  }]
                });
              }
              res.status(500).json({
                data: auth
              });
            });
          });
        });
      });
    });
  });
}

exports.get = function(req, res) {
  Auth.find({
    _owner: req.session._user
  }, function(err, auths) {
    if (err) {
      var error = "Failed to find your auths.";
      console.log(error, err);
      return res.json({
        errors: [{
          title: error
        }]
      });
    }
    res.json({
      data: auths
    })
  })
}
