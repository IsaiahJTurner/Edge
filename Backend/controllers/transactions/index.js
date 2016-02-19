var _ = require('underscore');
var mongoose = require('mongoose');
var plaid = require('plaid');
var async = require('async');
var User = mongoose.model('User');
var Account = mongoose.model('Account');
var Transaction = mongoose.model('Transaction');

var config = require("../../config");

var plaidClient = config.plaid.client;

exports.get = function(req, res) {
  Account.find({
    owner: req.session.user
  }, function(err, accounts) {
    if (err) {
      var error = "Failed to find your accounts.";
      console.log(error, err);
      return res.json({
        errors: [{
          title: error
        }]
      });
    }
    var transactions = [];
    async.each(accounts, function(account, callback) {
      plaidClient.getConnectUser(account.accessToken, {
        gte: '30 days ago',
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
        response.transactions.map(function(transaction) {
          var transaction = Transaction({

          })
        });
        callback(null);
        console.log(err, response);
        console.log('You have ' + response.transactions.length +
          ' transactions from the last thirty days.');
      });
    }, function(err) {
      if (err) {
        return;
      }
      res.send("worked")
    });
  })
}

exports.post = function() {
  res.send("Coming soon");
}
