import Ember from 'ember';

export default Ember.Component.extend({
  featureFlag: Ember.inject.service('feature-flag'),
  moment: Ember.inject.service(),
  reviewDueAtFlag: Ember.computed('featureFlag', function() {
    return this.get('featureFlag').value('REVIEW_DUE_AT').then((response) => {
      return response;
    });
  }),
  dispatchDateFormat: 'MMMM D, h:mma z'
});
