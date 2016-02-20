var bcrypt = require('bcrypt');
var _ = require('underscore');
var mongoose = require('mongoose');
var User = mongoose.model('User');

exports.get = function(req, res) {
  res.json({
    "jsonapi": {
      "version": "1.0"
    }
  });
};

exports.signout = function(req, res) {
  delete req.session._user;
  res.json({
    success: true
  });
};
exports.signin = function(req, res) {
  var email = req.body.email;
  if (!_.isString(email)) {
    var error = "Please enter your email address.";
    return res.json({
      errors: [{
        title: error
      }]
    });
  }
  var password = req.body.password;
  if (!_.isString(password)) {
    var error = "Please enter your password.";
    return res.json({
      errors: [{
        title: error
      }]
    });
  }
  User.findOne({
    email: email
  }, function(err, user) {
    if (err) {
      var error = "Failed to lookup your account. Try again?";
      console.log(error, err);
      return res.json({
        errors: [{
          title: error
        }]
      });
    }
    if (!user) {
      var error = "A user with this email does not exist.";
      return res.json({
        errors: [{
          title: error
        }]
      });
    }
    bcrypt.compare(password, user.password, function(err, isMatch) {
      if (err) {
        var error = "Unable to compare your password.";
        console.log(error, err);
        return res.json({
          errors: [{
            title: error
          }]
        });
      }
      if (!isMatch) {
        var error = "Your password was entered incorrectly.";
        return res.json({
          errors: [{
            title: error
          }]
        });
      }
      req.session._user = user._id.toString();
      res.json({
        data: user.toJSON()
      });
    });
  });
};
