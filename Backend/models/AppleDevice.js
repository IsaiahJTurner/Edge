var mongoose = require('mongoose');
var Schema = mongoose.Schema;
var ObjectId = Schema.ObjectId;
var _ = require('underscore');

var AppleDeviceSchema = new Schema({
  _owner: {
    type: Schema.ObjectId,
    ref: 'User'
  },
  token: {
    type: String
  },
  alert: {
    type: Boolean
  },
  badge: {
    type: Boolean
  },
  sound: {
    type: Boolean
  },
  deviceId: {
    type: String
  },
  createdAt: {
    type: Date
  },
  updatedAt: {
    type: Date
  }
});

AppleDeviceSchema.pre('save', function(next) {
  now = new Date();
  this.updatedAt = now;
  if (!this.createdAt) {
    this.createdAt = now;
  }
  next();
});


AppleDeviceSchema.method('toJSON', function() {
  var self = this.toObject();
  var obj = _.clone(self);
  delete obj._id;
  delete obj.__v;
  delete obj._owner;
  obj.createdAt = Number(obj.createdAt);
  obj.updatedAt = Number(obj.updatedAt);
  var data = {
    type: "appledevices",
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
  return data;
});

module.exports = mongoose.model('AppleDevice', AppleDeviceSchema);
