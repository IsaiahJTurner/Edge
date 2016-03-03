var _ = require('underscore');
var mongoose = require('mongoose');
var User = mongoose.model('User');

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
  var email = req.body.data.attributes.email;
  if (!_.isString(email) || email.length < 6 || email.indexOf("@") < 0 ||
    email.indexOf(".") < 0) {
    var error = "Please enter a valid email address.";
    return res.json({
      errors: [{
        title: error
      }]
    });
  }
  var password = req.body.data.attributes.password;
  if (!_.isString(password) || password.length === 0) {
    var error = "Please enter a password.";
    return res.json({
      errors: [{
        title: error
      }]
    });
  }
  var user = new User({
    email: email,
    queryEmail: email.toLowerCase(),
    password: password
  })
  user.save(function(err, user) {
    if (err) {
      var error;
      if (err.code === 11000) {
        error = "A user with this email already exists";
      } else {
        error = "Could not create your account.";
        console.log(error, err);
      }
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
}
