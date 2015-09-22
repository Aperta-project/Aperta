import Ember from 'ember';
import TaskController from "tahi/pods/paper/task/controller";

export default TaskController.extend({
  showNewReviewerForm: false,
  task: Ember.computed.alias("model"),
  reviewerRecommendations: Ember.computed.alias("task.reviewerRecommendations"),

  resetForm: function() {

  },

  actions: {
    toggleReviewerForm: function() {
      this.send("addReviewerRecommendation");
      this.toggleProperty('showNewReviewerForm');
    },

    saveNewRecommendation: function() {

    },

    institutionSelected: function(institution) {
      this.set('newRecommendation.affiliation', institution.name);
      this.set('newRecommendation.ringgoldId', institution['institution-id']);
    },

    cancelEdit: function() {
      this.resetForm();
    },

    addReviewerRecommendation: function() {
      console.log("creating record", this.get("task").get("id"));
      return this.store.createRecord("reviewerRecommendation", {
        reviewerRecommendationsTask: this.get("task")
      }).save();
    }
  }
});
