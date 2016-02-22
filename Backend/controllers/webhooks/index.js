var _ = require('underscore');
var mongoose = require('mongoose');
var plaid = require('plaid');
var User = mongoose.model('User');
var Auth = mongoose.model('Auth');
var config = require("../../config");
var sync = require("../../sync");

var plaidClient = config.plaid.client;

exports.post = function(req, res) {
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
  }, function(err, auth) {
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
    if (body.code === 4) {
      auth.webhookAcknowledged = true;
      auth.save(function(err, auth) {
        if (err) {
          console.log("Could not save auth.", err, body);
          return res.status(500).send("");
        }
        res.send("");
      })
    }
  });
};
