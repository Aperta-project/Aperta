import Ember from 'ember';
import TaskController from "tahi/pods/paper/task/controller";

export default TaskController.extend({
  showNewReviewerForm: false,
  task: Ember.computed.alias("model"),
  reviewerRecommendations: Ember.computed.alias("task.reviewerRecommendations"),

  newRecommendationQuestions: Ember.on('init', function(){
    this.store.findQuery('nested-question', { type: "ReviewerRecommendation" }).then( (nestedQuestions) => {
      this.set('nestedQuestionsForNewRecommendation', nestedQuestions);
    });
  }),

  newRecommendation: Ember.computed('showNewReviewerForm', function(){
    return this.store.createRecord('reviewer-recommendation', {
      nestedQuestions: this.get('nestedQuestionsForNewRecommendation')
    });
  }),

  actions: {
    toggleReviewerForm: function() {
      this.toggleProperty('showNewReviewerForm');
    },

    saveNewRecommendation: function() {
      let recommendation = this.get("newRecommendation");
      recommendation.set("reviewerRecommendationsTask", this.get("model"));
      recommendation.save().then( () => {
        this.toggleProperty('showNewReviewerForm');
      });
    },

    institutionSelected: function(institution) {
      this.set('newRecommendation.affiliation', institution.name);
      this.set('newRecommendation.ringgoldId', institution['institution-id']);
    },

    cancelEdit: function() {
      this.toggleProperty('showNewReviewerForm');
    }
  }
});
