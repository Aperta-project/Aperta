import Ember from 'ember';
import TaskController from 'tahi/pods/task/controller';
import ValidationErrorsMixin from 'tahi/mixins/validation-errors';

export default TaskController.extend(ValidationErrorsMixin, {
  showNewReviewerForm: false,
  newRecommendation: {},
  reset: function() {
    this.setProperties({
      showNewReviewerForm: false,
      newRecommendation: {}
    });

    this.clearAllValidationErrors();
  },
  actions: {
    toggleReviewerForm: function() {
      this.toggleProperty('showNewReviewerForm');
    },
    saveNewRecommendation: function() {
      this.set('newRecommendation.reviewerRecommendationsTask', this.get('model'));

      this.store.createRecord('reviewerRecommendation', this.get('newRecommendation'))
      .save().then((savedRecommendation) => {
        this.get('model.reviewerRecommendations').addObject(savedRecommendation);
        this.reset();
      }).catch((response) => {
        this.displayValidationErrorsFromResponse(response);
      });
    },
    cancelEdit: function() {
      this.reset();
    }
  }
});
