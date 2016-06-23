import TaskComponent from 'tahi/pods/components/task-base/component';
import Ember from 'ember';

export default TaskComponent.extend({
  showNewReviewerForm: false,

  // Doing this to prevent short period of time
  // where `newRecommendation` is in the DOM while save is happening.
  // If it becomes invalid after save it is removed.
  // This creates a glitchy look to the list.
  validReviewerRecommendations: Ember.computed(
    'task.reviewerRecommendations.@each.isNew',
    function() {
      return this.get('task.reviewerRecommendations').filterBy('isNew', false);
    }
  ),

  newRecommendationQuestions: Ember.on('init', function() {
    const queryParams = { type: 'ReviewerRecommendation' };
    this.get('store').findQuery('nested-question', queryParams).then( (questions) => {
      this.set('nestedQuestionsForNewRecommendation', questions);
    });
  }),

  clearNewRecommendationAnswers() {
    this.get('nestedQuestionsForNewRecommendation').forEach( (question) => {
      question.clearAnswerForOwner(this.get('newRecommendation'));
    });
  },

  actions: {
    addNewReviewer() {
      // Note that when referring to ember data models when interacting with the store
      // (pushPayload, createRecord, findRecord, etc) we should always be using the
      // dasherized form of the name going forward
      const recommendation = this.get('store').createRecord('reviewer-recommendation', {
        reviewerRecommendationsTask: this.get('task'),
        nestedQuestions: this.get('nestedQuestionsForNewRecommendation')
      });
      this.set('newRecommendation', recommendation);
      this.set('showNewReviewerForm', true);
    },

    cancelNewRecommendation() {
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
            answer.set('owner', savedRecommendation);
            answer.save();
          }
        });
        this.set('showNewReviewerForm', false);
        this.set('newRecommendation', null);
      }).catch((response) => {
        this.displayValidationErrorsFromResponse(response);
      });
    },

    cancelEdit() {
      this.clearNewRecommendationAnswers();
      this.set('showNewReviewerForm', false);
    }
  }
});
