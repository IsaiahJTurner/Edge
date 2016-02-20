var _ = require('underscore');
var mongoose = require('mongoose');
var plaid = require('plaid');
var async = require('async');
var User = mongoose.model('User');
var Auth = mongoose.model('Auth');
var Transaction = mongoose.model('Transaction');
var sync = require("../../sync");

var config = require("../../config");

var plaidClient = config.plaid.client;

exports.get = function(req, res) {
  Auth.find({
    _owner: req.session._user
  }).populate("_accounts").exec(function(err, auths) {
    if (err) {
      var error = "Failed to find your auths.";
      console.log(error, err);
      return res.json({
        errors: [{
          title: error
        }]
      });
    }
    if (auths.length === 0) {
      var error = "You need to link a bank account first.";
      console.log(error, err);
      return res.json({
        errors: [{
          title: error
        }]
      });
    }
    // merges the accounts of each auth into one array of accounts
    var accounts = [].concat.apply([], _.pluck(auths, "_accounts"));
    var allTransactions = [];
    async.each(auths, function(auth, callback) {
      plaidClient.getConnectUser(auth.accessToken, {
        //gte: '30 days ago',
        pending: true
      }, function(err, response) {
        if (err) {
          var error = "Failed to retrieve your transactions.";
          console.log(error, err);
          callback(true);
          return res.json({
            errors: [{
              title: error
            }]
          });
        }
        allTransactions = allTransactions.concat(response.transactions);
        callback(null);
      });
    }, function(err) {
      if (err) {
        return;
      }
      sync.transactions(allTransactions, {
        _owner: req.session._user,
        accounts: accounts
      }, function(err, transactions) {
        if (err){
          var error = "Failed to sync your transactions.";
          console.log(error, err);
          return res.json({
            errors: [{
              title: error
            }]
          });
        }

        Transaction.find({
          _owner: req.session._user
        }, function(err, transactions) {
          if (err) {
            var error = "Could not find your transactions.";
            console.log(error, err);
            return res.json({
              errors: [{
                title: error
              }]
            });
          }
          res.json({
            data: transactions
          });
        });
      });
    });
  })
}

exports.post = function() {
  res.send("Coming soon");
}
