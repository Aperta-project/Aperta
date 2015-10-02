import Ember from 'ember';
import TaskController from 'tahi/pods/paper/task/controller';
import ValidationErrorsMixin from 'tahi/mixins/validation-errors';

export default TaskController.extend(ValidationErrorsMixin, {
  showNewReviewerForm: false,
  newRecommendation: null,

  // Doing this to prevent short period of time where `newRecommendation` is in the DOM
  // while save is happening. If it becomes invalid after save it is removed. This creates
  // a glitchy look to the list.
  validReviewerRecommendations: Ember.computed('model.reviewerRecommendations.@each.isNew', function() {
    return this.get('model.reviewerRecommendations').filterBy('isNew', false);
  }),

  actions: {

    addNewReviewer() {
      let recommendation = this.store.createRecord('reviewerRecommendation', {
        reviewerRecommendationsTask: this.get('model')
      });
      this.set('newRecommendation', recommendation);
      this.set('showNewReviewerForm', true);
    },

    cancelRecommendation() {
      this.set('showNewReviewerForm', false);
      this.set('newRecommendation', null);
    },

    saveRecommendation(recommendation) {
      recommendation.save().then(() => {
        this.set('showNewReviewerForm', false);
        this.set('newRecommendation', null);
      }).catch((response) => {
        this.displayValidationErrorsFromResponse(response);
      });
    }
  }
});
