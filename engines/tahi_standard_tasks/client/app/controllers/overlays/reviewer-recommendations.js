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

  clearNewRecommendationAnswers: function(){
    this.get('nestedQuestionsForNewRecommendation').forEach( (nestedQuestion) => {
      nestedQuestion.clearAnswerForOwner(this.get("newRecommendation"));
    });
  },

  actions: {
    toggleReviewerForm: function() {
      this.toggleProperty('showNewReviewerForm');
    },

    saveNewRecommendation: function() {
      let recommendation = this.get("newRecommendation");
      recommendation.set("reviewerRecommendationsTask", this.get("model"));
      recommendation.save().then( (savedRecommendation) => {
        recommendation.get('nestedQuestionAnswers').toArray().forEach(function(answer){
          let value = answer.get("value");
          if(value || value === false){
            answer.set("owner", savedRecommendation);
            answer.save();
          }
        });
        this.toggleProperty('showNewReviewerForm');
      });
    },

    institutionSelected: function(institution) {
      this.set('newRecommendation.affiliation', institution.name);
      this.set('newRecommendation.ringgoldId', institution['institution-id']);
    },

    cancelEdit: function() {
      this.clearNewRecommendationAnswers();
      this.toggleProperty('showNewReviewerForm');
    }
  }
});
