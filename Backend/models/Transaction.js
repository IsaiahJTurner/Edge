var mongoose = require('mongoose');
var Schema = mongoose.Schema;
var ObjectId = Schema.ObjectId;

var TransactionSchema = new Schema({
  owner: {
    type: Schema.ObjectId,
    ref: 'User'
  },
  account: {
    type: Schema.ObjectId,
    ref: 'Account'
  },
  title: {
    type: String
  },
  subtotal: {
    type: Number
  },
  tip: {
    type: Number
  },
  total: {
    type: Number
  },
  plaid_id: {
    type: String,
    unique: true
  },
  plaid_account: {
    type: String
  },
  plaidAmount: [{
    type: Number
  }],
  plaidDate: [{
    type: Date
  }],
  plaidMeta: [{
    type: Object
  }],
  plaidPending: {
    type: Boolean
  },
  plaidScore: [{
    type: Object
  }],
  plaidType: [{
    type: Object
  }],
  plaidCategory_id: [{
    type: Object
  }],
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


TransactionSchema.method('toJSON', function() {
  var self = this.toObject();
  var obj = _.clone(self);
  delete obj._id;
  delete obj.__v;
  delete obj.owner;
  delete obj.account;
  for (var key in obj) {
    if (key.indexOf("plaid") === 0) {
      delete obj[key];
    }
  }
  obj.createdAt = Number(obj.createdAt);
  obj.updatedAt = Number(obj.updatedAt);
  var data = {
    type: "accounts",
    id: self._id,
    attributes: obj,
    relationships: {
      owner: {
        data: {
          id: self.owner
        }
      }
    }
  };
  if (self.account) {
    data.relationships.account = {
      data: {
        type: "accounts",
        id: self.account
      }
    }
  }
  return data;
});

module.exports = mongoose.model('Transaction', TransactionSchema);
