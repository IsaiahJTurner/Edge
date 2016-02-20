var mongoose = require('mongoose');
var Schema = mongoose.Schema;
var ObjectId = Schema.ObjectId;
var _ = require('underscore');
var bcrypt = require('bcrypt');
var SALT_WORK_FACTOR = 10;

var UserSchema = new Schema({
  name: {
    type: String
  },
  email: {
    type: String,
    required: true,
    unique: true
  },
  queryEmail: {
    type: String,
    unique: true
  },
  phone: {
    type: String
  },
  password: {
    type: String,
    required: true
  },
  _auths: [{
    type: Schema.ObjectId,
    ref: 'Auth'
  }],
  createdAt: {
    type: Date
  },
  updatedAt: {
    type: Date
  }
});

UserSchema.pre('save', function(next) {
  now = new Date();
  this.updatedAt = now;
  if (!this.createdAt) {
    this.createdAt = now;
  }
  next();
});
/**
 * Automatic Password Hashing
 */
UserSchema.pre('save', function(next) {
  var user = this;

  // only hash the password if it has been modified (or is new)
  if (!user.isModified('password')) return next();

  // generate a salt
  bcrypt.genSalt(SALT_WORK_FACTOR, function(err, salt) {
    if (err) return next(err);

    // hash the password using our new salt
    bcrypt.hash(user.password, salt, function(err, hash) {
      if (err) return next(err);

      // override the cleartext password with the hashed one
      user.password = hash;
      next();
    });
  });
});

UserSchema.method('toJSON', function() {
  var self = this.toObject();
  var obj = _.clone(self);
  delete obj.password;
  delete obj._id;
  delete obj.__v;
  delete obj.queryEmail;
  delete obj._auths;
  obj.createdAt = Number(obj.createdAt);
  obj.updatedAt = Number(obj.updatedAt);
  var data = {
    type: "users",
    id: self._id,
    attributes: obj,
    relationships: {}
  }
  if (self._auths) {
    data.relationships.auths = {
      data: self._auths.map(function(auth) {
        return {
          type: "auths",
          id: auth
        }
      })
    }
  }
  return data;
});

module.exports = mongoose.model('User', UserSchema);
