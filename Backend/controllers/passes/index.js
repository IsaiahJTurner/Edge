var passes = [
  {
    title: "Trial Pass",
    description: "On a budget? Get started now for just $0.99.",
    cost: 99
  },
  {
    title: "365 Day Pass",
    description: "Save 40% by ordering in the next 6 days!",
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
      id: index,
      type: "passes",
      attributes: plan
    };
  });
  res.json({
    data: jsonPlans
  });
}
