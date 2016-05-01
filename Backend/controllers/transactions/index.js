var _ = require('underscore');
var mongoose = require('mongoose');
var plaid = require('plaid');
var async = require('async');
var User = mongoose.model('User');
var Auth = mongoose.model('Auth');
var Transaction = mongoose.model('Transaction');
var sync = require("../../sync");

var config = require("../../config");

var plaidClient = config.plaid.client;

exports.get = function(req, res) {
    Auth.find({
        _owner: req.session._user
    }).populate("_accounts").exec(function(err, auths) {
        if (err) {
            var error = "Failed to find your auths.";
            console.log(error, err);
            return res.json({
                errors: [{
                    title: error
                }]
            });
        }
        if (auths.length === 0) {
            var error = "You need to link a bank account first.";
            console.log(error, err);
            return res.json({
                errors: [{
                    title: error
                }]
            });
        }
        // merges the accounts of each auth into one array of accounts
        var accounts = [].concat.apply([], _.pluck(auths, "_accounts"));
        var allTransactions = [];
        async.each(auths, function(auth, callback) {
            plaidClient.getConnectUser(auth.accessToken, {
                //gte: '30 days ago',
                pending: true
            }, function(err, response) {
                if (err) {
                    var error = "Failed to retrieve your transactions.";
                    console.log(error, err);
                    callback(true);
                    return res.json({
                        errors: [{
                            title: error
                        }]
                    });
                }
                allTransactions = allTransactions.concat(response.transactions);
                callback(null);
            });
        }, function(err) {
            if (err) {
                return;
            }
            sync.transactions(allTransactions, {
                _owner: req.session._user,
                accounts: accounts
            }, function(err, transactions) {
                if (err) {
                    var error = "Failed to sync your transactions.";
                    console.log(error, err);
                    return res.json({
                        errors: [{
                            title: error
                        }]
                    });
                }

                Transaction.find({
                    _owner: req.session._user,
                    plaidCategory_id : { $regex : /^13005/ }
                }).sort({
                    "_auth": 1,
                    "plaidDate": -1
                }).exec(function(err, transactions) {
                    if (err) {
                        var error = "Could not find your transactions.";
                        console.log(error, err);
                        return res.json({
                            errors: [{
                                title: error
                            }]
                        });
                    }
                    res.json({
                        data: transactions
                    });
                });
            });
        });
    })
}

exports.post = function(req, res) {
    if (!_.isObject(req.body.data)) {
        var error = "Please include data with your request.";
        return res.json({
            errors: [{
                title: error
            }]
        });
    }
    if (!_.isObject(req.body.data.attributes)) {
        var error = "Please include attributes with your request.";
        return res.json({
            errors: [{
                title: error
            }]
        });
    }
    var title = req.body.data.attributes.title;
    if (!_.isString(title) || title.length === 0) {
        var error = "Please include a title with your request.";
        return res.json({
            errors: [{
                title: error
            }]
        });
    }
    var subtotal = req.body.data.attributes.subtotal;
    if (!_.isNumber(subtotal) || subtotal === 0) {
        var error = "Please include a subtotal with your request.";
        return res.json({
            errors: [{
                title: error
            }]
        });
    }
    var tip = req.body.data.attributes.tip;
    if (!_.isNumber(tip)) {
        var error = "Please include a tip with your request.";
        return res.json({
            errors: [{
                title: error
            }]
        });
    }
    tip = Math.max(0, tip);
    subtotal = Math.max(0, subtotal);
    var transaction = Transaction({
        _owner: req.session._user,
        title: title,
        subtotal: subtotal,
        tip: tip,
        total: subtotal + tip
    });
    transaction.save(function(err, transaction) {
        if (err) {
            var error = "Failed to save transaction.";
            console.log(error, err);
            return res.json({
                errors: [{
                    title: error
                }]
            });
        }
        res.json({
            data: transaction
        });
    });
}
