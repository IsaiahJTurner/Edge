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
