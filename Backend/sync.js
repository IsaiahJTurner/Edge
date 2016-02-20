var _ = require('underscore');
var mongoose = require('mongoose');
var plaid = require('plaid');
var async = require('async');
var User = mongoose.model('User');
var Auth = mongoose.model('Auth');
var Transaction = mongoose.model('Transaction');
var Account = mongoose.model('Account');

exports.transactions = function(transactionsData, options, callback) {
  // callback(err, transactions)
  var accounts = {};
  var auths = {};
  for (var i = 0; i < options.accounts.length; i++) {
    var account = options.accounts[i];
    accounts[account.plaid_id] = account._id;
    auths[account.plaid_id] = account._auth;
  }

  var transactions = transactionsData.map(function(transaction) {
    return {
      _owner: options._owner,
      _account: accounts[transaction._account],
      _auth: auths[transaction._account],
      total: transaction.amount,
      title: transaction.name,
      plaid_id: transaction._id,
      plaid_account: transaction._account,
      plaidAmount: [transaction.amount],
      plaidName: [transaction.name],
      plaidDate: [transaction.date],
      plaidMeta: [transaction.meta],
      plaidPending: [transaction.pending],
      plaidType: [transaction.type],
      plaidCategory_id: [transaction.category_id],
      plaidScore: [transaction.score],
      createdAt: Date.now(),
      updatedAt: Date.now()
    };
  });

  Transaction.collection.insert(transactions, {
    continueOnError: true
  }, function(err, transactions) {
    if (err) {
      if (err.code === 11000) {
        // ignore duplicate key erros
      } else {
        return callback({
          title: "Could not create transactions",
          err: err
        });
      }
    }

    callback(null, transactions);
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
