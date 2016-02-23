var _ = require('underscore');
var mongoose = require('mongoose');
var apn = require('apn');
var User = mongoose.model('User');
var AppleDevice = mongoose.model('AppleDevice');

var config = require("../../config");
var options = {
  "production": config.apns.isProduction
};
if (config.apns.isProduction) {
  options.cert = __dirname + "/../../apns/production/cert.pem";
  options.key = __dirname + "/../../apns/production/key.pem";
} else {
  options.cert = __dirname + "/../../apns/sandbox/cert.pem";
  options.key = __dirname + "/../../apns/sandbox/key.pem";
}

var service = new apn.Connection(options);

service.on("connected", function() {
  console.log("Connected");
});

service.on("transmitted", function(notification, device) {
  console.log("Notification transmitted to:" + device.token.toString("hex"));
});

service.on("transmissionError", function(errCode, notification, device) {
  console.error("Notification caused error: " + errCode + " for device ", device, notification);
  if (errCode === 8) {
    console.log("A error code of 8 indicates that the device token is invalid. This could be for a number of reasons - are you using the correct environment? i.e. Production vs. Sandbox");
  }
});

service.on("timeout", function() {
  console.log("Connection Timeout");
});

service.on("disconnected", function() {
  console.log("Disconnected from APNS");
});

service.on("socketError", console.error);

AppleDevice.find(function(err, appledevices) {
  if (err) {
    return console.log("Could not find devices", err);
  }
  var tokens = appledevices.map(function(appledevice) {
    return appledevice.token;
  });
  console.log("Tokens", tokens);
  var note = new apn.notification();
  note.setAlertText("Server started2!");
  note.badge = 1;
  service.pushNotification(note, tokens);
});

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
        sessionId: req.sessionId
      });
      if (req.session._user) {
        appledevice._owner = req.session._user;
      }
    } else if (appledevice._owner.toString() !== req.session._user.toString() && appledevice.sessionId !== req.sessionId) {
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
      appledevice.sessionId = req.sessionId;
      appledevice.token = token;
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
