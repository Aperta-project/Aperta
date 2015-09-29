import Ember from 'ember';
import TaskController from 'tahi/pods/paper/task/controller';
import ValidationErrorsMixin from 'tahi/mixins/validation-errors';

export default TaskController.extend(ValidationErrorsMixin, {
  showNewReviewerForm: false,
  newRecommendation: {},

  // Doing this to prevent short period of time where `newRecommendation` is in the DOM
  // while save is happening. If it becomes invalid after save it is removed. This creates
  // a glitchy look to the list.
  validReviewerRecommendations: Ember.computed('model.reviewerRecommendations.@each.isNew', function() {
    return this.get('model.reviewerRecommendations').filterBy('isNew', false);
  }),

  resetForm: function() {
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
      let newRecommendation = this.store.createRecord('reviewerRecommendation', this.get('newRecommendation'));

      newRecommendation
        .set('reviewerRecommendationsTask', this.get('model'))
        .save().then(() => {
          this.resetForm();
        }).catch((response) => {
          newRecommendation.deleteRecord();
          this.displayValidationErrorsFromResponse(response);
        });
    },

    institutionSelected: function(institution) {
      this.set('newRecommendation.affiliation', institution.name);
      this.set('newRecommendation.ringgoldId', institution['institution-id']);
    },

    cancelEdit: function() {
      this.resetForm();
    },

    removeReviewer(reviewer) {
      reviewer.destroyRecord();
    }
  }
});
