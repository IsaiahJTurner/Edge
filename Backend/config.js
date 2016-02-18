var plaid = require('plaid');

var config = {
  mongoURL: "mongodb://edge:4bOw3B2XffjE0gZ79uPzTCc0YhtQbvyY8bvAufu61evJuTwoCZ@ds059185.mongolab.com:59185/edge",
  plaid: {
    publicKey: "db0c7fe8afdfac06b1997b0d4a1b96",
    clientId: "56b96681db2afcb6184d2b85",
    secret: "1940fb678863766d4068499b725774",
    environment: plaid.environments.tartan
  }
};
config.plaid.client = new plaid.Client(config.plaid.clientId, config.plaid.secret,
  config.plaid.environment);

module.exports = config;
