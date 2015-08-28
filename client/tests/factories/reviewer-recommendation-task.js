import FactoryGuy from "ember-data-factory-guy";

FactoryGuy.define("reviewer-recommendations-task", {
  default: {
    title: "Reviewer Candidates",
    type: "ReviewerRecommendationsTask",
    completed: false,
  }
});
