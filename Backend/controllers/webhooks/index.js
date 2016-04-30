var _ = require('underscore');
var mongoose = require('mongoose');
var plaid = require('plaid');
var User = mongoose.model('User');
var Auth = mongoose.model('Auth');
var config = require("../../config");
var phoneHasher = require("../../helpers/phone-hasher");

var sync = require("../../sync");

var plaidClient = config.plaid.client;

exports.phone = function(req, res) {
  var userId = req.query.u;
  var code = req.query.c;
  User.findOne({
    _id: userId
  }, function(err, user) {
    if (err) {
      var error = "Could not find user for phone verification.";
      console.log(error, err, user, userId, code);
      return res.send(error);
    }
    if (phoneHasher(user.phone, user._id) !== code) {
      return res.send("Invalid code!");
    }
    user.phoneIsVerified = true;
    user.save(function(err, user) {
      if (err) {
        var error = "Could not update user with verified phone.";
        console.log(error, err, user, userId, code);
        return res.send(error);
      }
      res.send("Your phone has been verified.")
    });
  });
}

exports.plaid = function(req, res) {
  var body = req.body;
  console.log(body)
  if (!_.isObject(body)) {
    return res.status(400).json({
      needs: "body"
    });
  }
  var accessToken = body.access_token;
  if (!accessToken) {
    return res.status(401).json({
      go: "away"
    });
  }
  Auth.findOne({
    accessToken: accessToken
  }).populate("_accounts").exec(function(err, auth) {
    if (err) {
      console.log("Could not find callback auth.", err, body);
      return res.status(500).send("");
    }
    if (!auth) {
      console.log("An auth for this access token could not be found.", err, body);
      return res.status(404).send("");
    }
    /*
      CODE	DETAILS
      0	Occurs once the initial transaction pull has finished.
      1	Occurs once the historical transaction pull has completed, shortly after the initial transaction pull.
      2	Occurs at set intervals throughout the day as data is updated from the financial institutions.
      3	Occurs when transactions have been removed from our system.
      4	Occurs when an user's webhook is updated via a PATCH request without credentials.
      Other	Triggered when an error has occurred. Includes the relevant Plaid error code with details on both the error type and steps for error resolution.
      */
    if (body.code === 0 || body.code === 1 || body.code === 2) {
      plaidClient.getConnectUser(auth.accessToken, {
        //gte: '30 days ago',
        pending: true
      }, function(err, response) {
        if (err) {
          console.log("Failed to retrieve webhook transactions.", err, body, auth);
          return res.status(500).send("");
        }
        allTransactions = allTransactions.concat(response.transactions);
        sync.transactions(allTransactions, {
          _owner: req.session._user,
          accounts: auth._accounts
        }, function(err, transactions) {
          if (err) {
            var error = "Failed to sync your transactions.";
            console.log(error, err);
            return res.json({
              errors: [{
                title: error
              }]
            });
          }
        });
      });
    } else if (body.code === 3) {
      // 3	Occurs when transactions have been removed from our system.
      var removedIds = body.removed_transactions;
      Transaction.update({
        plaid_id: {
          $in: removedIds
        }
      }, {
        removed: true
      }, {
        multi: true
      }, function(err, updated) {
        if (err) {
          console.log("Could not update removed transactions.", err, body, auth);
          return res.status(500).send("");
        }
        res.send("");
      });
    } else if (body.code === 4) {
      auth.webhookAcknowledged = true;
      auth.save(function(err, auth) {
        if (err) {
          console.log("Could not save auth.", err, body);
          return res.status(500).send("");
        }
        res.send("");
      })
    } else {
      console.log("Unknown error", body)
      res.send("");
    }
  });
};
