var mongoose = require('mongoose');
var Schema = mongoose.Schema;
var ObjectId = Schema.ObjectId;
var _ = require('underscore');

var AccountSchema = new Schema({
  owner: {
    type: Schema.ObjectId,
    ref: 'User'
  },
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
  delete obj.owner;
  delete obj.accessToken;
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
  return data;
});

module.exports = mongoose.model('Account', AccountSchema);
