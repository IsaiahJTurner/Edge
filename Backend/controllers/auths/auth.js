var _ = require('underscore');
var mongoose = require('mongoose');
var plaid = require('plaid');
var User = mongoose.model('User');
var Transaction = mongoose.model('Transaction');
var Account = mongoose.model('Account');
var Auth = mongoose.model('Auth');
var config = require("../../config");

var plaidClient = config.plaid.client;
exports.delete = function(req, res) {
  Auth.findOne({
    _owner: req.session._user,
    _id: req.params.authId
  }, function(err, auth) {
    if (err) {
      var error = "Could not find auths.";
      console.log(error, err, auth);
      return res.json({
        errors: [{
          title: error
        }]
      });
    }
    if (!auth) {
      var error = "Could not find auth.";
      return res.json({
        errors: [{
          title: error
        }]
      });
    }
    Transaction.find({
      _auth: auth
    }).remove().exec(function(err) {
      if (err) {
        var error = "Failed to remove transactions.";
        console.log(error, err, auth);
        return res.json({
          errors: [{
            title: error
          }]
        })
      }
      Account.find({
        _auth: auth
      }).remove().exec(function(err) {
        if (err) {
          var error = "Failed to remove transactions.";
          console.log(error, err, auth);
          return res.json({
            errors: [{
              title: error
            }]
          })
        }
        plaidClient.deleteConnectUser(auth.accessToken, {}, function(err, response) {
          if (err) {
            var error = "Failed to remove bank acocunt.";
            console.log(error, err, auth, response);
            return res.json({
              errors: [{
                title: error
              }]
            })
          }
          auth.remove(function(err) {
            if (err) {
              var error = "Failed to remove auth.";
              console.log(error, err, auth);
              return res.json({
                errors: [{
                  title: error
                }]
              })
            }
            User.update({
              _id: auth._owner
            }, {
              '$pull': {
                  _auths: auth._id
              }
            }).exec(function(err, updated) {
              if (err) {
                var error = "Failed to remove auth from user.";
                console.log(error, err, updated, auth);
                return res.json({
                  errors: [{
                    title: error
                  }]
                });
              }
              res.json({})
            });
          });
        });
      });
    });
  });
}
