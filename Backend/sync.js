var _ = require('underscore');
var mongoose = require('mongoose');
var plaid = require('plaid');
var async = require('async');
var apn = require('apn');
var User = mongoose.model('User');
var Auth = mongoose.model('Auth');
var Transaction = mongoose.model('Transaction');
var Account = mongoose.model('Account');
var AppleDevice = mongoose.model('AppleDevice');

var service = require("./apns/service");

/*
  yeah, i did that.
*/
String.prototype.capitalizeFirstLetter = function() {
    return this.charAt(0).toUpperCase() + this.slice(1);
};
Array.prototype.last = function(){
    return this[this.length - 1];
};

exports.transactions = function(transactionsData, options, cb) {
  // cb(err, updatedTransactions)
  async.waterfall([
    function(callback) {
      /*
        Search the database to see if any of the transactions we're trying to sync already exist.
        We're not going to send notifications for those ALSO we will use them to link _pendingTransactions
      */
      Transaction.find({
        plaid_id: {
          $in: _.pluck(transactionsData, "_id").concat(_.pluck(transactionsData, "_pendingTransaction"))
        }
      }, function(err, existingTransactions) {
        if (err) {
          return callback({
            title: "Could not get transaction.",
            err: err
          });
        }
        callback(null, existingTransactions);
      });
    },
    function(existingTransactions, callback) {
      /*
        Key:Value associate all the accounts with their Plaid ID
        AND
        Key:Value associate all the auths with their Plaid Auth ID

        This will allow us to quickly reference the account for database insert.
      */
      var accounts = {};
      var auths = {};
      for (var i = 0; i < options.accounts.length; i++) {
        var account = options.accounts[i];
        accounts[account.plaid_id] = account._id;
        auths[account.plaid_id] = account._auth;
      }

      var transactionsMap = {};
      existingTransactions.map(function(transaction) {
        var plaid_id = transaction.plaid_id;
        transactionsMap[plaid_id] = transaction;
      });
      var newTransactions = transactionsData.filter(function(transactionData) {
          if (!transactionsMap[transactionData._id]) {
            return true; // transaction doesn't exist, return true to create it
          }
          return false; // transaction already exists, dont create it
        }).map(function(transactionData) {
          // check to make sure the account and auth exist. the auth should always exist. the account may not exist if it wasn't sync'd
          // TODO: sync accounts if they aren't found
          var account = accounts[transactionData._account];
          var auth = auths[transactionData._account];
          if (!account || !auth) {
            return callback({
              title: "Could not match one of your transactions to an existing account. Please contact support.",
              account: account,
              auth: auth,
              transactionData: transactionData
            });
          }
          // Transaction model
          var pendingTransaction = transactionsMap[transactionData._pendingTransaction];
          if (pendingTransaction) {
            var _pendingTransaction = pendingTransaction._id;
          }
          return {
            _owner: options._owner,
            _account: account,
            _auth: auth,
            _pendingTransaction: _pendingTransaction,
            total: transactionData.amount,
            title: transactionData.name,
            plaid_id: transactionData._id,
            plaid_account: transactionData._account,
            plaid_pendingTransaction: transactionData._pendingTransaction,
            plaidAmount: [transactionData.amount],
            plaidName: [transactionData.name],
            plaidDate: transactionData.date,
            plaidMeta: [transactionData.meta],
            plaidPending: transactionData.pending,
            plaidType: [transactionData.type],
            plaidCategory_id: [transactionData.category_id],
            plaidScore: [transactionData.score],
            createdAt: Date.now(),
            updatedAt: Date.now()
          };
        });
        callback(null, transactions, newTransactions);
    },
    function(transactions, newTransactions, callback) {
      /*
        Mongoose doesn't have a great insert method so we're going to insert these directly into the DB
        Data validation for Mongoose will not occur but it will be FAST
      */
      if (newTransactions.length === 0) {
        // fixes "Invalid Operation, No operations in bulk" error that results from attempting to insert nothing
        return callback(null, transactions, newTransactions);
      }
      Transaction.collection.insert(newTransactions, {
        continueOnError: true
      }, function(err, result) {
        if (err) {
          if (err.code === 11000) {
            // TODO: remove this if statement that supresses duplicate key errors, continueOnError may also need to be changed
            // this should be relatively simple to change, temporarily leaving it
          } else {
            return callback({
              title: "Could not create transactions",
              err: err
            });
          }
        }
        callback(null, transactions, newTransactions);
      });
    },
    function(transactions, newTransactions, callback) {
      Transaction.find({
        _id: {
          $in: _.pluck(newTransactions, "_id")
        }
      }, function(err, newTransactions) {
        if (err) {
          return callback({
            title: "Could not find new transactions",
            err: err
          });
        }
        callback(null, transactions, newTransactions);
      });
    },
    function(transactions, newTransactions, callback) {
      AppleDevice.find({
        _owner: options._owner
      }, function(err, appledevices) {
        if (err) {
          return callback({
            title: "Could not notify your devices.",
            err: err
          });
        }
        newTransactions.forEach(function(transaction) {
          var note = new apn.notification();
          note.setAlertText("Update your transaction for " + transaction.title);
          note.badge = 0;
          service.pushNotification(note, _.pluck(appledevices, "token"));
        });
        callback(null, );
      });
    }
  ], function(err, newTransactions) {
    cb(err, newTransactions);
  });
};

exports.accounts = function(accountsData, options, callback) {
  // callback(err, accounts)
  /*
    var options = {
      owner: req.session.user
    }
  */
  var accounts = accountsData.map(function(accountData) {
    return {
      _owner: options._owner,
      _auth: options.auth._id,
      plaid_id: accountData._id,
      plaid_item: accountData._item,
      plaid_user: accountData._user,
      plaidInstitution_type: accountData.institution_type
    };
  });
  Account.create(accounts, function(err, accounts) {
    if (err) {
      return callback({
        title: "Could not create accounts",
        err: err
      });
    }
    options.auth.update({
        $addToSet: {
          _accounts: {
            $each: accounts.map(function(account) {
              return account._id;
            })
          }
        }
      },
      function(err, updated) {
        if (err) {
          return callback({
            title: "Could not add accounts to auth.",
            err: err,
            updated: updated
          });
        }
        callback(null, accounts);
      });
  });
}
