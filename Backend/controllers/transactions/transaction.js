var _ = require('underscore');
var mongoose = require('mongoose');
var plaid = require('plaid');
var User = mongoose.model('User');
var Auth = mongoose.model('Auth');
var Transaction = mongoose.model('Transaction');

var config = require("../../config");

exports.get = function(req, res) {
  res.send("Coming soon");
}
exports.patch = function(req, res) {
  res.send("Coming soon");
}
exports.delete = function(req, res) {
  Transaction.findOne({
    _id: req.params.transactionId,
    _owner: req.session._user
  }, function(err, transaction) {
    if (err) {
      var error = "Failed to find transaction.";
      console.log(error, err, transaction);
      return res.json({
        errors: [{
          title: error
        }]
      })
    }
    if (!transaction) {
      var error = "This transaction does not exist.";
      console.log(error, err, transaction);
      return res.json({
        errors: [{
          title: error
        }]
      })
    }
    if (transaction.plaid_id) {
      var error = "You can't delete data from your bank.";
      console.log(error, err, transaction);
      return res.json({
        errors: [{
          title: error
        }]
      })
    }
    transaction.remove(function(err) {
      if (err) {
        var error = "Failed to remove transaction.";
        console.log(error, err, transaction);
        return res.json({
          errors: [{
            title: error
          }]
        })
      }
      res.json({});
    });
  })
}
