import Ember from 'ember';
import TaskController from 'tahi/pods/task/controller';

export default TaskController.extend({
  showNewReviewerForm: false,
  newRecommendation: {},
  reset: function() {
    this.set('showNewReviewerForm', {});
  },
  actions: {
    toggleReviewerForm: function() {
      this.toggleProperty('showNewReviewerForm');
    },
    saveNewRecommendation: function() {
      this.set('newRecommendation.reviewerRecommendationsTask', this.get('model'));
      let newRec = this.get('newRecommendation');
      this.store.createRecord('reviewerRecommendation', newRec)
      .save().then(function() {
        console.log('success?', arguments);
      }).catch(function() {
        console.log('fail?', arguments);
      });
    },
    cancelEdit: function() {
      this.toggleProperty('showNewReviewerForm');
    }
  }
});
