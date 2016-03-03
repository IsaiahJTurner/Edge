var _ = require('underscore');
var mongoose = require('mongoose');
var apn = require('apn');
var User = mongoose.model('User');
var AppleDevice = mongoose.model('AppleDevice');

var config = require("../../config");
var service = require("../../apns/service");

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
  var deviceId = req.body.data.attributes.deviceId;
  if (!_.isString(deviceId)) {
    var error = "Please include a device ID with your request.";
    return res.json({
      errors: [{
        title: error
      }]
    });
  }
  var token = req.body.data.attributes.token;
  if (!_.isString(token)) {
    var error = "Please include a token with your request.";
    return res.json({
      errors: [{
        title: error
      }]
    });
  }
  var alert = Boolean(req.body.data.attributes.alert);
  var badge = Boolean(req.body.data.attributes.badge);
  var sound = Boolean(req.body.data.attributes.sound);
  var transactionNotifications = Boolean(req.body.data.attributes.transactionNotifications);
  var allNotifications = Boolean(req.body.data.attributes.allNotifications);

  AppleDevice.findOne({
    deviceId: deviceId
  }, function(err, appledevice) {
    if (err) {
      var error = "Could not find your device.";
      console.log(error, err);
      return res.json({
        errors: [{
          title: error
        }]
      });
    }
    if (!appledevice) {
      var appledevice = AppleDevice({
        deviceId: deviceId,
        alert: alert,
        badge: badge,
        sound: sound,
        token: token,
        allNotifications: allNotifications,
        transactionNotifications: transactionNotifications,
        sessionId: req.sessionId
      });
    } else if (appledevice._owner.toString() !== (req.session._user || "").toString() && appledevice.sessionId !== req.sessionId) {
      var error = "You are not authorized to retrieve notifications for this device.";
      console.log(error, err);
      return res.json({
        errors: [{
          title: error
        }]
      });
    } else {
      appledevice.alert = alert;
      appledevice.badge = badge;
      appledevice.sound = sound;
      appledevice.transactionNotifications = transactionNotifications;
      appledevice.allNotifications = allNotifications
      appledevice.sessionId = req.sessionId;
      appledevice.token = token;
    }
    if (req.session._user) {
      appledevice._owner = req.session._user;
    }
    appledevice.save(function(err, appledevice) {
      if (err) {
        var error = "Could not save your device.";
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
