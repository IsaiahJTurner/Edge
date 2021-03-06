var mongoose = require('mongoose');
var Schema = mongoose.Schema;
var ObjectId = Schema.ObjectId;
var _ = require('underscore');

var AccountSchema = new Schema({
  _owner: {
    type: Schema.ObjectId,
    ref: 'User'
  },
  _auth: {
    type: Schema.ObjectId,
    ref: 'Auth'
  },
  plaid_id: {
    type: String,
    unique: true
  },
  plaid_item: {
    type: String
  },
  plaid_user: {
    type: String
  },
  plaidInstitution_type: {
    type: String,
    required: true
  },
  createdAt: {
    type: Date
  },
  updatedAt: {
    type: Date
  }
});

AccountSchema.pre('save', function(next) {
  now = new Date();
  this.updatedAt = now;
  if (!this.createdAt) {
    this.createdAt = now;
  }
  next();
});


AccountSchema.method('toJSON', function() {
  var self = this.toObject();
  var obj = _.clone(self);
  delete obj._id;
  delete obj.__v;
  delete obj._owner;
  delete obj._auth;
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
      },
      auth: {
        data: {
          type: "auths",
          id: self._auth
        }
      }
    }
  };
  return data;
});

module.exports = mongoose.model('Account', AccountSchema);
