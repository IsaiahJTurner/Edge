var apn = require('apn');

var config = require("../config");

var options = {
  "production": config.apns.isProduction
};
if (config.apns.isProduction) {
  options.cert = __dirname + "/production/cert.pem";
  options.key = __dirname + "/production/key.pem";
} else {
  options.cert = __dirname + "/sandbox/cert.pem";
  options.key = __dirname + "/sandbox/key.pem";
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

module.exports = service;
