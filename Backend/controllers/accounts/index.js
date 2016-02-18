var _ = require('underscore');
var mongoose = require('mongoose');
var plaid = require('plaid');
var User = mongoose.model('User');
var Account = mongoose.model('Account');
var config = require("../../config");

var plaidClient = config.plaid.client;
/*Account.findOne({}, function(err, account) {
  console.log(account)
  plaidClient.getConnectUser(account.accessToken, {
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
        var error =
          "An unknown error occurred while validating your token.";
        console.log(error, err);
        return res.json({
          errors: [{
            title: error
          }]
        });
      }
    }
    var account = Account({
      owner: req.session.user,
      publicToken: publicToken,
      accessToken: response.access_token
    });
    account.save(function(err, account) {
      if (err) {
        var error = "Failed to save your account.";
        console.log(error, err);
        return res.json({
          errors: [{
            title: error
          }]
        });
      }
      res.json({
        data: account
      });
    });
  });
}

exports.get = function(req, res) {

}
