var config = require("../config");
var crypto = require("crypto");

module.exports = function(phone, userId) {
  var shasum = crypto.createHash('sha1');
  shasum.update(phone + userId + config.twilio.hasherSecret);
  return shasum.digest('hex');
};
