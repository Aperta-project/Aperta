import Ember from 'ember';
import TaskController from 'tahi/pods/task/controller';

export default TaskController.extend({
  showNewReviewerForm: false,
  newRecommendation: {},
  reset: function() {
    this.setProperties({
      showNewReviewerForm: false,
      newRecommendation: {}
    });
  },
  actions: {
    toggleReviewerForm: function() {
      this.toggleProperty('showNewReviewerForm');
    },
    saveNewRecommendation: function() {
      let self = this;
      this.set('newRecommendation.reviewerRecommendationsTask', this.get('model'));
      this.store.createRecord('reviewerRecommendation', this.get('newRecommendation'))
      .save().then(function(savedRecommendation) {
        self.get('model.reviewerRecommendations').addObject(savedRecommendation);
      }).finally(function() { self.reset(); });
    },
    cancelEdit: function() {
      this.reset();
    }
  }
});
