import Ember from 'ember';
import TaskController from 'tahi/pods/paper/task/controller';
import ValidationErrorsMixin from 'tahi/mixins/validation-errors';

export default TaskController.extend(ValidationErrorsMixin, {
  showNewReviewerForm: false,

  // Doing this to prevent short period of time where `newRecommendation` is in the DOM
  // while save is happening. If it becomes invalid after save it is removed. This creates
  // a glitchy look to the list.
  validReviewerRecommendations: Ember.computed('model.reviewerRecommendations.@each.isNew', function() {
    return this.get('model.reviewerRecommendations').filterBy('isNew', false);
  }),

  newRecommendationQuestions: Ember.on('init', function(){
    let queryParams = { type: "ReviewerRecommendation" };
    this.store.findQuery('nested-question', queryParams).then( (questions) => {
      this.set('nestedQuestionsForNewRecommendation', questions);
    });
  }),

  clearNewRecommendationAnswers: function(){
    this.get('nestedQuestionsForNewRecommendation').forEach( (question) => {
      question.clearAnswerForOwner(this.get("newRecommendation"));
    });
  },

  actions: {
    addNewReviewer() {
      let recommendation = this.store.createRecord('reviewerRecommendation', {
        reviewerRecommendationsTask: this.get('model'),
        nestedQuestions: this.get('nestedQuestionsForNewRecommendation')
      });
      this.set('newRecommendation', recommendation);
      this.set('showNewReviewerForm', true);
    },

    cancelRecommendation() {
      this.set('showNewReviewerForm', false);
      this.clearNewRecommendationAnswers();
      this.get('newRecommendation').destroyRecord();
      this.set('newRecommendation', null);
      this.clearAllValidationErrors();
    },

    saveRecommendation(recommendation) {
      recommendation.save().then((savedRecommendation) => {
        recommendation.get('nestedQuestionAnswers').forEach(function(answer){
          if(answer.get('wasAnswered')){
            answer.set("owner", savedRecommendation);
            answer.save();
          }
        });
        this.set('showNewReviewerForm', false);
        this.set('newRecommendation', null);
      }).catch((response) => {
        this.displayValidationErrorsFromResponse(response);
      });
    },

    cancelEdit: function() {
      this.clearNewRecommendationAnswers();
      this.set('showNewReviewerForm', false);
    }
  }
});
