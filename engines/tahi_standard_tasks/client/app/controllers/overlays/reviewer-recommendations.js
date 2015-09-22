import Ember from 'ember';
import TaskController from "tahi/pods/paper/task/controller";

export default TaskController.extend({
  showNewReviewerForm: false,
  task: Ember.computed.alias("model"),
  reviewerRecommendations: Ember.computed.alias("task.reviewerRecommendations"),
  newRecommendation: Ember.computed.alias("reviewerRecommendation"),

  recommendOrOpposeQuestion: Ember.computed("model", "model.newRecommendation", function(){
    return this.get("newRecommendation").findQuestion("recommend_or_oppose");
  }),

  reasonQuestion: Ember.computed("model", "model.newRecommendation", function(){
    return this.get("newRecommendation").findQuestion("reason");
  }),

  actions: {
    toggleReviewerForm: function() {
      this.send("addReviewerRecommendation");
    },

    saveNewRecommendation: function() {
      //TODO: Validate form
      this.get("newRecommendation").save();
      this.toggleProperty('showNewReviewerForm');
    },

    institutionSelected: function(institution) {
      this.set('newRecommendation.affiliation', institution.name);
      this.set('newRecommendation.ringgoldId', institution['institution-id']);
    },

    cancelEdit: function() {
      let newRecommendation = this.get("newRecommendation");
      this.store.find('reviewerRecommendation', newRecommendation.id)
        .then((newRecommendation) => {
          newRecommendation.deleteRecord();
          newRecommendation.save();
          this.toggleProperty('showNewReviewerForm');
        });
    },

    addReviewerRecommendation: function() {
      let newRecommendation = this.store.createRecord("reviewerRecommendation", {
        reviewerRecommendationsTask: this.get("task")
      }).save()
        .then((newRecommendation) => {
          this.set("newRecommendation", newRecommendation);
          this.toggleProperty('showNewReviewerForm');
        });
    }
  }
});
