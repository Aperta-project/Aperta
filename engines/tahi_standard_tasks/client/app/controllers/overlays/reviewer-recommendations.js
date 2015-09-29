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

  actions: {

    toggleReviewerForm() {
      this.toggleProperty('showNewReviewerForm');
    },

    saveNewRecommendation(recommendation) {
      let newRecommendation = this.store.createRecord('reviewerRecommendation', recommendation);

      newRecommendation
        .set('reviewerRecommendationsTask', this.get('model'))
        .save().then(() => {
          console.log("todo OK");
        }).catch((response) => {
          newRecommendation.deleteRecord();
          this.displayValidationErrorsFromResponse(response);
        });
    },

    removeReviewer(reviewer) {
      reviewer.destroyRecord();
    }
  }
});
