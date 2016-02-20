var mongoose = require('mongoose');
var Schema = mongoose.Schema;
var ObjectId = Schema.ObjectId;
var _ = require('underscore');

var AuthSchema = new Schema({
  _owner: {
    type: Schema.ObjectId,
    ref: 'User'
  },
  _accounts: [{
    type: Schema.ObjectId,
    ref: 'Account'
  }],
  publicToken: {
    type: String,
    required: true,
    unique: true
  },
  accessToken: {
    type: String,
    required: true,
    unique: true
  },
  plaid_user: {
    type: String
  },
  createdAt: {
    type: Date
  },
  updatedAt: {
    type: Date
  }
});

AuthSchema.pre('save', function(next) {
  now = new Date();
  this.updatedAt = now;
  if (!this.createdAt) {
    this.createdAt = now;
  }
  next();
});


AuthSchema.method('toJSON', function() {
  var self = this.toObject();
  var obj = _.clone(self);
  delete obj._id;
  delete obj.__v;
  delete obj._owner;
  delete obj._accounts;
  delete obj.accessToken;
  delete obj.plaid_user;
  
  obj.createdAt = Number(obj.createdAt);
  obj.updatedAt = Number(obj.updatedAt);
  var data = {
    type: "auths",
    id: self._id,
    attributes: obj,
    relationships: {
      owner: {
        data: {
          type: "users",
          id: self._owner
        }
      }
    }
  };
  if (self._accounts) {
    data.relationships.accounts = {
      data: self._accounts.map(function(account) {
        return {
          type: "accounts",
          id: account
        }
      })
    }
  }
  return data;
});

module.exports = mongoose.model('Auth', AuthSchema);
