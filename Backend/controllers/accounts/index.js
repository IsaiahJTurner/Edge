var _ = require('underscore');
var mongoose = require('mongoose');
var plaid = require('plaid');
var User = mongoose.model('User');
var Account = mongoose.model('Account');
var Auth = mongoose.model('Auth');
var config = require("../../config");

var plaidClient = config.plaid.client;

exports.get = function(req, res) {
  Account.find({
    _owner: req.session._user
  }).exec(function(err, accounts) {
    if (err) {
      var error = "Failed to find your accounts.";
      console.log(error, err);
      return res.json({
        errors: [{
          title: error
        }]
      });
    }
    res.json({
      data: accounts
    })
  })
}
