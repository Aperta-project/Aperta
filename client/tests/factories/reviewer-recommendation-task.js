import FactoryGuy from "ember-data-factory-guy";

FactoryGuy.define("reviewer-recommendations-task", {
  default: {
    title: "Reviewer Recommendations",
    type: "ReviewerRecommendationsTask",
    completed: false,
  }
});
