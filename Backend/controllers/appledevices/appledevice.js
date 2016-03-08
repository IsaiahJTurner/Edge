var _ = require('underscore');
var mongoose = require('mongoose');
var apn = require('apn');
var User = mongoose.model('User');
var AppleDevice = mongoose.model('AppleDevice');

var config = require("../../config");
var service = require("../../apns/service");

exports.patch = function(req, res) {
  var _appledevice = req.params.deviceId;
  if (!_.isString(_appledevice)) {
    var error = "You must include an ID with your request.";
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
  AppleDevice.findOne({
    _id: _appledevice
  }, function(err, appledevice) {
    if (err) {
      var error = "Could not find device";
      console.log(error, err);
      return res.json({
        errors: [{
          title: error
        }]
      });
    }
    if (req.session._user != appledevice._owner) {
      // if the Device header matches the requested device ID, update the AppleDevice to link to this user
      // this can happen if a user signs out and then signs in to a different account.
      if (req.headers.device !== appledevice.deviceId) {
        var error = "You are not authorized to access this device";
        console.log(error, appledevice, req.headers.device);
        return res.json({
          errors: [{
            title: error
          }]
        });
      }
      appledevice._owner = req.session._user
      appledevice.save(function(err, appledevice) {
        if (err) {
          var error = "Failed to save appledevice with new owner";
          console.log(error);
          return;
        }
      });
    }
    appledevice.transactionNotifications = Boolean(req.body.data.attributes.transactionNotifications);
    appledevice.allNotifications = Boolean(req.body.data.attributes.allNotifications);
    appledevice.save(function(err, appledevice) {
      if (err) {
        var error = "Could not save device.";
        console.log(error, err);
        return res.json({
          errors: [{
            title: error
          }]
        });
      }
      res.json({
        data: appledevice
      });
    });
  });
};

exports.get = function(req, res) {
  var _appledevice = req.params.deviceId;
  if (!_.isString(_appledevice)) {
    var error = "You must include an ID with your request.";
    return res.json({
      errors: [{
        title: error
      }]
    });
  }
  AppleDevice.findOne({
    _id: _appledevice
  }, function(err, appledevice) {
    if (err) {
      var error = "Could not find device.";
      console.log(error, err);
      return res.json({
        errors: [{
          title: error
        }]
      });
    }
    if (req.session._user != appledevice._owner) {
      // if the Device header matches the requested device ID, update the AppleDevice to link to this user
      // this can happen if a user signs out and then signs in to a different account.
      if (req.headers.device !== appledevice.deviceId) {
        var error = "You are not authorized to access this device!";
        console.log(error, appledevice, req.headers.device);
        return res.json({
          errors: [{
            title: error
          }]
        });
      }
      appledevice._owner = req.session._user
      appledevice.save(function(err, appledevice) {
        if (err) {
          var error = "Failed to save appledevice with new owner";
          console.log(error);
          return;
        }
      });
    }
    res.json({
      data: appledevice
    });
  });
};
