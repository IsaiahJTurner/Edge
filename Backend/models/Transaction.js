var mongoose = require('mongoose');
var Schema = mongoose.Schema;
var ObjectId = Schema.ObjectId;

var TransactionSchema = new Schema({
  owner: {
    type: Schema.ObjectId,
    ref: 'User'
  },
  originalCharge: {
    type: Number
  },
  tip: {
    type: Number
  },
  finalCharge: {
    type: Number
  },
  transactionId: {
    type: String
  },
  transactionName: {
    type: String
  },
  transactionAccount: {
    type: String
  },
  transactionDate: {
    type: String
  },
  password: {
    type: String
  },
  createdAt: {
    type: Date
  },
  updatedAt: {
    type: Date
  }
});

TransactionSchema.pre('save', function(next) {
  now = new Date();
  this.updatedAt = now;
  if (!this.createdAt) {
    this.createdAt = now;
  }
  next();
});

module.exports = mongoose.model('Transaction', TransactionSchema);
