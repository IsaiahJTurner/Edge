var plaid = require('plaid');

var config = {
  mongoURL: "mongodb://edge:4bOw3B2XffjE0gZ79uPzTCc0YhtQbvyY8bvAufu61evJuTwoCZ@ds059185.mongolab.com:59185/edge",
  plaid: {
    publicKey: "db0c7fe8afdfac06b1997b0d4a1b96",
    clientId: "56b96681db2afcb6184d2b85",
    secret: "1940fb678863766d4068499b725774",
    environment: plaid.environments.tartan
  },
  plaid_webhook: "https://edge-development.herokuapp.com/api/v1.0/webhooks/plaid",
  apns: {
    isProduction: false
  },
  twilio: {
    ACCOUNT_SID: "AC98f199067b6295de876b4b1e1d9ea0e3",
    AUTH_TOKEN: "66c102003d36cc34366ed6a34ee9cc60",
    hasherSecret: "Follow @IsaiahJTurner on Twitter!"
  }
};
config.plaid.client = new plaid.Client(config.plaid.clientId, config.plaid.secret,
  config.plaid.environment);

module.exports = config;
