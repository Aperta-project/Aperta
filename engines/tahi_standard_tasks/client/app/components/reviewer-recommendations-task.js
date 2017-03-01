import TaskComponent from 'tahi/pods/components/task-base/component';
import MultiExpandableList from 'tahi/mixins/multi-expandable-list';
import ObjectProxyWithErrors from 'tahi/models/object-proxy-with-validation-errors';
import Ember from 'ember';

export default TaskComponent.extend(MultiExpandableList, {
  validateData() {
    this.validateAll();
    const objs = this.get('reviewerRecommendationsWithErrors');
    objs.invoke('validateAll');

    const taskErrors    = this.validationErrorsPresent();
    const collectionErrors = ObjectProxyWithErrors.errorsPresentInCollection(objs);

    if(taskErrors || collectionErrors) {
      this.set('validationErrors.completed', 'Please fix all errors');
    }
  },

  reviewerRecommendationsWithErrors: Ember.computed.map('task.reviewerRecommendations',
    function(recommendation) {
      return ObjectProxyWithErrors.create({
        object: recommendation,
        skipValidations: () => { return this.get('skipValidations'); },
        validations: recommendation.validations
      });
    }
  ),

  actions: {
    addNewReviewer() {
      // Note that when referring to ember data models when interacting with the store
      // (pushPayload, createRecord, findRecord, etc) we should always be using the
      // dasherized form of the name going forward
      let store = this.get('store');
      let recommendation = store.createRecord('reviewer-recommendation', {
        reviewerRecommendationsTask: this.get('task'),
        card: store.peekCard('TahiStandardTasks::ReviewerRecommendation')
      });
      recommendation.save().then((rec) => { this.setExpanded(rec); });
    },

    saveRecommendation(recommendation) {
      recommendation.save().catch((response) => {
        this.displayValidationErrorsFromResponse(response);
      });
    },

    cancelEdit() {
      this.clearNewRecommendationAnswers();
      this.set('showNewReviewerForm', false);
    }
  }
});
