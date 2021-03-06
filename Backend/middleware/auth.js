exports.requiresUser = function(req, res, next) {
  if (!req.session._user) {
    return res.json({
      errors: [{
        title: "You must be signed in to do that."
      }]
    });
  }
  next();
};
