var _ = require('underscore');
var mongoose = require('mongoose');
var User = mongoose.model('User');
var config = require('../../config');
var phoneHasher = require("../../helpers/phone-hasher");
var twilio = require('twilio')(config.twilio.ACCOUNT_SID, config.twilio.AUTH_TOKEN);

exports.get = function(req, res) {
  var _user = req.params.userId;
  if (!_.isString(_user)) {
    var error = "Please include a user ID with your request.";
    return res.json({
      errors: [{
        title: error
      }]
    });
  }
  if (_user === "me") {
    _user = req.session._user
  }
  if (_user != req.session._user) {
    var error = "You are not authorized to get that user.";
    return res.json({
      errors: [{
        title: error
      }]
    });
  }
  if (!req.session._user) {
    var error = "You are not signed in.";
    return res.json({
      errors: [{
        title: error
      }]
    });
  }

  User.findOne({
    _id: _user
  }, function(err, user) {
    if (err || !user) {
      var error = "An error occured trying to look up your information.";
      console.log(error, err, user);
      return res.json({
        errors: [{
          title: error
        }]
      });
    }
    res.json({
      data: user.toJSON()
    });
  });
};

exports.patch = function(req, res) {
  console.log(req.body)
  var _user = req.params.userId;
  if (!_.isString(_user)) {
    var error = "Please include a user ID with your request.";
    return res.json({
      errors: [{
        title: error
      }]
    });
  }
  if (_user === "me") {
    _user = req.session._user;
  }
  if (_user != req.session._user) {
    var error = "You are not authorized to get that user.";
    return res.json({
      errors: [{
        title: error
      }]
    });
  }
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
  User.findOne({
    _id: _user
  }, function(err, user) {
    if (err || !user) {
      var error = "Unable to get your data.";
      console.log(error, err, user);
      return res.json({
        errors: [{
          title: error
        }]
      });
    }
    var email = req.body.data.attributes.email;
    if (email != user.email) {
      user.email = email;
      user.emailIsVerified = false;
    }
    var phone = req.body.data.attributes.phone;
    if (phone != user.phone) {
      user.phone = phone;
      user.phoneIsVerified = false;
    }
    user.name = req.body.data.attributes.name;
    user.textNotifications = req.body.data.attributes.textNotifications;
    user.emailNotifications = req.body.data.attributes.emailNotifications;
    user.save(function(err, user) {
      if (err || !user) {
        var error = "Could not save your account.";
        console.log(error, err, user);
        return res.json({
          errors: [{
            title: error
          }]
        });
      }
      if (!user.phoneIsVerified) {
        return twilio.sendMessage({
            to: user.phone,
            from: '+17738253343',
            body: "To enable text message notifications for Edge visit http://padding.tips/p?u=" + user._id + "&c=" + phoneHasher(phone, user._id)
        }, function(err, responseData) {
            if (err) {
                var error = "You account was updated but the phone verification text failed to send.";
                console.log(error, responseData, user);
                return res.json({
                  errors: [{
                    title: error
                  }]
                });
            }
            res.json({
              data: user
            })
        });
      }
      res.json({
        data: user
      })
    });
  });
}
