var mongoose = require('mongoose');
var Schema = mongoose.Schema;
var ObjectId = Schema.ObjectId;
var _ = require('underscore');

var TransactionSchema = new Schema({
  _owner: {
    type: Schema.ObjectId,
    ref: 'User'
  },
  _account: {
    type: Schema.ObjectId,
    ref: 'Account'
  },
  _auth: {
    type: Schema.ObjectId,
    ref: 'Auth'
  },
  _pendingTransaction: {
    type: Schema.ObjectId,
    ref: 'Transaction'
  },
  _settledTransaction: {
    type: Schema.ObjectId,
    ref: 'Transaction'
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
  removed: {
    type: Boolean
  },
  plaid_id: {
    type: String,
    unique: true,
    index: true,
    sparse: true
  },
  plaid_account: {
    type: String
  },
  plaid_pendingTransaction: {
    type: String
  },
  plaidAmount: {
    type: Number
  },
  plaidDate: {
    type: Date
  },
  plaidName: {
    type: String
  },
  plaidMeta: {
    type: Object
  },
  plaidPending: {
    type: Boolean
  },
  plaidScore: {
    type: Object
  },
  plaidType: {
    primary: String
  },
  plaidCategory_id: {
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


TransactionSchema.method('toJSON', function() {
  var self = this.toObject();
  var obj = _.clone(self);
  delete obj._id;
  delete obj.__v;
  delete obj._owner;
  delete obj._account;
  delete obj._pendingTransaction;
  for (var key in obj) {
    if (key.indexOf("plaid") === 0) {
      // delete obj[key];
    }
  }
  obj.createdAt = Number(obj.createdAt);
  obj.updatedAt = Number(obj.updatedAt);
  var data = {
    type: "transactions",
    id: self._id,
    attributes: obj,
    relationships: {
      owner: {
        data: {
          id: self._owner
        }
      }
    }
  };
  if (self._account) {
    data.relationships.account = {
      data: {
        type: "transactions",
        id: self._account
      }
    }
  }
  if (self._auth) {
    data.relationships.auth = {
      data: {
        type: "auths",
        id: self._auth
      }
    }
  }
  if (self._pendingTransaction) {
    data.relationships.pendingTransaction = {
      data: {
        type: "transactions",
        id: self._pendingTransaction
      }
    }
  }
  return data;
});

module.exports = mongoose.model('Transaction', TransactionSchema);
