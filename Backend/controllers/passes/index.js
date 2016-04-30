var passes = [
  {
    title: "Trial Pass",
    description: "On a budget? Get started now for just $0.99.",
    cost: 99
  },
  {
    title: "365 Day Pass",
    description: "Limited time offer. Save 40% by ordering in the next 6 days!",
    cost: 1499
  },
  {
    title: "365 Day Pass",
    description: "Enjoy complete protection for a whole year. No strings attached.",
    cost: 2499
  }
];

exports.get = function(req, res) {
  var jsonPlans = passes.map(function(plan, index) {
    return {
      id: index + 1,
      type: "passes",
      attributes: plan
    };
  });
  res.json({
    data: jsonPlans
  });
}

exports.getOne = function(req, res) {
  var passId = req.params.passId;
  if (isNaN(passId)) {
    var error = "Pass ID must be a number.";
    return res.json({
      errors: [{
        title: error
      }]
    });
  }
  passId = Math.max(1, passId); // dont let pass ID be less than 1
  passId = Math.min(passId, passes.length); // no index out of bounds
  res.json({
    data: {
      id: index,
      type: "passes",
      attributes: passes[passId]
    }
  });
}
